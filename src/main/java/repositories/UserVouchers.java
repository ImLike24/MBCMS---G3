package repositories;

import config.DBContext;
import models.UserVoucher;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    public List<UserVoucher> getVouchersByUserId(int userId) {
        List<UserVoucher> lists = new ArrayList<>();
        String sql = "SELECT * FROM user_vouchers WHERE user_id = ? ORDER BY redeemed_at DESC";
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
}
