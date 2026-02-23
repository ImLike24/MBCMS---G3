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

    /**
     * Create a new showtime
     */
    public int createShowtime(Showtime showtime) {
        String sql = "INSERT INTO showtimes (movie_id, room_id, show_date, start_time, end_time, base_price, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?) ";
        try (PreparedStatement ps = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, showtime.getMovieId());
            ps.setInt(2, showtime.getRoomId());
            ps.setDate(3, java.sql.Date.valueOf(showtime.getShowDate()));
            ps.setTime(4, java.sql.Time.valueOf(showtime.getStartTime()));
            ps.setTime(5, java.sql.Time.valueOf(showtime.getEndTime()));
            ps.setBigDecimal(6, showtime.getBasePrice());
            ps.setString(7, showtime.getStatus() != null ? showtime.getStatus() : "SCHEDULED");
            ps.executeUpdate();
            try (java.sql.ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Check if a room already has a showtime that overlaps the given time slot on
     * the given date.
     * Overlap condition: newStart < existingEnd AND newEnd > existingStart
     */
    public boolean hasSchedulingConflict(int roomId, java.time.LocalDate date,
            java.time.LocalTime startTime, java.time.LocalTime endTime,
            Integer excludeShowtimeId) {
        String sql = "SELECT COUNT(*) FROM showtimes " +
                "WHERE room_id = ? AND show_date = ? " +
                "AND status NOT IN ('CANCELLED','COMPLETED') " +
                "AND start_time < ? AND end_time > ? " +
                (excludeShowtimeId != null ? "AND showtime_id != ?" : "");
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            ps.setTime(3, java.sql.Time.valueOf(endTime));
            ps.setTime(4, java.sql.Time.valueOf(startTime));
            if (excludeShowtimeId != null)
                ps.setInt(5, excludeShowtimeId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cancel a showtime (set status to CANCELLED)
     */
    public boolean cancelShowtime(int showtimeId) {
        String sql = "UPDATE showtimes SET status = 'CANCELLED' WHERE showtime_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, showtimeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Auto-update showtime statuses for a branch based on current server time.
     * SCHEDULED -> ONGOING : show_date = today AND start_time <= now AND end_time >
     * now
     * SCHEDULED/ONGOING -> COMPLETED : (show_date < today) OR (show_date = today
     * AND end_time <= now)
     */
    public void autoUpdateStatuses(int branchId) {
        // Mark COMPLETED first (past showtimes)
        String sqlCompleted = "UPDATE showtimes SET status = 'COMPLETED' " +
                "WHERE status IN ('SCHEDULED','ONGOING') " +
                "AND room_id IN (SELECT room_id FROM screening_rooms WHERE branch_id = ?) " +
                "AND (show_date < CAST(GETDATE() AS DATE) " +
                "     OR (show_date = CAST(GETDATE() AS DATE) AND end_time <= CAST(GETDATE() AS TIME)))";
        try (PreparedStatement ps = connection.prepareStatement(sqlCompleted)) {
            ps.setInt(1, branchId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Mark ONGOING (currently showing)
        String sqlOngoing = "UPDATE showtimes SET status = 'ONGOING' " +
                "WHERE status = 'SCHEDULED' " +
                "AND room_id IN (SELECT room_id FROM screening_rooms WHERE branch_id = ?) " +
                "AND show_date = CAST(GETDATE() AS DATE) " +
                "AND start_time <= CAST(GETDATE() AS TIME) " +
                "AND end_time > CAST(GETDATE() AS TIME)";
        try (PreparedStatement ps = connection.prepareStatement(sqlOngoing)) {
            ps.setInt(1, branchId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Get all showtimes for a branch (joined with movie and room info)
     * with optional date + status filters.
     */
    /**
     * Get all showtimes for a branch with optional date, status, and movie keyword
     * filters.
     */
    public List<Map<String, Object>> getShowtimesByBranch(int branchId, java.time.LocalDate date,
            String statusFilter, String movieKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT st.showtime_id, st.movie_id, st.room_id, st.show_date, st.start_time, st.end_time, " +
                        "       st.base_price, st.status, st.created_at, " +
                        "       m.title AS movie_title, m.duration, m.poster_url, m.age_rating, " +
                        "       sr.room_name " +
                        "FROM showtimes st " +
                        "JOIN movies m ON st.movie_id = m.movie_id " +
                        "JOIN screening_rooms sr ON st.room_id = sr.room_id " +
                        "WHERE sr.branch_id = ? ");
        if (date != null)
            sql.append("AND st.show_date = ? ");
        if (statusFilter != null && !statusFilter.isBlank())
            sql.append("AND st.status = ? ");
        if (movieKeyword != null && !movieKeyword.isBlank())
            sql.append("AND m.title LIKE ? ");
        sql.append("ORDER BY st.show_date DESC, st.start_time ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, branchId);
            if (date != null)
                ps.setDate(idx++, java.sql.Date.valueOf(date));
            if (statusFilter != null && !statusFilter.isBlank())
                ps.setString(idx++, statusFilter);
            if (movieKeyword != null && !movieKeyword.isBlank())
                ps.setString(idx++, "%" + movieKeyword.trim() + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("showtimeId", rs.getInt("showtime_id"));
                    row.put("movieId", rs.getInt("movie_id"));
                    row.put("roomId", rs.getInt("room_id"));
                    row.put("showDate", rs.getDate("show_date") != null ? rs.getDate("show_date").toLocalDate() : null);
                    row.put("startTime",
                            rs.getTime("start_time") != null ? rs.getTime("start_time").toLocalTime() : null);
                    row.put("endTime", rs.getTime("end_time") != null ? rs.getTime("end_time").toLocalTime() : null);
                    row.put("basePrice", rs.getBigDecimal("base_price"));
                    row.put("status", rs.getString("status"));
                    row.put("movieTitle", rs.getString("movie_title"));
                    row.put("duration", rs.getInt("duration"));
                    row.put("posterUrl", rs.getString("poster_url"));
                    row.put("ageRating", rs.getString("age_rating"));
                    row.put("roomName", rs.getString("room_name"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 3-param backward-compat overload (no movie keyword) */
    public List<Map<String, Object>> getShowtimesByBranch(int branchId, java.time.LocalDate date, String statusFilter) {
        return getShowtimesByBranch(branchId, date, statusFilter, null);
    }

    /** 2-param backward-compat overload (no status/keyword filter) */
    public List<Map<String, Object>> getShowtimesByBranch(int branchId, java.time.LocalDate date) {
        return getShowtimesByBranch(branchId, date, null, null);
    }

    /**
     * Update a SCHEDULED showtime's date, start/end time, and base price.
     */
    public boolean updateShowtime(int showtimeId, java.time.LocalDate newDate,
            java.time.LocalTime newStart, java.time.LocalTime newEnd, java.math.BigDecimal newPrice) {
        String sql = "UPDATE showtimes SET show_date = ?, start_time = ?, end_time = ?, base_price = ? "
                + "WHERE showtime_id = ? AND status = 'SCHEDULED'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(newDate));
            ps.setTime(2, java.sql.Time.valueOf(newStart));
            ps.setTime(3, java.sql.Time.valueOf(newEnd));
            ps.setBigDecimal(4, newPrice);
            ps.setInt(5, showtimeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Hard-delete a CANCELLED showtime.
     */
    public boolean deleteShowtime(int showtimeId) {
        String sql = "DELETE FROM showtimes WHERE showtime_id = ? AND status IN ('CANCELLED', 'COMPLETED')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, showtimeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update the room of a SCHEDULED showtime.
     */
    public boolean updateShowtimeRoom(int showtimeId, int roomId) {
        String sql = "UPDATE showtimes SET room_id = ? WHERE showtime_id = ? AND status = 'SCHEDULED'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setInt(2, showtimeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Return counts of showtimes for a branch grouped by status.
     * Keys: total, SCHEDULED, ONGOING, COMPLETED, CANCELLED
     */
    public Map<String, Integer> countShowtimesByBranch(int branchId) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", 0);
        stats.put("SCHEDULED", 0);
        stats.put("ONGOING", 0);
        stats.put("COMPLETED", 0);
        stats.put("CANCELLED", 0);
        String sql = "SELECT st.status, COUNT(*) AS cnt FROM showtimes st "
                + "JOIN screening_rooms sr ON st.room_id = sr.room_id "
                + "WHERE sr.branch_id = ? GROUP BY st.status";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                int total = 0;
                while (rs.next()) {
                    String status = rs.getString("status");
                    if (status != null) {
                        status = status.trim().toUpperCase();
                        int cnt = rs.getInt("cnt");
                        stats.put(status, cnt);
                        total += cnt;
                    }
                }
                stats.put("total", total);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    /**
     * Get bookings/tickets for a showtime — used to preview impact before
     * cancellation.
     * Returns a list of maps with keys:
     * source (ONLINE/COUNTER), bookingId, userId, customerName, customerEmail,
     * finalAmount, paymentMethod, paymentStatus, bookingCode
     */
    public List<Map<String, Object>> getBookingsByShowtime(int showtimeId) {
        List<Map<String, Object>> list = new ArrayList<>();

        // Online bookings
        String onlineSql = """
                SELECT 'ONLINE' AS source,
                       b.booking_id, b.user_id, b.booking_code,
                       COALESCE(u.fullName, 'N/A') AS customer_name,
                       COALESCE(u.email, '')        AS customer_email,
                       b.final_amount, b.payment_method, b.payment_status
                FROM bookings b
                JOIN users u ON b.user_id = u.user_id
                WHERE b.showtime_id = ?
                  AND b.status NOT IN ('CANCELLED')
                """;
        try (PreparedStatement ps = connection.prepareStatement(onlineSql)) {
            ps.setInt(1, showtimeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("source", rs.getString("source"));
                    row.put("bookingId", rs.getInt("booking_id"));
                    row.put("userId", rs.getInt("user_id"));
                    row.put("bookingCode", rs.getString("booking_code"));
                    row.put("customerName", rs.getString("customer_name"));
                    row.put("customerEmail", rs.getString("customer_email"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentStatus", rs.getString("payment_status"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Counter tickets
        String counterSql = """
                SELECT 'COUNTER' AS source,
                       ct.ticket_id AS booking_id, NULL AS user_id,
                       CONCAT('C-', ct.ticket_id) AS booking_code,
                       COALESCE(ct.customer_name,  'Walk-in') AS customer_name,
                       COALESCE(ct.customer_email, '')         AS customer_email,
                       ct.price AS final_amount,
                       ct.payment_method, 'PAID' AS payment_status
                FROM counter_tickets ct
                WHERE ct.showtime_id = ?
                """;
        try (PreparedStatement ps = connection.prepareStatement(counterSql)) {
            ps.setInt(1, showtimeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("source", rs.getString("source"));
                    row.put("bookingId", rs.getInt("booking_id"));
                    row.put("userId", null);
                    row.put("bookingCode", rs.getString("booking_code"));
                    row.put("customerName", rs.getString("customer_name"));
                    row.put("customerEmail", rs.getString("customer_email"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentStatus", rs.getString("payment_status"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Cancel a showtime and trigger refund flagging for all associated bookings.
     *
     * Online bookings (bookings table) → status=CANCELLED,
     * payment_status=REFUND_PENDING
     * Counter tickets (counter_tickets) → no payment_status column, so we just note
     * they need manual refund
     *
     * Returns a summary Map with keys:
     * success (boolean), onlineRefunds (int), counterRefunds (int),
     * totalRefundAmount (BigDecimal), errorMsg (String)
     */
    public Map<String, Object> cancelShowtimeWithRefund(int showtimeId, String reason) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("onlineRefunds", 0);
        result.put("counterRefunds", 0);
        result.put("totalRefundAmount", java.math.BigDecimal.ZERO);

        boolean autoCommit = true;
        try {
            autoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            // 1. Cancel the showtime itself
            String cancelShowtime = "UPDATE showtimes SET status = 'CANCELLED' WHERE showtime_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(cancelShowtime)) {
                ps.setInt(1, showtimeId);
                if (ps.executeUpdate() == 0) {
                    connection.rollback();
                    result.put("errorMsg", "Suất chiếu không tồn tại hoặc đã bị huỷ.");
                    return result;
                }
            }

            // 2. Cancel online bookings and flag for refund
            int onlineRefunds = 0;
            java.math.BigDecimal totalOnline = java.math.BigDecimal.ZERO;

            String getBookings = """
                    SELECT booking_id, final_amount, payment_status
                    FROM bookings
                    WHERE showtime_id = ? AND status NOT IN ('CANCELLED')
                    """;
            List<Integer> paidBookingIds = new ArrayList<>();
            try (PreparedStatement ps = connection.prepareStatement(getBookings)) {
                ps.setInt(1, showtimeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int bId = rs.getInt("booking_id");
                        java.math.BigDecimal amt = rs.getBigDecimal("final_amount");
                        String pStatus = rs.getString("payment_status");
                        if ("PAID".equalsIgnoreCase(pStatus) || "COMPLETED".equalsIgnoreCase(pStatus)) {
                            paidBookingIds.add(bId);
                            if (amt != null)
                                totalOnline = totalOnline.add(amt);
                        }
                        onlineRefunds++;
                    }
                }
            }

            if (onlineRefunds > 0) {
                String safeReason = (reason != null && !reason.isBlank()) ? reason
                        : "Suất chiếu bị huỷ bởi Branch Manager";
                String updateBookings = """
                        UPDATE bookings
                        SET status = 'CANCELLED',
                            payment_status = CASE WHEN payment_status IN ('PAID','COMPLETED') THEN 'REFUND_PENDING' ELSE payment_status END,
                            cancellation_reason = ?,
                            cancelled_at = GETDATE()
                        WHERE showtime_id = ? AND status NOT IN ('CANCELLED')
                        """;
                try (PreparedStatement ps = connection.prepareStatement(updateBookings)) {
                    ps.setString(1, safeReason);
                    ps.setInt(2, showtimeId);
                    ps.executeUpdate();
                }
            }

            // 3. Count counter tickets
            int counterRefunds = 0;
            java.math.BigDecimal totalCounter = java.math.BigDecimal.ZERO;
            String countCounter = "SELECT COUNT(*) AS cnt, COALESCE(SUM(price), 0) AS total FROM counter_tickets WHERE showtime_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(countCounter)) {
                ps.setInt(1, showtimeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        counterRefunds = rs.getInt("cnt");
                        totalCounter = rs.getBigDecimal("total");
                    }
                }
            }

            connection.commit();

            result.put("success", true);
            result.put("onlineRefunds", onlineRefunds);
            result.put("onlinePaid", paidBookingIds.size());
            result.put("counterRefunds", counterRefunds);
            result.put("totalRefundAmount",
                    totalOnline.add(totalCounter != null ? totalCounter : java.math.BigDecimal.ZERO));

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            result.put("errorMsg", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        } finally {
            try {
                connection.setAutoCommit(autoCommit);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return result;
    }
}
