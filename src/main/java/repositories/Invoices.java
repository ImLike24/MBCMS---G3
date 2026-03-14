package repositories;

import config.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class Invoices extends DBContext {

    public Invoices() {
        super();
    }

    public String generateInvoiceCode() {
        String datePart = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = new Random().nextInt(900) + 100;
        return "INV-" + datePart + "-" + random;
    }

    /**
     * Insert invoice and return generated invoice_id.
     */
    public int insertInvoice(int bookingId, String invoiceCode, String saleChannel,
                             String customerName, String customerPhone, String customerEmail,
                             int branchId, java.math.BigDecimal totalAmount, java.math.BigDecimal discountAmount,
                             java.math.BigDecimal finalAmount, String paymentMethod, int createdBy, String notes)
            throws SQLException {
        String sql = """
                INSERT INTO invoices
                (invoice_code, booking_id, sale_channel, customer_name, customer_phone, customer_email,
                 branch_id, total_amount, discount_amount, final_amount, payment_method, payment_status,
                 status, created_by, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PAID', 'ACTIVE', ?, ?, SYSDATETIME(), SYSDATETIME())
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, invoiceCode);
            ps.setInt(2, bookingId);
            ps.setString(3, saleChannel);
            ps.setString(4, customerName != null ? customerName : "");
            ps.setString(5, customerPhone != null ? customerPhone : "");
            ps.setString(6, customerEmail != null ? customerEmail : "");
            ps.setInt(7, branchId);
            ps.setBigDecimal(8, totalAmount);
            ps.setBigDecimal(9, discountAmount != null ? discountAmount : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(10, finalAmount);
            ps.setString(11, paymentMethod);
            ps.setInt(12, createdBy);
            ps.setString(13, notes);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Insert invoice item for an online ticket.
     */
    public void insertInvoiceItem(int invoiceId, int onlineTicketId, String itemDescription,
                                  String movieTitle, LocalDate showtimeDate, LocalTime showtimeTime,
                                  String roomName, String seatCode, String ticketType, String seatType,
                                  java.math.BigDecimal unitPrice, java.math.BigDecimal amount) throws SQLException {
        String sql = """
                INSERT INTO invoice_items
                (invoice_id, item_type, online_ticket_id, item_description, movie_title, showtime_date,
                 showtime_time, room_name, seat_code, ticket_type, seat_type, quantity, unit_price, amount)
                VALUES (?, 'ONLINE_TICKET', ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ps.setInt(2, onlineTicketId);
            ps.setString(3, itemDescription);
            ps.setString(4, movieTitle);
            ps.setDate(5, showtimeDate != null ? java.sql.Date.valueOf(showtimeDate) : null);
            ps.setTime(6, showtimeTime != null ? java.sql.Time.valueOf(showtimeTime) : null);
            ps.setString(7, roomName);
            ps.setString(8, seatCode);
            ps.setString(9, ticketType);
            ps.setString(10, seatType);
            ps.setBigDecimal(11, unitPrice);
            ps.setBigDecimal(12, amount);
            ps.executeUpdate();
        }
    }

    public void closeConnection() {
        super.closeConnection();
    }
}
