package repositories;

import config.DBContext;
import models.PointHistory;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PointHistories extends DBContext {

    private PointHistory mapResultSetToHistory(ResultSet rs) throws SQLException {
        PointHistory ph = new PointHistory();
        ph.setHistoryId(rs.getInt("history_id"));
        ph.setUserId(rs.getInt("user_id"));
        ph.setPointsChanged(rs.getInt("points_changed"));
        ph.setTransactionType(rs.getString("transaction_type"));
        ph.setDescription(rs.getString("description"));
        ph.setReferenceId(rs.getInt("reference_id"));
        if (rs.wasNull()) {
            ph.setReferenceId(null);
        }
        if (rs.getTimestamp("created_at") != null) {
            ph.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return ph;
    }

    public List<PointHistory> getHistoryByUserId(int userId) {
        List<PointHistory> lists = new ArrayList<>();
        String sql = "SELECT * FROM point_history WHERE user_id = ? ORDER BY created_at DESC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    lists.add(mapResultSetToHistory(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lists;
    }

    public boolean insert(PointHistory ph) {
        String sql = "INSERT INTO point_history (user_id, points_changed, transaction_type, description, reference_id) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, ph.getUserId());
            st.setInt(2, ph.getPointsChanged());
            st.setString(3, ph.getTransactionType());
            st.setString(4, ph.getDescription());
            if (ph.getReferenceId() != null) {
                st.setInt(5, ph.getReferenceId());
            } else {
                st.setNull(5, java.sql.Types.INTEGER);
            }
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
