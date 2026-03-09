/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package repositories;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

import java.math.BigDecimal;

import config.DBContext; // Đảm bảo bạn đã có DBContext

public class Bookings {

    private Connection conn;

    public Bookings() throws Exception {
        conn = new DBContext().getConnection();
    }

    // ==============================
    // Generate booking code
    // Format: BK20260305123045XYZ
    // ==============================
    public String generateBookingCode() {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));

        int randomNumber = new Random().nextInt(900) + 100; // 100-999

        return "BK" + timestamp + randomNumber;
    }

    // ==========================================
    // Create Online Booking (Initial PENDING)
    // ==========================================
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
                        ?, 'PAID', 'CONFIRMED', SYSDATETIME())
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

    // ==============================
    // Close connection
    // ==============================
    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
