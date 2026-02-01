import repositories.customer;

import models.Seat;
import config.DBContext;
import models.CinemaBranch;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SeatsInRoom extends DBContext {

    
    // chuyen doi du lieu tu ResultSet sang Seat obj

    public List<Seat> getSeatsFromScreeningRooms(int roomId){
        List<Seat> seats = new ArrayList<>();
        String sql = """
                SELECT s.*
                FROM seats s
                JOIN screening_rooms sr ON s.room_id = sr.room_id
                WHERE sr.room_id = ?
                ORDER BY s.seat_id ASC
                """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Seat seat = new Seat();
                seat.setSeatId(rs.getInt("seat_id"));
                seat.setRoomId(rs.getInt("room_id"));
                seat.setSeatCode(rs.getString("seat_code"));
                seat.setSeatType(rs.getString("seat_type"));
                seat.setRowNumber(rs.getString("row_number"));
                seat.setSeatNumber(rs.getInt("seat_number"));
                seat.setStatus(rs.getString("status"));
                seats.add(seat);
            }

        }catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Lỗi khi lấy danh sách ghế từ phòng chiếu: " + e.getMessage());
    }
    return seats;
}
    }