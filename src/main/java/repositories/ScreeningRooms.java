package repositories;

import config.DBContext;
import models.ScreeningRoom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ScreeningRooms extends DBContext {

    // Helper method to map ResultSet to ScreeningRoom object
    private ScreeningRoom mapResultSetToScreeningRoom(ResultSet rs) throws SQLException {
        ScreeningRoom room = new ScreeningRoom();
        room.setRoomId(rs.getInt("room_id"));
        room.setBranchId(rs.getInt("branch_id"));
        room.setRoomName(rs.getString("room_name"));
        room.setTotalSeats(rs.getInt("total_seats"));
        room.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null)
            room.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            room.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());

        return room;
    }

    // Get all screening rooms for a specific branch
    public List<ScreeningRoom> getAllRoomsByBranch(int branchId) {
        String sql = "SELECT * FROM screening_rooms WHERE branch_id = ? ORDER BY room_name ASC";
        List<ScreeningRoom> rooms = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapResultSetToScreeningRoom(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get screening room by ID
    public ScreeningRoom getRoomById(int roomId) {
        String sql = "SELECT * FROM screening_rooms WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToScreeningRoom(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Insert new screening room
    public boolean insertRoom(ScreeningRoom room) {
        String sql = "INSERT INTO screening_rooms (branch_id, room_name, total_seats, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, room.getBranchId());
            st.setString(2, room.getRoomName());
            st.setInt(3, room.getTotalSeats());
            st.setString(4, room.getStatus());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update screening room
    public boolean updateRoom(ScreeningRoom room) {
        String sql = "UPDATE screening_rooms SET room_name = ?, total_seats = ?, status = ?, updated_at = SYSDATETIME() WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, room.getRoomName());
            st.setInt(2, room.getTotalSeats());
            st.setString(3, room.getStatus());
            st.setInt(4, room.getRoomId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete screening room
    public boolean deleteRoom(int roomId) {
        String sql = "DELETE FROM screening_rooms WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update room status
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE screening_rooms SET status = ?, updated_at = SYSDATETIME() WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, roomId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check if room name exists in branch
    public boolean roomNameExistsInBranch(String roomName, int branchId, Integer excludeRoomId) {
        String sql = "SELECT COUNT(*) FROM screening_rooms WHERE room_name = ? AND branch_id = ? AND room_id != ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, roomName);
            st.setInt(2, branchId);
            st.setInt(3, excludeRoomId != null ? excludeRoomId : -1);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get room count by branch
    public int getRoomCountByBranch(int branchId) {
        String sql = "SELECT COUNT(*) FROM screening_rooms WHERE branch_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Lấy tất cả phòng của 1 chi nhánh cụ thể
    public List<ScreeningRoom> findByBranchId(int branchId) {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM screening_rooms WHERE branch_id = ? ORDER BY room_name ASC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToScreeningRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
