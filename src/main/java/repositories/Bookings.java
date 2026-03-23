package repositories;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import config.DBContext;

public class Bookings {

    private Connection conn;

    public Bookings() throws Exception {
        conn = new DBContext().getConnection();
    }

    // ========================
    // 🔹 GENERATE CODE
    // ========================
    public String generateBookingCode() {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));

        int randomNumber = new Random().nextInt(900) + 100;

        return "BK" + timestamp + randomNumber;
    }

    // ========================
    // CREATE BOOKING
    // ========================
    public int createOnlineBooking(int userId,
                                   int showtimeId,
                                   String paymentMethod,
                                   String bookingCode) throws SQLException {

        String sql = """
                INSERT INTO bookings
                (user_id, showtime_id, booking_code,
                 total_amount, discount_amount, final_amount,
                 payment_method, payment_status, status, payment_time)
                VALUES (?, ?, ?,
                        0, 0, 0,
                        ?, 'PENDING', 'PENDING', SYSDATETIME())
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            ps.setInt(2, showtimeId);
            ps.setString(3, bookingCode);
            ps.setString(4, paymentMethod);

            int affectedRows = ps.executeUpdate();

            if (affectedRows == 0) return -1;

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // ========================
    // UPDATE AMOUNT (VNPay)
    // ========================
    public void updateBookingAmounts(int bookingId,
                                     BigDecimal totalAmount,
                                     BigDecimal discountAmount,
                                     BigDecimal finalAmount,
                                     String appliedVoucherCode) throws SQLException {

        String sql = """
                UPDATE bookings
                SET total_amount = ?, discount_amount = ?, final_amount = ?,
                    applied_voucher_code = ?
                WHERE booking_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, totalAmount != null ? totalAmount : BigDecimal.ZERO);
            ps.setBigDecimal(2, discountAmount != null ? discountAmount : BigDecimal.ZERO);
            ps.setBigDecimal(3, finalAmount != null ? finalAmount : BigDecimal.ZERO);
            ps.setString(4, appliedVoucherCode);
            ps.setInt(5, bookingId);
            ps.executeUpdate();
        }
    }

    // ========================
    // INSERT TICKET
    // ========================
    public void insertOnlineTicket(int bookingId, int showtimeId, int seatId,
                                   String ticketType, String seatType,
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

    // ========================
    // DELETE BOOKING (PENDING / thanh toán thất bại)
    // ========================
    /**
     * Xóa toàn bộ dữ liệu tạm của đơn online (payment_status PENDING): vé, hóa đơn (nếu có), booking.
     * Được gọi từ {@code payment.FinalizeBooking} khi VNPay trả về thất bại — logic nghiệp vụ ở Java,
     * thao tác DB là các câu DELETE SQL theo thứ tự FK.
     */
    public void deleteBooking(String bookingCode) throws Exception {
        if (bookingCode == null || bookingCode.isBlank()) {
            return;
        }

        // 1) Hóa đơn (invoice_items CASCADE theo invoice_id khi xóa invoice)
        String sqlInv = """
                DELETE FROM invoices
                WHERE booking_id = (SELECT booking_id FROM bookings WHERE booking_code = ?)
                """;
        try (PreparedStatement ps = conn.prepareStatement(sqlInv)) {
            ps.setString(1, bookingCode);
            ps.executeUpdate();
        }

        // 2) Vé online
        String sqlOt = """
                DELETE FROM online_tickets
                WHERE booking_id = (SELECT booking_id FROM bookings WHERE booking_code = ?)
                """;
        try (PreparedStatement ps = conn.prepareStatement(sqlOt)) {
            ps.setString(1, bookingCode);
            ps.executeUpdate();
        }

        // 3) Booking
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM bookings WHERE booking_code = ?")) {
            ps.setString(1, bookingCode);
            ps.executeUpdate();
        }
    }

    /**
     * Xóa các đơn online còn {@code payment_status = PENDING} đã quá {@code olderThanMinutes} phút
     * kể từ {@code payment_time} (thời điểm tạo đơn khi bấm "Xử lý thanh toán"), để giải phóng ghế / dữ liệu tạm.
     */
    public int deleteExpiredPendingOnlineBookings(int olderThanMinutes) throws Exception {
        if (olderThanMinutes <= 0) {
            return 0;
        }
        String selectSql = """
                SELECT booking_code FROM bookings
                WHERE payment_status = 'PENDING'
                  AND status = 'PENDING'
                  AND payment_time IS NOT NULL
                  AND payment_time <= DATEADD(MINUTE, ?, SYSDATETIME())
                """;
        List<String> codes = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, -olderThanMinutes);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    codes.add(rs.getString("booking_code"));
                }
            }
        }
        int removed = 0;
        for (String code : codes) {
            deleteBooking(code);
            removed++;
        }
        return removed;
    }

    // ========================
    // 🔹 GET INFO
    // ========================
    public int getShowtimeIdByCode(String bookingCode) throws Exception {
        String sql = "SELECT showtime_id FROM bookings WHERE booking_code=?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) return rs.getInt("showtime_id");
        return 0;
    }

    /**
     * Trả về payment_status (vd. PENDING, PAID) hoặc null nếu không có booking.
     */
    public String getPaymentStatusByBookingCode(String bookingCode) throws SQLException {
        if (bookingCode == null || bookingCode.isBlank()) {
            return null;
        }
        String sql = "SELECT payment_status FROM bookings WHERE booking_code = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bookingCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("payment_status");
                }
            }
        }
        return null;
    }

    public int getBookingIdByCode(String bookingCode) throws Exception {
        String sql = "SELECT booking_id FROM bookings WHERE booking_code = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) return rs.getInt("booking_id");
        return 0;
    }

    public String getSeatIdsByBookingCode(String bookingCode) throws Exception {
        String sql = """
                SELECT seat_id
                FROM online_tickets
                WHERE booking_id = (
                    SELECT booking_id FROM bookings WHERE booking_code = ?
                )
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);
        ResultSet rs = ps.executeQuery();

        StringBuilder seatIds = new StringBuilder();

        while (rs.next()) {
            if (seatIds.length() > 0) seatIds.append(",");
            seatIds.append(rs.getInt("seat_id"));
        }

        return seatIds.toString();
    }

    // ========================
    // 🔹 CONFIRM BOOKING
    // ========================
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

    // ========================
    // 🔹 POINT / VOUCHER
    // ========================
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

    // ========================
    // 🔹 CHECK WATCHED
    // ========================
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

    // ========================
    // 🔹 CLOSE CONNECTION
    // ========================
    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}