package repositories;

import config.DBContext;
import models.UserVoucher;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserVouchers extends DBContext {

    private UserVoucher mapResultSetToUserVoucher(ResultSet rs) throws SQLException {
        UserVoucher uv = new UserVoucher();
        uv.setId(rs.getInt("id"));
        uv.setUserId(rs.getInt("user_id"));
        uv.setVoucherId(rs.getInt("voucher_id"));
        uv.setVoucherCode(rs.getString("voucher_code"));
        uv.setStatus(rs.getString("status"));
        if (rs.getTimestamp("redeemed_at") != null) {
            uv.setRedeemedAt(rs.getTimestamp("redeemed_at").toLocalDateTime());
        }
        if (rs.getTimestamp("expires_at") != null) {
            uv.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
        }
        if (rs.getTimestamp("used_at") != null) {
            uv.setUsedAt(rs.getTimestamp("used_at").toLocalDateTime());
        }
        return uv;
    }

    /**
     * Lấy các voucher còn hiệu lực cho 1 user:
     * - status = 'AVAILABLE'
     * - expires_at > SYSDATETIME()
     * Kết quả sắp xếp theo ngày hết hạn tăng dần (ưu tiên voucher sắp hết hạn).
     */
    public List<UserVoucher> getAvailableVouchersByUserId(int userId) {
        List<UserVoucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM user_vouchers WHERE user_id = ? AND status = 'AVAILABLE' AND expires_at > SYSDATETIME() ORDER BY expires_at ASC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    lists.add(mapResultSetToUserVoucher(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public UserVoucher getVoucherByCode(String code) {
        String sql = "SELECT * FROM user_vouchers WHERE voucher_code = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, code);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUserVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean redeemVoucher(int userId, models.Voucher voucher) {
        String updatePointsSql = "UPDATE users SET points = points - ? WHERE user_id = ? AND points >= ?";
        String insertUserVoucherSql = "INSERT INTO user_vouchers (user_id, voucher_id, voucher_code, expires_at) VALUES (?, ?, ?, ?)";
        String insertHistorySql = "INSERT INTO point_history (user_id, points_changed, transaction_type, description) VALUES (?, ?, 'REDEEM', ?)";

        String prefix = "";
        if (voucher.getVoucherCode() != null) {
            prefix = voucher.getVoucherCode() + "-";
        }

        try {
            // 0. Check if user already has this loyalty voucher (same prefix)
            if (!prefix.isEmpty()) {
                String checkPrefixSql = "SELECT count(*) FROM user_vouchers WHERE user_id = ? AND voucher_code LIKE ?";
                try (PreparedStatement stCheck = connection.prepareStatement(checkPrefixSql)) {
                    stCheck.setInt(1, userId);
                    stCheck.setString(2, prefix + "%");
                    try (ResultSet rsCheck = stCheck.executeQuery()) {
                        if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                            return false; // User already has a voucher with this prefix
                        }
                    }
                }
            }

            String randomCode = prefix + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
            java.time.LocalDateTime expiresAt = java.time.LocalDateTime.now().plusDays(voucher.getValidDays());

            // 1. Check if voucher is still active and valid
            String checkActiveSql = "SELECT is_active, current_usage, max_usage_limit FROM vouchers WHERE voucher_id = ? AND is_active = 1";
            try (PreparedStatement st = connection.prepareStatement(checkActiveSql)) {
                st.setInt(1, voucher.getVoucherId());
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        if (rs.getInt("current_usage") >= rs.getInt("max_usage_limit")) {
                            return false; // Out of usage
                        }
                    } else {
                        return false; // Inactive
                    }
                }
            }

            // 2. Update Points
            try (PreparedStatement st = connection.prepareStatement(updatePointsSql)) {
                st.setInt(1, voucher.getPointsCost());
                st.setInt(2, userId);
                st.setInt(3, voucher.getPointsCost());
                if (st.executeUpdate() == 0) {
                    return false;
                }
            }

            // 3. Insert User Voucher
            try (PreparedStatement st = connection.prepareStatement(insertUserVoucherSql)) {
                st.setInt(1, userId);
                st.setInt(2, voucher.getVoucherId());
                st.setString(3, randomCode);
                st.setTimestamp(4, java.sql.Timestamp.valueOf(expiresAt));
                st.executeUpdate();
            }

            // 4. Insert point history
            try (PreparedStatement st = connection.prepareStatement(insertHistorySql)) {
                st.setInt(1, userId);
                st.setInt(2, -voucher.getPointsCost());
                st.setString(3, "Đổi voucher: " + voucher.getVoucherName());
                st.executeUpdate();
            }

            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean savePublicVoucher(int userId, models.Voucher voucher) {
        String insertUserVoucherSql = "INSERT INTO user_vouchers (user_id, voucher_id, voucher_code, expires_at) VALUES (?, ?, ?, ?)";

        
        String checkSql = "SELECT count(*) FROM user_vouchers WHERE user_id = ? AND voucher_id = ? AND status = 'AVAILABLE'";

        try (PreparedStatement stCheck = connection.prepareStatement(checkSql)) {
            stCheck.setInt(1, userId);
            stCheck.setInt(2, voucher.getVoucherId());
            try (ResultSet rs = stCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // User already has this voucher
                }
            }

            java.time.LocalDateTime expiresAt = java.time.LocalDateTime.now().plusDays(voucher.getValidDays());

            // 1. Check if voucher is still active and valid
            String checkActiveSql = "SELECT is_active, current_usage, max_usage_limit FROM vouchers WHERE voucher_id = ? AND is_active = 1";
            try (PreparedStatement st = connection.prepareStatement(checkActiveSql)) {
                st.setInt(1, voucher.getVoucherId());
                try (ResultSet rs = st.executeQuery()) {
                    if (rs.next()) {
                        if (rs.getInt("current_usage") >= rs.getInt("max_usage_limit")) {
                            return false; // Out of usage
                        }
                    } else {
                        return false; // Inactive
                    }
                }
            }

            // 2. Insert User Voucher
            try (PreparedStatement st = connection.prepareStatement(insertUserVoucherSql)) {
                st.setInt(1, userId);
                st.setInt(2, voucher.getVoucherId());
                st.setString(3, voucher.getVoucherCode());
                st.setTimestamp(4, java.sql.Timestamp.valueOf(expiresAt));
                st.executeUpdate();
            }

            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteVoucherByCode(String code) {
        if (code == null || code.trim().isEmpty())
            return false;
        String sql = "DELETE FROM user_vouchers WHERE voucher_code = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, code.trim());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
