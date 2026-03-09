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
        v.setValidDays(rs.getInt("valid_days"));
        v.setIsActive(rs.getBoolean("is_active"));
        if (rs.getTimestamp("created_at") != null) {
            v.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return v;
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
        String sql = "INSERT INTO vouchers (voucher_name, voucher_type, voucher_code, points_cost, discount_amount, max_usage_limit, valid_days) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, v.getVoucherName());
            st.setString(2, v.getVoucherType());
            st.setString(3, v.getVoucherCode());
            st.setInt(4, v.getPointsCost());
            st.setBigDecimal(5, v.getDiscountAmount());
            st.setInt(6, v.getMaxUsageLimit());
            st.setInt(7, v.getValidDays());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Voucher v) {
        String sql = "UPDATE vouchers SET voucher_name = ?, voucher_type = ?, voucher_code = ?, points_cost = ?, discount_amount = ?, max_usage_limit = ?, valid_days = ?, is_active = ? WHERE voucher_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, v.getVoucherName());
            st.setString(2, v.getVoucherType());
            st.setString(3, v.getVoucherCode());
            st.setInt(4, v.getPointsCost());
            st.setBigDecimal(5, v.getDiscountAmount());
            st.setInt(6, v.getMaxUsageLimit());
            st.setInt(7, v.getValidDays());
            st.setBoolean(8, v.getIsActive());
            st.setInt(9, v.getVoucherId());
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
}
