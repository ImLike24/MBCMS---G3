package controllers.customer;

import java.io.IOException;

import models.User;
import models.Showtime;
import repositories.Showtimes;
import repositories.Vouchers;
import repositories.UserVouchers;
import models.Voucher;
import models.UserVoucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "BookingSummary", urlPatterns = { "/customer/booking-summary" })
public class BookingSummary extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        String showtimeIdParam = request.getParameter("showtimeId");

        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        String successParam = request.getParameter("success");
        boolean isSuccessRedirect = "1".equals(successParam);
        boolean pendingPayment = "1".equals(request.getParameter("pendingPayment"));
        if (pendingPayment) {
            request.setAttribute("pendingPaymentMessage", true);
        }

        // Hiển thị lỗi từ session (khi redirect từ doPost)
        if (session.getAttribute("paymentError") != null) {
            request.setAttribute("error", session.getAttribute("paymentError"));
            session.removeAttribute("paymentError");
        }

        // Khi success=1: hiển thị hóa đơn (dữ liệu từ session receipt)
        // Khi không success: cần customerBookingData từ booking-tickets
        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        List<Map<String, Object>> selectedSeats = new ArrayList<>();
        java.math.BigDecimal totalAmount = java.math.BigDecimal.ZERO;

        if (!isSuccessRedirect) {
            if (bookingData == null || !Integer.valueOf(showtimeIdParam).equals(bookingData.get("showtimeId"))) {
                response.sendRedirect(
                        request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeIdParam);
                return;
            }
            selectedSeats = (List<Map<String, Object>>) bookingData.get("seats");
            totalAmount = (java.math.BigDecimal) bookingData.get("totalAmount");
            if (selectedSeats == null)
                selectedSeats = new ArrayList<>();
            if (totalAmount == null)
                totalAmount = java.math.BigDecimal.ZERO;
        }

        Showtimes showtimesRepo = null;

        try {

            int showtimeId = Integer.parseInt(showtimeIdParam);

            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);

            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            User user = (User) session.getAttribute("user");
            request.setAttribute("customerName", user != null && user.getFullName() != null ? user.getFullName() : "");
            request.setAttribute("customerEmail", user != null && user.getEmail() != null ? user.getEmail() : "");

            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));
            request.setAttribute("selectedSeats", selectedSeats != null ? selectedSeats : new ArrayList<>());
            request.setAttribute("totalAmount", totalAmount != null ? totalAmount : java.math.BigDecimal.ZERO);
            List<Map<String, Object>> concessions = (List<Map<String, Object>>) (bookingData != null
                    ? bookingData.get("concessions")
                    : null);
            request.setAttribute("selectedConcessions", concessions != null ? concessions : new ArrayList<>());
            java.math.BigDecimal ticketTotalAttr = bookingData != null
                    ? (java.math.BigDecimal) bookingData.get("ticketTotal")
                    : null;
            java.math.BigDecimal concessionTotalAttr = bookingData != null
                    ? (java.math.BigDecimal) bookingData.get("concessionTotal")
                    : null;
            if (ticketTotalAttr == null)
                ticketTotalAttr = totalAmount;
            if (concessionTotalAttr == null)
                concessionTotalAttr = java.math.BigDecimal.ZERO;
            request.setAttribute("ticketTotal", ticketTotalAttr);
            request.setAttribute("concessionTotal", concessionTotalAttr);

            // --- RESTORED: Voucher Validation ---
            // Ưu tiên mã từ URL (khi user bấm "Áp dụng mã"), nếu không có thì lấy từ session (từ booking-tickets)
            String voucherCode = request.getParameter("voucherCode");
            if ((voucherCode == null || voucherCode.trim().isEmpty()) && bookingData != null && bookingData.get("voucherCode") != null) {
                voucherCode = (String) bookingData.get("voucherCode");
            }
            BigDecimal discountAmountAttr = BigDecimal.ZERO;
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                Vouchers voucherRepo = new Vouchers();
                UserVouchers uvRepo = new UserVouchers();
                try {
                    String code = voucherCode.trim();
                    Voucher v = voucherRepo.getActiveVoucherByCode(code);
                    if (v == null) {
                        User currentUser = (User) session.getAttribute("user");
                        if (currentUser != null) {
                            UserVoucher uv = uvRepo.getVoucherByCode(code);
                            if (uv != null && uv.getUserId() == currentUser.getUserId()) {
                                if ("AVAILABLE".equals(uv.getStatus())) {
                                    if (uv.getExpiresAt() != null
                                            && uv.getExpiresAt().isAfter(java.time.LocalDateTime.now())) {
                                        v = voucherRepo.getVoucherById(uv.getVoucherId());
                                    } else {
                                        request.setAttribute("voucherMessage", "Voucher đã hết hạn sử dụng.");
                                    }
                                } else {
                                    request.setAttribute("voucherMessage",
                                            "Voucher này đã được sử dụng hoặc không khả dụng.");
                                }
                            }
                        }
                    }

                    if (v != null && request.getAttribute("voucherMessage") == null) {
                        if (v.getIsActive()
                                && (v.getMaxUsageLimit() == null || v.getCurrentUsage() < v.getMaxUsageLimit())) {
                            discountAmountAttr = v.getDiscountAmount();
                            request.setAttribute("discountAmount", discountAmountAttr);
                            request.setAttribute("appliedVoucherCode", code);
                            request.setAttribute("voucherMessage", "Áp dụng thành công: " + v.getVoucherName());
                            request.setAttribute("isVoucherValid", true);
                        } else {
                            request.setAttribute("voucherMessage", "Voucher đã hết lượt sử dụng hoặc đã bị tạm ngưng.");
                            request.setAttribute("isVoucherValid", false);
                        }
                    } else if (request.getAttribute("isVoucherValid") == null) {
                        if (request.getAttribute("voucherMessage") == null) {
                            request.setAttribute("voucherMessage", "Mã voucher không hợp lệ.");
                        }
                        request.setAttribute("isVoucherValid", false);
                    }
                } finally {
                    voucherRepo.closeConnection();
                    uvRepo.closeConnection();
                }
            }
            request.setAttribute("discountAmount", discountAmountAttr);

            request.setAttribute("userPoints", user != null ? user.getPoints() : 0);

            Showtime st = (Showtime) showtimeDetails.get("showtime");

            if (st != null) {

                if (st.getShowDate() != null) {
                    request.setAttribute("showDateFormatted",
                            st.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

                if (st.getStartTime() != null) {
                    request.setAttribute("showTimeFormatted",
                            st.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
            }

            // Hiển thị hóa đơn sau thanh toán thành công (redirect với success=1)
            if (isSuccessRedirect) {
                request.setAttribute("paymentSuccess", true);
                request.setAttribute("receiptBookingCode", session.getAttribute("receiptBookingCode"));
                request.setAttribute("receiptInvoiceCode", session.getAttribute("receiptInvoiceCode"));
                request.setAttribute("receiptSeats", session.getAttribute("receiptSeats"));
                request.setAttribute("receiptTotal", session.getAttribute("receiptTotal"));
                session.removeAttribute("receiptBookingCode");
                session.removeAttribute("receiptInvoiceCode");
                session.removeAttribute("receiptSeats");
                session.removeAttribute("receiptTotal");
            }

            request.getRequestDispatcher("/pages/customer/booking-summary.jsp").forward(request, response);
        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("error", e.getMessage());

            request.getRequestDispatcher("/pages/customer/booking-summary.jsp")
                    .forward(request, response);

        } finally {

            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int customerId = currentUser.getUserId();

        // Lấy dữ liệu từ form (không dùng JSON/JavaScript)
        String customerName = request.getParameter("customerName");
        String customerEmail = request.getParameter("customerEmail");
        if (customerName == null || customerName.isBlank()) {
            customerName = currentUser.getFullName() != null ? currentUser.getFullName() : "";
        }
        if (customerEmail == null || customerEmail.isBlank()) {
            customerEmail = currentUser.getEmail() != null ? currentUser.getEmail() : "";
        }

        // Lấy dữ liệu đặt vé từ session (do booking-tickets lưu)
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

        try {
            // 1. Tính toán số tiền cuối cùng (Trừ đi Voucher nếu có)
            java.math.BigDecimal discountAmount = java.math.BigDecimal.ZERO;
            String appliedVoucherCode = request.getParameter("appliedVoucherCode");

            if (appliedVoucherCode != null && !appliedVoucherCode.trim().isEmpty()) {
                repositories.Vouchers voucherRepo = new repositories.Vouchers();
                models.Voucher v = voucherRepo.getActiveVoucherByCode(appliedVoucherCode.trim());
                if (v != null) discountAmount = v.getDiscountAmount();
                voucherRepo.closeConnection();
            }

            java.math.BigDecimal finalAmount = totalAmount.subtract(discountAmount);
            if (finalAmount.compareTo(java.math.BigDecimal.ZERO) < 0) {
                finalAmount = java.math.BigDecimal.ZERO;
            }
                long amountInVND = finalAmount.longValue() * 100; 

            // 2. Tạo mã GD (TxnRef) & Insert vào Database (Trạng thái PENDING)
            String vnp_TxnRef = payment.Config.getRandomNumber(8);
            repositories.Bookings bookingRepo = new repositories.Bookings();

            int bookingId = bookingRepo.createOnlineBooking(customerId, showtimeId, "BANKING", vnp_TxnRef, totalAmount, discountAmount, finalAmount, appliedVoucherCode);

            // Lưu từng chiếc vé khách đã chọn
            for (Map<String, Object> seat : seatsList) {
                int seatId = (Integer) seat.get("seatId");
                String ticketType = (String) seat.get("ticketType");
                String seatType = (String) seat.get("seatType");
                java.math.BigDecimal price = (java.math.BigDecimal) seat.get("price");
                bookingRepo.insertOnlineTicket(bookingId, showtimeId, seatId, ticketType, seatType, price);
            }

            // 3. Tạo URL thanh toán VNPay
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

            // Xử lý thời gian giao dịch
            java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT+7"));
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
            vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));
            cld.add(java.util.Calendar.MINUTE, 15); // Hết hạn sau 15 phút
            vnp_Params.put("vnp_ExpireDate", formatter.format(cld.getTime()));

            // Build URL bảo mật với SecureHash
            java.util.List<String> fieldNames = new java.util.ArrayList<>(vnp_Params.keySet());
            java.util.Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            java.util.Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName).append('=').append(java.net.URLEncoder.encode(fieldValue, java.nio.charset.StandardCharsets.US_ASCII.toString()));
                    query.append(java.net.URLEncoder.encode(fieldName, java.nio.charset.StandardCharsets.US_ASCII.toString())).append('=').append(java.net.URLEncoder.encode(fieldValue, java.nio.charset.StandardCharsets.US_ASCII.toString()));
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

            // 4. Redirect thẳng sang trang thanh toán của VNPay
            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId + "&error=" + java.net.URLEncoder.encode("Lỗi khi tạo đơn hàng, vui lòng thử lại.", "UTF-8"));
        }
    }
}