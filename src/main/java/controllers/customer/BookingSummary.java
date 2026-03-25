package controllers.customer;

import java.io.IOException;

import config.VNPayConfig;
import models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.VNPay;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "BookingSummary", urlPatterns = { "/booking-summary" })
public class BookingSummary extends HttpServlet {

    private final services.BookingService bookingService = new services.BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Kiểm tra quyền
        String role = (String) session.getAttribute("role");
        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        // Lấy dữ liệu đặt vé từ Session
        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        if (bookingData == null) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
            return;
        }

        try {
            int showtimeId = (Integer) bookingData.get("showtimeId");

            // ==========================================================
            // LẤY THÔNG TIN PHIM, RẠP, SUẤT CHIẾU
            // ==========================================================
            Map<String, Object> showtimeDetails = bookingService.getShowtimeDetails(showtimeId);
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            // Format ngày giờ
            request.setAttribute("showDateFormatted", showtimeDetails.get("showDateFormatted"));
            request.setAttribute("showTimeFormatted", showtimeDetails.get("showTimeFormatted"));

            // ==========================================================
            // LOGIC ƯU TIÊN VOUCHER TỪ SESSION NẾU URL TRỐNG
            // ==========================================================
            String voucherCode = request.getParameter("voucherCode");

            // Nếu URL không có, tự động lấy từ Session (khi vừa từ trang ghế chuyển sang)
            if (voucherCode == null || voucherCode.trim().isEmpty()) {
                voucherCode = (String) bookingData.get("voucherCode");
            }

            // Cập nhật lại vào bookingData để lưu trạng thái mới nhất
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                bookingData.put("voucherCode", voucherCode.trim());
            } else {
                bookingData.remove("voucherCode");
            }

            // Gửi ngược lại mã này ra JSP để giữ nguyên Text trên ô input
            request.setAttribute("inputVoucherCode", voucherCode);

            // ==========================================================
            // CALL SERVICE
            // ==========================================================
            User currentUser = (User) session.getAttribute("user");
            Map<String, Object> summaryResult = bookingService.calculateSummaryAndVoucher(bookingData, voucherCode, currentUser.getUserId());

            // Bắn dữ liệu về cho giao diện (JSP)
            request.setAttribute("bookingData", bookingData);
            request.setAttribute("totalAmount", summaryResult.get("totalAmount"));
            request.setAttribute("discountAmount", summaryResult.get("discountAmount"));
            request.setAttribute("finalAmount", summaryResult.get("finalAmount"));

            // Bắn kết quả Voucher ra giao diện để in thông báo Xanh / Đỏ
            if (summaryResult.get("appliedVoucher") != null) {
                request.setAttribute("appliedVoucher", summaryResult.get("appliedVoucher"));
            }
            if (summaryResult.get("voucherError") != null) {
                request.setAttribute("voucherError", summaryResult.get("voucherError"));
            }

            request.getRequestDispatcher("/pages/customer/booking-summary.jsp").forward(request, response);

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

        User user = (User) session.getAttribute("user");

        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        if (bookingData == null) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
            return;
        }

        try {
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode == null || voucherCode.trim().isEmpty()) {
                voucherCode = (String) bookingData.get("voucherCode");
            }
            Map<String, Object> summaryResult = bookingService.calculateSummaryAndVoucher(bookingData, voucherCode, user.getUserId());

            BigDecimal finalAmount = (BigDecimal) summaryResult.get("finalAmount");
            BigDecimal discountAmount = (BigDecimal) summaryResult.get("discountAmount");
            BigDecimal totalAmount = (BigDecimal) summaryResult.get("totalAmount");
            int showtimeId = (Integer) bookingData.get("showtimeId");

            // =========================================================================
            // KIỂM TRA ĐÃ TẠO BOOKING CHƯA
            // =========================================================================
            String bookingCode = (String) bookingData.get("savedBookingCode");

            if (bookingCode == null) {
                // CHƯA CÓ: Tạo mới hoàn toàn
                bookingCode = "BK" + System.currentTimeMillis() + new java.util.Random().nextInt(1000);

                try {
                    // Insert Booking
                    repositories.Bookings bookingDao = new repositories.Bookings();
                    int bookingId = bookingDao.createOnlineBooking(
                            user.getUserId(), showtimeId, "BANKING", bookingCode,
                            totalAmount, BigDecimal.ZERO, totalAmount, // Để discount = 0, final = total
                            null // Giấu voucherCode
                    );

                    // Insert Tickets
                    repositories.OnlineTickets ticketDao = new repositories.OnlineTickets();
                    List<Map<String, Object>> seats = (List<Map<String, Object>>) bookingData.get("seats");
                    for (Map<String, Object> seat : seats) {
                        ticketDao.insertOnlineTicket(
                                bookingId, showtimeId, (Integer) seat.get("seatId"),
                                (String) seat.get("ticketType"), (String) seat.get("seatType"),
                                (BigDecimal) seat.get("price")
                        );
                    }

                    if (summaryResult.get("appliedVoucher") != null) {
                        bookingDao.applyVoucher(bookingId, discountAmount, finalAmount, voucherCode);
                    } else {
                        // Nếu không có voucher, vẫn update 1 lần cho chắc chắn finalAmount chuẩn xác
                        bookingDao.applyVoucher(bookingId, BigDecimal.ZERO, totalAmount, null);
                    }

                    // LƯU LẠI VÀO SESSION ĐỂ CHỐNG SPAM
                    bookingData.put("savedBookingCode", bookingCode);
                    session.setAttribute("customerBookingData", bookingData);

                } catch (java.sql.SQLException ex) {
                    // Nếu lỗi duplicate key bắn ra (có người vừa nhanh tay mua mất ghế)
                    if (ex.getMessage() != null && ex.getMessage().contains("ux_online_ticket_showtime_seat")) {
                        response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeId + "&error=" + java.net.URLEncoder.encode("Rất tiếc, ghế bạn chọn vừa có người thanh toán. Vui lòng chọn ghế khác.", "UTF-8"));
                        return;
                    }
                    throw ex; // Nếu lỗi khác thì ném ra ngoài
                }
            }

            // =========================================================================
            // Cấu hình & Chuyển hướng VNPay (Dùng chung cho cả tạo mới lẫn ấn Back)
            // =========================================================================
            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String vnp_TxnRef = bookingCode; // Dùng mã cũ hoặc mới
            String vnp_IpAddr = VNPay.getIpAddress(request);
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;

            long amount = finalAmount.longValue() * 100;

            Map<String, String> vnp_Params = new java.util.HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan ve phim " + vnp_TxnRef);
            vnp_Params.put("vnp_OrderType", "other");
            vnp_Params.put("vnp_Locale", "vn");
            vnp_Params.put("vnp_ReturnUrl", VNPayConfig.vnp_ReturnUrl);
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT+7"));
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
            vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));

            cld.add(java.util.Calendar.MINUTE, 15);
            vnp_Params.put("vnp_ExpireDate", formatter.format(cld.getTime()));

            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            java.util.Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            java.util.Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if (fieldValue != null && fieldValue.length() > 0) {
                    hashData.append(fieldName).append('=').append(java.net.URLEncoder.encode(fieldValue, "US-ASCII"));
                    query.append(java.net.URLEncoder.encode(fieldName, "US-ASCII")).append('=').append(java.net.URLEncoder.encode(fieldValue, "US-ASCII"));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }

            String queryUrl = query.toString();
            String vnp_SecureHash = VNPay.hmacSHA512(VNPayConfig.secretKey, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}