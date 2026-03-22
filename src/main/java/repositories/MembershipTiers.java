package repositories;

import config.DBContext;
import models.MembershipTier;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MembershipTiers extends DBContext {

    private MembershipTier mapResultSetToTier(ResultSet rs) throws SQLException {
        MembershipTier tier = new MembershipTier();
        tier.setTierId(rs.getInt("tier_id"));
        tier.setTierName(rs.getString("tier_name"));
        tier.setMinPointsRequired(rs.getInt("min_points_required"));
        tier.setPointMultiplier(rs.getBigDecimal("point_multiplier"));
        if (rs.getTimestamp("created_at") != null) {
            tier.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return tier;
    }

    public List<MembershipTier> getAllTiers() {
        List<MembershipTier> tiers = new ArrayList<>();
        String sql = "SELECT * FROM membership_tiers ORDER BY min_points_required ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                tiers.add(mapResultSetToTier(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tiers;
    }

    public MembershipTier getTierById(int id) {
        String sql = "SELECT * FROM membership_tiers WHERE tier_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTier(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(MembershipTier tier) {
        String sql = "INSERT INTO membership_tiers (tier_name, min_points_required, point_multiplier) VALUES (?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, tier.getTierName());
            st.setInt(2, tier.getMinPointsRequired());
            st.setBigDecimal(3, tier.getPointMultiplier());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(MembershipTier tier) {
        String sql = "UPDATE membership_tiers SET tier_name = ?, min_points_required = ?, point_multiplier = ? WHERE tier_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, tier.getTierName());
            st.setInt(2, tier.getMinPointsRequired());
            st.setBigDecimal(3, tier.getPointMultiplier());
            st.setInt(4, tier.getTierId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int tierId) {
        String sql = "DELETE FROM membership_tiers WHERE tier_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, tierId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
