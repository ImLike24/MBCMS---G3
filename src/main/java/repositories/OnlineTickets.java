package repositories;

import config.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.sql.Connection;
import java.sql.SQLException;
import models.OnlineTicket;

public class OnlineTickets extends DBContext {

    /**
     * Insert online ticket and return generated ticket_id.
     */
    public int insertOnlineTicket(Integer bookingId, Integer showtimeId, Integer seatId,
                                   String ticketType, String seatType, BigDecimal price) throws SQLException {
        String sql = "INSERT INTO online_tickets " +
                "(booking_id, showtime_id, seat_id, ticket_type, seat_type, price, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, bookingId);
            stmt.setInt(2, showtimeId);
            stmt.setInt(3, seatId);
            stmt.setString(4, ticketType);
            stmt.setString(5, seatType);
            stmt.setBigDecimal(6, price);
            stmt.setTimestamp(7, java.sql.Timestamp.valueOf(LocalDateTime.now()));
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }
}
