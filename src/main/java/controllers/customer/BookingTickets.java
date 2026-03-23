package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import models.Concession;
import models.Seat;
import models.SeatTypeSurcharge;
import models.Showtime;
import repositories.Concessions;
import repositories.SeatTypeSurcharges;
import repositories.Showtimes;
import repositories.TicketPrices;
import services.TicketPriceService;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = { "/customer/booking-tickets" })
public class BookingTickets extends HttpServlet {

    private final TicketPriceService ticketPriceRules = new TicketPriceService();

    // force update
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // dam bao user da dang nhap truoc khi dat ve
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Hiển thị lỗi từ session (khi redirect từ doPost)
        if (session.getAttribute("bookingError") != null) {
            request.setAttribute("error", session.getAttribute("bookingError"));
            session.removeAttribute("bookingError");
        }

        // Lấy showtimeId từ query string
        String showtimeIdParam = request.getParameter("showtimeId");
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
                return;
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            int availableSeats = showtimesRepo.countAvailableSeats(showtimeId);

            // Nhóm ghế theo hàng để hiển thị sơ đồ (server-side)
            // Map <String, ...> : key = hang so, value = danh sach ghe trong hang do (gom theo hang so)
            // List <Map ... > : (trong 1 hang co nhieu ghe), mot list cac o ghe
            // Map <String, object> :
            Map<String, List<Map<String, Object>>> seatsByRow = new LinkedHashMap<>();
            for (Map<String, Object> sws : seatsWithStatus) {
                Seat seat = (Seat) sws.get("seat"); // lay tu mapResultSetToSeat(rs) trong Showtimes.java
                String row = seat != null && seat.getRowNumber() != null ? seat.getRowNumber() : ""; // lay hang (A, B, C, ...)
                seatsByRow.computeIfAbsent(row, k -> new ArrayList<>()).add(sws); 
            }

            // Map seatId -> seatInfo để tra cứu ghế đã chọn từ GET
            Map<Integer, Map<String, Object>> seatIdToInfo = new java.util.HashMap<>();
            for (Map<String, Object> sws : seatsWithStatus) {
                Seat s = (Seat) sws.get("seat");
                if (s != null) {
                    seatIdToInfo.put(s.getSeatId(), sws);
                }
            }

            // Phụ phí theo loại ghế (một lần gọi repo, dùng cho tính giá + JSP)
            Integer branchId = (Integer) showtimeDetails.get("branchId");
            Map<String, Double> surchargeRates = new java.util.HashMap<>();
            List<SeatTypeSurcharge> surchargeList = new ArrayList<>();
            if (branchId != null) {
                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
                surchargeList = surchargesRepo.getSurchargesByBranch(branchId);
                for (SeatTypeSurcharge s : surchargeList) {
                    if (s.getSurchargeRate() != null) {
                        surchargeRates.put(s.getSeatType(), s.getSurchargeRate());
                    }
                }
                StringBuilder jsonBuilder = new StringBuilder();
                jsonBuilder.append("{");
                for (int i = 0; i < surchargeList.size(); i++) {
                    SeatTypeSurcharge s = surchargeList.get(i);
                    if (s.getSeatType() == null) continue;
                    double rate = s.getSurchargeRate() != null ? s.getSurchargeRate() : 0.0;
                    if (jsonBuilder.length() > 1) jsonBuilder.append(",");
                    jsonBuilder.append("\"").append(s.getSeatType()).append("\":").append(rate);
                }
                jsonBuilder.append("}");
                request.setAttribute("surchargeRatesJson", jsonBuilder.toString());
                surchargesRepo.closeConnection();
            } else {
                // neu branchId khong co phu phi hoac null, thi set json rong
                request.setAttribute("surchargeRatesJson", "{}");
            }
            // hien thi bang phu phi theo loai ghe
            request.setAttribute("surchargeList", surchargeList);

