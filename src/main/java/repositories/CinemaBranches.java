package repositories;

import config.DBContext;
import models.CinemaBranch;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CinemaBranches extends DBContext {

    // Mapper: Chuyển dữ liệu từ SQL sang Object Java
    private CinemaBranch mapRow(ResultSet rs) throws SQLException {
        CinemaBranch b = new CinemaBranch();
        b.setBranchId(rs.getInt("branch_id"));
        b.setBranchName(rs.getString("branch_name"));
        b.setAddress(rs.getString("address"));
        b.setPhone(rs.getString("phone"));
        b.setEmail(rs.getString("email"));

        int mgrId = rs.getInt("manager_id");
        b.setManagerId(rs.wasNull() ? null : mgrId);

        b.setActive(rs.getBoolean("is_active"));

        // Convert Timestamp SQL -> LocalDateTime Java
        if (rs.getTimestamp("created_at") != null)
            b.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            b.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());

        return b;
    }

    public List<CinemaBranch> findAll() {
        List<CinemaBranch> list = new ArrayList<>();
        String sql = "SELECT * FROM cinema_branches ORDER BY branch_id DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public CinemaBranch findById(int id) {
        String sql = "SELECT * FROM cinema_branches WHERE branch_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(CinemaBranch b) {
        // Lưu ý: created_at và updated_at để DB tự lo (default GETDATE())
        String sql = "INSERT INTO cinema_branches (branch_name, address, phone, email, manager_id, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, b.getBranchName());
            st.setString(2, b.getAddress());
            st.setString(3, b.getPhone());
            st.setString(4, b.getEmail());

            if (b.getManagerId() != null) st.setInt(5, b.getManagerId());
            else st.setNull(5, java.sql.Types.INTEGER);

            st.setBoolean(6, b.isActive());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(CinemaBranch b) {
        // Cập nhật updated_at tự động bằng trigger hoặc set tay ở đây
        String sql = "UPDATE cinema_branches SET branch_name=?, address=?, phone=?, email=?, manager_id=?, is_active=?, updated_at=SYSDATETIME() WHERE branch_id=?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, b.getBranchName());
            st.setString(2, b.getAddress());
            st.setString(3, b.getPhone());
            st.setString(4, b.getEmail());

            if (b.getManagerId() != null) st.setInt(5, b.getManagerId());
            else st.setNull(5, java.sql.Types.INTEGER);

            st.setBoolean(6, b.isActive());
            st.setInt(7, b.getBranchId());

            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM cinema_branches WHERE branch_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}