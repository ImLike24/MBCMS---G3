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
import repositories.*;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = { "/booking-tickets" })
public class BookingTickets extends HttpServlet {

    private final services.BookingService bookingService = new services.BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String showtimeIdParam = request.getParameter("showtimeId");
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);

            Map<String, Object> pageData = bookingService.getBookingTicketsData(showtimeId);

            // Set toàn bộ data ra View
            request.setAttribute("showtime", pageData.get("showtime"));
            request.setAttribute("movie", pageData.get("movie"));
            request.setAttribute("room", pageData.get("room"));
            request.setAttribute("occupiedSeats", pageData.get("occupiedSeats"));
            request.setAttribute("seatsByRow", pageData.get("seatsByRow"));
            request.setAttribute("surchargeList", pageData.get("surchargeList"));
            request.setAttribute("concessionsList", pageData.get("concessions"));
            request.setAttribute("basePrice", pageData.get("basePrice"));

            // Gửi dữ liệu giá cơ bản cho Javascript
            request.setAttribute("adultPrice", pageData.get("adultPrice"));
            request.setAttribute("childPrice", pageData.get("childPrice"));
            request.setAttribute("surchargeRatesJson", pageData.get("surchargeRatesJson"));

            // XỬ LÝ DANH SÁCH GHẾ ĐƯỢC CHỌN & TÍNH TIỀN
            String[] selectedSeatIdsStr = request.getParameterValues("seatIds");
            java.util.List<Integer> selectedSeatIds = new java.util.ArrayList<>();
            java.util.List<java.util.Map<String, Object>> selectedSeatsInfo = new java.util.ArrayList<>();

            double adultPrice = (Double) pageData.get("adultPrice");
            double childPrice = (Double) pageData.get("childPrice");
            @SuppressWarnings("unchecked")
            java.util.List<models.SeatTypeSurcharge> surcharges = (java.util.List<models.SeatTypeSurcharge>) pageData.get("surchargeList");

            double ticketTotal = 0;

            if (selectedSeatIdsStr != null) {
                @SuppressWarnings("unchecked")
                java.util.Map<String, java.util.List<java.util.Map<String, Object>>> seatsByRow =
                        (java.util.Map<String, java.util.List<java.util.Map<String, Object>>>) pageData.get("seatsByRow");

                for (String idStr : selectedSeatIdsStr) {
                    try {
                        int sId = Integer.parseInt(idStr);
                        selectedSeatIds.add(sId);

                        // Tìm thông tin chiếc ghế đó trong sơ đồ
                        if (seatsByRow != null) {
                            for (java.util.List<java.util.Map<String, Object>> row : seatsByRow.values()) {
                                for (java.util.Map<String, Object> seatInfo : row) {
                                    models.Seat s = (models.Seat) seatInfo.get("seat");
                                    if (s != null && s.getSeatId() == sId) {
                                        java.util.Map<String, Object> selectedSeat = new java.util.HashMap<>();
                                        selectedSeat.put("seatId", s.getSeatId());
                                        selectedSeat.put("seatCode", s.getSeatCode());
                                        selectedSeat.put("seatType", s.getSeatType());

                                        // Hứng loại vé (ADULT/CHILD) nếu khách đổi ở UI
                                        String ticketType = request.getParameter("ticketType_" + sId);
                                        ticketType = (ticketType != null) ? ticketType : "ADULT";
                                        selectedSeat.put("ticketType", ticketType);

                                        // TÍNH TOÁN GIÁ 1 CHIẾC GHẾ = Giá Base * (1 + % Phụ phí)
                                        double baseP = "CHILD".equals(ticketType) ? childPrice : adultPrice;
                                        double rate = 0;
                                        if (surcharges != null) {
                                            for (models.SeatTypeSurcharge sur : surcharges) {
                                                if (sur.getSeatType().equals(s.getSeatType())) {
                                                    rate = sur.getSurchargeRate();
                                                    break;
                                                }
                                            }
                                        }
                                        double seatPrice = Math.round(baseP * (1 + rate / 100.0));
                                        selectedSeat.put("price", seatPrice);
                                        ticketTotal += seatPrice;

                                        selectedSeatsInfo.add(selectedSeat);
                                    }
                                }
                            }
                        }
                    } catch (Exception ignored) {}
                }
            }

            // Xử lý giữ lại trạng thái số lượng bắp nước và tính tổng tiền bắp nước
            double concessionTotal = 0;
            java.util.Map<Integer, Integer> concessionQty = new java.util.HashMap<>();
            @SuppressWarnings("unchecked")
            java.util.List<models.Concession> concessions = (java.util.List<models.Concession>) pageData.get("concessions");
            if (concessions != null) {
                for (models.Concession c : concessions) {
                    String qtyStr = request.getParameter("concession_" + c.getConcessionId());
                    if (qtyStr != null && !qtyStr.isEmpty()) {
                        try {
                            int q = Integer.parseInt(qtyStr);
                            if (q > 0) {
                                concessionQty.put(c.getConcessionId(), q);
                                concessionTotal += (q * c.getPriceBase());
                            }
                        } catch (Exception ignored) {}
                    }
                }
            }

            // Đẩy ra lại cho JSP vẽ cột bên phải và giữ trạng thái Checked
            request.setAttribute("selectedSeatIds", selectedSeatIds);
            request.setAttribute("selectedSeatsInfo", selectedSeatsInfo);

            // Truyền các biến tính tiền khởi tạo ra View
            request.setAttribute("concessionQty", concessionQty);
            request.setAttribute("ticketTotal", ticketTotal);
            request.setAttribute("concessionTotal", concessionTotal);
            request.setAttribute("totalAmount", ticketTotal + concessionTotal);

            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải sơ đồ ghế.");
            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp").forward(request, response);
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

        // Kiểm tra đầu vào
        if (showtimeIdParam == null || showtimeIdParam.isEmpty() || seatIdsParam == null || seatIdsParam.length == 0) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
            return;
        }

        if (seatIdsParam == null || seatIdsParam.length == 0) {
            session.setAttribute("bookingError", "Vui lòng chọn ít nhất 1 ghế để tiếp tục.");
            response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeIdParam);
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);

            Map<String, Object> pageData = bookingService.getBookingTicketsData(showtimeId);

            @SuppressWarnings("unchecked")
            java.util.List<Integer> occupiedSeats = (java.util.List<Integer>) pageData.get("occupiedSeats");
            double adultPrice = (Double) pageData.get("adultPrice");
            double childPrice = (Double) pageData.get("childPrice");

            @SuppressWarnings("unchecked")
            java.util.List<models.SeatTypeSurcharge> surcharges = (java.util.List<models.SeatTypeSurcharge>) pageData.get("surchargeList");

            java.util.List<Map<String, Object>> selectedSeats = new ArrayList<>();
            BigDecimal ticketTotal = BigDecimal.ZERO;

            @SuppressWarnings("unchecked")
            java.util.Map<String, java.util.List<java.util.Map<String, Object>>> seatsByRow =
                    (java.util.Map<String, java.util.List<java.util.Map<String, Object>>>) pageData.get("seatsByRow");

            // Xử lý từng chiếc ghế khách hàng chọn
            for (String sidStr : seatIdsParam) {
                int seatId;
                try {
                    seatId = Integer.parseInt(sidStr.trim());
                } catch (Exception e) { continue; }

                // Kiểm tra: Ghế có bị nẫng tay trên trong lúc đang thao tác không?
                if (occupiedSeats.contains(seatId)) {
                    session.setAttribute("bookingError", "Ghế bạn chọn vừa có người đặt. Vui lòng chọn ghế khác.");
                    response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeId);
                    return;
                }

                // Tìm thông tin ghế từ sơ đồ
                models.Seat s = null;
                if (seatsByRow != null) {
                    for (java.util.List<java.util.Map<String, Object>> row : seatsByRow.values()) {
                        for (java.util.Map<String, Object> seatInfo : row) {
                            models.Seat temp = (models.Seat) seatInfo.get("seat");
                            if (temp != null && temp.getSeatId() == seatId) {
                                s = temp; break;
                            }
                        }
                        if (s != null) break;
                    }
                }

                if (s == null) continue;

                // Tính tiền ghế = Giá gốc theo loại khách * (1 + % Phụ phí ghế)
                String ticketType = request.getParameter("ticketType_" + seatId);
                ticketType = (ticketType != null && ticketType.equals("CHILD")) ? "CHILD" : "ADULT";

                double baseP = "CHILD".equals(ticketType) ? childPrice : adultPrice;
                double rate = 0;
                if (surcharges != null) {
                    for (models.SeatTypeSurcharge sur : surcharges) {
                        if (sur.getSeatType().equals(s.getSeatType())) {
                            rate = sur.getSurchargeRate();
                            break;
                        }
                    }
                }
                double seatPrice = Math.round(baseP * (1 + rate / 100.0));

                Map<String, Object> seatData = new java.util.HashMap<>();
                seatData.put("seatId", seatId);
                seatData.put("seatCode", s.getSeatCode());
                seatData.put("seatType", s.getSeatType());
                seatData.put("ticketType", ticketType);
                seatData.put("price", BigDecimal.valueOf(seatPrice));

                selectedSeats.add(seatData);
                ticketTotal = ticketTotal.add(BigDecimal.valueOf(seatPrice));
            }

            if (selectedSeats.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            // Xử lý bắp nước
            @SuppressWarnings("unchecked")
            java.util.List<models.Concession> concessionsListPost = (java.util.List<models.Concession>) pageData.get("concessions");
            List<Map<String, Object>> bookingConcessions = new ArrayList<>();
            BigDecimal concessionTotalPost = BigDecimal.ZERO;

            if (concessionsListPost != null) {
                for (models.Concession c : concessionsListPost) {
                    String qtyParam = request.getParameter("concession_" + c.getConcessionId());
                    if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                        try {
                            int qty = Integer.parseInt(qtyParam.trim());
                            if (qty > 0) {
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
                        } catch (Exception ignored) {}
                    }
                }
            }

            // Tổng kết tiền và đóng gói vào Session
            BigDecimal grandTotal = ticketTotal.add(concessionTotalPost);
            String voucherCodeParam = request.getParameter("voucherCode");

            Map<String, Object> bookingData = new java.util.HashMap<>();
            bookingData.put("showtimeId", showtimeId);
            bookingData.put("totalAmount", grandTotal);
            bookingData.put("ticketTotal", ticketTotal);
            bookingData.put("concessionTotal", concessionTotalPost);
            bookingData.put("seats", selectedSeats);
            bookingData.put("concessions", bookingConcessions);
            if (voucherCodeParam != null && !voucherCodeParam.trim().isEmpty()) {
                bookingData.put("voucherCode", voucherCodeParam.trim());
            }

            session.setAttribute("customerBookingData", bookingData);

            // =====================================================================
            // THÀNH CÔNG: Chuyển hướng sang trang Summary
            // =====================================================================
            response.sendRedirect(request.getContextPath() + "/booking-summary?showtimeId=" + showtimeId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/movies");
        }
    }
}
