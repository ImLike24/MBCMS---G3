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
}