package repositories;

import config.DBContext;
import models.Concession;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Concessions extends DBContext {

    // Lấy tất cả concession (danh sách)
    public List<Concession> getAllConcessions() {
        List<Concession> list = new ArrayList<>();
        String sql = """
            SELECT concession_id, concession_type, quantity, price_base, 
                   added_by, created_at, updated_at
            FROM concessions
            ORDER BY concession_type
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToConcession(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy theo ID
    public Concession getConcessionById(int id) {
        String sql = """
            SELECT concession_id, concession_type, quantity, price_base, 
                   added_by, created_at, updated_at
            FROM concessions WHERE concession_id = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToConcession(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm mới
    public boolean addConcession(Concession c) {
        String sql = """
            INSERT INTO concessions 
            (concession_type, quantity, price_base, added_by, created_at, updated_at)
            VALUES (?, ?, ?, ?, GETDATE(), GETDATE())
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getConcessionType());
            ps.setInt(2, c.getQuantity() != null ? c.getQuantity() : 0);
            ps.setDouble(3, c.getPriceBase());
            ps.setInt(4, c.getAddedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật
    public boolean updateConcession(Concession c) {
        String sql = """
            UPDATE concessions 
            SET concession_type = ?, quantity = ?, price_base = ?, 
                updated_at = GETDATE()
            WHERE concession_id = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getConcessionType());
            ps.setInt(2, c.getQuantity());
            ps.setDouble(3, c.getPriceBase());
            ps.setInt(4, c.getConcessionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa hẳn (hard delete)
    public boolean deleteConcession(int id) {
        String sql = "DELETE FROM concessions WHERE concession_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Concession mapRowToConcession(ResultSet rs) throws SQLException {
        Concession c = new Concession();
        c.setConcessionId(rs.getInt("concession_id"));
        c.setConcessionType(rs.getString("concession_type"));
        c.setQuantity(rs.getInt("quantity"));
        c.setPriceBase(rs.getDouble("price_base"));
        c.setAddedBy(rs.getInt("added_by"));
        if (rs.getTimestamp("created_at") != null) {
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            c.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        return c;
    }
}