package repositories;

import config.DBContext;
import models.TicketPrice;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketPrices extends DBContext {

    private TicketPrice mapRow(ResultSet rs) throws SQLException {
        TicketPrice p = new TicketPrice();
        p.setPriceId(rs.getInt("price_id"));
        p.setBranchId(rs.getInt("branch_id"));
        p.setTicketType(rs.getString("ticket_type"));
        p.setDayType(rs.getString("day_type"));
        p.setTimeSlot(rs.getString("time_slot"));
        p.setPrice(rs.getBigDecimal("price"));
        if (rs.getDate("effective_from") != null) p.setEffectiveFrom(rs.getDate("effective_from").toLocalDate());
        if (rs.getDate("effective_to") != null) p.setEffectiveTo(rs.getDate("effective_to").toLocalDate());
        p.setActive(rs.getBoolean("is_active"));
        return p;
    }

    // Lấy bảng giá theo chi nhánh
    public List<TicketPrice> findByBranchId(int branchId) {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices WHERE branch_id = ? ORDER BY day_type, time_slot, ticket_type";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insert(TicketPrice p) {
        String sql = "INSERT INTO ticket_prices (branch_id, ticket_type, day_type, time_slot, price, effective_from, effective_to, is_active) VALUES (?,?,?,?,?,?,?,?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, p.getBranchId());
            st.setString(2, p.getTicketType());
            st.setString(3, p.getDayType());
            st.setString(4, p.getTimeSlot());
            st.setBigDecimal(5, p.getPrice());
            st.setDate(6, Date.valueOf(p.getEffectiveFrom()));
            if (p.getEffectiveTo() != null) st.setDate(7, Date.valueOf(p.getEffectiveTo()));
            else st.setNull(7, Types.DATE);
            st.setBoolean(8, p.isActive());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


    // Cập nhật bảng giá
    public boolean update(TicketPrice p) {
        String sql = "UPDATE ticket_prices SET branch_id=?, ticket_type=?, day_type=?, time_slot=?, price=?, effective_from=?, effective_to=?, is_active=? WHERE price_id=?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, p.getBranchId());
            st.setString(2, p.getTicketType());
            st.setString(3, p.getDayType());
            st.setString(4, p.getTimeSlot());
            st.setBigDecimal(5, p.getPrice());
            st.setDate(6, Date.valueOf(p.getEffectiveFrom()));

            if (p.getEffectiveTo() != null) {
                st.setDate(7, Date.valueOf(p.getEffectiveTo()));
            } else {
                st.setNull(7, Types.DATE);
            }

            st.setBoolean(8, p.isActive());
            st.setInt(9, p.getPriceId());

            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa bảng giá theo id
    public boolean delete(int priceId) {
        String sql = "DELETE FROM ticket_prices WHERE price_id = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, priceId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deactivate(int priceId) {
        String sql = "UPDATE ticket_prices SET is_active = 0 WHERE price_id = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, priceId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public TicketPrice findById(int priceId) {
        String sql = "SELECT * FROM ticket_prices WHERE price_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, priceId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy danh sách có Filter, Search và Phân trang
    public List<TicketPrice> getPricesWithFilterAndPagination(int branchId, String search, String dayType, String status, int page, int pageSize) {
        List<TicketPrice> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ticket_prices WHERE branch_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(branchId);

        if (search != null && !search.trim().isEmpty()) {
            // Chỉ còn search theo loại khách
            sql.append(" AND ticket_type LIKE ?");
            params.add("%" + search.trim() + "%");
        }
        if (dayType != null && !dayType.trim().isEmpty()) {
            sql.append(" AND day_type = ?");
            params.add(dayType);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND is_active = ?");
            params.add("ACTIVE".equalsIgnoreCase(status) ? 1 : 0);
        }

        sql.append(" ORDER BY day_type, time_slot, ticket_type OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) st.setObject(i + 1, params.get(i));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Đếm tổng số để tính số trang
    public int countPricesWithFilter(int branchId, String search, String dayType, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM ticket_prices WHERE branch_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(branchId);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND ticket_type LIKE ?");
            params.add("%" + search.trim() + "%");
        }
        if (dayType != null && !dayType.trim().isEmpty()) {
            sql.append(" AND day_type = ?");
            params.add(dayType);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND is_active = ?");
            params.add("ACTIVE".equalsIgnoreCase(status) ? 1 : 0);
        }

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) st.setObject(i + 1, params.get(i));
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // Lấy giá vé chính xác dựa trên tổ hợp điều kiện và ngày chiếu phim
    public BigDecimal getTicketPrice(int branchId, String ticketType, String dayType, String timeSlot, java.time.LocalDate showDate) {
        String sql = "SELECT TOP 1 price FROM ticket_prices " +
                "WHERE branch_id = ? AND ticket_type = ? AND day_type = ? AND time_slot = ? " +
                "AND is_active = 1 " +
                "AND effective_from <= ? " +
                "AND (effective_to IS NULL OR effective_to >= ?) " +
                "ORDER BY effective_from DESC";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setString(2, ticketType);
            st.setString(3, dayType);
            st.setString(4, timeSlot);
            st.setDate(5, java.sql.Date.valueOf(showDate));
            st.setDate(6, java.sql.Date.valueOf(showDate));

            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("price");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}