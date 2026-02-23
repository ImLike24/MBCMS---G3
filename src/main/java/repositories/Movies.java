package repositories;

import config.DBContext;
import models.Movie;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

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
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
                ORDER BY m.movie_id ASC
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                movies.add(mapResultSetToMovie(rs));
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
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.is_active = 1
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
                ORDER BY m.release_date DESC
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                movies.add(mapResultSetToMovie(rs));
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
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.is_active = 1
                  AND s.show_date = CAST(GETDATE() AS DATE)
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
                ORDER BY m.title
                """;

        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                movies.add(mapResultSetToMovie(rs));
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
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
                ORDER BY m.title
                """;

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setDate(1, java.sql.Date.valueOf(date));

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    movies.add(mapResultSetToMovie(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    public Movie getMovieById(int id) {
        String sql = """
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.movie_id = ?
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
                """;

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);

            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToMovie(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
                SELECT m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                FROM movies m
                INNER JOIN showtimes s ON m.movie_id = s.movie_id
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                """);

        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.cast LIKE ?) ");
            String p = "%" + search.trim() + "%";
            params.add(p);
            params.add(p);
            params.add(p);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            sql.append("AND g.genre_name LIKE ? ");
            params.add("%" + genre.trim() + "%");
        }

        if (ageRating != null && !ageRating.trim().isEmpty()) {
            sql.append("AND m.age_rating = ? ");
            params.add(ageRating.trim());
        }

        sql.append("""
                GROUP BY
                    m.movie_id, m.title, m.description, m.duration,
                    m.release_date, m.end_date, m.rating, m.age_rating,
                    m.director, m.cast, m.poster_url, m.is_active,
                    m.created_at, m.updated_at
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
                    movies.add(mapResultSetToMovie(rs));
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
                LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                LEFT JOIN genres g ON mg.genre_id = g.genre_id
                WHERE m.is_active = 1
                  AND s.show_date = ?
                  AND s.status IN ('SCHEDULED', 'ONGOING')
                """);

        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.cast LIKE ?) ");
            String p = "%" + search.trim() + "%";
            params.add(p);
            params.add(p);
            params.add(p);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            sql.append("AND g.genre_name LIKE ? ");
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

    /**
     * Get distinct genres from movies showing on date
     */
    // public List<String> getGenresShowingOnDate(LocalDate date) {
    // List<String> genres = new ArrayList<>();
    // String sql = "SELECT DISTINCT m.genre FROM movies m " +
    // "INNER JOIN showtimes s ON m.movie_id = s.movie_id " +
    // "WHERE m.is_active = 1 AND m.genre IS NOT NULL " +
    // "AND s.show_date = ? " +
    // "AND s.status IN ('SCHEDULED', 'ONGOING') " +
    // "ORDER BY m.genre";
    //
    // try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
    // pstmt.setDate(1, java.sql.Date.valueOf(date));
    //
    // try (ResultSet rs = pstmt.executeQuery()) {
    // while (rs.next()) {
    // String genre = rs.getString("genres");
    // if (genre != null && !genre.trim().isEmpty()) {
    // genres.add(genre);
    // }
    // }
    // }
    // } catch (SQLException e) {
    // e.printStackTrace();
    // }
    // return genres;
    // }

    /**
     * Get distinct age ratings from movies showing on date
     */
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

    /**
     * Helper method to map ResultSet to Movie object
     */
    private Movie mapResultSetToMovie(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setMovieId(rs.getInt("movie_id"));
        m.setTitle(rs.getString("title"));
        m.setDescription(rs.getString("description"));
        m.setDuration(rs.getInt("duration"));

        // NEW: map genres
        String genreList = rs.getString("genre_list");
        if (genreList != null && !genreList.isEmpty()) {
            m.setGenres(List.of(genreList.split("\\s*,\\s*")));
        } else {
            m.setGenres(new ArrayList<>());
        }

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

    public void insertMovieWithGenres(Movie m, List<Integer> genreIds) {
        String insertMovieSql = """
                INSERT INTO movies
                (title, description, duration, release_date, end_date, rating, age_rating,
                 director, cast, poster_url, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        String insertMovieGenreSql = """
                INSERT INTO movie_genres (movie_id, genre_id)
                VALUES (?, ?)
                """;

        Connection conn = null;

        try {
            conn = connection;
            conn.setAutoCommit(false);

            // 1. Insert movie
            int movieId;
            try (PreparedStatement ps = conn.prepareStatement(
                    insertMovieSql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, m.getTitle());
                ps.setString(2, m.getDescription());
                ps.setInt(3, m.getDuration());
                ps.setDate(4, m.getReleaseDate() != null ? Date.valueOf(m.getReleaseDate()) : null);
                ps.setDate(5, m.getEndDate() != null ? Date.valueOf(m.getEndDate()) : null);
                ps.setDouble(6, m.getRating());
                ps.setString(7, m.getAgeRating());
                ps.setString(8, m.getDirector());
                ps.setString(9, m.getCast());
                ps.setString(10, m.getPosterUrl());
                ps.setBoolean(11, m.isActive());

                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        movieId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to retrieve movie_id.");
                    }
                }
            }

            // 2. Insert movie_genres
            try (PreparedStatement ps = conn.prepareStatement(insertMovieGenreSql)) {
                for (Integer genreId : genreIds) {
                    ps.setInt(1, movieId);
                    ps.setInt(2, genreId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null)
                    conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (conn != null)
                    conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public void updateMovieWithGenres(Movie m, List<Integer> genreIds) {
        String updateMovieSql = """
                UPDATE movies
                SET title = ?, description = ?, duration = ?, release_date = ?, end_date = ?,
                    rating = ?, age_rating = ?, director = ?, cast = ?, poster_url = ?, is_active = ?
                WHERE movie_id = ?
                """;

        String deleteMovieGenresSql = """
                DELETE FROM movie_genres WHERE movie_id = ?
                """;

        String insertMovieGenreSql = """
                INSERT INTO movie_genres (movie_id, genre_id)
                VALUES (?, ?)
                """;

        Connection conn = null;

        try {
            conn = connection;
            conn.setAutoCommit(false);

            // 1. Update movies
            try (PreparedStatement ps = conn.prepareStatement(updateMovieSql)) {
                ps.setString(1, m.getTitle());
                ps.setString(2, m.getDescription());
                ps.setInt(3, m.getDuration());
                ps.setDate(4, m.getReleaseDate() != null ? Date.valueOf(m.getReleaseDate()) : null);
                ps.setDate(5, m.getEndDate() != null ? Date.valueOf(m.getEndDate()) : null);
                ps.setDouble(6, m.getRating());
                ps.setString(7, m.getAgeRating());
                ps.setString(8, m.getDirector());
                ps.setString(9, m.getCast());
                ps.setString(10, m.getPosterUrl());
                ps.setBoolean(11, m.isActive());
                ps.setInt(12, m.getMovieId());

                ps.executeUpdate();
            }

            // 2. Delete old genres
            try (PreparedStatement ps = conn.prepareStatement(deleteMovieGenresSql)) {
                ps.setInt(1, m.getMovieId());
                ps.executeUpdate();
            }

            // 3. Insert new genres
            try (PreparedStatement ps = conn.prepareStatement(insertMovieGenreSql)) {
                for (Integer genreId : genreIds) {
                    ps.setInt(1, m.getMovieId());
                    ps.setInt(2, genreId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null)
                    conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (conn != null)
                    conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public void deleteMovieWithGenres(int movieId) {
        String deleteMovieGenresSql = """
                DELETE FROM movie_genres WHERE movie_id = ?
                """;

        String deleteMovieSql = """
                DELETE FROM movies WHERE movie_id = ?
                """;

        Connection conn = null;

        try {
            conn = connection;
            conn.setAutoCommit(false);

            // 1. Delete from movie_genres
            try (PreparedStatement ps = conn.prepareStatement(deleteMovieGenresSql)) {
                ps.setInt(1, movieId);
                ps.executeUpdate();
            }

            // 2. Delete from movies
            try (PreparedStatement ps = conn.prepareStatement(deleteMovieSql)) {
                ps.setInt(1, movieId);
                ps.executeUpdate();
            }

            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null)
                    conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (conn != null)
                    conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public List<Movie> getNowShowing() {
        // Lấy 12 phim đang chiếu, sắp xếp theo ngày phát hành mới nhất
        String sql = """
                    SELECT TOP 12 m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                    FROM movies m
                    LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                    LEFT JOIN genres g ON mg.genre_id = g.genre_id
                    WHERE m.is_active = 1
                      AND m.release_date <= CAST(GETDATE() AS DATE)
                      AND (m.end_date IS NULL OR m.end_date >= CAST(GETDATE() AS DATE))
                    GROUP BY
                        m.movie_id, m.title, m.description, m.duration,
                        m.release_date, m.end_date, m.rating, m.age_rating,
                        m.director, m.cast, m.poster_url, m.is_active,
                        m.created_at, m.updated_at
                    ORDER BY m.release_date DESC
                """;
        return getMoviesBySql(sql);
    }

    public List<Movie> getComingSoon() {
        // Lấy 12 phim sắp chiếu
        String sql = """
                    SELECT TOP 12 m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                    FROM movies m
                    LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                    LEFT JOIN genres g ON mg.genre_id = g.genre_id
                    WHERE m.is_active = 1
                      AND m.release_date > CAST(GETDATE() AS DATE)
                    GROUP BY
                        m.movie_id, m.title, m.description, m.duration,
                        m.release_date, m.end_date, m.rating, m.age_rating,
                        m.director, m.cast, m.poster_url, m.is_active,
                        m.created_at, m.updated_at
                    ORDER BY m.release_date ASC
                """;
        return getMoviesBySql(sql);
    }

    public List<Movie> getTopRated(int limit) {
        // Lấy phim có rating cao nhất
        String sql = """
                    SELECT TOP (?) m.*, STRING_AGG(g.genre_name, ', ') AS genre_list
                    FROM movies m
                    LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
                    LEFT JOIN genres g ON mg.genre_id = g.genre_id
                    WHERE m.is_active = 1
                    GROUP BY
                        m.movie_id, m.title, m.description, m.duration,
                        m.release_date, m.end_date, m.rating, m.age_rating,
                        m.director, m.cast, m.poster_url, m.is_active,
                        m.created_at, m.updated_at
                    ORDER BY m.rating DESC
                """;
        return getMoviesBySql(sql, limit);
    }

    private List<Movie> getMoviesBySql(String sql, Object... params) {
        List<Movie> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToMovie(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