            // Gia ve theo cau hinh manager (ticket_prices), khong dung gia suat chieu
            Showtime st = (Showtime) showtimeDetails.get("showtime");
            double adultPriceValue = 0.0;
            double childPriceValue = 0.0;
            if (branchId != null && st != null && st.getShowDate() != null && st.getStartTime() != null) {
                TicketPrices ticketPricesDao = new TicketPrices();
                String timeSlot = ticketPriceRules.getTimeSlot(st.getStartTime());
                String dayType = ticketPriceRules.resolveDayTypeForTicketPrice(
                        branchId, st.getShowDate(), st.getStartTime(), ticketPricesDao);
                BigDecimal adultBd = ticketPricesDao.getTicketPrice(branchId, "ADULT", dayType, timeSlot, st.getShowDate());
                BigDecimal childBd = ticketPricesDao.getTicketPrice(branchId, "CHILD", dayType, timeSlot, st.getShowDate());
                adultPriceValue = adultBd != null ? adultBd.doubleValue() : 0.0;
                childPriceValue = childBd != null ? childBd.doubleValue() : 0.0;
                ticketPricesDao.closeConnection();
            }
            request.setAttribute("adultPrice", adultPriceValue);
            request.setAttribute("childPrice", childPriceValue);
            request.setAttribute("basePrice", adultPriceValue); // de gia ve mac dinh la gia ve nguoi lon, co the thay doi neu muon

            // Dong nay chua tat ca seatId, de xu ly khi nguoi dung chon ghe
            String[] seatIdsParam = request.getParameterValues("seatIds");

            // Bat dau xu ly khi nguoi dung chon ghe
            List<Integer> selectedSeatIds = new ArrayList<>();

            // Bat dau luu thong tin ghe da chon
            List<Map<String, Object>> selectedSeatsInfo = new ArrayList<>();

            // bat dau tinh gia ve khi nguoi dung chon ghe
            BigDecimal totalAmount = BigDecimal.ZERO;

