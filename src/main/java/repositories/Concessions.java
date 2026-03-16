package repositories;

import config.DBContext;
import models.Concession;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Concessions extends DBContext {

    // Lấy tất cả
    public List<Concession> getAllConcessions() {
        List<Concession> list = new ArrayList<>();
        String sql = """
            SELECT concession_type, quantity, price_base,
                   concession_name, added_by, created_at
            FROM concessions
            ORDER BY concession_name, concession_type
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
            SELECT concession_type, quantity, price_base,
                   concession_name, added_by, created_at
            FROM concessions
            WHERE concession_id = ?
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
            (concession_type, quantity, price_base, added_by, concession_name, created_at)
            VALUES (?, ?, ?, ?, ?, GETDATE())
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, c.getConcessionType());
            ps.setObject(2, c.getQuantity(), Types.INTEGER);
            ps.setDouble(3, c.getPriceBase());
            ps.setInt(4, c.getAddedBy());
            ps.setString(5, c.getConcessionName());

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
            SET concession_type = ?,
                quantity = ?,
                price_base = ?,
                concession_name = ?
            WHERE concession_id = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getConcessionType());
            ps.setObject(2, c.getQuantity(), Types.INTEGER);
            ps.setDouble(3, c.getPriceBase());
            ps.setString(4, c.getConcessionName());
            ps.setInt(5, c.getConcessionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa
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
        c.setConcessionType(rs.getString("concession_type"));
        c.setQuantity(rs.getObject("quantity", Integer.class));
        c.setConcessionName(rs.getString("concession_name"));
        // DB lưu theo nghìn -> nhân lại 1000
        c.setPriceBase(rs.getDouble("price_base") * 1000);
        c.setAddedBy(rs.getInt("added_by"));
        Timestamp ts = rs.getTimestamp("created_at");
        c.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
        return c;
    }
}