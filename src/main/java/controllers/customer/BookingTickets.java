package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.DayOfWeek;
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

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = { "/customer/booking-tickets" })
public class BookingTickets extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đảm bảo user đã đăng nhập trước khi đặt vé
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
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            int availableSeats = showtimesRepo.countAvailableSeats(showtimeId);

            // Nhóm ghế theo hàng để hiển thị sơ đồ (server-side)
            Map<String, List<Map<String, Object>>> seatsByRow = new LinkedHashMap<>();
            for (Map<String, Object> sws : seatsWithStatus) {
                Seat seat = (Seat) sws.get("seat");
                String row = seat != null && seat.getRowNumber() != null ? seat.getRowNumber() : "";
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
                request.setAttribute("surchargeRatesJson", "{}");
            }
            request.setAttribute("surchargeList", surchargeList);

            // Giá vé theo cấu hình manager (ticket_prices), không dùng giá suất chiếu
            Showtime st = (Showtime) showtimeDetails.get("showtime");
            double adultPriceValue = 0.0;
            double childPriceValue = 0.0;
            if (branchId != null && st != null && st.getShowDate() != null && st.getStartTime() != null) {
                DayOfWeek dayOfWeek = st.getShowDate().getDayOfWeek();
                String dayType = (dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY) ? "WEEKEND" : "WEEKDAY";
                int hour = st.getStartTime().getHour();
                String timeSlot = (hour >= 6 && hour < 12) ? "MORNING" : (hour >= 12 && hour < 17) ? "AFTERNOON" : (hour >= 17 && hour < 22) ? "EVENING" : "NIGHT";
                TicketPrices ticketPricesDao = new TicketPrices();
                BigDecimal adultBd = ticketPricesDao.getTicketPrice(branchId, "ADULT", dayType, timeSlot, st.getShowDate());
                BigDecimal childBd = ticketPricesDao.getTicketPrice(branchId, "CHILD", dayType, timeSlot, st.getShowDate());
                adultPriceValue = adultBd != null ? adultBd.doubleValue() : 0.0;
                childPriceValue = childBd != null ? childBd.doubleValue() : 0.0;
                ticketPricesDao.closeConnection();
            }
            request.setAttribute("adultPrice", adultPriceValue);
            request.setAttribute("childPrice", childPriceValue);
            request.setAttribute("basePrice", adultPriceValue);

            String[] seatIdsParam = request.getParameterValues("seatIds");
            List<Integer> selectedSeatIds = new ArrayList<>();
            List<Map<String, Object>> selectedSeatsInfo = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;
            if (seatIdsParam != null && seatIdsParam.length > 0) {
                for (String sid : seatIdsParam) {
                    try {
                        int seatId = Integer.parseInt(sid.trim());
                        Map<String, Object> sws = seatIdToInfo.get(seatId);
                        if (sws != null && "AVAILABLE".equals(sws.get("bookingStatus"))) {
                            Seat seat = (Seat) sws.get("seat");
                            selectedSeatIds.add(seatId);

                            String ticketType = request.getParameter("ticketType_" + seatId);
                            if (ticketType == null || ticketType.isEmpty()) ticketType = "ADULT";
                            if (!"ADULT".equals(ticketType) && !"CHILD".equals(ticketType)) ticketType = "ADULT";

                            String seatType = seat.getSeatType() != null ? seat.getSeatType() : "NORMAL";
                            double rate = surchargeRates.getOrDefault(seatType, 0.0);
                            double baseByType = "CHILD".equals(ticketType) ? childPriceValue : adultPriceValue;
                            double price = baseByType * (1 + rate / 100);
                            BigDecimal seatPrice = BigDecimal.valueOf(price);
                            totalAmount = totalAmount.add(seatPrice);

                            Map<String, Object> info = new java.util.HashMap<>();
                            info.put("seatId", seat.getSeatId());
                            info.put("seatCode", seat.getSeatCode());
                            info.put("seatType", seatType);
                            info.put("ticketType", ticketType);
                            info.put("price", seatPrice);
                            selectedSeatsInfo.add(info);
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            // Concessions (đồ ăn / thức uống) — luôn set để JSP hiển thị quầy hoặc thông báo "chưa được bán"
            Concessions concessionsRepo = new Concessions();
            List<Concession> concessionsList = concessionsRepo.getConcessionsForSale();
            concessionsRepo.closeConnection();
            if (concessionsList == null) {
                concessionsList = new ArrayList<>();
            }
            request.setAttribute("concessionsList", concessionsList);

            Map<Integer, Integer> concessionQty = new java.util.HashMap<>();
            List<Map<String, Object>> selectedConcessions = new ArrayList<>();
            BigDecimal concessionTotal = BigDecimal.ZERO;
            for (Concession c : concessionsList) {
                String qtyParam = request.getParameter("concession_" + c.getConcessionId());
                int qty = 0;
                if (qtyParam != null && !qtyParam.isEmpty()) {
                    try {
                        qty = Integer.parseInt(qtyParam.trim());
                        if (qty < 0) qty = 0;
                    } catch (NumberFormatException ignored) { }
                }
                concessionQty.put(c.getConcessionId(), qty);
                if (qty > 0 && c.getPriceBase() != null) {
                    BigDecimal lineTotal = BigDecimal.valueOf(c.getPriceBase() * qty);
                    concessionTotal = concessionTotal.add(lineTotal);
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


            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    request.setAttribute("formattedStartTime",
                            showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
                if (showtime.getShowDate() != null) {
                    request.setAttribute("formattedShowDate",
                            showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

            }

            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                    .forward(request, response);

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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String[] seatIdsParam = request.getParameterValues("seatIds");
        String showtimeIdParam = request.getParameter("showtimeId");

        if (showtimeIdParam == null || showtimeIdParam.isEmpty() || seatIdsParam == null || seatIdsParam.length == 0) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            Integer branchId = (Integer) showtimeDetails.get("branchId");

            // Giá vé theo cấu hình manager (ticket_prices)
            double adultPriceVal = 0.0;
            double childPriceVal = 0.0;
            if (branchId != null && showtime != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
                DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
                String dayType = (dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY) ? "WEEKEND" : "WEEKDAY";
                int hour = showtime.getStartTime().getHour();
                String timeSlot = (hour >= 6 && hour < 12) ? "MORNING" : (hour >= 12 && hour < 17) ? "AFTERNOON" : (hour >= 17 && hour < 22) ? "EVENING" : "NIGHT";
                TicketPrices ticketPricesRepo = new TicketPrices();
                BigDecimal adultBd = ticketPricesRepo.getTicketPrice(branchId, "ADULT", dayType, timeSlot, showtime.getShowDate());
                BigDecimal childBd = ticketPricesRepo.getTicketPrice(branchId, "CHILD", dayType, timeSlot, showtime.getShowDate());
                adultPriceVal = adultBd != null ? adultBd.doubleValue() : 0.0;
                childPriceVal = childBd != null ? childBd.doubleValue() : 0.0;
                ticketPricesRepo.closeConnection();
            }

            Map<String, Double> surchargeRates = new java.util.HashMap<>();
            if (branchId != null) {
                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
                for (SeatTypeSurcharge s : surchargesRepo.getSurchargesByBranch(branchId)) {
                    if (s.getSurchargeRate() != null) {
                        surchargeRates.put(s.getSeatType(), s.getSurchargeRate());
                    }
                }
                surchargesRepo.closeConnection();
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            Map<Integer, Map<String, Object>> seatMap = new java.util.HashMap<>();
            for (Map<String, Object> sws : seatsWithStatus) {
                Seat seat = (Seat) sws.get("seat");
                if (seat != null) {
                    seatMap.put(seat.getSeatId(), sws);
                }
            }

            List<Map<String, Object>> selectedSeats = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;

            for (String sid : seatIdsParam) {
                int seatId;
                try {
                    seatId = Integer.parseInt(sid.trim());
                } catch (NumberFormatException e) {
                    continue;
                }

                Map<String, Object> sws = seatMap.get(seatId);
                if (sws == null) continue;
                if (!"AVAILABLE".equals(sws.get("bookingStatus"))) {
                    request.getSession().setAttribute("bookingError", "Ghế đã được đặt trước. Vui lòng chọn ghế khác.");
                    response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                    return;
                }
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    request.getSession().setAttribute("bookingError", "Ghế đã được đặt trước. Vui lòng chọn ghế khác.");
                    response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                    return;
                }

                String ticketType = request.getParameter("ticketType_" + seatId);
                if (ticketType == null || ticketType.isEmpty()) {
                    ticketType = "ADULT";
                }
                if (!"ADULT".equals(ticketType) && !"CHILD".equals(ticketType)) {
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

            Map<String, Object> bookingData = new java.util.HashMap<>();
            bookingData.put("showtimeId", showtimeId);
            bookingData.put("totalAmount", grandTotal);
            bookingData.put("ticketTotal", totalAmount);
            bookingData.put("concessionTotal", concessionTotalPost);
            bookingData.put("seats", selectedSeats);
            bookingData.put("concessions", bookingConcessions);
            session.setAttribute("customerBookingData", bookingData);

            response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/movies");
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}
