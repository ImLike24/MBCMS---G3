package repositories;

import config.DBContext;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Booking history for customer (online bookings only).
 *
 * Replaces invoice/invoice_items usage by reading directly from:
 * - bookings (header)
 * - online_tickets (per seat detail)
 */
public class BookingHistories extends DBContext {

    private static String buildPlaceholders(int count) {
        return String.join(",", Collections.nCopies(count, "?"));
    }

    public List<String> getDistinctMovieTitlesByUserId(int userId) {
        List<String> list = new ArrayList<>();
        String sql = """
                SELECT DISTINCT m.title
                FROM bookings b
                INNER JOIN showtimes st ON b.showtime_id = st.showtime_id
                INNER JOIN movies m ON st.movie_id = m.movie_id
                WHERE b.user_id = ?
                  AND b.status = 'CONFIRMED'
                  AND b.payment_status = 'PAID'
                  AND m.title IS NOT NULL
                  AND m.title <> ''
                ORDER BY m.title
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("title"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countBookingsByUserIdInRange(int userId,
                                              LocalDateTime from,
                                              LocalDateTime to,
                                              String movieTitle) {
        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*)
                FROM bookings b
                INNER JOIN showtimes st ON b.showtime_id = st.showtime_id
                INNER JOIN movies m ON st.movie_id = m.movie_id
                WHERE b.user_id = ?
                  AND b.status = 'CONFIRMED'
                  AND b.payment_status = 'PAID'
                """);

        if (from != null) sql.append(" AND b.payment_time >= ?");
        if (to != null) sql.append(" AND b.payment_time < ?");
        if (movieTitle != null && !movieTitle.isBlank()) sql.append(" AND m.title = ?");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (from != null) ps.setTimestamp(idx++, Timestamp.valueOf(from));
            if (to != null) ps.setTimestamp(idx++, Timestamp.valueOf(to));
            if (movieTitle != null && !movieTitle.isBlank()) ps.setString(idx++, movieTitle.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getBookingsByUserIdInRange(int userId,
                                                                  int offset,
                                                                  int limit,
                                                                  LocalDateTime from,
                                                                  LocalDateTime to,
                                                                  String movieTitle) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
                SELECT
                    b.booking_id,
                    b.booking_code,
                    b.total_amount,
                    b.discount_amount,
                    b.final_amount,
                    b.payment_method,
                    b.payment_time,
                    cb.branch_name
                FROM bookings b
                INNER JOIN showtimes st ON b.showtime_id = st.showtime_id
                INNER JOIN screening_rooms sr ON st.room_id = sr.room_id
                INNER JOIN cinema_branches cb ON sr.branch_id = cb.branch_id
                INNER JOIN movies m ON st.movie_id = m.movie_id
                WHERE b.user_id = ?
                  AND b.status = 'CONFIRMED'
                  AND b.payment_status = 'PAID'
                """);

        if (from != null) sql.append(" AND b.payment_time >= ?");
        if (to != null) sql.append(" AND b.payment_time < ?");
        if (movieTitle != null && !movieTitle.isBlank()) sql.append(" AND m.title = ?");

        sql.append(" ORDER BY b.payment_time DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (from != null) ps.setTimestamp(idx++, Timestamp.valueOf(from));
            if (to != null) ps.setTimestamp(idx++, Timestamp.valueOf(to));
            if (movieTitle != null && !movieTitle.isBlank()) ps.setString(idx++, movieTitle.trim());

            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("bookingId", rs.getInt("booking_id"));
                    row.put("bookingCode", rs.getString("booking_code"));
                    row.put("totalAmount", rs.getBigDecimal("total_amount"));
                    row.put("discountAmount", rs.getBigDecimal("discount_amount"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("createdAt", rs.getTimestamp("payment_time"));
                    row.put("branchName", rs.getString("branch_name"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getSeatItemsByBookingIds(List<Integer> bookingIds) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (bookingIds == null || bookingIds.isEmpty()) return list;

        String sql = """
                SELECT
                    b.booking_id,
                    CONCAT(b.booking_code, '-', ot.ticket_id) AS bookingSeatCode,
                    m.title AS movieTitle,
                    st.show_date AS showtimeDate,
                    st.start_time AS showtimeTime,
                    sr.room_name AS roomName,
                    s.seat_code AS seatCode,
                    s.row_number AS seatRow,
                    s.seat_number AS seatCol,
                    ot.ticket_type AS ticketType,
                    ot.seat_type AS seatType,
                    ot.price AS unitPrice,
                    ot.price AS amount
                FROM bookings b
                INNER JOIN online_tickets ot ON ot.booking_id = b.booking_id
                INNER JOIN showtimes st ON b.showtime_id = st.showtime_id
                INNER JOIN movies m ON st.movie_id = m.movie_id
                INNER JOIN screening_rooms sr ON st.room_id = sr.room_id
                INNER JOIN seats s ON ot.seat_id = s.seat_id
                WHERE b.booking_id IN (%s)
                ORDER BY b.booking_id, ot.ticket_id
                """.formatted(buildPlaceholders(bookingIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            for (int i = 0; i < bookingIds.size(); i++) {
                ps.setInt(i + 1, bookingIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("bookingId", rs.getInt("booking_id"));
                    row.put("bookingSeatCode", rs.getString("bookingSeatCode"));
                    row.put("movieTitle", rs.getString("movieTitle"));
                    row.put("showtimeDate", rs.getDate("showtimeDate"));
                    row.put("showtimeTime", rs.getTime("showtimeTime"));
                    row.put("roomName", rs.getString("roomName"));
                    row.put("seatCode", rs.getString("seatCode"));
                    row.put("seatRow", rs.getString("seatRow"));
                    Object sc = rs.getObject("seatCol");
                    row.put("seatCol", sc != null ? rs.getInt("seatCol") : null);
                    row.put("ticketType", rs.getString("ticketType"));
                    row.put("seatType", rs.getString("seatType"));
                    BigDecimal unitPrice = rs.getBigDecimal("unitPrice");
                    row.put("unitPrice", unitPrice != null ? unitPrice : BigDecimal.ZERO);
                    BigDecimal amount = rs.getBigDecimal("amount");
                    row.put("amount", amount != null ? amount : BigDecimal.ZERO);
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}
