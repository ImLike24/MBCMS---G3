package repositories;

import config.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Doanh thu vé — lọc theo screening_rooms.branch_id IN (...).
 * Khoảng ngày: online theo {@code bookings.payment_time} (fallback {@code booking_time});
 * quầy theo {@code counter_tickets.sold_at}.
 */
public class RevenueReports extends DBContext {

    private static String ph(int n) {
        return String.join(",", Collections.nCopies(n, "?"));
    }

    public List<Row> listByBranches(List<Integer> branchIds, LocalDate from, LocalDate to) {
        List<Row> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;
        String sql = """
                SELECT x.branch_name, x.show_date,
                       COUNT(*) AS total_tickets_sold,
                       SUM(x.price) AS total_revenue
                FROM (
                    SELECT b.branch_name, s.show_date, ot.price
                    FROM online_tickets ot
                    INNER JOIN bookings bk ON ot.booking_id = bk.booking_id
                    INNER JOIN showtimes s ON ot.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    INNER JOIN cinema_branches b ON r.branch_id = b.branch_id
                    WHERE r.branch_id IN (%s)
                      AND (bk.payment_status = 'PAID' OR bk.status = 'CONFIRMED')
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) >= ?
                      AND CAST(COALESCE(bk.payment_time, bk.booking_time) AS DATE) <= ?
                    UNION ALL
                    SELECT b.branch_name, s.show_date, ct.price
                    FROM counter_tickets ct
                    INNER JOIN showtimes s ON ct.showtime_id = s.showtime_id
                    INNER JOIN screening_rooms r ON s.room_id = r.room_id
                    INNER JOIN cinema_branches b ON r.branch_id = b.branch_id
                    WHERE r.branch_id IN (%s)
                      AND CAST(ct.sold_at AS DATE) >= ?
                      AND CAST(ct.sold_at AS DATE) <= ?
                ) x
                GROUP BY x.branch_name, x.show_date
                ORDER BY x.branch_name, x.show_date
                """.formatted(ph(branchIds.size()), ph(branchIds.size()));
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int i = 1;
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, Date.valueOf(from));
            ps.setDate(i++, Date.valueOf(to));
            for (Integer bid : branchIds) ps.setInt(i++, bid);
            ps.setDate(i++, Date.valueOf(from));
            ps.setDate(i++, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Row row = new Row();
                    row.setBranchName(rs.getString("branch_name"));
                    row.setShowDate(rs.getDate("show_date").toLocalDate());
                    row.setTotalTicketsSold(rs.getInt("total_tickets_sold"));
                    BigDecimal rev = rs.getBigDecimal("total_revenue");
                    row.setTotalRevenue(rev != null ? rev : BigDecimal.ZERO);
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static class Row {
        private String branchName;
        private LocalDate showDate;
        private int totalTicketsSold;
        private BigDecimal totalRevenue;
        public String getBranchName() { return branchName; }
        public void setBranchName(String branchName) { this.branchName = branchName; }
        public LocalDate getShowDate() { return showDate; }
        public void setShowDate(LocalDate showDate) { this.showDate = showDate; }
        public int getTotalTicketsSold() { return totalTicketsSold; }
        public void setTotalTicketsSold(int totalTicketsSold) { this.totalTicketsSold = totalTicketsSold; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    }
}
