package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import models.Seat;
import models.SeatTypeSurcharge;
import models.Showtime;
import repositories.SeatTypeSurcharges;
import repositories.Showtimes;
import services.TicketPriceService;
import java.math.BigDecimal;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = { "/customer/booking-tickets" })
public class BookingTickets extends HttpServlet {

    private static final double CHILD_DISCOUNT_RATE = 0.7; // Trẻ em giảm 30%

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

            String[] seatIdsParam = request.getParameterValues("seatIds");
            List<Integer> selectedSeatIds = new ArrayList<>();
            List<Map<String, Object>> selectedSeatsInfo = new ArrayList<>();
            if (seatIdsParam != null && seatIdsParam.length > 0) {
                for (String sid : seatIdsParam) {
                    try {
                        int seatId = Integer.parseInt(sid.trim());
                        Map<String, Object> sws = seatIdToInfo.get(seatId);
                        if (sws != null && "AVAILABLE".equals(sws.get("bookingStatus"))) {
                            Seat seat = (Seat) sws.get("seat");
                            selectedSeatIds.add(seatId);
                            Map<String, Object> info = new java.util.HashMap<>();
                            info.put("seatId", seat.getSeatId());
                            info.put("seatCode", seat.getSeatCode());
                            selectedSeatsInfo.add(info);
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }

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

            // Lấy tỉ lệ phụ phí từng loại ghế cho chi nhánh
            Integer branchId = (Integer) showtimeDetails.get("branchId");
            if (branchId != null) {
                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
                var surchargeList = surchargesRepo.getSurchargesByBranch(branchId);
                request.setAttribute("surchargeList", surchargeList);
                surchargesRepo.closeConnection();
            }

            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    request.setAttribute("formattedStartTime",
                            showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
                if (showtime.getShowDate() != null) {
                    request.setAttribute("formattedShowDate",
                            showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

                // Dynamically fetch basePrice using TicketPriceService
                TicketPriceService ticketPriceService = new TicketPriceService();
                BigDecimal basePriceBD = BigDecimal.ZERO;
                if (branchId != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
                    basePriceBD = ticketPriceService.getBasePriceForShowtime(branchId, showtime.getShowDate(),
                            showtime.getStartTime());
                }
                double basePrice = basePriceBD != null ? basePriceBD.doubleValue() : 0.0;
                request.setAttribute("basePrice", basePrice);
            } else {
                request.setAttribute("basePrice", 0.0);
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
            double basePrice = showtime != null && showtime.getBasePrice() != null
                    ? showtime.getBasePrice().doubleValue() : 0.0;

            Integer branchId = (Integer) showtimeDetails.get("branchId");
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
                double price = basePrice * (1 + rate / 100);
                if ("CHILD".equals(ticketType)) {
                    price *= CHILD_DISCOUNT_RATE;
                }

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

            Map<String, Object> bookingData = new java.util.HashMap<>();
            bookingData.put("showtimeId", showtimeId);
            bookingData.put("totalAmount", totalAmount);
            bookingData.put("seats", selectedSeats);
            session.setAttribute("customerBookingData", bookingData);

            response.sendRedirect(request.getContextPath() + "/customer/booking-payment?showtimeId=" + showtimeId);

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
