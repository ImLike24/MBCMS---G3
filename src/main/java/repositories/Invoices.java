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
        return countInvoicesByUserIdInRange(userId, null, null);
    }

    /**
     * Count invoices for a user in a time range (created_at between [from, to)).
     * from/to = null nghĩa là không giới hạn đầu/cuối.
     */
    public int countInvoicesByUserIdInRange(int userId, LocalDateTime from, LocalDateTime to) {
        return countInvoicesByUserIdInRange(userId, from, to, null);
    }

    /**
     * Count invoices for a user in a time range, optionally filtered by movie title (invoice_items.movie_title).
     * movieTitle = null or blank means no movie filter.
     */
    public int countInvoicesByUserIdInRange(int userId, LocalDateTime from, LocalDateTime to, String movieTitle) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM invoices i INNER JOIN bookings b ON i.booking_id = b.booking_id " +
                        "WHERE b.user_id = ? AND i.status = 'ACTIVE'");
        if (from != null) {
            sql.append(" AND i.created_at >= ?");
        }
        if (to != null) {
            sql.append(" AND i.created_at < ?");
        }
        if (movieTitle != null && !movieTitle.isBlank()) {
            sql.append(" AND EXISTS (SELECT 1 FROM invoice_items ii WHERE ii.invoice_id = i.invoice_id AND ii.movie_title = ?)");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (from != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(from));
            }
            if (to != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(to));
            }
            if (movieTitle != null && !movieTitle.isBlank()) {
                ps.setString(idx++, movieTitle.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get distinct movie titles that appear in this user's invoice items (for filter dropdown).
     */
    public List<String> getDistinctMovieTitlesByUserId(int userId) {
        List<String> list = new ArrayList<>();
        String sql = """
                SELECT DISTINCT ii.movie_title
                FROM invoice_items ii
                INNER JOIN invoices i ON ii.invoice_id = i.invoice_id
                INNER JOIN bookings b ON i.booking_id = b.booking_id
                WHERE b.user_id = ? AND i.status = 'ACTIVE' AND ii.movie_title IS NOT NULL AND ii.movie_title != ''
                ORDER BY ii.movie_title
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("movie_title"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get paged list of invoices for user, each with invoice header fields (no items yet).
     */
    public List<Map<String, Object>> getInvoicesByUserId(int userId, int offset, int limit) {
        return getInvoicesByUserIdInRange(userId, offset, limit, null, null);
    }

    /**
     * Get paged list of invoices in a time range.
     */
    public List<Map<String, Object>> getInvoicesByUserIdInRange(int userId, int offset, int limit,
                                                                LocalDateTime from, LocalDateTime to) {
        return getInvoicesByUserIdInRange(userId, offset, limit, from, to, null);
    }

    /**
     * Get paged list of invoices in a time range, optionally filtered by movie title.
     * movieTitle = null or blank means no movie filter.
     */
    public List<Map<String, Object>> getInvoicesByUserIdInRange(int userId, int offset, int limit,
                                                                LocalDateTime from, LocalDateTime to, String movieTitle) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                SELECT i.invoice_id, i.invoice_code, i.created_at, i.total_amount, i.discount_amount, i.final_amount,
                       i.payment_method, i.branch_id, cb.branch_name, b.booking_code
                FROM invoices i
                INNER JOIN bookings b ON i.booking_id = b.booking_id
                LEFT JOIN cinema_branches cb ON i.branch_id = cb.branch_id
                WHERE b.user_id = ? AND i.status = 'ACTIVE'
                """);
        if (from != null) {
            sql.append(" AND i.created_at >= ?");
        }
        if (to != null) {
            sql.append(" AND i.created_at < ?");
        }
        if (movieTitle != null && !movieTitle.isBlank()) {
            sql.append(" AND EXISTS (SELECT 1 FROM invoice_items ii WHERE ii.invoice_id = i.invoice_id AND ii.movie_title = ?)");
        }
        sql.append(" ORDER BY i.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (from != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(from));
            }
            if (to != null) {
                ps.setTimestamp(idx++, Timestamp.valueOf(to));
            }
            if (movieTitle != null && !movieTitle.isBlank()) {
                ps.setString(idx++, movieTitle.trim());
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);

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
     * Get booking_id for an invoice (to fallback load items from online_tickets when invoice_items is empty).
     */
    public Integer getBookingIdByInvoiceId(int invoiceId) {
        String sql = "SELECT booking_id FROM invoices WHERE invoice_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("booking_id");
                    return rs.wasNull() ? null : id;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get ticket details for a booking (from online_tickets + showtimes/movies/rooms/seats) for backfilling invoice_items.
     */
    public List<Map<String, Object>> getTicketDetailsByBookingId(int bookingId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
                SELECT ot.ticket_id, ot.ticket_type, ot.seat_type, ot.price,
                       st.show_date AS showtime_date, st.start_time AS showtime_time,
                       m.title AS movie_title, sr.room_name,
                       s.seat_code, s.row_number AS seat_row, s.seat_number AS seat_col
                FROM online_tickets ot
                INNER JOIN showtimes st ON ot.showtime_id = st.showtime_id
                INNER JOIN movies m ON st.movie_id = m.movie_id
                INNER JOIN screening_rooms sr ON st.room_id = sr.room_id
                INNER JOIN seats s ON ot.seat_id = s.seat_id
                WHERE ot.booking_id = ?
                ORDER BY ot.ticket_id
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("ticketId", rs.getInt("ticket_id"));
                    row.put("movieTitle", rs.getString("movie_title"));
                    row.put("showtimeDate", rs.getDate("showtime_date")); // alias from st.show_date
                    row.put("showtimeTime", rs.getTime("showtime_time")); // alias from st.start_time
                    row.put("roomName", rs.getString("room_name"));
                    row.put("seatCode", rs.getString("seat_code"));
                    row.put("ticketType", rs.getString("ticket_type"));
                    row.put("seatType", rs.getString("seat_type"));
                    java.math.BigDecimal price = rs.getBigDecimal("price");
                    row.put("unitPrice", price);
                    row.put("amount", price);
                    row.put("seatRow", rs.getString("seat_row"));
                    Object sc = rs.getObject("seat_col");
                    row.put("seatCol", sc != null ? rs.getInt("seat_col") : null);
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get invoice items (ticket details) for a single invoice from invoice_items table.
     */
    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(int invoiceId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
                SELECT ii.invoice_id, ii.item_description, ii.movie_title, ii.showtime_date, ii.showtime_time,
                       ii.room_name, ii.seat_code, ii.ticket_type, ii.seat_type, ii.quantity, ii.unit_price, ii.amount,
                       s.row_number AS seat_row, s.seat_number AS seat_col
                FROM invoice_items ii
                LEFT JOIN online_tickets ot ON ii.online_ticket_id = ot.ticket_id
                LEFT JOIN seats s ON ot.seat_id = s.seat_id
                WHERE ii.invoice_id = ? AND ii.item_type = 'ONLINE_TICKET'
                ORDER BY ii.item_id
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("itemDescription", rs.getString("item_description"));
                    item.put("movieTitle", rs.getString("movie_title"));
                    item.put("showtimeDate", rs.getDate("showtime_date"));
                    item.put("showtimeTime", rs.getTime("showtime_time"));
                    item.put("roomName", rs.getString("room_name"));
                    item.put("seatCode", rs.getString("seat_code"));
                    item.put("ticketType", rs.getString("ticket_type"));
                    item.put("seatType", rs.getString("seat_type"));
                    String rowNum = rs.getString("seat_row");
                    Integer colNum = rs.getObject("seat_col") != null ? rs.getInt("seat_col") : null;
                    item.put("seatRow", rowNum);
                    item.put("seatCol", colNum);
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("unitPrice", rs.getBigDecimal("unit_price"));
                    item.put("amount", rs.getBigDecimal("amount"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get or build invoice items: from invoice_items if present, else from online_tickets and backfill invoice_items.
     */
    public List<Map<String, Object>> getOrBuildInvoiceItemsForInvoice(int invoiceId) {
        List<Map<String, Object>> items = getInvoiceItemsByInvoiceId(invoiceId);
        if (items != null && !items.isEmpty()) return items;

        Integer bookingId = getBookingIdByInvoiceId(invoiceId);
        if (bookingId == null) return new ArrayList<>();

        List<Map<String, Object>> tickets = getTicketDetailsByBookingId(bookingId);
        if (tickets.isEmpty()) return new ArrayList<>();

        for (Map<String, Object> t : tickets) {
            int ticketId = ((Number) t.get("ticketId")).intValue();
            String movieTitle = (String) t.get("movieTitle");
            String roomName = (String) t.get("roomName");
            String seatCode = (String) t.get("seatCode");
            String ticketType = (String) t.get("ticketType");
            String seatType = (String) t.get("seatType");
            java.math.BigDecimal price = (java.math.BigDecimal) t.get("unitPrice");
            if (price == null) price = java.math.BigDecimal.ZERO;
            java.sql.Date sd = (java.sql.Date) t.get("showtimeDate");
            java.sql.Time st = (java.sql.Time) t.get("showtimeTime");
            LocalDate showtimeDate = sd != null ? sd.toLocalDate() : null;
            LocalTime showtimeTime = st != null ? st.toLocalTime() : null;
            String itemDesc = (movieTitle != null ? movieTitle : "") + " - " + (seatType != null ? seatType : "") + " - " + (seatCode != null ? seatCode : "");
            try {
                insertInvoiceItem(invoiceId, ticketId, itemDesc, movieTitle, showtimeDate, showtimeTime,
                        roomName, seatCode, ticketType, seatType, price, price);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return buildItemListFromTickets(tickets);
    }

    private List<Map<String, Object>> buildItemListFromTickets(List<Map<String, Object>> tickets) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> t : tickets) {
            Map<String, Object> item = new LinkedHashMap<>();
            String movieTitle = (String) t.get("movieTitle");
            String seatType = (String) t.get("seatType");
            String seatCode = (String) t.get("seatCode");
            item.put("itemDescription", (movieTitle != null ? movieTitle : "") + " - " + (seatType != null ? seatType : "") + " - " + (seatCode != null ? seatCode : ""));
            item.put("movieTitle", movieTitle);
            item.put("showtimeDate", t.get("showtimeDate"));
            item.put("showtimeTime", t.get("showtimeTime"));
            item.put("roomName", t.get("roomName"));
            item.put("seatCode", seatCode);
            item.put("ticketType", t.get("ticketType"));
            item.put("seatType", seatType);
            item.put("seatRow", t.get("seatRow"));
            item.put("seatCol", t.get("seatCol"));
            item.put("quantity", 1);
            item.put("unitPrice", t.get("unitPrice"));
            item.put("amount", t.get("amount"));
            list.add(item);
        }
        return list;
    }

    /**
     * Get invoice items (ticket details) for given invoice IDs. Uses getOrBuild so missing invoice_items are backfilled from online_tickets.
     */
    public Map<Integer, List<Map<String, Object>>> getInvoiceItemsByInvoiceIds(List<Integer> invoiceIds) {
        Map<Integer, List<Map<String, Object>>> result = new HashMap<>();
        if (invoiceIds == null || invoiceIds.isEmpty()) return result;
        for (Integer invId : invoiceIds) {
            if (invId != null) {
                result.put(invId, getOrBuildInvoiceItemsForInvoice(invId));
            }
        }
        return result;
    }

    public void closeConnection() {
        super.closeConnection();
    }
}
