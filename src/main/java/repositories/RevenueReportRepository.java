package repositories;

import config.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Repository for revenue report queries from invoices and invoice_items.
 */
public class RevenueReportRepository extends DBContext {

    public RevenueReportRepository() {
        super();
    }

    private static String buildPlaceholders(int count) {
        return String.join(",", Collections.nCopies(count, "?"));
    }

    /**
     * Revenue by branch - for manager's managed branches.
     */
    public List<BranchRevenueRow> getRevenueByBranch(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<BranchRevenueRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String sql = """
                SELECT b.branch_id, b.branch_name,
                       COUNT(i.invoice_id) AS invoice_count,
                       COALESCE(SUM(i.final_amount), 0) AS total_revenue
                FROM cinema_branches b
                LEFT JOIN invoices i ON i.branch_id = b.branch_id
                    AND i.status = 'ACTIVE' AND i.payment_status = 'PAID'
                    AND CAST(i.invoice_date AS DATE) >= ? AND CAST(i.invoice_date AS DATE) <= ?
                WHERE b.branch_id IN (%s)
                GROUP BY b.branch_id, b.branch_name
                ORDER BY total_revenue DESC
                """.formatted(buildPlaceholders(branchIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            for (Integer bid : branchIds) {
                ps.setInt(idx++, bid);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BranchRevenueRow row = new BranchRevenueRow();
                    row.setBranchId(rs.getInt("branch_id"));
                    row.setBranchName(rs.getString("branch_name"));
                    row.setInvoiceCount(rs.getInt("invoice_count"));
                    row.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Revenue by date (daily breakdown).
     */
    public List<DateRevenueRow> getRevenueByDate(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<DateRevenueRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String sql = """
                SELECT CAST(i.invoice_date AS DATE) AS report_date,
                       COUNT(i.invoice_id) AS invoice_count,
                       COALESCE(SUM(i.final_amount), 0) AS total_revenue
                FROM invoices i
                WHERE i.branch_id IN (%s)
                  AND i.status = 'ACTIVE' AND i.payment_status = 'PAID'
                  AND CAST(i.invoice_date AS DATE) >= ? AND CAST(i.invoice_date AS DATE) <= ?
                GROUP BY CAST(i.invoice_date AS DATE)
                ORDER BY report_date DESC
                """.formatted(buildPlaceholders(branchIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) {
                ps.setInt(idx++, bid);
            }
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DateRevenueRow row = new DateRevenueRow();
                    row.setReportDate(rs.getDate("report_date"));
                    row.setInvoiceCount(rs.getInt("invoice_count"));
                    row.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Revenue by movie (from invoice_items).
     */
    public List<MovieRevenueRow> getRevenueByMovie(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<MovieRevenueRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String sql = """
                SELECT ii.movie_title,
                       COUNT(DISTINCT i.invoice_id) AS invoice_count,
                       COALESCE(SUM(ii.amount), 0) AS total_revenue
                FROM invoice_items ii
                INNER JOIN invoices i ON ii.invoice_id = i.invoice_id
                WHERE i.branch_id IN (%s)
                  AND i.status = 'ACTIVE' AND i.payment_status = 'PAID'
                  AND CAST(i.invoice_date AS DATE) >= ? AND CAST(i.invoice_date AS DATE) <= ?
                  AND ii.movie_title IS NOT NULL AND ii.movie_title != ''
                GROUP BY ii.movie_title
                ORDER BY total_revenue DESC
                """.formatted(buildPlaceholders(branchIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) {
                ps.setInt(idx++, bid);
            }
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MovieRevenueRow row = new MovieRevenueRow();
                    row.setMovieTitle(rs.getString("movie_title"));
                    row.setInvoiceCount(rs.getInt("invoice_count"));
                    row.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Revenue by payment method.
     */
    public List<PaymentMethodRevenueRow> getRevenueByPaymentMethod(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        List<PaymentMethodRevenueRow> list = new ArrayList<>();
        if (branchIds == null || branchIds.isEmpty()) return list;

        String sql = """
                SELECT i.payment_method,
                       COUNT(i.invoice_id) AS invoice_count,
                       COALESCE(SUM(i.final_amount), 0) AS total_revenue
                FROM invoices i
                WHERE i.branch_id IN (%s)
                  AND i.status = 'ACTIVE' AND i.payment_status = 'PAID'
                  AND CAST(i.invoice_date AS DATE) >= ? AND CAST(i.invoice_date AS DATE) <= ?
                GROUP BY i.payment_method
                ORDER BY total_revenue DESC
                """.formatted(buildPlaceholders(branchIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) {
                ps.setInt(idx++, bid);
            }
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentMethodRevenueRow row = new PaymentMethodRevenueRow();
                    row.setPaymentMethod(rs.getString("payment_method"));
                    row.setInvoiceCount(rs.getInt("invoice_count"));
                    row.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get total revenue for summary.
     */
    public BigDecimal getTotalRevenue(List<Integer> branchIds, LocalDate fromDate, LocalDate toDate) {
        if (branchIds == null || branchIds.isEmpty()) return BigDecimal.ZERO;

        String sql = """
                SELECT COALESCE(SUM(i.final_amount), 0) AS total
                FROM invoices i
                WHERE i.branch_id IN (%s)
                  AND i.status = 'ACTIVE' AND i.payment_status = 'PAID'
                  AND CAST(i.invoice_date AS DATE) >= ? AND CAST(i.invoice_date AS DATE) <= ?
                """.formatted(buildPlaceholders(branchIds.size()));

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer bid : branchIds) {
                ps.setInt(idx++, bid);
            }
            ps.setDate(idx++, java.sql.Date.valueOf(fromDate));
            ps.setDate(idx++, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    // --- DTO classes (inner) ---
    public static class BranchRevenueRow {
        private int branchId;
        private String branchName;
        private int invoiceCount;
        private BigDecimal totalRevenue;

        public int getBranchId() { return branchId; }
        public void setBranchId(int branchId) { this.branchId = branchId; }
        public String getBranchName() { return branchName; }
        public void setBranchName(String branchName) { this.branchName = branchName; }
        public int getInvoiceCount() { return invoiceCount; }
        public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    }

    public static class DateRevenueRow {
        private java.sql.Date reportDate;
        private int invoiceCount;
        private BigDecimal totalRevenue;

        public java.sql.Date getReportDate() { return reportDate; }
        public void setReportDate(java.sql.Date reportDate) { this.reportDate = reportDate; }
        public int getInvoiceCount() { return invoiceCount; }
        public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    }

    public static class MovieRevenueRow {
        private String movieTitle;
        private int invoiceCount;
        private BigDecimal totalRevenue;

        public String getMovieTitle() { return movieTitle; }
        public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }
        public int getInvoiceCount() { return invoiceCount; }
        public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    }

    public static class PaymentMethodRevenueRow {
        private String paymentMethod;
        private int invoiceCount;
        private BigDecimal totalRevenue;

        public String getPaymentMethod() { return paymentMethod; }
        public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
        public int getInvoiceCount() { return invoiceCount; }
        public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    }
}
