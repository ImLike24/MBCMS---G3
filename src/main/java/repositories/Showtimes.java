package repositories;

import config.DBContext;
import models.Showtime;
import models.Seat;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Showtimes extends DBContext {

    /**
     * Get showtimes for a specific movie on a specific date
     */
    public List<Showtime> getShowtimesForMovieOnDate(int movieId, LocalDate date) {
        List<Showtime> showtimes = new ArrayList<>();
        String sql = "SELECT * FROM showtimes " +
                "WHERE movie_id = ? AND show_date = ? " +
                "AND status IN ('SCHEDULED', 'ONGOING') " +
                "ORDER BY start_time";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, movieId);
            pstmt.setDate(2, java.sql.Date.valueOf(date));

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    showtimes.add(mapResultSetToShowtime(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return showtimes;
    }

    /**
     * Get showtime by ID
     */
    public Showtime getShowtimeById(int showtimeId) {
        String sql = "SELECT * FROM showtimes WHERE showtime_id = ?";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShowtime(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get showtime details with room and branch info
     */
    public Map<String, Object> getShowtimeDetails(int showtimeId) {
        Map<String, Object> details = new HashMap<>();
        String sql = "SELECT s.*, sr.room_name, sr.total_seats, " +
                "cb.branch_id, cb.branch_name, cb.address, " +
                "m.title, m.duration, m.age_rating, m.poster_url, m.movie_id " +
                "FROM showtimes s " +
                "INNER JOIN screening_rooms sr ON s.room_id = sr.room_id " +
                "INNER JOIN cinema_branches cb ON sr.branch_id = cb.branch_id " +
                "INNER JOIN movies m ON s.movie_id = m.movie_id " +
                "WHERE s.showtime_id = ?";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Showtime details
                    Showtime showtime = mapResultSetToShowtime(rs);
                    details.put("showtime", showtime);

                    // Room details
                    details.put("roomName", rs.getString("room_name"));
                    details.put("totalSeats", rs.getInt("total_seats"));

                    // Branch details
                    details.put("branchId", rs.getInt("branch_id"));
                    details.put("branchName", rs.getString("branch_name"));
                    details.put("branchAddress", rs.getString("address"));

                    // Movie details
                    details.put("movieTitle", rs.getString("title"));
                    details.put("movieDuration", rs.getInt("duration"));

                    int movieId = rs.getInt("movie_id");
                    List<String> genres = getGenresByMovieId(movieId);
                    details.put("movieGenre", String.join(", ", genres));

                    details.put("movieAgeRating", rs.getString("age_rating"));
                    details.put("moviePosterUrl", rs.getString("poster_url"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }

    /**
     * Count available seats for a showtime
     */
    public int countAvailableSeats(int showtimeId) {
        String sql = "SELECT COUNT(*) as available_count " +
                "FROM seats s " +
                "INNER JOIN screening_rooms sr ON s.room_id = sr.room_id " +
                "INNER JOIN showtimes st ON sr.room_id = st.room_id " +
                "WHERE st.showtime_id = ? " +
                "AND s.status = 'AVAILABLE' " +
                "AND s.seat_id NOT IN ( " +
                "    SELECT seat_id FROM online_tickets WHERE showtime_id = ? " +
                "    UNION " +
                "    SELECT seat_id FROM counter_tickets WHERE showtime_id = ? " +
                ")";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);
            pstmt.setInt(2, showtimeId);
            pstmt.setInt(3, showtimeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("available_count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get available seats for a showtime
     */
    public List<Seat> getAvailableSeats(int showtimeId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT s.* " +
                "FROM seats s " +
                "INNER JOIN screening_rooms sr ON s.room_id = sr.room_id " +
                "INNER JOIN showtimes st ON sr.room_id = st.room_id " +
                "WHERE st.showtime_id = ? " +
                "AND s.status = 'AVAILABLE' " +
                "AND s.seat_id NOT IN ( " +
                "    SELECT seat_id FROM online_tickets WHERE showtime_id = ? " +
                "    UNION " +
                "    SELECT seat_id FROM counter_tickets WHERE showtime_id = ? " +
                ") " +
                "ORDER BY s.row_number, s.seat_number";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);
            pstmt.setInt(2, showtimeId);
            pstmt.setInt(3, showtimeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    seats.add(mapResultSetToSeat(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }

    /**
     * Get all seats for a showtime's room with booking status
     */
    public List<Map<String, Object>> getSeatsWithBookingStatus(int showtimeId) {
        List<Map<String, Object>> seatsWithStatus = new ArrayList<>();
        String sql = "SELECT s.*, " +
                "CASE " +
                "    WHEN EXISTS (SELECT 1 FROM online_tickets ot WHERE ot.showtime_id = ? AND ot.seat_id = s.seat_id) THEN 'BOOKED_ONLINE' "
                +
                "    WHEN EXISTS (SELECT 1 FROM counter_tickets ct WHERE ct.showtime_id = ? AND ct.seat_id = s.seat_id) THEN 'BOOKED_COUNTER' "
                +
                "    WHEN s.status != 'AVAILABLE' THEN s.status " +
                "    ELSE 'AVAILABLE' " +
                "END as booking_status " +
                "FROM seats s " +
                "INNER JOIN screening_rooms sr ON s.room_id = sr.room_id " +
                "INNER JOIN showtimes st ON sr.room_id = st.room_id " +
                "WHERE st.showtime_id = ? " +
                "ORDER BY s.row_number, s.seat_number";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);
            pstmt.setInt(2, showtimeId);
            pstmt.setInt(3, showtimeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> seatInfo = new HashMap<>();
                    seatInfo.put("seat", mapResultSetToSeat(rs));
                    seatInfo.put("bookingStatus", rs.getString("booking_status"));
                    seatsWithStatus.add(seatInfo);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seatsWithStatus;
    }

    /**
     * Check if a specific seat is available for a showtime
     */
    public boolean isSeatAvailable(int showtimeId, int seatId) {
        String sql = "SELECT CASE " +
                "    WHEN EXISTS (SELECT 1 FROM online_tickets WHERE showtime_id = ? AND seat_id = ?) THEN 0 " +
                "    WHEN EXISTS (SELECT 1 FROM counter_tickets WHERE showtime_id = ? AND seat_id = ?) THEN 0 " +
                "    WHEN EXISTS (SELECT 1 FROM seats WHERE seat_id = ? AND status != 'AVAILABLE') THEN 0 " +
                "    ELSE 1 " +
                "END as is_available";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, showtimeId);
            pstmt.setInt(2, seatId);
            pstmt.setInt(3, showtimeId);
            pstmt.setInt(4, seatId);
            pstmt.setInt(5, seatId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("is_available") == 1;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Helper method to map ResultSet to Showtime object
     */
    private Showtime mapResultSetToShowtime(ResultSet rs) throws SQLException {
        Showtime showtime = new Showtime();
        showtime.setShowtimeId(rs.getInt("showtime_id"));
        showtime.setMovieId(rs.getInt("movie_id"));
        showtime.setRoomId(rs.getInt("room_id"));

        if (rs.getDate("show_date") != null) {
            showtime.setShowDate(rs.getDate("show_date").toLocalDate());
        }
        if (rs.getTime("start_time") != null) {
            showtime.setStartTime(rs.getTime("start_time").toLocalTime());
        }
        if (rs.getTime("end_time") != null) {
            showtime.setEndTime(rs.getTime("end_time").toLocalTime());
        }

        showtime.setBasePrice(rs.getBigDecimal("base_price"));
        showtime.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null) {
            showtime.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }

        return showtime;
    }

    /**
     * Helper method to map ResultSet to Seat object
     */
    private Seat mapResultSetToSeat(ResultSet rs) throws SQLException {
        Seat seat = new Seat();
        seat.setSeatId(rs.getInt("seat_id"));
        seat.setRoomId(rs.getInt("room_id"));
        seat.setSeatCode(rs.getString("seat_code"));
        seat.setSeatType(rs.getString("seat_type"));
        seat.setRowNumber(rs.getString("row_number"));
        seat.setSeatNumber(rs.getInt("seat_number"));
        seat.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null) {
            seat.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }

        return seat;
    }

    /**
     * Helper method to get genres by movie id
     */
    private List<String> getGenresByMovieId(int movieId) {
        List<String> genres = new ArrayList<>();
        String sql = """
                    SELECT g.genre_name
                    FROM genres g
                    JOIN movie_genres mg ON g.genre_id = mg.genre_id
                    WHERE mg.movie_id = ?
                    ORDER BY g.genre_name
                """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, movieId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    genres.add(rs.getString("genre_name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return genres;
    }

    /**
     */
    public List<models.Movie> getMoviesWithShowtimes(int branchId, LocalDate date) {
        Map<Integer, models.Movie> movieMap = new java.util.LinkedHashMap<>();

        String sql = "SELECT s.*, m.* " +
                "FROM showtimes s " +
                "JOIN movies m ON s.movie_id = m.movie_id " +
                "JOIN screening_rooms r ON s.room_id = r.room_id " +
                "WHERE r.branch_id = ? AND s.show_date = ? AND s.status IN ('SCHEDULED', 'ONGOING') " +
                "ORDER BY m.title, s.start_time";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int movieId = rs.getInt("movie_id");
                    models.Movie movie = movieMap.get(movieId);
                    if (movie == null) {
                        movie = new models.Movie();
                        movie.setMovieId(movieId);
                        movie.setTitle(rs.getString("title"));
                        movie.setPosterUrl(rs.getString("poster_url"));
                        movie.setDuration(rs.getInt("duration"));
                        movie.setRating(rs.getDouble("rating"));
                        movie.setAgeRating(rs.getString("age_rating"));
                        
                        // Use helper to fetch genres
                        movie.setGenres(getGenresByMovieId(movieId));

                        movieMap.put(movieId, movie);
                    }
                    Showtime showtime = mapResultSetToShowtime(rs);
                    movie.getShowtimes().add(showtime);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(movieMap.values());
    }
}
