package repositories;

import config.DBContext;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class OnlineTickets extends DBContext {

    public String generateETicketCode() {
        LocalDateTime now = LocalDateTime.now();
        String dateTime = String.format("%04d%02d%02d-%02d%02d%02d",
                now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
                now.getHour(), now.getMinute(), now.getSecond());
        int random = (int) (Math.random() * 90000) + 10000;
        return "ET-" + dateTime + "-" + random;
    }

    public void insertOnlineTicket(Integer bookingId, Integer showtimeId, Integer seatId,
                                   String ticketType, String seatType, BigDecimal price) throws SQLException {
        String sql = "INSERT INTO online_tickets " +
                "(booking_id, showtime_id, seat_id, ticket_type, seat_type, price, e_ticket_code, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, bookingId);
            stmt.setInt(2, showtimeId);
            stmt.setInt(3, seatId);
            stmt.setString(4, ticketType);
            stmt.setString(5, seatType);
            stmt.setBigDecimal(6, price);
            stmt.setString(7, generateETicketCode());
            stmt.setTimestamp(8, java.sql.Timestamp.valueOf(LocalDateTime.now()));
            stmt.executeUpdate();
        }
    }
}
