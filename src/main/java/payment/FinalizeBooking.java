package payment;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

import repositories.Bookings;

@WebServlet("/FinalizeBooking")
public class FinalizeBooking extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Bookings bookingRepo = new Bookings();

            String bookingCode = request.getParameter("vnp_TxnRef");
            String transactionStatus = request.getParameter("vnp_TransactionStatus");

            if ("00".equals(transactionStatus)) {
                // Call confirmBooking
                bookingRepo.confirmBooking(bookingCode);

                Map<String, Object> bookingInfo = bookingRepo.getBookingInfoForPoints(bookingCode);
                if (bookingInfo != null) {
                    int userId = (int) bookingInfo.get("userId");
                    BigDecimal finalAmount = bookingInfo.get("finalAmount") != null
                            ? (BigDecimal) bookingInfo.get("finalAmount") : BigDecimal.ZERO;
                    String appliedVoucherCode = (String) bookingInfo.get("voucherCode");

                    repositories.Users userRepo = new repositories.Users();
                    repositories.LoyaltyConfigs configRepo = new repositories.LoyaltyConfigs();
                    repositories.MembershipTiers tiersRepo = new repositories.MembershipTiers();

                    models.User user = userRepo.getUserById(userId);
                    models.LoyaltyConfig config = configRepo.getConfig();

                    if (user != null && config != null) {
                        models.MembershipTier tier = tiersRepo.getTierById(user.getTierId());
                        BigDecimal multiplier = (tier != null) ? tier.getPointMultiplier()
                                : BigDecimal.ONE;

                        // Points = (FinalAmount / EarnRateAmount) * EarnPoints * Multiplier
                        BigDecimal earnRateAmount = config.getEarnRateAmount();
                        int earnPointsPerRate = config.getEarnPoints();
                        
                        // (finalAmount / earnRateAmount) * earnPointsPerRate * multiplier
                        BigDecimal earnedPointsBD = finalAmount
                                .divide(earnRateAmount, 4, java.math.RoundingMode.HALF_UP)
                                .multiply(BigDecimal.valueOf(earnPointsPerRate))
                                .multiply(multiplier);

                        int earnedPoints = earnedPointsBD.intValue();

                        if (earnedPoints > 0) {
                            userRepo.addPoints(userId, earnedPoints);
                            // Cập nhật hạng thành viên (Logic tự động dựa trên tổng điểm tích lũy)
                            userRepo.updateTier(userId);
                        }
                    }

                    // 3. Increment Voucher Usage
                    if (appliedVoucherCode != null && !appliedVoucherCode.isEmpty()) {
                        repositories.Vouchers voucherRepo = new repositories.Vouchers();
                        repositories.UserVouchers uvRepo = new repositories.UserVouchers();

                        // Increment global usage
                        voucherRepo.incrementVoucherUsage(appliedVoucherCode);
                        // Mark personalized voucher as USED
                        uvRepo.markVoucherAsUsed(appliedVoucherCode);
                    }
                }

                response.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
            } else {
                // Nếu thanh toán thất bại/hủy -> Xóa Booking và giải phóng ghế
                bookingRepo.deleteBooking(bookingCode);
                System.out.println("TransactionStatus Failed: " + transactionStatus);
                response.getWriter().write("FAILED");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}