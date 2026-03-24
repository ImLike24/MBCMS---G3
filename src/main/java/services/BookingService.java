package services;

import repositories.Bookings;
import repositories.Showtimes;
import repositories.Users;
import repositories.Vouchers;
import repositories.UserVouchers;
import java.math.BigDecimal;
import java.util.Map;

public class BookingService {

    // Khai báo các DAO (Công cụ) ở đây
    private final Showtimes showtimeDao = new Showtimes();
    private Bookings bookingDao;

    public BookingService() {
        try {
            this.bookingDao = new Bookings();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Giữ nguyên hàm cũ
    public Map<String, Object> getShowtimeDetails(int showtimeId) {
        return showtimeDao.getShowtimeDetails(showtimeId);
    }

    // ---------------------------------------------------------
    // LOGIC NGHIỆP VỤ THANH TOÁN (Chuyển từ FinalizeBooking sang)
    // ---------------------------------------------------------

    // 1. Xử lý khi thanh toán THÀNH CÔNG
    public void processSuccessfulPayment(String bookingCode) throws Exception {
        // 1. Cập nhật trạng thái Booking
        bookingDao.confirmBooking(bookingCode);

        // 2. Xử lý điểm thưởng & Hạng thành viên
        Map<String, Object> bookingInfo = bookingDao.getBookingInfoForPoints(bookingCode);
        if (bookingInfo != null) {
            int userId = (int) bookingInfo.get("userId");
            BigDecimal finalAmount = (BigDecimal) bookingInfo.get("finalAmount");
            String appliedVoucherCode = (String) bookingInfo.get("voucherCode");

            Users userRepo = new Users();
            // Tính toán và cộng điểm
            int earnedPoints = finalAmount.divide(new BigDecimal(1000)).intValue();
            if (earnedPoints > 0) {
                userRepo.addPoints(userId, earnedPoints);
                userRepo.updateTier(userId); // Cập nhật hạng
            }

            // 3. Xử lý Voucher (Nếu có dùng)
            if (appliedVoucherCode != null && !appliedVoucherCode.isEmpty()) {
                Vouchers voucherRepo = new Vouchers();
                UserVouchers uvRepo = new UserVouchers();
                voucherRepo.incrementVoucherUsage(appliedVoucherCode);
                uvRepo.deleteVoucherByCode(appliedVoucherCode);
            }
        }
    }

    // 2. Xử lý khi thanh toán THẤT BẠI / HỦY
    public void processFailedPayment(String bookingCode) throws Exception {
        // Hủy booking, giải phóng ghế cho người khác mua
        bookingDao.deleteBooking(bookingCode);
    }
}