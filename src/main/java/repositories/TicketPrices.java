package repositories;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import config.DBContext;
import models.TicketPrice;


public class TicketPrices extends DBContext {
    
    /**
     * Map ResultSet to TicketPrice object
     */
    private TicketPrice getTicketPricesFromResultSet(ResultSet rs) throws SQLException {
        TicketPrice tp = new TicketPrice();
        tp.setPriceId(rs.getInt("price_id"));
        tp.setSeatType(rs.getString("seat_type"));
        tp.setTicketType(rs.getString("ticket_type"));
        tp.setDayType(rs.getString("day_type"));
        tp.setTimeSlot(rs.getString("time_slot"));
        tp.setPrice(rs.getBigDecimal("price"));
        tp.setEffectiveFrom(rs.getDate("effective_from").toLocalDate());
        
        Date effectiveTo = rs.getDate("effective_to");
        tp.setEffectiveTo(effectiveTo != null ? effectiveTo.toLocalDate() : null);
        
        tp.setActive(rs.getBoolean("is_active"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        tp.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);
        
        return tp;
    }

    /**
     * Get price by specific criteria (seat type, ticket type, day type, time slot)
     * Returns the active price for the given date
     */
    public BigDecimal getPrice(String seatType, String ticketType, String dayType, String timeSlot, LocalDate date) {
        String sql = "SELECT TOP 1 price FROM ticket_prices " +
                     "WHERE seat_type = ? AND ticket_type = ? AND day_type = ? AND time_slot = ? " +
                     "AND is_active = 1 " +
                     "AND effective_from <= ? " +
                     "AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY effective_from DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, seatType);
            ps.setString(2, ticketType);
            ps.setString(3, dayType);
            ps.setString(4, timeSlot);
            ps.setDate(5, java.sql.Date.valueOf(date));
            ps.setDate(6, java.sql.Date.valueOf(date));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("price");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get all active ticket prices by date
     */
    public List<TicketPrice> getAllActiveByDate(LocalDate date) {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices " +
                     "WHERE is_active = 1 " +
                     "AND effective_from <= ? " +
                     "AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY seat_type, ticket_type, day_type, time_slot";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, java.sql.Date.valueOf(date));
            ps.setDate(2, java.sql.Date.valueOf(date));
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(getTicketPricesFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get ticket price by ID
     */
    public TicketPrice getById(int priceId) {
        String sql = "SELECT * FROM ticket_prices WHERE price_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, priceId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return getTicketPricesFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get all ticket prices
     */
    public List<TicketPrice> getAll() {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices ORDER BY effective_from DESC, seat_type, ticket_type, day_type, time_slot";
        
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(getTicketPricesFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get all active ticket prices
     */
    public List<TicketPrice> getAllActive() {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices WHERE is_active = 1 ORDER BY seat_type, ticket_type, day_type, time_slot";
        
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(getTicketPricesFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Create new ticket price
     */
    public boolean create(TicketPrice ticketPrice) {
        // Auto-set is_active to false if current date is after effective_to
        if (ticketPrice.getEffectiveTo() != null && LocalDate.now().isAfter(ticketPrice.getEffectiveTo())) {
            ticketPrice.setActive(false);
        }
        
        String sql = "INSERT INTO ticket_prices (seat_type, ticket_type, day_type, time_slot, price, effective_from, effective_to, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, ticketPrice.getSeatType());
            ps.setString(2, ticketPrice.getTicketType());
            ps.setString(3, ticketPrice.getDayType());
            ps.setString(4, ticketPrice.getTimeSlot());
            ps.setBigDecimal(5, ticketPrice.getPrice());
            ps.setDate(6, java.sql.Date.valueOf(ticketPrice.getEffectiveFrom()));
            
            if (ticketPrice.getEffectiveTo() != null) {
                ps.setDate(7, java.sql.Date.valueOf(ticketPrice.getEffectiveTo()));
            } else {
                ps.setNull(7, Types.DATE);
            }
            
            ps.setBoolean(8, ticketPrice.isActive());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                // Get the generated price_id and set it to the ticketPrice object
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        ticketPrice.setPriceId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update existing ticket price
     */
    public boolean update(TicketPrice ticketPrice) {
        String sql = "UPDATE ticket_prices SET seat_type = ?, ticket_type = ?, day_type = ?, time_slot = ?, " +
                     "price = ?, effective_from = ?, effective_to = ?, is_active = ? WHERE price_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, ticketPrice.getSeatType());
            ps.setString(2, ticketPrice.getTicketType());
            ps.setString(3, ticketPrice.getDayType());
            ps.setString(4, ticketPrice.getTimeSlot());
            ps.setBigDecimal(5, ticketPrice.getPrice());
            ps.setDate(6, java.sql.Date.valueOf(ticketPrice.getEffectiveFrom()));
            
            if (ticketPrice.getEffectiveTo() != null) {
                ps.setDate(7, java.sql.Date.valueOf(ticketPrice.getEffectiveTo()));
            }
            
            ps.setBoolean(8, ticketPrice.isActive());
            ps.setInt(9, ticketPrice.getPriceId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete ticket price by ID
     */
    public boolean delete(int priceId) {
        String sql = "DELETE FROM ticket_prices WHERE price_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, priceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Deactivate ticket price (soft delete)
     */
    public boolean deactivate(int priceId) {
        String sql = "UPDATE ticket_prices SET is_active = 0 WHERE price_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, priceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Activate ticket price
     */
    public boolean activate(int priceId) {
        String sql = "UPDATE ticket_prices SET is_active = 1 WHERE price_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, priceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get prices by seat type and ticket type
     */
    public List<TicketPrice> getPricesByCategory(String seatType, String ticketType) {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices " +
                     "WHERE seat_type = ? AND ticket_type = ? " +
                     "ORDER BY day_type, time_slot, effective_from DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, seatType);
            ps.setString(2, ticketType);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(getTicketPricesFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get prices by day type and time slot
     */
    public List<TicketPrice> getPricesByDayAndTime(String dayType, String timeSlot) {
        List<TicketPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM ticket_prices " +
                     "WHERE day_type = ? AND time_slot = ? AND is_active = 1 " +
                     "ORDER BY seat_type, ticket_type, effective_from DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dayType);
            ps.setString(2, timeSlot);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(getTicketPricesFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Check if price configuration exists for specific criteria
     */
    public boolean exists(String seatType, String ticketType, String dayType, String timeSlot) {
        String sql = "SELECT COUNT(*) as cnt FROM ticket_prices " +
                     "WHERE seat_type = ? AND ticket_type = ? AND day_type = ? AND time_slot = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, seatType);
            ps.setString(2, ticketType);
            ps.setString(3, dayType);
            ps.setString(4, timeSlot);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}