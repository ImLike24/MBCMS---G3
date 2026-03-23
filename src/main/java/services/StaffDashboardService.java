package services;

import config.DBContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Provides dashboard data scoped to a specific cinema branch (for staff view).
 */
public class StaffDashboardService extends DBContext {

    private final int branchId;

    public StaffDashboardService(int branchId) {
        this.branchId = branchId;
    }

    /** Counter tickets sold today at this branch, grouped by hour. */
    public List<Map<String, Object>> getTicketsByHourToday() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
                SELECT DATEPART(HOUR, ct.sold_at) AS hour_slot, COUNT(*) AS cnt
                FROM counter_tickets ct
                JOIN showtimes s ON ct.showtime_id = s.showtime_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id = ?
                  AND CAST(ct.sold_at AS DATE) = CAST(GETDATE() AS DATE)
                GROUP BY DATEPART(HOUR, ct.sold_at)
                ORDER BY hour_slot
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("hour", rs.getInt("hour_slot"));
                    row.put("count", rs.getInt("cnt"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Revenue per day for the last 7 days at this branch (counter tickets only). */
    public List<Map<String, Object>> getRevenueLast7Days() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
                SELECT CAST(ct.sold_at AS DATE) AS sale_date, SUM(ct.price) AS revenue
                FROM counter_tickets ct
                JOIN showtimes s ON ct.showtime_id = s.showtime_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id = ?
                  AND ct.sold_at >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE))
                GROUP BY CAST(ct.sold_at AS DATE)
                ORDER BY sale_date
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("date", rs.getDate("sale_date").toString());
                    row.put("revenue", rs.getDouble("revenue"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Top 5 movies by tickets sold (counter) at this branch (all time). */
    public List<Map<String, Object>> getTopMoviesByTickets() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
                SELECT TOP 5 m.title, COUNT(ct.ticket_id) AS tickets
                FROM counter_tickets ct
                JOIN showtimes s ON ct.showtime_id = s.showtime_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                JOIN movies m ON s.movie_id = m.movie_id
                WHERE sr.branch_id = ?
                GROUP BY m.title
                ORDER BY tickets DESC
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("title", rs.getString("title"));
                    row.put("tickets", rs.getInt("tickets"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Today's showtimes at this branch with seat availability. */
    public List<Map<String, Object>> getTodayShowtimes() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
                SELECT s.showtime_id, m.title AS movie_title,
                       s.start_time, s.end_time, s.status,
                       sr.room_name,
                       (SELECT COUNT(*) FROM seats se WHERE se.room_id = sr.room_id) AS total_seats,
                       (SELECT COUNT(*) FROM counter_tickets ct2 WHERE ct2.showtime_id = s.showtime_id) AS sold_counter,
                       (SELECT COUNT(*) FROM online_tickets ot2 WHERE ot2.showtime_id = s.showtime_id) AS sold_online
                FROM showtimes s
                JOIN movies m ON s.movie_id = m.movie_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id = ?
                  AND s.show_date = CAST(GETDATE() AS DATE)
                ORDER BY s.start_time
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("showtimeId", rs.getInt("showtime_id"));
                    row.put("movieTitle", rs.getString("movie_title"));
                    row.put("startTime", rs.getString("start_time"));
                    row.put("endTime", rs.getString("end_time"));
                    row.put("status", rs.getString("status"));
                    row.put("roomName", rs.getString("room_name"));
                    int total = rs.getInt("total_seats");
                    int soldCounter = rs.getInt("sold_counter");
                    int soldOnline = rs.getInt("sold_online");
                    int sold = soldCounter + soldOnline;
                    row.put("totalSeats", total);
                    row.put("soldSeats", sold);
                    row.put("availableSeats", Math.max(0, total - sold));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Recent 10 counter ticket transactions at this branch. */
    public List<Map<String, Object>> getRecentTransactions() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
                SELECT TOP 10
                    ct.ticket_id, m.title AS movie_title,
                    ct.customer_name, ct.customer_phone,
                    ct.seat_id, ct.ticket_type, ct.seat_type,
                    ct.price, ct.payment_method, ct.sold_at
                FROM counter_tickets ct
                JOIN showtimes s ON ct.showtime_id = s.showtime_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                JOIN movies m ON s.movie_id = m.movie_id
                WHERE sr.branch_id = ?
                ORDER BY ct.sold_at DESC
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("ticketId", rs.getInt("ticket_id"));
                    row.put("movieTitle", rs.getString("movie_title"));
                    String cName = rs.getString("customer_name");
                    row.put("customerName", cName != null && !cName.isBlank() ? cName : "Khách vãng lai");
                    row.put("customerPhone", rs.getString("customer_phone"));
                    row.put("ticketType", rs.getString("ticket_type"));
                    row.put("seatType", rs.getString("seat_type"));
                    row.put("price", rs.getDouble("price"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    if (rs.getTimestamp("sold_at") != null) {
                        java.time.LocalDateTime ldt = rs.getTimestamp("sold_at").toLocalDateTime();
                        row.put("soldAt", ldt.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy")));
                    } else {
                        row.put("soldAt", "");
                    }
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Summary totals for today at this branch. */
    public Map<String, Object> getTodaySummary() {
        Map<String, Object> summary = new LinkedHashMap<>();
        String sql = """
                SELECT COUNT(*) AS tickets_sold, ISNULL(SUM(ct.price), 0) AS revenue
                FROM counter_tickets ct
                JOIN showtimes s ON ct.showtime_id = s.showtime_id
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id = ?
                  AND CAST(ct.sold_at AS DATE) = CAST(GETDATE() AS DATE)
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("ticketsSoldToday", rs.getInt("tickets_sold"));
                    summary.put("revenueToday", rs.getDouble("revenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Count today's showtimes
        String sqlShowtimes = """
                SELECT COUNT(*) AS cnt FROM showtimes s
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id = ? AND s.show_date = CAST(GETDATE() AS DATE)
                """;
        try (PreparedStatement ps = connection.prepareStatement(sqlShowtimes)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) summary.put("showtimesToday", rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return summary;
    }
}
