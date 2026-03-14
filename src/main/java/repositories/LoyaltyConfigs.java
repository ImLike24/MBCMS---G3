package repositories;

import config.DBContext;
import models.LoyaltyConfig;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LoyaltyConfigs extends DBContext {

    private LoyaltyConfig mapResultSetToConfig(ResultSet rs) throws SQLException {
        LoyaltyConfig config = new LoyaltyConfig();
        config.setConfigId(rs.getInt("config_id"));
        config.setEarnRateAmount(rs.getBigDecimal("earn_rate_amount"));
        config.setEarnPoints(rs.getInt("earn_points"));
        config.setMinRedeemPoints(rs.getInt("min_redeem_points"));
        if (rs.getTimestamp("updated_at") != null) {
            config.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        config.setUpdatedBy(rs.getInt("updated_by"));
        if (rs.wasNull()) {
            config.setUpdatedBy(null);
        }
        return config;
    }

    public LoyaltyConfig getConfig() {
        String sql = "SELECT * FROM loyalty_configs WHERE config_id = 1";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToConfig(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateConfig(LoyaltyConfig config) {
        String sql = "UPDATE loyalty_configs SET earn_rate_amount = ?, earn_points = ?, min_redeem_points = ?, updated_at = SYSDATETIME(), updated_by = ? WHERE config_id = 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setBigDecimal(1, config.getEarnRateAmount());
            st.setInt(2, config.getEarnPoints());
            st.setInt(3, config.getMinRedeemPoints());
            if (config.getUpdatedBy() != null) {
                st.setInt(4, config.getUpdatedBy());
            } else {
                st.setNull(4, java.sql.Types.INTEGER);
            }
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
