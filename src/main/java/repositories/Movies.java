package repositories;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import config.DBContext;
import models.Movie;

public class Movies extends DBContext {
    
    public List<Movie> getMockUpMovies() {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT * FROM movies WHERE is_active = 1 ORDER BY release_date DESC";

        try (Statement stmt = connection.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                movies.add(mapResultSetToMovie(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    // Get all movies
    public List<Movie> getAllMovies() {
        List<Movie> movies = new ArrayList<>();

        String sql = """
                SELECT * FROM movies ORDER BY movie_id ASC
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Movie m = mapResultSetToMovie(rs);
                m.setGenres(getGenresByMovieId(m.getMovieId()));
                movies.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return movies;
    }

    // Get all active movies
    public List<Movie> getAllActiveMovies() {
        List<Movie> movies = new ArrayList<>();

        String sql = """
                SELECT * FROM movies WHERE is_active = 1 ORDER BY release_date DESC
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Movie m = mapResultSetToMovie(rs);
                m.setGenres(getGenresByMovieId(m.getMovieId()));
                movies.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return movies;
    }

    // Get movies showing today (with showtimes)
    public List<Movie> getMoviesShowingToday() {
        List<Movie> movies = new ArrayList<>();

        String sql = """
                SELECT DISTINCT m.*
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                WHERE m.is_active = 1
                  AND s.show_date = CAST(GETDATE() AS DATE)
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                ORDER BY m.title
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Movie m = mapResultSetToMovie(rs);
                m.setGenres(getGenresByMovieId(m.getMovieId()));
                movies.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    /**
     * Get movies showing on specific date
     */
    public List<Movie> getMoviesShowingOnDate(LocalDate date) {
        List<Movie> movies = new ArrayList<>();

        String sql = """
                SELECT DISTINCT m.*
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                ORDER BY m.title
                """;

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setDate(1, java.sql.Date.valueOf(date));

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Movie m = mapResultSetToMovie(rs);
                    m.setGenres(getGenresByMovieId(m.getMovieId()));
                    movies.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    public Movie getMovieById(int id) throws SQLException {
        String sql = "SELECT * FROM movies WHERE movie_id = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);

            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Movie m = mapResultSetToMovie(rs);
                    m.setGenres(getGenresByMovieId(m.getMovieId()));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Get movies showing on date with search, filter and pagination
     */
    public List<Movie> getMoviesShowingOnDateWithFilter(
            LocalDate date, String search, String genre,
            String ageRating, int page, int pageSize) {

        List<Movie> movies = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("""
                SELECT DISTINCT m.*
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                """);

        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.[cast] LIKE ?) ");
            String p = "%" + search.trim() + "%";
            params.add(p);
            params.add(p);
            params.add(p);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            sql.append(
                    "AND EXISTS (SELECT 1 FROM movie_genres mg JOIN genres g ON mg.genre_id = g.genre_id WHERE mg.movie_id = m.movie_id AND g.genre_name LIKE ?) ");
            params.add("%" + genre.trim() + "%");
        }

        if (ageRating != null && !ageRating.trim().isEmpty()) {
            sql.append("AND m.age_rating = ? ");
            params.add(ageRating.trim());
        }

        sql.append("""
                ORDER BY m.title
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """);

        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement pstmt = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof java.sql.Date) {
                    pstmt.setDate(i + 1, (java.sql.Date) param);
                } else if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                } else {
                    pstmt.setString(i + 1, (String) param);
                }
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Movie m = mapResultSetToMovie(rs);
                    m.setGenres(getGenresByMovieId(m.getMovieId()));
                    movies.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return movies;
    }

    /**
     * Count movies showing on date with search and filter
     */
    public int countMoviesShowingOnDateWithFilter(
            LocalDate date, String search, String genre, String ageRating) {

        StringBuilder sql = new StringBuilder();
        sql.append("""
                SELECT COUNT(DISTINCT m.movie_id)
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                """);

        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.[cast] LIKE ?) ");
            String p = "%" + search.trim() + "%";
            params.add(p);
            params.add(p);
            params.add(p);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            sql.append(
                    "AND EXISTS (SELECT 1 FROM movie_genres mg JOIN genres g ON mg.genre_id = g.genre_id WHERE mg.movie_id = m.movie_id AND g.genre_name LIKE ?) ");
            params.add("%" + genre.trim() + "%");
        }

        if (ageRating != null && !ageRating.trim().isEmpty()) {
            sql.append("AND m.age_rating = ? ");
            params.add(ageRating.trim());
        }

        try (PreparedStatement pstmt = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof java.sql.Date) {
                    pstmt.setDate(i + 1, (java.sql.Date) param);
                } else {
                    pstmt.setString(i + 1, (String) param);
                }
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<String> getAgeRatingsShowingOnDate(LocalDate date) {
        List<String> ageRatings = new ArrayList<>();
        String sql = "SELECT DISTINCT m.age_rating FROM movies m " +
                "INNER JOIN showtimes s ON m.movie_id = s.movie_id " +
                "WHERE m.is_active = 1 AND m.age_rating IS NOT NULL " +
                "AND s.show_date = ? " +
                "AND s.status IN ('SCHEDULED', 'ONGOING') " +
                "ORDER BY m.age_rating";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setDate(1, java.sql.Date.valueOf(date));

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String ageRating = rs.getString("age_rating");
                    if (ageRating != null && !ageRating.trim().isEmpty()) {
                        ageRatings.add(ageRating);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ageRatings;
    }

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
     * Helper method to map ResultSet to Movie object
     */
    private Movie mapResultSetToMovie(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setMovieId(rs.getInt("movie_id"));
        m.setTitle(rs.getString("title"));
        m.setDescription(rs.getString("description"));
        m.setDuration(rs.getInt("duration"));

        m.setGenres(new ArrayList<>()); // Initialize empty list, populated by caller

        if (rs.getDate("release_date") != null) {
            m.setReleaseDate(rs.getDate("release_date").toLocalDate());
        }
        if (rs.getDate("end_date") != null) {
            m.setEndDate(rs.getDate("end_date").toLocalDate());
        }

        m.setRating(rs.getDouble("rating"));
        m.setAgeRating(rs.getString("age_rating"));
        m.setDirector(rs.getString("director"));
        m.setCast(rs.getString("cast"));
        m.setPosterUrl(rs.getString("poster_url"));
        m.setActive(rs.getBoolean("is_active"));

        if (rs.getTimestamp("created_at") != null) {
            m.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            m.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }

        return m;
    }
    
    public void insertMovieWithGenres(Movie m, List<Integer> genreIds) throws SQLException {
        String insertMovieSql = """
            INSERT INTO movies 
            (title, description, duration, release_date, end_date, rating, age_rating, 
             director, cast, poster_url, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())
        """;

        String insertGenreSql = "INSERT INTO movie_genres (movie_id, genre_id) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = connection;
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(insertMovieSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, m.getTitle());
                ps.setString(2, m.getDescription());
                ps.setInt(3, m.getDuration() != null ? m.getDuration() : 0);
                ps.setDate(4, m.getReleaseDate() != null ? Date.valueOf(m.getReleaseDate()) : null);
                ps.setDate(5, m.getEndDate() != null ? Date.valueOf(m.getEndDate()) : null);
                ps.setDouble(6, m.getRating() != null ? m.getRating() : 0.0);
                ps.setString(7, m.getAgeRating());
                ps.setString(8, m.getDirector());
                ps.setString(9, m.getCast());
                ps.setString(10, m.getPosterUrl());
                ps.setBoolean(11, m.isActive());

                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        m.setMovieId(rs.getInt(1));
                    } else {
                        throw new SQLException("Không lấy được movie_id");
                    }
                }
            }

            if (genreIds != null && !genreIds.isEmpty()) {
                try (PreparedStatement psGenre = conn.prepareStatement(insertGenreSql)) {
                    for (Integer genreId : genreIds) {
                        psGenre.setInt(1, m.getMovieId());
                        psGenre.setInt(2, genreId);
                        psGenre.addBatch();
                    }
                    psGenre.executeBatch();
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
    
    public void updateMovieWithGenres(Movie m, List<Integer> genreIds) throws SQLException {
        String updateMovieSql = """
            UPDATE movies SET
                title = ?,
                description = ?,
                duration = ?,
                release_date = ?,
                end_date = ?,
                rating = ?,
                age_rating = ?,
                director = ?,
                cast = ?,
                poster_url = ?,
                is_active = ?,
                updated_at = GETDATE()
            WHERE movie_id = ?
        """;

        String deleteGenresSql = "DELETE FROM movie_genres WHERE movie_id = ?";
        String insertGenreSql = "INSERT INTO movie_genres (movie_id, genre_id) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = connection;
            conn.setAutoCommit(false);

            // 1. Update thông tin phim
            try (PreparedStatement ps = conn.prepareStatement(updateMovieSql)) {
                ps.setString(1, m.getTitle());
                ps.setString(2, m.getDescription());
                ps.setInt(3, m.getDuration() != null ? m.getDuration() : 0);
                ps.setDate(4, m.getReleaseDate() != null ? Date.valueOf(m.getReleaseDate()) : null);
                ps.setDate(5, m.getEndDate() != null ? Date.valueOf(m.getEndDate()) : null);
                ps.setDouble(6, m.getRating() != null ? m.getRating() : 0.0);
                ps.setString(7, m.getAgeRating());
                ps.setString(8, m.getDirector());
                ps.setString(9, m.getCast());
                ps.setString(10, m.getPosterUrl());
                ps.setBoolean(11, m.isActive());
                ps.setInt(12, m.getMovieId());

                int rows = ps.executeUpdate();
                if (rows == 0) {
                    throw new SQLException("Không tìm thấy phim với ID " + m.getMovieId());
                }
            }

            // 2. Xóa hết thể loại cũ của phim
            try (PreparedStatement psDelete = conn.prepareStatement(deleteGenresSql)) {
                psDelete.setInt(1, m.getMovieId());
                psDelete.executeUpdate();
            }

            // 3. Insert thể loại mới (nếu có)
            if (genreIds != null && !genreIds.isEmpty()) {
                try (PreparedStatement psInsert = conn.prepareStatement(insertGenreSql)) {
                    for (Integer genreId : genreIds) {
                        psInsert.setInt(1, m.getMovieId());
                        psInsert.setInt(2, genreId);
                        psInsert.addBatch();
                    }
                    psInsert.executeBatch();
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
}