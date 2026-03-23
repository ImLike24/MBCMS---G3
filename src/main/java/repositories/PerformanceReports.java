package repositories;

import config.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Báo cáo hiệu suất — lọc theo screening_rooms.branch_id (danh sách ID đã xác thực manager ở servlet).
 * Khoảng ngày: online theo {@code bookings.payment_time} (fallback {@code booking_time});
 * quầy theo {@code counter_tickets.sold_at}.
 */
public class PerformanceReports extends DBContext {

    private static String ph(int n) {
        return String.join(",", Collections.nCopies(n, "?"));
    }

    public int countShowtimes(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        if (branchIds == null || branchIds.isEmpty()) return 0;
        String in = ph(branchIds.size());
        String sql = """
                SELECT COUNT(DISTINCT t.showtime_id) AS total_showtimes
                FROM (
                    SELECT ot.showtime_id
                    FROM online_tickets ot
                    INNER JOIN bookings bk ON ot.booking_id = bk.booking_id
                    INNER JOIN showtimes s ON ot.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND (bk.payment_status = 'PAID' OR bk.status = 'CONFIRMED')
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) >= ?
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) <= ?
                    UNION ALL
                    SELECT ct.showtime_id
                    FROM counter_tickets ct
                    INNER JOIN showtimes s ON ct.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND CAST(ct.sold_at AS DATE) >= ?
                      AND CAST(ct.sold_at AS DATE) <= ?
                ) t
                """.formatted(in, in);
        return queryInt(sql, branchIds, fromDate, toDate);
    }

    public List<BranchPerformanceRow> listShowtimesByBranch(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<BranchPerformanceRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;
        String in = ph(branchIds.size());
        String sql = """
                SELECT b.branch_id, b.branch_name,
                    COUNT(DISTINCT t.showtime_id) AS total_showtimes,
                    COUNT(*) AS total_tickets
                FROM (
                    SELECT ot.showtime_id, r.branch_id
                    FROM online_tickets ot
                    INNER JOIN bookings bk ON ot.booking_id = bk.booking_id
                    INNER JOIN showtimes s ON ot.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND (bk.payment_status = 'PAID' OR bk.status = 'CONFIRMED')
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) >= ?
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) <= ?
                    UNION ALL
                    SELECT ct.showtime_id, r.branch_id
                    FROM counter_tickets ct
                    INNER JOIN showtimes s ON ct.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND CAST(ct.sold_at AS DATE) >= ?
                      AND CAST(ct.sold_at AS DATE) <= ?
                ) t
                INNER JOIN cinema_branches b ON t.branch_id = b.branch_id
                GROUP BY b.branch_id, b.branch_name
                ORDER BY b.branch_name
                """.formatted(in, in);
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int i = 1;
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BranchPerformanceRow row = new BranchPerformanceRow();
                    row.setBranchId(rs.getInt("branch_id"));
                    row.setBranchName(rs.getString("branch_name"));
                    row.setTotalShowtimes(rs.getInt("total_showtimes"));
                    row.setTotalTicketsSold(rs.getInt("total_tickets"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTicketsSold(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        if (branchIds == null || branchIds.isEmpty()) return 0;
        String in = ph(branchIds.size());
        String sql = """
                SELECT ISNULL((
                    SELECT COUNT(*) FROM online_tickets ot
                    INNER JOIN bookings bk ON ot.booking_id = bk.booking_id
                    INNER JOIN showtimes s ON ot.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND (bk.payment_status = 'PAID' OR bk.status = 'CONFIRMED')
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) >= ?
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) <= ?
                ), 0) + ISNULL((
                    SELECT COUNT(*) FROM counter_tickets ct
                    INNER JOIN showtimes s ON ct.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    WHERE r.branch_id IN (%s)
                      AND CAST(ct.sold_at AS DATE) >= ?
                      AND CAST(ct.sold_at AS DATE) <= ?
                ), 0) AS total_tickets
                """.formatted(in, in);
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int i = 1;
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total_tickets");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<MovieTicketRow> listTopMoviesByTickets(List<Integer> branchIds,
                                                       LocalDate fromDate, LocalDate toDate) {
        List<MovieTicketRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;
        String sql = """
                SELECT m.title, COUNT(*) AS total_tickets
                FROM (
                    SELECT ot.showtime_id FROM online_tickets ot
                    INNER JOIN bookings bk ON ot.booking_id = bk.booking_id
                    WHERE (bk.payment_status = 'PAID' OR bk.status = 'CONFIRMED')
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) >= ?
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) <= ?
                    UNION ALL
                    SELECT showtime_id FROM counter_tickets ct
                    WHERE CAST(ct.sold_at AS DATE) >= ?
                      AND CAST(ct.sold_at AS DATE) <= ?
                ) t
                INNER JOIN showtimes s ON t.showtime_id = s.showtime_id
                INNER JOIN screening_rooms r ON s.room_id = r.room_id
                INNER JOIN movies m ON s.movie_id = m.movie_id
                WHERE r.branch_id IN (%s)
                GROUP BY m.movie_id, m.title ORDER BY total_tickets DESC
                """.formatted(ph(branchIds.size()));
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int i = 1;
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MovieTicketRow row = new MovieTicketRow();
                    row.setTitle(rs.getString("title"));
                    row.setTotalTickets(rs.getInt("total_tickets"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private int queryInt(String sql, List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int i = 1;
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, java.sql.Date.valueOf(fromDate));
            ps.setDate(i++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static class MovieTicketRow {
        private String title;
        private int totalTickets;
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public int getTotalTickets() { return totalTickets; }
        public void setTotalTickets(int totalTickets) { this.totalTickets = totalTickets; }
    }

    public static class BranchPerformanceRow {
        private int branchId;
        private String branchName;
        private int totalShowtimes;
        private int totalTicketsSold;
        public int getBranchId() { return branchId; }
        public void setBranchId(int branchId) { this.branchId = branchId; }
        public String getBranchName() { return branchName; }
        public void setBranchName(String branchName) { this.branchName = branchName; }
        public int getTotalShowtimes() { return totalShowtimes; }
        public void setTotalShowtimes(int totalShowtimes) { this.totalShowtimes = totalShowtimes; }
        public int getTotalTicketsSold() { return totalTicketsSold; }
        public void setTotalTicketsSold(int totalTicketsSold) { this.totalTicketsSold = totalTicketsSold; }
    }
}
