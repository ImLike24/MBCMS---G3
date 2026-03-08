/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package repositories;

import models.Concession;

import java.sql.*;
import java.time.LocalDateTime;

import java.util.*;

/**
 *
 * @author Admin
 */
public class Concessions {

    private Connection connection;

    private Concession mapRow(ResultSet rs) throws SQLException {
        Concession concession = new Concession();

        concession.setConcessionId(rs.getInt("concession_id"));
        concession.setConcessionType(rs.getString("concession_type"));
        concession.setQuantity(rs.getInt("quantity"));
        concession.setBasePrice(rs.getBigDecimal("price_base"));
        concession.setAddBy((Integer) rs.getObject("added_by"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            concession.setCreatedAt(ts.toLocalDateTime());
        }

        return concession;

    }

    // Lay danh sach (findAll and findType)
    public List<Concession> findAll() {
        List<Concession> foodsAndDrinksList = new ArrayList<>();

        String sql = """
                     SELECT * 
                     FROM concessions
                     ORDER BY concession_id
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                foodsAndDrinksList.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return foodsAndDrinksList;
    }

    // lay danh sach food
    public List<Concession> getFoods() {

        List<Concession> list = new ArrayList<>();

        String sql = "SELECT * FROM concessions WHERE concession_type = 'FOOD'";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // lay danh sach drink
    public List<Concession> getDrinks() {

        List<Concession> list = new ArrayList<>();

        String sql = "SELECT * FROM concessions WHERE concession_type = 'BEVERAGE'";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // them 1 loai food / beverage moi
    public boolean insertItem(Concession concession) {

        String sql = """
                 INSERT INTO concessions
                 (concession_type, quantity, price_base, added_by)
                 VALUES (?, ?, ?, ?)
                 """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, concession.getConcessionType());
            ps.setInt(2, concession.getQuantity());
            ps.setBigDecimal(3, concession.getBasePrice());
            ps.setObject(4, concession.getAddBy());

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // chinh sua loai do an / thuc uong
    public boolean updateItem(Concession concession) {

        String sql = """
                 UPDATE concessions
                 SET concession_type = ?, quantity = ?, price_base = ?
                 WHERE concession_id = ?
                 """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, concession.getConcessionType());
            ps.setInt(2, concession.getQuantity());
            ps.setBigDecimal(3, concession.getBasePrice());
            ps.setInt(4, concession.getConcessionId());

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // xoa do an / thuc uong tu id
    public boolean delete(int concessionId) {

        String sql = """
                 DELETE FROM concessions
                 WHERE concession_id = ?
                 """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, concessionId);

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
