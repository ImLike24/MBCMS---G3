package repositories;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.math.BigDecimal;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

import config.DBContext;
public class Bookings {

    private Connection conn;

    public Bookings() throws Exception {
        conn = new DBContext().getConnection();
    }

    public int createOnlineBooking(int userId,
                                   int showtimeId,
                                   String paymentMethod,
                                   String bookingCode,
                                   BigDecimal totalAmount,
                                   BigDecimal discountAmount,
                                   BigDecimal finalAmount,
                                   String appliedVoucherCode) throws SQLException {

        String sql = """
                INSERT INTO bookings
                (user_id, showtime_id, booking_code,
                 total_amount, discount_amount, final_amount,
                 payment_method, payment_status, status, payment_time, applied_voucher_code)
                VALUES (?, ?, ?,
                        ?, ?, ?,
                        ?, 'PENDING', 'PENDING', SYSDATETIME(), ?)
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            ps.setInt(2, showtimeId);
            ps.setString(3, bookingCode);
            ps.setBigDecimal(4, totalAmount);
            ps.setBigDecimal(5, discountAmount);
            ps.setBigDecimal(6, finalAmount);
            ps.setString(7, paymentMethod);
            ps.setString(8, appliedVoucherCode);

            int affectedRows = ps.executeUpdate();

            if (affectedRows == 0) {
                return -1;
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // booking_id
                }
            }
        }

        return -1;
    }


    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void insertOnlineTicket(int bookingId, int showtimeId, int seatId, String ticketType, String seatType,
            BigDecimal price) throws Exception {
        String sql = """
                INSERT INTO online_tickets
                (booking_id, showtime_id, seat_id, ticket_type, seat_type, price)
                VALUES (?, ?, ?, ?, ?, ?)
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, bookingId);
        ps.setInt(2, showtimeId);
        ps.setInt(3, seatId);
        ps.setString(4, ticketType);
        ps.setString(5, seatType);
        ps.setBigDecimal(6, price);

        ps.executeUpdate();
    }

    // Delete booking
    public void deleteBooking(String bookingCode) throws Exception {

        String sql1 = """
                DELETE FROM online_tickets
                WHERE booking_id = (
                    SELECT booking_id FROM bookings WHERE booking_code=?
                )
                """;

        PreparedStatement ps1 = conn.prepareStatement(sql1);
        ps1.setString(1, bookingCode);
        ps1.executeUpdate();

        String sql2 = "DELETE FROM bookings WHERE booking_code=?";

        PreparedStatement ps2 = conn.prepareStatement(sql2);
        ps2.setString(1, bookingCode);
        ps2.executeUpdate();
    }

    public void confirmBooking(String bookingCode) throws Exception {
        String sql = """
                UPDATE bookings
                SET payment_status='PAID',
                    status='CONFIRMED',
                    payment_method='BANKING',
                    payment_time=SYSDATETIME()
                WHERE booking_code=?
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ps.executeUpdate();
    }

    public java.util.Map<String, Object> getBookingInfoForPoints(String bookingCode) throws Exception {
        String sql = "SELECT user_id, final_amount, applied_voucher_code FROM bookings WHERE booking_code = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            java.util.Map<String, Object> info = new java.util.HashMap<>();
            info.put("userId", rs.getInt("user_id"));
            info.put("finalAmount", rs.getBigDecimal("final_amount"));
            info.put("voucherCode", rs.getString("applied_voucher_code"));
            return info;
        }
        return null;
    }

    public boolean hasUserWatchedMovie(int userId, int movieId) throws Exception {
        String sql = """
                SELECT TOP 1 1
                FROM bookings b
                JOIN showtimes s ON b.showtime_id = s.showtime_id
                WHERE b.user_id = ?
                  AND s.movie_id = ?
                  AND b.payment_status = 'PAID'
                  AND (s.show_date < CAST(SYSDATETIME() AS DATE)
                       OR (s.show_date = CAST(SYSDATETIME() AS DATE)
                           AND s.start_time <= CAST(SYSDATETIME() AS TIME)))
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void cleanupExpiredBookings() {
        try {
            // Cập nhật các booking PENDING quá 10 phút thành EXPIRED
            String updateBookingsSql = """
                UPDATE bookings 
                SET status = 'EXPIRED' 
                WHERE status = 'PENDING' 
                AND DATEDIFF(MINUTE, booking_time, SYSDATETIME()) >= 10
            """;
            try (PreparedStatement ps1 = conn.prepareStatement(updateBookingsSql)) {
                ps1.executeUpdate();
            }

            // GIẢI PHÓNG GHẾ
            // Xóa sạch vé của tất cả những đơn hàng đã bị EXPIRED (Quá hạn) hoặc CANCELLED (Đã hủy).
            // Lệnh này sẽ tự động "chữa lành" cho toàn bộ các ghế đang bị kẹt trong DB của bạn ngay lập tức.
            String deleteTicketsSql = """
                DELETE FROM online_tickets 
                WHERE booking_id IN (
                    SELECT booking_id FROM bookings 
                    WHERE status IN ('EXPIRED', 'CANCELLED')
                )
            """;
            try (PreparedStatement ps2 = conn.prepareStatement(deleteTicketsSql)) {
                ps2.executeUpdate();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Hàm này để ốp mã giảm giá SAU KHI đã insert xong toàn bộ vé và bắp nước
    public void applyVoucher(int bookingId, BigDecimal discountAmount, BigDecimal finalAmount, String voucherCode) throws SQLException {
        String sql = "UPDATE bookings SET discount_amount = ?, final_amount = ?, applied_voucher_code = ? WHERE booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, discountAmount);
            ps.setBigDecimal(2, finalAmount);
            ps.setString(3, voucherCode);
            ps.setInt(4, bookingId);
            ps.executeUpdate();
        }
    }
}
