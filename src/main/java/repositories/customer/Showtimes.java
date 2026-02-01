package repositories.customer;

import config.DBContext;
import models.Showtime;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class Showtimes extends DBContext {

    // map du lieu tu ResultSet sang obj
    private Showtime mapResultSetToShowtime(ResultSet rs) throws SQLException {
        Showtime st = new Showtime();
        st.setShowtimeId(rs.getInt("showtime_id"));
        st.setMovieId(rs.getInt("movie_id"));
        st.setRoomId(rs.getInt("room_id"));
        
        if(rs.getDate("show_date") != null){
            st.setShowDate(rs.getDate("show_date").toLocalDate());
        }

        if(rs.getTime("start_time") != null){
            st.setStartTime(rs.getTime("start_time").toLocalTime());
        }

        if(rs.getTime("end_time") != null){
            st.setEndTime(rs.getTime("end_time").toLocalTime());
        }

        if(rs.getTimestamp("created_at") != null){
            st.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }

        return st; // tra ve obj
    }

    // lay danh sach lich chieu dang hoat dong theo thoi gian thuc

    public List<Showtime> getActiveShowtimes(int movieId, LocalDate date){
        List<Showtime> activeShowtimes = new ArrayList<>();
        String sql = """
                SELECT * FROM showtimes
                WHERE movie_id = ? AND show_date = ? AND status IN ('SCHEDULED', 'ONGOING')
                ORDER BY start_time ASC
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()){
                while(rs.next()){
                    activeShowtimes.add(mapResultSetToShowtime(rs));
                }
            }
        } catch (SQLException e){
            e.printStackTrace();
            System.err.println("Lỗi khi lấy danh sách suất chiếu đang hoạt động: " + e.getMessage());
        }
        return activeShowtimes;
    }
}