            // chi xu ly khi nguoi dung da chon >= 1 ghe (it nhat 1 seatId duoc gui len tu JSP)
            if (seatIdsParam != null && seatIdsParam.length > 0) {

                // duyet tung chuoi id ghe trong mang
                for (String sid : seatIdsParam) {
                    try {

                        // dich chuoi seatId sang he so nguyen (int)
                        int seatId = Integer.parseInt(sid.trim());

                        // lay thong tin ghe tu map seatIdToInfo
                        Map<String, Object> sws = seatIdToInfo.get(seatId);

                        // neu ghe co trong map seatIdToInfo va trang thai ghe = AVAILABLE (chua co nguoi dat)
                        if (sws != null && "AVAILABLE".equals(sws.get("bookingStatus"))) {
                            Seat seat = (Seat) sws.get("seat"); // lay object Seat tu mapResultSetToSeat(rs) trong Showtimes.java
                            selectedSeatIds.add(seatId); // luu id ghe da chon vao list

                            String ticketType = request.getParameter("ticketType_" + seatId); // lay loai ve (ADULT, CHILD) tu JSP

                            if (ticketType == null || ticketType.isEmpty()) ticketType = "ADULT"; // neu khong co thi mac dinh la ADULT

                            // neu loai ve khong phai ADULT hoac CHILD thi mac dinh la ADULT
                            if (!"ADULT".equals(ticketType) && !"CHILD".equals(ticketType)) ticketType = "ADULT"; 

                            // lay loai ghe (NORMAL, VIP, COUPLE) tu object Seat, neu khong co thi mac dinh la NORMAL
                            String seatType = seat.getSeatType() != null ? seat.getSeatType() : "NORMAL";

                            // lay phu phi theo loai ghe tu map surchargeRates, neu khong co thi mac dinh la 0.0
                            double rate = surchargeRates.getOrDefault(seatType, 0.0);

                            // neu loai ve la CHILD thi tinh gia ve theo gia ve tre, khong thi tinh theo gia ve nguoi lon
                            double baseByType = "CHILD".equals(ticketType) ? childPriceValue : adultPriceValue; 
                            double price = baseByType * (1 + rate / 100); // tinh gia ve sau khi tinh phu phi
                            BigDecimal seatPrice = BigDecimal.valueOf(price); // chuyen sang BigDecimal
                            totalAmount = totalAmount.add(seatPrice); // cong them gia ve cua ghe da chon vao tong gia ve

                            Map<String, Object> info = new java.util.HashMap<>(); // tao map de luu thong tin ghe da chon
                            info.put("seatId", seat.getSeatId()); // luu id ghe da chon vao map
                            info.put("seatCode", seat.getSeatCode()); // luu ma ghe da chon vao map
                            info.put("seatType", seatType); // luu loai ghe da chon vao map
                            info.put("ticketType", ticketType); // luu loai ve da chon vao map
                            info.put("price", seatPrice); // luu gia ve cua ghe da chon vao map
                            selectedSeatsInfo.add(info); // luu map thong tin ghe da chon vao list
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            // do an / thuc uong, luon set de JSP hien thi quay hoac thong bao "chua duoc ban"
            Concessions concessionsRepo = new Concessions(); // tao object Concessions
            List<Concession> concessionsList = concessionsRepo.getConcessionsForSale(); // lay danh sach do an / thuc uong tu repo
            concessionsRepo.closeConnection(); // dong connection
            if (concessionsList == null) { // neu danh sach do an / thuc uong khong co, thi tao danh sach rong
                concessionsList = new ArrayList<>();
            }
            request.setAttribute("concessionsList", concessionsList); // set danh sach do an / thuc uong vao request

            Map<Integer, Integer> concessionQty = new java.util.HashMap<>(); // tao map de luu so luong do an / thuc uong da chon
            List<Map<String, Object>> selectedConcessions = new ArrayList<>(); // tao list de luu thong tin do an / thuc uong da chon
            BigDecimal concessionTotal = BigDecimal.ZERO; // tong gia do an / thuc uong da chon
            for (Concession c : concessionsList) {
                String qtyParam = request.getParameter("concession_" + c.getConcessionId()); // lay so luong do an / thuc uong da chon tu JSP
                int qty = 0;
                if (qtyParam != null && !qtyParam.isEmpty()) { // neu so luong do an / thuc uong da chon khong rong
                    try {
                        qty = Integer.parseInt(qtyParam.trim());
                        if (qty < 0) qty = 0;
                    } catch (NumberFormatException ignored) { }
                }
                concessionQty.put(c.getConcessionId(), qty); // luu so luong do an / thuc uong da chon vao map
                if (qty > 0 && c.getPriceBase() != null) {
                    BigDecimal lineTotal = BigDecimal.valueOf(c.getPriceBase() * qty); // tinh gia do an / thuc uong cua 1 mon
                    concessionTotal = concessionTotal.add(lineTotal); // cong them gia do an / thuc uong cua 1 mon vao tong gia do an / thuc uong da chon
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("concessionId", c.getConcessionId());
                    item.put("concessionName", c.getConcessionName());
                    item.put("concessionType", c.getConcessionType());
                    item.put("quantity", qty);
                    item.put("priceBase", c.getPriceBase());
                    item.put("lineTotal", lineTotal);
                    selectedConcessions.add(item);
                }
            }
            request.setAttribute("concessionQty", concessionQty);
            request.setAttribute("selectedConcessions", selectedConcessions);
            request.setAttribute("concessionTotal", concessionTotal);
            request.setAttribute("ticketTotal", totalAmount);
            request.setAttribute("totalAmount", totalAmount.add(concessionTotal));

            request.setAttribute("seatsByRow", seatsByRow);
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("seatsWithStatus", seatsWithStatus);
            request.setAttribute("availableSeats", availableSeats);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("selectedSeatIds", selectedSeatIds);
            request.setAttribute("selectedSeatsInfo", selectedSeatsInfo);

            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            request.setAttribute("showtime", showtime);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("moviePosterUrl", showtimeDetails.get("moviePosterUrl"));
            request.setAttribute("roomName", showtimeDetails.get("roomName"));
            request.setAttribute("totalSeats", showtimeDetails.get("totalSeats"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            // hien thi thoi gian va ngay chieu
            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    request.setAttribute("formattedStartTime",
                            showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm"))); // format thoi gian chieu thanh HH:mm
                }
                if (showtime.getShowDate() != null) {
                    request.setAttribute("formattedShowDate",
                            showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))); // format ngay chieu thanh dd/MM/yyyy
                }

            }

            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                    .forward(request, response); // forward request to JSP

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải sơ đồ ghế.");
            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                    .forward(request, response);
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // dam bao user da dang nhap truoc khi dat ve
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // lay danh sach id ghe da chon tu JSP
        String[] seatIdsParam = request.getParameterValues("seatIds");

        // lay id suat chieu tu JSP (showtimeId)
        String showtimeIdParam = request.getParameter("showtimeId");

        if (showtimeIdParam == null || showtimeIdParam.isEmpty() || seatIdsParam == null || seatIdsParam.length == 0) { // neu showtimeId khong co hoac rong hoac seatIds khong co hoac rong
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        // chuyen showtimeId sang he so nguyen (int)
        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam); // chuyen showtimeId sang he so nguyen (int)
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        Showtimes showtimesRepo = null; // tao object Showtimes
        try {
            showtimesRepo = new Showtimes(); // tao object Showtimes
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId); // lay thong tin suat chieu tu repo
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
                return;
            }

            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            Integer branchId = (Integer) showtimeDetails.get("branchId");

            // gia ve tu cau hinh manager (ticket_prices)
            double adultPriceVal = 0.0;
            double childPriceVal = 0.0;
            if (branchId != null && showtime != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
                TicketPrices ticketPricesRepo = new TicketPrices(); // tao object TicketPrices
                String timeSlot = ticketPriceRules.getTimeSlot(showtime.getStartTime()); // lay khung gio tu object Showtime
                String dayType = ticketPriceRules.resolveDayTypeForTicketPrice(
                        branchId, showtime.getShowDate(), showtime.getStartTime(), ticketPricesRepo); // lay loai ngay tu object Showtime
                BigDecimal adultBd = ticketPricesRepo.getTicketPrice(branchId, "ADULT", dayType, timeSlot, showtime.getShowDate()); // lay gia ve nguoi lon tu repo
                BigDecimal childBd = ticketPricesRepo.getTicketPrice(branchId, "CHILD", dayType, timeSlot, showtime.getShowDate()); // lay gia ve tre tu repo
                adultPriceVal = adultBd != null ? adultBd.doubleValue() : 0.0;
                childPriceVal = childBd != null ? childBd.doubleValue() : 0.0;
                ticketPricesRepo.closeConnection(); // dong connection
            }

            Map<String, Double> surchargeRates = new java.util.HashMap<>(); // tao map de luu phu phi theo loai ghe tu repo
            if (branchId != null) {
                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges(); // tao object SeatTypeSurcharges
                for (SeatTypeSurcharge s : surchargesRepo.getSurchargesByBranch(branchId)) { // lay danh sach phu phi theo loai ghe tu repo
                    if (s.getSurchargeRate() != null) {
                        surchargeRates.put(s.getSeatType(), s.getSurchargeRate()); // luu phu phi theo loai ghe vao map
                    }
                }
                surchargesRepo.closeConnection(); // dong connection
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId); // lay danh sach ghe co trang thai booking tu repo (AVAILABLE, BROKEN, MAINTENANCE)
            Map<Integer, Map<String, Object>> seatMap = new java.util.HashMap<>(); // tao map de luu ghe va trang thai booking
            for (Map<String, Object> sws : seatsWithStatus) {
                Seat seat = (Seat) sws.get("seat");
                if (seat != null) {
                    seatMap.put(seat.getSeatId(), sws); // luu ghe vao map
                }
            }

            List<Map<String, Object>> selectedSeats = new ArrayList<>(); // tao list de luu thong tin ghe da chon
            BigDecimal totalAmount = BigDecimal.ZERO; // tong gia ve da chon

            for (String sid : seatIdsParam) {
                int seatId;
                try {
                    seatId = Integer.parseInt(sid.trim()); // chuyen chuoi seatId sang he so nguyen (int)
                } catch (NumberFormatException e) {
                    continue; // neu khong the chuyen thanh so nguyen thi bo qua
                }

                Map<String, Object> sws = seatMap.get(seatId); // lay thong tin ghe tu map seatMap
                if (sws == null) continue; // neu ghe khong co trong map seatMap thi bo qua
                String bookingStatus = sws.get("bookingStatus") != null ? sws.get("bookingStatus").toString() : "";
                if (!"AVAILABLE".equals(bookingStatus)) { // neu trang thai ghe khong phai AVAILABLE thi thong bao loi
                    String bookingError;
                    if ("BROKEN".equalsIgnoreCase(bookingStatus)) {
                        bookingError = "Ghế đang bị hỏng (BROKEN). Vui lòng chọn ghế khác."; // neu trang thai ghe la BROKEN thi thong bao loi
                    } else if ("MAINTENANCE".equalsIgnoreCase(bookingStatus)) {
                        bookingError = "Ghế đang bảo trì (MAINTENANCE). Vui lòng chọn ghế khác."; // neu trang thai ghe la MAINTENANCE thi thong bao loi
                    } else {
                        bookingError = "Ghế đã được đặt trước. Vui lòng chọn ghế khác."; // neu trang thai ghe khong phai AVAILABLE, BROKEN hoac MAINTENANCE thi thong bao loi
                    }

                    request.getSession().setAttribute("bookingError", bookingError); // luu thong bao loi vao session
                    response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId); // redirect ve trang booking-tickets
                    return;
                }
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) { // neu ghe khong co trong repo thi thong bao loi
                    request.getSession().setAttribute("bookingError", "Ghế đã được đặt trước. Vui lòng chọn ghế khác."); // luu thong bao loi vao session
                    response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId); // redirect ve trang booking-tickets
                    return;
                }

