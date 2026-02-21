package repositories;

import config.DBContext;
import models.SeatTypeSurcharge;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SeatTypeSurcharges extends DBContext {

    private SeatTypeSurcharge mapRow(ResultSet rs) throws SQLException {
        SeatTypeSurcharge s = new SeatTypeSurcharge();
        s.setSurchargeId(rs.getInt("surcharge_id"));
        s.setBranchId(rs.getInt("branch_id"));
        s.setSeatType(rs.getString("seat_type"));
        s.setSurchargeRate(rs.getDouble("surcharge_rate"));
        if (rs.getTimestamp("updated_at") != null)
            s.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        return s;
    }

    /** Get all surcharge configs for a branch */
    public List<SeatTypeSurcharge> getSurchargesByBranch(int branchId) {
        String sql = "SELECT * FROM seat_type_surcharges WHERE branch_id = ? ORDER BY seat_type";
        List<SeatTypeSurcharge> list = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Get surcharge for a specific branch + seat type */
    public SeatTypeSurcharge getSurchargeByBranchAndType(int branchId, String seatType) {
        String sql = "SELECT * FROM seat_type_surcharges WHERE branch_id = ? AND seat_type = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setString(2, seatType);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Insert or update surcharge rate for a branch + type.
     * Uses MERGE (SQL Server) for upsert.
     */
    public boolean upsertSurcharge(int branchId, String seatType, double rate) {
        String sql = """
                MERGE INTO seat_type_surcharges AS target
                USING (SELECT ? AS branch_id, ? AS seat_type, ? AS surcharge_rate) AS source
                   ON target.branch_id = source.branch_id AND target.seat_type = source.seat_type
                WHEN MATCHED THEN
                    UPDATE SET surcharge_rate = source.surcharge_rate, updated_at = SYSDATETIME()
                WHEN NOT MATCHED THEN
                    INSERT (branch_id, seat_type, surcharge_rate)
                    VALUES (source.branch_id, source.seat_type, source.surcharge_rate);
                """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setString(2, seatType);
            st.setDouble(3, rate);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
