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

@WebServlet(name = "BookingSummary", urlPatterns = {"/booking-summary"})
public class BookingSummary extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        services.BookingService bookingService = new services.BookingService();

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

        services.BookingService bookingService = new services.BookingService();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        if (bookingData == null) {
            response.sendRedirect(request.getContextPath() + "/home");
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

            // CHỐT CHẶN 1: KIỂM TRA ĐIỀU KIỆN 10.000Đ TRƯỚC KHI VÀO DATABASE
            // Chỉ bắt những đơn hàng nằm trong khoảng: 0đ < finalAmount < 10.000đ
            if (finalAmount.compareTo(BigDecimal.ZERO) > 0 && finalAmount.compareTo(new BigDecimal("10000")) < 0) {

                // Gỡ bỏ mã booking cũ (nếu có) để làm sạch giỏ hàng
                bookingData.remove("savedBookingCode");
                session.setAttribute("customerBookingData", bookingData);

                // Gắn thông báo lỗi vào Session và hất về trang Summary
                session.setAttribute("errorMsg", "Giao dịch VNPay yêu cầu tối thiểu 10.000đ. Vui lòng mua thêm bắp nước hoặc gỡ mã giảm giá!");
                response.sendRedirect(request.getContextPath() + "/booking-summary");
                return; // DỪNG LẠI NGAY LẬP TỨC. KHÔNG LƯU VÀO DB!
            }
            // =========================================================================

            String bookingCode = (String) bookingData.get("savedBookingCode");
            repositories.Bookings bookingDao = new repositories.Bookings();

            // CHỐT CHẶN 2: CHỈ TẠO BOOKING KHI ĐƠN HỢP LỆ (0đ HOẶC >= 10.000đ)
            if (bookingCode == null) {
                bookingCode = "BK" + System.currentTimeMillis() + new java.util.Random().nextInt(1000);

                try {
                    int bookingId = bookingDao.createOnlineBooking(
                            user.getUserId(), showtimeId, "BANKING", bookingCode,
                            totalAmount, BigDecimal.ZERO, totalAmount,
                            null
                    );

                    repositories.OnlineTickets ticketDao = new repositories.OnlineTickets();
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> seats = (List<Map<String, Object>>) bookingData.get("seats");
                    for (Map<String, Object> seat : seats) {
                        ticketDao.insertOnlineTicket(
                                bookingId, showtimeId, (Integer) seat.get("seatId"),
                                (String) seat.get("ticketType"), (String) seat.get("seatType"),
                                (BigDecimal) seat.get("price")
                        );
                    }

                    bookingData.put("savedBookingCode", bookingCode);
                    session.setAttribute("customerBookingData", bookingData);

                    // Áp dụng Voucher
                    if (summaryResult.get("appliedVoucher") != null) {
                        bookingDao.applyVoucher(bookingId, totalAmount, discountAmount, finalAmount, voucherCode);
                    } else {
                        bookingDao.applyVoucher(bookingId, totalAmount, BigDecimal.ZERO, totalAmount, null);
                    }

                } catch (java.sql.SQLException ex) {
                    if (ex.getMessage() != null && ex.getMessage().contains("ux_online_ticket_showtime_seat")) {
                        session.setAttribute("errorMsg", "Rất tiếc, ghế bạn chọn vừa có người thanh toán. Vui lòng chọn ghế khác.");
                        response.sendRedirect(request.getContextPath() + "/booking-tickets?showtimeId=" + showtimeId);
                        return;
                    }
                    throw ex; // Ném ra ngoài cho Catch tổng xử lý
                }
            }

            // =========================================================================
            // CHỐT CHẶN 3: XỬ LÝ ĐƠN HÀNG 0Đ (ĐỒNG BỘ UI VỚI VNPAY RETURN)
            // =========================================================================
            if (finalAmount.compareTo(BigDecimal.ZERO) == 0) {
                // Vẫn xử lý chốt đơn và trừ kho bình thường
                bookingService.processSuccessfulPayment(bookingCode);

                @SuppressWarnings("unchecked")
                java.util.List<Map<String, Object>> concessions = (java.util.List<Map<String, Object>>) bookingData.get("concessions");
                if (concessions != null && !concessions.isEmpty()) {
                    repositories.Concessions concessionRepo = new repositories.Concessions();
                    for (Map<String, Object> c : concessions) {
                        concessionRepo.deductQuantity((Integer) c.get("concessionId"), (Integer) c.get("quantity"));
                    }
                }
                session.removeAttribute("customerBookingData");

                // TẠO URL GIẢ LẬP VNPAY ĐỂ ĐẨY VỀ vnpay_return.jsp
                Map<String, String> returnParams = new java.util.HashMap<>();
                returnParams.put("vnp_Amount", "0");
                returnParams.put("vnp_BankCode", "VOUCHER"); // Hiển thị mã ngân hàng là VOUCHER
                returnParams.put("vnp_OrderInfo", "Thanh toan 0d cho don hang " + bookingCode);
                java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT+7"));
                java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
                returnParams.put("vnp_PayDate", formatter.format(cld.getTime()));
                returnParams.put("vnp_ResponseCode", "00");
                returnParams.put("vnp_TmnCode", config.VNPayConfig.vnp_TmnCode);
                returnParams.put("vnp_TransactionNo", "000000"); // Mã GD giả
                returnParams.put("vnp_TransactionStatus", "00"); // Trạng thái thành công
                returnParams.put("vnp_TxnRef", bookingCode);

                // Băm chuỗi y hệt như cách VNPay làm để qua mặt lớp bảo mật của trang Return
                List<String> fieldNames = new ArrayList<>(returnParams.keySet());
                java.util.Collections.sort(fieldNames);
                StringBuilder hashData = new StringBuilder();
                StringBuilder query = new StringBuilder();
                java.util.Iterator<String> itr = fieldNames.iterator();
                while (itr.hasNext()) {
                    String fieldName = itr.next();
                    String fieldValue = returnParams.get(fieldName);
                    if (fieldValue != null && fieldValue.length() > 0) {
                        hashData.append(fieldName).append('=').append(java.net.URLEncoder.encode(fieldValue, "US-ASCII"));
                        query.append(java.net.URLEncoder.encode(fieldName, "US-ASCII")).append('=').append(java.net.URLEncoder.encode(fieldValue, "US-ASCII"));
                        if (itr.hasNext()) {
                            query.append('&');
                            hashData.append('&');
                        }
                    }
                }

                String secureHash = utils.VNPay.hmacSHA512(config.VNPayConfig.secretKey, hashData.toString());
                String returnUrl = request.getContextPath() + "/pages/vnpay/vnpay_return.jsp?" + query.toString() + "&vnp_SecureHash=" + secureHash;

                response.sendRedirect(returnUrl);
                return;
            }

            // =========================================================================
            // CHỐT CHẶN 4: ĐƠN HÀNG >= 10.000Đ -> ĐI QUA VNPAY
            // =========================================================================
            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String vnp_TxnRef = bookingCode;
            String vnp_IpAddr = utils.VNPay.getIpAddress(request);
            String vnp_TmnCode = config.VNPayConfig.vnp_TmnCode;

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
            vnp_Params.put("vnp_ReturnUrl", config.VNPayConfig.vnp_ReturnUrl);
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT+7"));
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
            vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));

            cld.add(java.util.Calendar.MINUTE, 5);
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
            String vnp_SecureHash = utils.VNPay.hmacSHA512(config.VNPayConfig.secretKey, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = config.VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Hệ thống bận hoặc có lỗi xử lý dữ liệu. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}