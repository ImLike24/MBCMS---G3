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

            request.setAttribute("showtimeId", showtimeId);

            // Truyền các biến cần thiết ra JSP để vẽ Sơ đồ ghế và Bắp nước
            request.setAttribute("movie", pageData.get("movie"));
            request.setAttribute("showtime", pageData.get("showtime"));
            request.setAttribute("room", pageData.get("room"));
            request.setAttribute("occupiedSeats", pageData.get("occupiedSeats"));
            request.setAttribute("seatsByRow", pageData.get("seatsByRow"));

            request.setAttribute("concessionsList", pageData.get("concessions"));

            // Truyền giá vé để Javascript đọc và tính toán
            request.setAttribute("surchargeRatesJson", pageData.get("surchargeRatesJson"));
            request.setAttribute("adultPrice", pageData.get("adultPrice"));
            request.setAttribute("childPrice", pageData.get("childPrice"));
            request.setAttribute("basePrice", pageData.get("basePrice"));

            // Hỗ trợ hiển thị thẻ <title> của web
            models.Movie m = (models.Movie) pageData.get("movie");
            if (m != null) {
                request.setAttribute("movieTitle", m.getTitle());
            }

            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/showtimes");
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

        // Chốt chặn 1: Đề phòng truy cập trái phép không có showtimeId
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        // Chốt chặn 2: Khách cố tình submit khi chưa chọn ghế
        if (seatIdsParam == null || seatIdsParam.length == 0) {
            // Lưu lỗi vào session để JSP hiển thị
            session.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế để tiếp tục.");
            response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeIdParam);
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);

            // Tận dụng lại hàm Service để lấy dữ liệu Bảng giá và Phụ phí cực kỳ tối ưu
            Map<String, Object> pageData = bookingService.getBookingTicketsData(showtimeId);

            @SuppressWarnings("unchecked")
            java.util.List<Integer> occupiedSeats = (java.util.List<Integer>) pageData.get("occupiedSeats");

            // Ép kiểu an toàn cho giá tiền (Đề phòng trường hợp Service trả về BigDecimal hoặc Integer)
            double adultPrice = ((Number) pageData.get("adultPrice")).doubleValue();
            double childPrice = ((Number) pageData.get("childPrice")).doubleValue();

            @SuppressWarnings("unchecked")
            java.util.List<models.SeatTypeSurcharge> surcharges = (java.util.List<models.SeatTypeSurcharge>) pageData.get("surchargeList");

            java.util.List<Map<String, Object>> selectedSeats = new ArrayList<>();
            BigDecimal ticketTotal = BigDecimal.ZERO;

            @SuppressWarnings("unchecked")
            java.util.Map<String, java.util.List<java.util.Map<String, Object>>> seatsByRow =
                    (java.util.Map<String, java.util.List<java.util.Map<String, Object>>>) pageData.get("seatsByRow");

            // ====================================================================
            // VÒNG LẶP TÍNH TIỀN TỪNG GHẾ (ĐÃ FIX CÔNG THỨC)
            // ====================================================================
            for (String sidStr : seatIdsParam) {
                int seatId;
                try {
                    seatId = Integer.parseInt(sidStr.trim());
                } catch (Exception e) { continue; }

                // Kiểm tra: Ghế có bị người khác nhanh tay mua mất không?
                if (occupiedSeats.contains(seatId)) {
                    session.setAttribute("error", "Ghế bạn chọn vừa có người đặt. Vui lòng chọn ghế khác.");
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
                                s = temp;
                                break;
                            }
                        }
                        if (s != null) break;
                    }
                }

                if (s == null) continue;

                // Xác định loại vé khách chọn
                String ticketType = request.getParameter("ticketType_" + seatId);
                ticketType = (ticketType != null && ticketType.equals("CHILD")) ? "CHILD" : "ADULT";

                // ---------------------------------------------------
                // CÔNG THỨC CHUẨN: Giá Cuối = Giá Cơ Bản + Phụ Phí Ghế
                // ---------------------------------------------------
                double basePrice = "CHILD".equals(ticketType) ? childPrice : adultPrice;
                double surchargeRate = 0;

                if (surcharges != null) {
                    for (models.SeatTypeSurcharge sur : surcharges) {
                        if (sur.getSeatType().equals(s.getSeatType())) {
                            surchargeRate = sur.getSurchargeRate().doubleValue();
                            break;
                        }
                    }
                }

                // ĐÃ FIX: Dùng phép CỘNG (+) thay vì nhân (*)
                double finalSeatPrice = Math.round(basePrice * (1 + surchargeRate / 100.0));

                Map<String, Object> seatData = new java.util.HashMap<>();
                seatData.put("seatId", seatId);
                seatData.put("seatCode", s.getSeatCode());
                seatData.put("seatType", s.getSeatType());
                seatData.put("ticketType", ticketType);
                seatData.put("price", BigDecimal.valueOf(finalSeatPrice));

                selectedSeats.add(seatData);
                ticketTotal = ticketTotal.add(BigDecimal.valueOf(finalSeatPrice));
            }

            if (selectedSeats.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            // ====================================================================
            // XỬ LÝ BẮP NƯỚC
            // ====================================================================
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

            // ====================================================================
            // TỔNG KẾT VÀ PHỤC HỒI VOUCHER TỪ SESSION CŨ
            // ====================================================================
            BigDecimal grandTotal = ticketTotal.add(concessionTotalPost);
            String voucherCodeParam = request.getParameter("voucherCode");

            if (voucherCodeParam == null || voucherCodeParam.trim().isEmpty()) {
                @SuppressWarnings("unchecked")
                Map<String, Object> oldData = (Map<String, Object>) session.getAttribute("customerBookingData");
                if (oldData != null && oldData.get("voucherCode") != null) {
                    voucherCodeParam = (String) oldData.get("voucherCode"); // Lôi voucher cũ ra xài lại
                }
            }

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
