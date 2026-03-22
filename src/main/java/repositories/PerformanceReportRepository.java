package repositories;

import config.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Repository for performance report queries (movie, room, operational, seat occupancy).
 */
public class PerformanceReportRepository extends DBContext {

    public PerformanceReportRepository() {
        super();
    }

    private static String buildPlaceholders(int count) {
        return String.join(",", Collections.nCopies(count, "?"));
    }

    /**
     * Movie performance: showtimes count, tickets sold, revenue per movie.
     */
    public List<MoviePerformanceRow> getMoviePerformance(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<MoviePerformanceRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                SELECT m.title AS movie_title,
                       COUNT(DISTINCT s.showtime_id) AS showtimes_count,
                       SUM(COALESCE(online_t.cnt, 0) + COALESCE(counter_t.cnt, 0)) AS tickets_sold,
                       SUM(COALESCE(online_t.rev, 0) + COALESCE(counter_t.rev, 0)) AS revenue
                FROM showtimes s
                INNER JOIN movies m ON s.movie_id = m.movie_id
                INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                LEFT JOIN (
                    SELECT ot.showtime_id, COUNT(*) AS cnt, SUM(ot.price) AS rev
                    FROM online_tickets ot
                    INNER JOIN bookings b ON ot.booking_id = b.booking_id
                    WHERE b.status = 'CONFIRMED' AND b.payment_status = 'PAID'
                    GROUP BY ot.showtime_id
                ) online_t ON online_t.showtime_id = s.showtime_id
                LEFT JOIN (
                    SELECT showtime_id, COUNT(*) AS cnt, SUM(price) AS rev
                    FROM counter_tickets GROUP BY showtime_id
                ) counter_t ON counter_t.showtime_id = s.showtime_id
                WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                GROUP BY m.movie_id, m.title
                ORDER BY revenue DESC
                """.formatted(ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) ps.setInt(idx++, bid);
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MoviePerformanceRow row = new MoviePerformanceRow();
                    row.setMovieTitle(rs.getString("movie_title"));
                    row.setShowtimesCount(rs.getInt("showtimes_count"));
                    row.setTicketsSold(rs.getInt("tickets_sold"));
                    row.setRevenue(rs.getBigDecimal("revenue"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Operational report: total showtimes, completed, cancelled, total tickets.
     */
    public OperationalRow getOperationalReport(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        OperationalRow row = new OperationalRow();
        if (branchIds == null || branchIds.isEmpty()) return row;

        String ph = buildPlaceholders(branchIds.size());

        String sql = """
                SELECT
                    COUNT(DISTINCT s.showtime_id) AS total_showtimes,
                    SUM(CASE WHEN s.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_showtimes,
                    SUM(CASE WHEN s.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_showtimes,
                    (SELECT COUNT(*) FROM online_tickets ot
                     INNER JOIN bookings b ON ot.booking_id = b.booking_id
                     INNER JOIN showtimes st ON ot.showtime_id = st.showtime_id
                     INNER JOIN screening_rooms sr2 ON st.room_id = sr2.room_id
                     WHERE sr2.branch_id IN (%s) AND st.show_date >= ? AND st.show_date <= ?
                     AND b.status = 'CONFIRMED' AND b.payment_status = 'PAID') +
                    (SELECT COUNT(*) FROM counter_tickets ct
                     INNER JOIN showtimes st ON ct.showtime_id = st.showtime_id
                     INNER JOIN screening_rooms sr2 ON st.room_id = sr2.room_id
                     WHERE sr2.branch_id IN (%s) AND st.show_date >= ? AND st.show_date <= ?) AS total_tickets
                FROM showtimes s
                INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                """.formatted(ph, ph, ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (int i = 0; i < 3; i++) {
                for (Integer bid : branchIds) ps.setInt(idx++, bid);
                ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
                ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    row.setTotalShowtimes(rs.getInt("total_showtimes"));
                    row.setCompletedShowtimes(rs.getInt("completed_showtimes"));
                    row.setCancelledShowtimes(rs.getInt("cancelled_showtimes"));
                    row.setTotalTickets(rs.getInt("total_tickets"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return row;
    }

    /**
     * Screening room performance: room name, showtimes, tickets, revenue.
     */
    public List<RoomPerformanceRow> getScreeningRoomPerformance(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<RoomPerformanceRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                SELECT sr.room_name, sr.branch_id,
                       COUNT(DISTINCT s.showtime_id) AS showtimes_count,
                       SUM(COALESCE(online_t.cnt, 0) + COALESCE(counter_t.cnt, 0)) AS tickets_sold,
                       SUM(COALESCE(online_t.rev, 0) + COALESCE(counter_t.rev, 0)) AS revenue
                FROM showtimes s
                INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                LEFT JOIN (
                    SELECT ot.showtime_id, COUNT(*) AS cnt, SUM(ot.price) AS rev
                    FROM online_tickets ot INNER JOIN bookings b ON ot.booking_id = b.booking_id
                    WHERE b.status = 'CONFIRMED' AND b.payment_status = 'PAID'
                    GROUP BY ot.showtime_id
                ) online_t ON online_t.showtime_id = s.showtime_id
                LEFT JOIN (
                    SELECT showtime_id, COUNT(*) AS cnt, SUM(price) AS rev
                    FROM counter_tickets GROUP BY showtime_id
                ) counter_t ON counter_t.showtime_id = s.showtime_id
                WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                GROUP BY sr.room_id, sr.room_name, sr.branch_id
                ORDER BY revenue DESC
                """.formatted(ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) ps.setInt(idx++, bid);
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomPerformanceRow r = new RoomPerformanceRow();
                    r.setRoomName(rs.getString("room_name"));
                    r.setBranchId(rs.getInt("branch_id"));
                    r.setShowtimesCount(rs.getInt("showtimes_count"));
                    r.setTicketsSold(rs.getInt("tickets_sold"));
                    r.setRevenue(rs.getBigDecimal("revenue"));
                    r.setTotalSeats(0); // will get from separate query if needed
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Seat occupancy: room, total seats, sold seats, occupancy %.
     */
    public List<SeatOccupancyRow> getSeatOccupancy(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<SeatOccupancyRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                SELECT sr.room_name, sr.total_seats,
                       COUNT(DISTINCT s.showtime_id) AS showtimes_count,
                       SUM(COALESCE(online_t.cnt, 0) + COALESCE(counter_t.cnt, 0)) AS sold_seats,
                       CASE WHEN sr.total_seats > 0 AND COUNT(DISTINCT s.showtime_id) > 0 THEN
                           CAST(SUM(COALESCE(online_t.cnt, 0) + COALESCE(counter_t.cnt, 0)) * 100.0
                               / (sr.total_seats * COUNT(DISTINCT s.showtime_id)) AS DECIMAL(5,2))
                       ELSE 0 END AS occupancy_pct
                FROM showtimes s
                INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                LEFT JOIN (
                    SELECT ot.showtime_id, COUNT(*) AS cnt
                    FROM online_tickets ot INNER JOIN bookings b ON ot.booking_id = b.booking_id
                    WHERE b.status = 'CONFIRMED' AND b.payment_status = 'PAID'
                    GROUP BY ot.showtime_id
                ) online_t ON online_t.showtime_id = s.showtime_id
                LEFT JOIN (
                    SELECT showtime_id, COUNT(*) AS cnt
                    FROM counter_tickets GROUP BY showtime_id
                ) counter_t ON counter_t.showtime_id = s.showtime_id
                WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                GROUP BY sr.room_id, sr.room_name, sr.total_seats
                ORDER BY occupancy_pct DESC
                """.formatted(ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) ps.setInt(idx++, bid);
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SeatOccupancyRow r = new SeatOccupancyRow();
                    r.setRoomName(rs.getString("room_name"));
                    r.setTotalSeats(rs.getInt("total_seats"));
                    r.setShowtimesCount(rs.getInt("showtimes_count"));
                    r.setSoldSeats(rs.getInt("sold_seats"));
                    r.setOccupancyPct(rs.getBigDecimal("occupancy_pct"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * General performance by branch: branch name, total showtimes in period.
     */
    public List<BranchPerformanceRow> getTotalShowtimesByBranch(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<BranchPerformanceRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                SELECT b.branch_id, b.branch_name,
                       COUNT(DISTINCT s.showtime_id) AS total_showtimes
                FROM cinema_branches b
                LEFT JOIN screening_rooms sr ON sr.branch_id = b.branch_id
                LEFT JOIN showtimes s ON s.room_id = sr.room_id AND s.show_date >= ? AND s.show_date <= ?
                WHERE b.branch_id IN (%s)
                GROUP BY b.branch_id, b.branch_name
                ORDER BY total_showtimes DESC
                """.formatted(ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) ps.setInt(idx++, bid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BranchPerformanceRow r = new BranchPerformanceRow();
                    r.setBranchId(rs.getInt("branch_id"));
                    r.setBranchName(rs.getString("branch_name"));
                    r.setTotalShowtimes(rs.getInt("total_showtimes"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Seat utilization: occupancy rate (% of seats used across all showtimes) and average seats sold per showtime.
     */
    public SeatUtilizationMetrics getSeatUtilizationMetrics(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        SeatUtilizationMetrics m = new SeatUtilizationMetrics();
        if (branchIds == null || branchIds.isEmpty()) return m;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                SELECT
                    COUNT(DISTINCT s.showtime_id) AS showtimes_count,
                    COALESCE(SUM(sr.total_seats), 0) AS total_capacity,
                    (SELECT COALESCE(SUM(cnt), 0) FROM (
                        SELECT ot.showtime_id, COUNT(*) AS cnt
                        FROM online_tickets ot
                        INNER JOIN bookings b ON ot.booking_id = b.booking_id
                        INNER JOIN showtimes st ON ot.showtime_id = st.showtime_id
                        INNER JOIN screening_rooms sr2 ON st.room_id = sr2.room_id
                        WHERE sr2.branch_id IN (%s) AND st.show_date >= ? AND st.show_date <= ?
                        AND b.status = 'CONFIRMED' AND b.payment_status = 'PAID'
                        GROUP BY ot.showtime_id
                    ) ot_cnt) +
                    (SELECT COALESCE(SUM(cnt), 0) FROM (
                        SELECT showtime_id, COUNT(*) AS cnt
                        FROM counter_tickets ct
                        INNER JOIN showtimes st ON ct.showtime_id = st.showtime_id
                        INNER JOIN screening_rooms sr2 ON st.room_id = sr2.room_id
                        WHERE sr2.branch_id IN (%s) AND st.show_date >= ? AND st.show_date <= ?
                        GROUP BY showtime_id
                    ) ct_cnt) AS total_sold
                FROM showtimes s
                INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                """.formatted(ph, ph, ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (int i = 0; i < 3; i++) {
                for (Integer bid : branchIds) ps.setInt(idx++, bid);
                ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
                ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int showtimesCount = rs.getInt("showtimes_count");
                    long totalCapacity = rs.getLong("total_capacity");
                    long totalSold = rs.getLong("total_sold");
                    m.setAverageSeatsSold(showtimesCount > 0 ? (int) (totalSold / showtimesCount) : 0);
                    if (totalCapacity > 0) {
                        m.setOccupancyRatePct(BigDecimal.valueOf(totalSold * 100.0 / totalCapacity).setScale(2, java.math.RoundingMode.HALF_UP));
                    } else {
                        m.setOccupancyRatePct(BigDecimal.ZERO);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return m;
    }

    /**
     * Peak hours and low demand hours: time slots with highest and lowest attendance.
     * Uses 4-hour buckets: 6-10, 10-14, 14-18, 18-22, 22-06.
     */
    public PeakLowHours getPeakAndLowHours(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        PeakLowHours result = new PeakLowHours();
        if (branchIds == null || branchIds.isEmpty()) return result;

        String ph = buildPlaceholders(branchIds.size());
        String sql = """
                WITH st_tickets AS (
                    SELECT s.showtime_id,
                        CASE
                            WHEN DATEPART(HOUR, s.start_time) >= 22 OR DATEPART(HOUR, s.start_time) < 6 THEN N'22:00 - 06:00'
                            WHEN DATEPART(HOUR, s.start_time) >= 18 THEN N'18:00 - 22:00'
                            WHEN DATEPART(HOUR, s.start_time) >= 14 THEN N'14:00 - 18:00'
                            WHEN DATEPART(HOUR, s.start_time) >= 10 THEN N'10:00 - 14:00'
                            WHEN DATEPART(HOUR, s.start_time) >= 6 THEN N'06:00 - 10:00'
                            ELSE N'22:00 - 06:00'
                        END AS time_slot,
                        (SELECT COUNT(*) FROM online_tickets ot INNER JOIN bookings b ON ot.booking_id = b.booking_id
                         WHERE ot.showtime_id = s.showtime_id AND b.status = 'CONFIRMED' AND b.payment_status = 'PAID')
                        + (SELECT COUNT(*) FROM counter_tickets ct WHERE ct.showtime_id = s.showtime_id) AS sold
                    FROM showtimes s
                    INNER JOIN screening_rooms sr ON s.room_id = sr.room_id
                    WHERE sr.branch_id IN (%s) AND s.show_date >= ? AND s.show_date <= ?
                )
                SELECT time_slot, SUM(sold) AS total_sold
                FROM st_tickets
                GROUP BY time_slot
                ORDER BY total_sold DESC
                """.formatted(ph);

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) ps.setInt(idx++, bid);
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                String peak = null, low = null;
                boolean first = true;
                while (rs.next()) {
                    String slot = rs.getString("time_slot");
                    if (first) {
                        peak = slot;
                        first = false;
                    }
                    low = slot;
                }
                result.setPeakHours(peak != null ? peak : "—");
                result.setLowDemandHours(low != null ? low : "—");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    // --- DTO classes ---
    public static class BranchPerformanceRow {
        private int branchId;
        private String branchName;
        private int totalShowtimes;

        public int getBranchId() { return branchId; }
        public void setBranchId(int branchId) { this.branchId = branchId; }
        public String getBranchName() { return branchName; }
        public void setBranchName(String branchName) { this.branchName = branchName; }
        public int getTotalShowtimes() { return totalShowtimes; }
        public void setTotalShowtimes(int totalShowtimes) { this.totalShowtimes = totalShowtimes; }
    }

    public static class SeatUtilizationMetrics {
        private BigDecimal occupancyRatePct = BigDecimal.ZERO;
        private int averageSeatsSold;

        public BigDecimal getOccupancyRatePct() { return occupancyRatePct; }
        public void setOccupancyRatePct(BigDecimal occupancyRatePct) { this.occupancyRatePct = occupancyRatePct; }
        public int getAverageSeatsSold() { return averageSeatsSold; }
        public void setAverageSeatsSold(int averageSeatsSold) { this.averageSeatsSold = averageSeatsSold; }
    }

    public static class PeakLowHours {
        private String peakHours = "—";
        private String lowDemandHours = "—";

        public String getPeakHours() { return peakHours; }
        public void setPeakHours(String peakHours) { this.peakHours = peakHours; }
        public String getLowDemandHours() { return lowDemandHours; }
        public void setLowDemandHours(String lowDemandHours) { this.lowDemandHours = lowDemandHours; }
    }

    public static class MoviePerformanceRow {
        private String movieTitle;
        private int showtimesCount;
        private int ticketsSold;
        private BigDecimal revenue;

        public String getMovieTitle() { return movieTitle; }
        public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }
        public int getShowtimesCount() { return showtimesCount; }
        public void setShowtimesCount(int showtimesCount) { this.showtimesCount = showtimesCount; }
        public int getTicketsSold() { return ticketsSold; }
        public void setTicketsSold(int ticketsSold) { this.ticketsSold = ticketsSold; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
    }

    public static class OperationalRow {
        private int totalShowtimes;
        private int completedShowtimes;
        private int cancelledShowtimes;
        private int totalTickets;

        public int getTotalShowtimes() { return totalShowtimes; }
        public void setTotalShowtimes(int totalShowtimes) { this.totalShowtimes = totalShowtimes; }
        public int getCompletedShowtimes() { return completedShowtimes; }
        public void setCompletedShowtimes(int completedShowtimes) { this.completedShowtimes = completedShowtimes; }
        public int getCancelledShowtimes() { return cancelledShowtimes; }
        public void setCancelledShowtimes(int cancelledShowtimes) { this.cancelledShowtimes = cancelledShowtimes; }
        public int getTotalTickets() { return totalTickets; }
        public void setTotalTickets(int totalTickets) { this.totalTickets = totalTickets; }
    }

    public static class RoomPerformanceRow {
        private String roomName;
        private int branchId;
        private int showtimesCount;
        private int ticketsSold;
        private BigDecimal revenue;
        private int totalSeats;

        public String getRoomName() { return roomName; }
        public void setRoomName(String roomName) { this.roomName = roomName; }
        public int getBranchId() { return branchId; }
        public void setBranchId(int branchId) { this.branchId = branchId; }
        public int getShowtimesCount() { return showtimesCount; }
        public void setShowtimesCount(int showtimesCount) { this.showtimesCount = showtimesCount; }
        public int getTicketsSold() { return ticketsSold; }
        public void setTicketsSold(int ticketsSold) { this.ticketsSold = ticketsSold; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
        public int getTotalSeats() { return totalSeats; }
        public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }
    }

    public static class SeatOccupancyRow {
        private String roomName;
        private int totalSeats;
        private int showtimesCount;
        private int soldSeats;
        private BigDecimal occupancyPct;

        public String getRoomName() { return roomName; }
        public void setRoomName(String roomName) { this.roomName = roomName; }
        public int getTotalSeats() { return totalSeats; }
        public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }
        public int getShowtimesCount() { return showtimesCount; }
        public void setShowtimesCount(int showtimesCount) { this.showtimesCount = showtimesCount; }
        public int getSoldSeats() { return soldSeats; }
        public void setSoldSeats(int soldSeats) { this.soldSeats = soldSeats; }
        public BigDecimal getOccupancyPct() { return occupancyPct; }
        public void setOccupancyPct(BigDecimal occupancyPct) { this.occupancyPct = occupancyPct; }
    }
}
