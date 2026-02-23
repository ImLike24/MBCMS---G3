package repositories;

import config.DBContext;
import models.CounterTicket;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CounterTickets extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CounterTickets.class.getName());

    /** Last SQL error message for debugging (cleared on next create call). */
    private String lastErrorMessage;

    /**
     * Create a new counter ticket
     */
    public int createCounterTicket(CounterTicket ticket) {
        lastErrorMessage = null;

        // The table has an INSTEAD OF INSERT trigger (trg_prevent_double_booking_counter).
        // With INSTEAD OF triggers, neither SCOPE_IDENTITY() nor RETURN_GENERATED_KEYS
        // can capture the identity because the actual row is inserted inside the trigger
        // body (a different scope). The only reliable approach is a plain INSERT followed
        // by a SELECT on the unique ticket_code to retrieve the generated ticket_id.
        String insertSql = "INSERT INTO counter_tickets " +
                    "(showtime_id, seat_id, ticket_type, seat_type, price, ticket_code, " +
                    "sold_by, payment_method, customer_name, customer_phone, customer_email, notes) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String selectSql = "SELECT ticket_id FROM counter_tickets WHERE ticket_code = ?";

        System.out.println("[CounterTickets] INSERT: showtimeId=" + ticket.getShowtimeId()
                + " seatId=" + ticket.getSeatId()
                + " ticketCode=" + ticket.getTicketCode()
                + " soldBy=" + ticket.getSoldBy());

        try {
            try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
                insertStmt.setInt(1, ticket.getShowtimeId());
                insertStmt.setInt(2, ticket.getSeatId());
                insertStmt.setString(3, ticket.getTicketType());
                insertStmt.setString(4, ticket.getSeatType());
                insertStmt.setBigDecimal(5, ticket.getPrice());
                insertStmt.setString(6, ticket.getTicketCode());
                insertStmt.setInt(7, ticket.getSoldBy());
                insertStmt.setString(8, ticket.getPaymentMethod());
                insertStmt.setString(9, ticket.getCustomerName());
                insertStmt.setString(10, ticket.getCustomerPhone());
                insertStmt.setString(11, ticket.getCustomerEmail());
                insertStmt.setString(12, ticket.getNotes());
                insertStmt.executeUpdate();
            }

            try (PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {
                selectStmt.setString(1, ticket.getTicketCode());
                try (ResultSet rs = selectStmt.executeQuery()) {
                    if (rs.next()) {
                        int id = rs.getInt("ticket_id");
                        System.out.println("[CounterTickets] Created ticket_id=" + id);
                        return id;
                    }
                }
            }
            System.err.println("[CounterTickets] INSERT succeeded but ticket_code not found: " + ticket.getTicketCode());
        } catch (SQLException e) {
            lastErrorMessage = e.getMessage();
            System.err.println("[CounterTickets] SQL ERROR: " + e.getMessage()
                    + " SQLState=" + e.getSQLState() + " ErrorCode=" + e.getErrorCode());
            e.printStackTrace();
        }
        return -1;
    }

    /** Returns the last SQL error message for debugging, or null. */
    public String getLastErrorMessage() {
        return lastErrorMessage;
    }

    /**
     * Generate unique ticket code
     * Format: CT-YYYYMMDD-HHMMSS-XXXXX
     */
    public String generateTicketCode() {
        LocalDateTime now = LocalDateTime.now();
        String dateTime = String.format("%04d%02d%02d-%02d%02d%02d",
            now.getYear(), now.getMonthValue(), now.getDayOfMonth(),
            now.getHour(), now.getMinute(), now.getSecond());
        
        // Get random 5-digit number
        int random = (int)(Math.random() * 90000) + 10000;
        
        return "CT-" + dateTime + "-" + random;
    }

    /**
     * Get counter ticket by ID
     */
    public CounterTicket getCounterTicketById(int ticketId) {
        String sql = "SELECT * FROM counter_tickets WHERE ticket_id = ?";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, ticketId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCounterTicket(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get counter tickets by ticket code (for receipt lookup).
     * Supports base code: finds ticket_code = ? OR ticket_code LIKE ? + '-%' so that
     * one transaction (multiple seats) stored as CT-xxx-1, CT-xxx-2 is found by base code CT-xxx.
     */
    public List<CounterTicket> getCounterTicketsByCode(String ticketCode) {
        List<CounterTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM counter_tickets WHERE ticket_code = ? OR ticket_code LIKE ? ORDER BY ticket_id";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, ticketCode);
            pstmt.setString(2, ticketCode + "-%");
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapResultSetToCounterTicket(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Get counter tickets by showtime
     */
    public List<CounterTicket> getCounterTicketsByShowtime(int showtimeId) {
        List<CounterTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM counter_tickets WHERE showtime_id = ? ORDER BY sold_at DESC";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapResultSetToCounterTicket(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Calculate total price for multiple tickets
     */
    public BigDecimal calculateTotalPrice(List<CounterTicket> tickets) {
        BigDecimal total = BigDecimal.ZERO;
        for (CounterTicket ticket : tickets) {
            total = total.add(ticket.getPrice());
        }
        return total;
    }

    /**
     * Helper method to map ResultSet to CounterTicket
     */
    private CounterTicket mapResultSetToCounterTicket(ResultSet rs) throws SQLException {
        CounterTicket ticket = new CounterTicket();
        ticket.setTicketId(rs.getInt("ticket_id"));
        ticket.setShowtimeId(rs.getInt("showtime_id"));
        ticket.setSeatId(rs.getInt("seat_id"));
        ticket.setTicketType(rs.getString("ticket_type"));
        ticket.setSeatType(rs.getString("seat_type"));
        ticket.setPrice(rs.getBigDecimal("price"));
        ticket.setTicketCode(rs.getString("ticket_code"));
        ticket.setSoldBy(rs.getInt("sold_by"));
        ticket.setPaymentMethod(rs.getString("payment_method"));
        ticket.setCustomerName(rs.getString("customer_name"));
        ticket.setCustomerPhone(rs.getString("customer_phone"));
        ticket.setCustomerEmail(rs.getString("customer_email"));
        ticket.setNotes(rs.getString("notes"));
        
        if (rs.getTimestamp("sold_at") != null) {
            ticket.setSoldAt(rs.getTimestamp("sold_at").toLocalDateTime());
        }
        
        return ticket;
    }
}
