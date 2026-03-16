package repositories;

import config.DBContext;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;
import java.sql.Connection;
import java.sql.SQLException;
import models.OnlineTicket;

public class OnlineTickets extends DBContext {
    
    private Connection conn;

    public OnlineTickets(Connection conn) {
        this.conn = conn;
    }

    public String generateETicketCode() {
        LocalDateTime now = LocalDateTime.now();
        String dateTime = String.format("%04d%02d%02d-%02d%02d%02d",
                now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
                now.getHour(), now.getMinute(), now.getSecond());
        int random = (int) (Math.random() * 90000) + 10000;
        return "ET-" + dateTime + "-" + random;
    }

    public void insertOnlineTicket(OnlineTicket ticket) throws SQLException {

        String sql = """
        INSERT INTO online_tickets
        (booking_id, showtime_id, seat_id, ticket_type, seat_type, price)
        VALUES (?,?,?,?,?,?)
        """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticket.getBookingId());
            ps.setInt(2, ticket.getShowtimeId());
            ps.setInt(3, ticket.getSeatId());
            ps.setString(4, ticket.getTicketType());
            ps.setString(5, ticket.getSeatType());
            ps.setBigDecimal(6, ticket.getPrice());

            ps.executeUpdate();
        }
    }
}