                String ticketType = request.getParameter("ticketType_" + seatId); // lay loai ve (ADULT, CHILD) tu JSP
                if (ticketType == null || ticketType.isEmpty()) {
                    ticketType = "ADULT"; // neu khong co thi mac dinh la ADULT
                }
                if (!"ADULT".equals(ticketType) && !"CHILD".equals(ticketType)) { // neu loai ve khong phai ADULT hoac CHILD thi mac dinh la ADULT
                    ticketType = "ADULT";
                }

                Seat seat = (Seat) sws.get("seat");
                String seatType = seat.getSeatType() != null ? seat.getSeatType() : "NORMAL";
                double rate = surchargeRates.getOrDefault(seatType, 0.0);
                double baseByType = "CHILD".equals(ticketType) ? childPriceVal : adultPriceVal;
                double price = baseByType * (1 + rate / 100);

                Map<String, Object> seatData = new java.util.HashMap<>();
                seatData.put("seatId", seatId);
                seatData.put("seatCode", seat.getSeatCode());
                seatData.put("seatType", seatType);
                seatData.put("ticketType", ticketType);
                seatData.put("price", BigDecimal.valueOf(price));
                selectedSeats.add(seatData);
                totalAmount = totalAmount.add(BigDecimal.valueOf(price));
            }

            if (selectedSeats.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            // Đồ ăn / thức uống
            Concessions concessionsRepoPost = new Concessions();
            List<Concession> concessionsListPost = concessionsRepoPost.getConcessionsForSale();
            List<Map<String, Object>> bookingConcessions = new ArrayList<>();
            BigDecimal concessionTotalPost = BigDecimal.ZERO;
            for (Concession c : concessionsListPost) {
                String qtyParam = request.getParameter("concession_" + c.getConcessionId());
                int qty = 0;
                if (qtyParam != null && !qtyParam.isEmpty()) {
                    try {
                        qty = Integer.parseInt(qtyParam.trim());
                        if (qty < 0) qty = 0;
                    } catch (NumberFormatException ignored) { }
                }
                if (qty > 0 && c.getPriceBase() != null) {
                    BigDecimal lineTotal = BigDecimal.valueOf(c.getPriceBase() * qty);
                    concessionTotalPost = concessionTotalPost.add(lineTotal);
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("concessionId", c.getConcessionId());
                    item.put("concessionName", c.getConcessionName());
                    item.put("concessionType", c.getConcessionType());
                    item.put("quantity", qty);
                    item.put("priceBase", c.getPriceBase());
                    item.put("lineTotal", lineTotal);
                    bookingConcessions.add(item);
                }
            }
            concessionsRepoPost.closeConnection();
            BigDecimal grandTotal = totalAmount.add(concessionTotalPost);

            String voucherCodeParam = request.getParameter("voucherCode");
            String voucherCodeToSummary = (voucherCodeParam != null && !voucherCodeParam.trim().isEmpty())
                    ? voucherCodeParam.trim() : null;

            Map<String, Object> bookingData = new java.util.HashMap<>();
            bookingData.put("showtimeId", showtimeId);
            bookingData.put("totalAmount", grandTotal);
            bookingData.put("ticketTotal", totalAmount);
            bookingData.put("concessionTotal", concessionTotalPost);
            bookingData.put("seats", selectedSeats);
            bookingData.put("concessions", bookingConcessions);
            if (voucherCodeToSummary != null) {
                bookingData.put("voucherCode", voucherCodeToSummary);
            }
            session.setAttribute("customerBookingData", bookingData);

            response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}
