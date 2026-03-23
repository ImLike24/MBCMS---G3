package controllers.customer;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import models.User;
import repositories.Bookings;
import repositories.Vouchers;
import models.Voucher;

/**
 * Bước duy nhất tạo đơn PENDING + online_tickets ngay trước khi redirect sang cổng VNPay.
 * Không nằm trong package {@code payment}; servlet {@code FinalizeBooking} giữ nguyên.
 */
@WebServlet(name = "StartOnlinePayment", urlPatterns = { "/customer/start-online-payment" })
public class StartOnlinePayment extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        String nonceParam = request.getParameter("nonce");
        String expectedNonce = (String) session.getAttribute("onlinePaymentCheckoutNonce");
        session.removeAttribute("onlinePaymentCheckoutNonce");

        if (nonceParam == null || expectedNonce == null || !expectedNonce.equals(nonceParam)) {
            redirectSummaryWithError(request, response, "Phiên thanh toán không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.");
            return;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        if (bookingData == null) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId = (Integer) bookingData.get("showtimeId");
        BigDecimal totalAmount = (BigDecimal) bookingData.get("totalAmount");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> seatsList = (List<Map<String, Object>>) bookingData.get("seats");

        if (seatsList == null || seatsList.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int customerId = currentUser.getUserId();

        String appliedVoucherCode = (String) session.getAttribute("checkoutAppliedVoucherCode");
        session.removeAttribute("checkoutAppliedVoucherCode");
        if (appliedVoucherCode == null || appliedVoucherCode.isBlank()) {
            Object vc = bookingData.get("voucherCode");
            if (vc != null && !vc.toString().isBlank()) {
                appliedVoucherCode = vc.toString().trim();
            }
        }

        Bookings bookingRepo = null;
        try {
            java.math.BigDecimal discountAmount = java.math.BigDecimal.ZERO;
            if (appliedVoucherCode != null && !appliedVoucherCode.trim().isEmpty()) {
                Vouchers voucherRepo = new Vouchers();
                try {
                    Voucher v = voucherRepo.getActiveVoucherByCode(appliedVoucherCode.trim());
                    if (v != null) {
                        discountAmount = v.getDiscountAmount();
                    }
                } finally {
                    voucherRepo.closeConnection();
                }
            }

            java.math.BigDecimal finalAmount = totalAmount.subtract(discountAmount);
            if (finalAmount.compareTo(java.math.BigDecimal.ZERO) < 0) {
                finalAmount = java.math.BigDecimal.ZERO;
            }
            long amountInVND = finalAmount.longValue() * 100;

            String vnp_TxnRef = payment.Config.getRandomNumber(8);
            bookingRepo = new Bookings();

            int bookingId = createOnlineBookingCompat(bookingRepo, customerId, showtimeId, "BANKING", vnp_TxnRef);

            for (Map<String, Object> seat : seatsList) {
                int seatId = (Integer) seat.get("seatId");
                String ticketType = (String) seat.get("ticketType");
                String seatType = (String) seat.get("seatType");
                java.math.BigDecimal price = (java.math.BigDecimal) seat.get("price");
                bookingRepo.insertOnlineTicket(bookingId, showtimeId, seatId, ticketType, seatType, price);
            }

            bookingRepo.updateBookingAmounts(bookingId, totalAmount, discountAmount, finalAmount,
                    appliedVoucherCode != null && !appliedVoucherCode.isBlank() ? appliedVoucherCode.trim() : null);

            session.setAttribute("pendingOnlineBookingCode", vnp_TxnRef);

            Map<String, String> vnp_Params = new java.util.HashMap<>();
            vnp_Params.put("vnp_Version", "2.1.0");
            vnp_Params.put("vnp_Command", "pay");
            vnp_Params.put("vnp_TmnCode", payment.Config.vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amountInVND));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang:" + vnp_TxnRef);
            vnp_Params.put("vnp_OrderType", "other");
            vnp_Params.put("vnp_Locale", "vn");
            vnp_Params.put("vnp_ReturnUrl", payment.Config.vnp_ReturnUrl);
            vnp_Params.put("vnp_IpAddr", payment.Config.getIpAddress(request));

            java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT+7"));
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
            vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));
            cld.add(java.util.Calendar.MINUTE, 15);
            vnp_Params.put("vnp_ExpireDate", formatter.format(cld.getTime()));

            java.util.List<String> fieldNames = new java.util.ArrayList<>(vnp_Params.keySet());
            java.util.Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            java.util.Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName).append('=').append(
                            java.net.URLEncoder.encode(fieldValue, java.nio.charset.StandardCharsets.US_ASCII.toString()));
                    query.append(java.net.URLEncoder.encode(fieldName, java.nio.charset.StandardCharsets.US_ASCII.toString()))
                            .append('=')
                            .append(java.net.URLEncoder.encode(fieldValue, java.nio.charset.StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }
            String queryUrl = query.toString();
            String vnp_SecureHash = payment.Config.hmacSHA512(payment.Config.secretKey, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = payment.Config.vnp_PayUrl + "?" + queryUrl;

            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            try {
                Bookings br = new Bookings();
                try {
                    String code = (String) session.getAttribute("pendingOnlineBookingCode");
                    if (code != null && !code.isBlank()) {
                        br.deleteBooking(code);
                    }
                } finally {
                    br.closeConnection();
                }
            } catch (Exception ignored) {
            }
            session.removeAttribute("pendingOnlineBookingCode");
            redirectSummaryWithError(request, response, "Lỗi khi tạo đơn hàng, vui lòng thử lại.");
        } finally {
            if (bookingRepo != null) {
                bookingRepo.closeConnection();
            }
        }
    }

    private void redirectSummaryWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        HttpSession session = request.getSession(false);
        int showtimeId = 0;
        if (session != null) {
            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> bd = (Map<String, Object>) session.getAttribute("customerBookingData");
                if (bd != null && bd.get("showtimeId") != null) {
                    showtimeId = (Integer) bd.get("showtimeId");
                }
            } catch (Exception ignored) {
            }
        }
        String suffix = showtimeId > 0
                ? "?showtimeId=" + showtimeId + "&error=" + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8)
                : "?error=" + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/customer/booking-summary" + suffix);
    }

    private int createOnlineBookingCompat(Bookings bookingRepo,
                                          int userId,
                                          int showtimeId,
                                          String paymentMethod,
                                          String bookingCode) throws Exception {
        Class<?> clazz = bookingRepo.getClass();

        try {
            java.lang.reflect.Method m = clazz.getMethod("createOnlineBooking",
                    int.class, int.class, String.class, String.class);
            Object v = m.invoke(bookingRepo, userId, showtimeId, paymentMethod, bookingCode);
            return ((Number) v).intValue();
        } catch (NoSuchMethodException ignored) {
        }

        try {
            java.lang.reflect.Method m = clazz.getMethod("createOnlineBooking",
                    Integer.class, Integer.class, String.class, String.class);
            Object v = m.invoke(bookingRepo, Integer.valueOf(userId), Integer.valueOf(showtimeId), paymentMethod, bookingCode);
            return ((Number) v).intValue();
        } catch (NoSuchMethodException ignored) {
        }

        for (java.lang.reflect.Method m : clazz.getMethods()) {
            if (!"createOnlineBooking".equals(m.getName())) {
                continue;
            }
            Class<?>[] params = m.getParameterTypes();
            if (params.length != 4) {
                continue;
            }

            boolean ok = (params[0] == int.class || params[0] == Integer.class)
                    && (params[1] == int.class || params[1] == Integer.class)
                    && params[2] == String.class
                    && params[3] == String.class;

            if (!ok) {
                continue;
            }

            Object v = m.invoke(bookingRepo, userId, showtimeId, paymentMethod, bookingCode);
            return ((Number) v).intValue();
        }

        throw new NoSuchMethodException("No compatible createOnlineBooking found in repositories.Bookings");
    }
}
