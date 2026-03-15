package repositories;

import config.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

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

    /**
     * Count invoices for a user (online bookings only).
     */
    public int countInvoicesByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM invoices i INNER JOIN bookings b ON i.booking_id = b.booking_id WHERE b.user_id = ? AND i.status = 'ACTIVE'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get paged list of invoices for user, each with invoice header fields (no items yet).
     */
    public List<Map<String, Object>> getInvoicesByUserId(int userId, int offset, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
                SELECT i.invoice_id, i.invoice_code, i.created_at, i.total_amount, i.discount_amount, i.final_amount,
                       i.payment_method, i.branch_id, cb.branch_name, b.booking_code
                FROM invoices i
                INNER JOIN bookings b ON i.booking_id = b.booking_id
                LEFT JOIN cinema_branches cb ON i.branch_id = cb.branch_id
                WHERE b.user_id = ? AND i.status = 'ACTIVE'
                ORDER BY i.created_at DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("invoiceId", rs.getInt("invoice_id"));
                    row.put("invoiceCode", rs.getString("invoice_code"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    row.put("totalAmount", rs.getBigDecimal("total_amount"));
                    row.put("discountAmount", rs.getBigDecimal("discount_amount"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("branchName", rs.getString("branch_name"));
                    row.put("bookingCode", rs.getString("booking_code"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get invoice items (ticket details) for given invoice IDs. Returns map: invoiceId -> list of item maps.
     */
    public Map<Integer, List<Map<String, Object>>> getInvoiceItemsByInvoiceIds(List<Integer> invoiceIds) {
        Map<Integer, List<Map<String, Object>>> result = new HashMap<>();
        if (invoiceIds == null || invoiceIds.isEmpty()) return result;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < invoiceIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        String sql = "SELECT invoice_id, item_description, movie_title, showtime_date, showtime_time, room_name, seat_code, ticket_type, seat_type, quantity, unit_price, amount FROM invoice_items WHERE invoice_id IN (" + placeholders + ") ORDER BY invoice_id, item_id";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            for (int i = 0; i < invoiceIds.size(); i++) {
                ps.setInt(i + 1, invoiceIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int invId = rs.getInt("invoice_id");
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("itemDescription", rs.getString("item_description"));
                    item.put("movieTitle", rs.getString("movie_title"));
                    item.put("showtimeDate", rs.getDate("showtime_date"));
                    item.put("showtimeTime", rs.getTime("showtime_time"));
                    item.put("roomName", rs.getString("room_name"));
                    item.put("seatCode", rs.getString("seat_code"));
                    item.put("ticketType", rs.getString("ticket_type"));
                    item.put("seatType", rs.getString("seat_type"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("unitPrice", rs.getBigDecimal("unit_price"));
                    item.put("amount", rs.getBigDecimal("amount"));
                    result.computeIfAbsent(invId, k -> new ArrayList<>()).add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public void closeConnection() {
        super.closeConnection();
    }
}
