package repositories;

import config.DBContext;
import models.Seat;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Seats extends DBContext {

    // Helper method to map ResultSet to Seat object
    private Seat mapResultSetToSeat(ResultSet rs) throws SQLException {
        Seat seat = new Seat();
        seat.setSeatId(rs.getInt("seat_id"));
        seat.setRoomId(rs.getInt("room_id"));
        seat.setSeatCode(rs.getString("seat_code"));
        seat.setSeatType(rs.getString("seat_type"));
        seat.setRowNumber(rs.getString("row_number"));
        seat.setSeatNumber(rs.getInt("seat_number"));
        seat.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null)
            seat.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

        return seat;
    }

    // Get all seats for a specific room
    public List<Seat> getSeatsByRoom(int roomId) {
        String sql = "SELECT * FROM seats WHERE room_id = ? ORDER BY row_number, seat_number";
        List<Seat> seats = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    seats.add(mapResultSetToSeat(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }

    // Get seat by ID
    public Seat getSeatById(int seatId) {
        String sql = "SELECT * FROM seats WHERE seat_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, seatId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSeat(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Insert single seat
    public boolean insertSeat(Seat seat) {
        String sql = "INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, seat.getRoomId());
            st.setString(2, seat.getSeatCode());
            st.setString(3, seat.getSeatType());
            st.setString(4, seat.getRowNumber());
            st.setInt(5, seat.getSeatNumber());
            st.setString(6, seat.getStatus());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Bulk insert seats for layout configuration
    public boolean insertSeatsInBatch(List<Seat> seats) {
        String sql = "INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            connection.setAutoCommit(false);

            for (Seat seat : seats) {
                st.setInt(1, seat.getRoomId());
                st.setString(2, seat.getSeatCode());
                st.setString(3, seat.getSeatType());
                st.setString(4, seat.getRowNumber());
                st.setInt(5, seat.getSeatNumber());
                st.setString(6, seat.getStatus());
                st.addBatch();
            }

            int[] results = st.executeBatch();
            connection.commit();
            connection.setAutoCommit(true);

            // Check if all inserts were successful
            for (int result : results) {
                if (result <= 0) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
        return false;
    }

    // Update seat type
    public boolean updateSeatType(int seatId, String seatType) {
        String sql = "UPDATE seats SET seat_type = ? WHERE seat_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, seatType);
            st.setInt(2, seatId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Bulk update seat types
    public boolean updateSeatTypesInBatch(List<Integer> seatIds, String seatType) {
        String sql = "UPDATE seats SET seat_type = ? WHERE seat_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            connection.setAutoCommit(false);

            for (Integer seatId : seatIds) {
                st.setString(1, seatType);
                st.setInt(2, seatId);
                st.addBatch();
            }

            int[] results = st.executeBatch();
            connection.commit();
            connection.setAutoCommit(true);

            for (int result : results) {
                if (result <= 0) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
        return false;
    }

    // Update seat status
    public boolean updateSeatStatus(int seatId, String status) {
        String sql = "UPDATE seats SET status = ? WHERE seat_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, seatId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Bulk update seat statuses
    public boolean updateSeatStatusesInBatch(List<Integer> seatIds, String status) {
        String sql = "UPDATE seats SET status = ? WHERE seat_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            connection.setAutoCommit(false);

            for (Integer seatId : seatIds) {
                st.setString(1, status);
                st.setInt(2, seatId);
                st.addBatch();
            }

            int[] results = st.executeBatch();
            connection.commit();
            connection.setAutoCommit(true);

            for (int result : results) {
                if (result <= 0) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
        return false;
    }

    // Delete all seats in a room
    public boolean deleteSeatsByRoom(int roomId) {
        String sql = "DELETE FROM seats WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            return st.executeUpdate() >= 0; // >= 0 because room might have no seats
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get seats by room and status
    public List<Seat> getSeatsByRoomAndStatus(int roomId, String status) {
        String sql = "SELECT * FROM seats WHERE room_id = ? AND status = ? ORDER BY row_number, seat_number";
        List<Seat> seats = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
            st.setString(2, status);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    seats.add(mapResultSetToSeat(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }

    // Get seat count by room
    public int getSeatCountByRoom(int roomId) {
        String sql = "SELECT COUNT(*) FROM seats WHERE room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roomId);
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

    // Check if seat code exists in room
    public boolean seatCodeExistsInRoom(String seatCode, int roomId) {
        String sql = "SELECT COUNT(*) FROM seats WHERE seat_code = ? AND room_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, seatCode);
            st.setInt(2, roomId);
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
}
