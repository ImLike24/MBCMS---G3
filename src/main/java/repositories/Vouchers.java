package repositories;

import config.DBContext;
import models.Voucher;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Vouchers extends DBContext {

    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("voucher_id"));
        v.setVoucherName(rs.getString("voucher_name"));
        v.setVoucherType(rs.getString("voucher_type"));
        v.setVoucherCode(rs.getString("voucher_code"));
        v.setPointsCost(rs.getInt("points_cost"));
        v.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        v.setMaxUsageLimit(rs.getInt("max_usage_limit"));
        v.setCurrentUsage(rs.getInt("current_usage"));
        v.setValidDays(rs.getInt("valid_days"));
        v.setIsActive(rs.getBoolean("is_active"));
        if (rs.getTimestamp("created_at") != null) {
            v.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return v;
    }

    public Voucher getActiveVoucherByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM vouchers WHERE UPPER(voucher_code) = UPPER(?) AND is_active = 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, code.trim());
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isVoucherCodeExists(String code, Integer excludeVoucherId) {
        if (code == null || code.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM vouchers WHERE UPPER(voucher_code) = UPPER(?)";
        if (excludeVoucherId != null) {
            sql += " AND voucher_id != ?";
        }

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, code.trim());
            if (excludeVoucherId != null) {
                st.setInt(2, excludeVoucherId);
            }
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Voucher> getAllVouchers() {
        List<Voucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM vouchers ORDER BY created_at DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                lists.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public List<Voucher> getAllActiveVouchers() {
        List<Voucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM vouchers WHERE is_active = 1 ORDER BY created_at DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                lists.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public List<Voucher> getLoyaltyVouchers() {
        List<Voucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM vouchers WHERE is_active = 1 AND voucher_type = 'LOYALTY' AND current_usage < max_usage_limit ORDER BY points_cost ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                lists.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public List<Voucher> getPublicVouchers() {
        List<Voucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM vouchers WHERE is_active = 1 AND voucher_type = 'PUBLIC' AND current_usage < max_usage_limit ORDER BY created_at DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                lists.add(mapResultSetToVoucher(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public Voucher getVoucherById(int id) {
        String sql = "SELECT * FROM vouchers WHERE voucher_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(Voucher v) {
        String sql = "INSERT INTO vouchers (voucher_name, voucher_type, voucher_code, points_cost, discount_amount, max_usage_limit, current_usage, valid_days) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, v.getVoucherName());
            st.setString(2, v.getVoucherType());
            st.setString(3, v.getVoucherCode());
            st.setInt(4, v.getPointsCost());
            st.setBigDecimal(5, v.getDiscountAmount());
            st.setInt(6, v.getMaxUsageLimit());
            st.setInt(7, v.getCurrentUsage() != null ? v.getCurrentUsage() : 0);
            st.setInt(8, v.getValidDays());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Voucher v) {
        String sql = "UPDATE vouchers SET voucher_name = ?, voucher_type = ?, voucher_code = ?, points_cost = ?, discount_amount = ?, max_usage_limit = ?, current_usage = ?, valid_days = ?, is_active = ? WHERE voucher_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, v.getVoucherName());
            st.setString(2, v.getVoucherType());
            st.setString(3, v.getVoucherCode());
            st.setInt(4, v.getPointsCost());
            st.setBigDecimal(5, v.getDiscountAmount());
            st.setInt(6, v.getMaxUsageLimit());
            st.setInt(7, v.getCurrentUsage());
            st.setInt(8, v.getValidDays());
            st.setBoolean(9, v.getIsActive());
            st.setInt(10, v.getVoucherId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int voucherId) {
        String sql = "DELETE FROM vouchers WHERE voucher_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, voucherId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean incrementVoucherUsage(String code) {
        if (code == null || code.trim().isEmpty())
            return false;

        // 1. Try to increment directly (for PUBLIC codes)
        String directSql = "UPDATE vouchers SET current_usage = current_usage + 1 WHERE UPPER(voucher_code) = UPPER(?)";
        try (PreparedStatement st = connection.prepareStatement(directSql)) {
            st.setString(1, code.trim());
            if (st.executeUpdate() > 0) {
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. If not found, try to find the voucher_id from user_vouchers (for UNIQUE
        // codes)
        String lookupSql = "UPDATE vouchers SET current_usage = current_usage + 1 " +
                "WHERE voucher_id = (SELECT voucher_id FROM user_vouchers WHERE voucher_code = ?)";
        try (PreparedStatement st = connection.prepareStatement(lookupSql)) {
            st.setString(1, code.trim());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
