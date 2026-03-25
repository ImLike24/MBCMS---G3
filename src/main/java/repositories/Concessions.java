package repositories;

import config.DBContext;
import models.Concession;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Concessions extends DBContext {

    public List<Concession> getActiveConcessions() {
        return getConcessionsForSale();
    }

    /** Danh sách đồ ăn/thức uống cho khách đặt (trang chọn ghế). */
    public List<Concession> getConcessionsForSale() {
        List<Concession> list = new ArrayList<>();
        String sql = """
            SELECT concession_id, concession_name, concession_type, price_base, quantity
            FROM concessions
            ORDER BY concession_type, concession_name
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowForSale(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy tất cả
    public List<Concession> getAllConcessions() {
        List<Concession> list = new ArrayList<>();
        String sql = """
            SELECT concession_id, concession_type, quantity, price_base, concession_name
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
            SELECT concession_id, concession_type, quantity, price_base,
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
                price_base = ?
            WHERE concession_id = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getConcessionType());
            ps.setObject(2, c.getQuantity(), Types.INTEGER);
            ps.setDouble(3, c.getPriceBase());
            ps.setInt(4, c.getConcessionId());
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

    private Concession mapRowForSale(ResultSet rs) throws SQLException {
        Concession c = new Concession();
        c.setConcessionId(rs.getInt("concession_id"));
        c.setConcessionName(rs.getString("concession_name"));
        c.setConcessionType(rs.getString("concession_type"));
        c.setPriceBase(rs.getDouble("price_base"));
        c.setQuantity(rs.getObject("quantity", Integer.class));
        return c;
    }

    private Concession mapRowToConcession(ResultSet rs) throws SQLException {
        Concession c = new Concession();
        c.setConcessionId(rs.getInt("concession_id"));
        c.setConcessionType(rs.getString("concession_type"));
        c.setQuantity(rs.getObject("quantity", Integer.class));
        c.setPriceBase(rs.getDouble("price_base"));
        c.setConcessionName(rs.getString("concession_name"));
        try {
            c.setAddedBy(rs.getObject("added_by") != null ? rs.getInt("added_by") : null);
        } catch (SQLException ignored) { }
        try {
            c.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        } catch (SQLException ignored) { }
        return c;
    }
}