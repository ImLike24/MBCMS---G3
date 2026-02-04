package repositories;

import config.DBContext;
import models.ScreeningRoom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ScreeningRooms extends DBContext {

    private ScreeningRoom mapRow(ResultSet rs) throws SQLException {
        ScreeningRoom r = new ScreeningRoom();
        r.setRoomId(rs.getInt("room_id"));
        r.setBranchId(rs.getInt("branch_id"));
        r.setRoomName(rs.getString("room_name"));
        r.setTotalSeats(rs.getInt("total_seats"));
        r.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null)
            r.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            r.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        return r;
    }



    // Lấy tất cả phòng của 1 chi nhánh cụ thể
    public List<ScreeningRoom> findByBranchId(int branchId) {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM screening_rooms WHERE branch_id = ? ORDER BY room_name ASC";
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

    public ScreeningRoom getRoomById(int roomId) {
        String sql = "SELECT * FROM screening_rooms WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ScreeningRoom> getAllRoomsByBranch(int branchId) {
        String sql = "SELECT * FROM screening_rooms WHERE branch_id = ? ORDER BY room_name ASC";
        List<ScreeningRoom> rooms = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    public ScreeningRoom findById(int id) {
        String sql = "SELECT * FROM screening_rooms WHERE room_id = ?";
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

    public boolean insert(ScreeningRoom r) {
        String sql = "INSERT INTO screening_rooms (branch_id, room_name, total_seats, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, r.getBranchId());
            st.setString(2, r.getRoomName());
            st.setInt(3, r.getTotalSeats());
            st.setString(4, r.getStatus()); // ACTIVE, MAINTENANCE...
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

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

    public boolean update(ScreeningRoom r) {
        String sql = "UPDATE screening_rooms SET room_name=?, total_seats=?, status=?, updated_at=SYSDATETIME() WHERE room_id=?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, r.getRoomName());
            st.setInt(2, r.getTotalSeats());
            st.setString(3, r.getStatus());
            st.setInt(4, r.getRoomId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

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

    public boolean delete(int id) {
        String sql = "DELETE FROM screening_rooms WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}