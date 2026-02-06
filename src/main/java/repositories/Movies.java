package repositories;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import config.DBContext;
import models.Movie;

public class Movies extends DBContext {

    // Get all movies
    public List<Movie> getAllMovies() {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT * FROM movies ORDER BY movie_id ASC";

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

    // Get movies showing today (with showtimes)
    public List<Movie> getMoviesShowingToday() {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT DISTINCT m.* FROM movies m " +
                    "INNER JOIN showtimes s ON m.movie_id = s.movie_id " +
                    "WHERE m.is_active = 1 " +
                    "AND s.show_date = CAST(GETDATE() AS DATE) " +
                    "AND s.status IN ('SCHEDULED', 'ONGOING') " +
                    "ORDER BY m.title";
        
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

    /**
     * Get movies showing on specific date
     */
    public List<Movie> getMoviesShowingOnDate(LocalDate date) {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT DISTINCT m.* FROM movies m " +
                    "INNER JOIN showtimes s ON m.movie_id = s.movie_id " +
                    "WHERE m.is_active = 1 " +
                    "AND s.show_date = ? " +
                    "AND s.status IN ('SCHEDULED', 'ONGOING') " +
                    "ORDER BY m.title";
        
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
        String sql = "SELECT * FROM movies WHERE movie_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Movie m = new Movie();
                    m.setMovieId(rs.getInt("movie_id"));
                    m.setTitle(rs.getString("title"));
                    m.setDescription(rs.getString("description"));
                    m.setGenre(rs.getString("genre"));
                    m.setDuration(rs.getInt("duration"));
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get movies showing on date with search, filter and pagination
     */
    public List<Movie> getMoviesShowingOnDateWithFilter(LocalDate date, String search, String genre, 
            String ageRating, int page, int pageSize) {
        List<Movie> movies = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT m.* FROM movies m ")
           .append("INNER JOIN showtimes s ON m.movie_id = s.movie_id ")
           .append("WHERE m.is_active = 1 ")
           .append("AND s.show_date = ? ")
           .append("AND s.status IN ('SCHEDULED', 'ONGOING') ");
        
        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.cast LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (genre != null && !genre.trim().isEmpty()) {
            sql.append("AND m.genre LIKE ? ");
            params.add("%" + genre.trim() + "%");
        }
        
        if (ageRating != null && !ageRating.trim().isEmpty()) {
            sql.append("AND m.age_rating = ? ");
            params.add(ageRating.trim());
        }
        
        sql.append("ORDER BY m.title ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
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
    public int countMoviesShowingOnDateWithFilter(LocalDate date, String search, String genre, String ageRating) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(DISTINCT m.movie_id) FROM movies m ")
           .append("INNER JOIN showtimes s ON m.movie_id = s.movie_id ")
           .append("WHERE m.is_active = 1 ")
           .append("AND s.show_date = ? ")
           .append("AND s.status IN ('SCHEDULED', 'ONGOING') ");
        
        List<Object> params = new ArrayList<>();
        params.add(java.sql.Date.valueOf(date));
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (m.title LIKE ? OR m.director LIKE ? OR m.cast LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (genre != null && !genre.trim().isEmpty()) {
            sql.append("AND m.genre LIKE ? ");
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
    public List<String> getGenresShowingOnDate(LocalDate date) {
        List<String> genres = new ArrayList<>();
        String sql = "SELECT DISTINCT m.genre FROM movies m " +
                    "INNER JOIN showtimes s ON m.movie_id = s.movie_id " +
                    "WHERE m.is_active = 1 AND m.genre IS NOT NULL " +
                    "AND s.show_date = ? " +
                    "AND s.status IN ('SCHEDULED', 'ONGOING') " +
                    "ORDER BY m.genre";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setDate(1, java.sql.Date.valueOf(date));
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String genre = rs.getString("genre");
                    if (genre != null && !genre.trim().isEmpty()) {
                        genres.add(genre);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return genres;
    }

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
        m.setGenre(rs.getString("genre"));
        m.setDuration(rs.getInt("duration"));
        
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

    /**
     * Insert a new movie
     */
    public boolean insertMovie(Movie movie) {
        String sql = "INSERT INTO movies (title, description, genre, duration, release_date, end_date, " +
                    "age_rating, director, cast, poster_url, is_active) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, movie.getTitle());
            pstmt.setString(2, movie.getDescription());
            pstmt.setString(3, movie.getGenre());
            pstmt.setInt(4, movie.getDuration());
            
            if (movie.getReleaseDate() != null) {
                pstmt.setDate(5, java.sql.Date.valueOf(movie.getReleaseDate()));
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
            }
            
            if (movie.getEndDate() != null) {
                pstmt.setDate(6, java.sql.Date.valueOf(movie.getEndDate()));
            } else {
                pstmt.setNull(6, java.sql.Types.DATE);
            }
            
            pstmt.setString(7, movie.getAgeRating());
            pstmt.setString(8, movie.getDirector());
            pstmt.setString(9, movie.getCast());
            pstmt.setString(10, movie.getPosterUrl());
            pstmt.setBoolean(11, movie.isActive());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing movie
     */
    public boolean updateMovie(Movie movie) {
        String sql = "UPDATE movies SET title = ?, description = ?, genre = ?, duration = ?, " +
                    "release_date = ?, end_date = ?, age_rating = ?, director = ?, cast = ?, " +
                    "poster_url = ?, is_active = ? WHERE movie_id = ?";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, movie.getTitle());
            pstmt.setString(2, movie.getDescription());
            pstmt.setString(3, movie.getGenre());
            pstmt.setInt(4, movie.getDuration());
            
            if (movie.getReleaseDate() != null) {
                pstmt.setDate(5, java.sql.Date.valueOf(movie.getReleaseDate()));
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
            }
            
            if (movie.getEndDate() != null) {
                pstmt.setDate(6, java.sql.Date.valueOf(movie.getEndDate()));
            } else {
                pstmt.setNull(6, java.sql.Types.DATE);
            }
            
            pstmt.setString(7, movie.getAgeRating());
            pstmt.setString(8, movie.getDirector());
            pstmt.setString(9, movie.getCast());
            pstmt.setString(10, movie.getPosterUrl());
            pstmt.setBoolean(11, movie.isActive());
            pstmt.setInt(12, movie.getMovieId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a movie (soft delete by setting is_active = false)
     */
    public boolean deleteMovie(int movieId) {
        String sql = "UPDATE movies SET is_active = 0 WHERE movie_id = ?";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, movieId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all movies (including inactive for admin)
     */
    public List<Movie> getAllMovies() {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT * FROM movies ORDER BY created_at DESC";
        
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

    /**
     * Search movies by title, director, or cast
     */
    public List<Movie> searchMovies(String keyword) {
        List<Movie> movies = new ArrayList<>();
        String sql = "SELECT * FROM movies WHERE (title LIKE ? OR director LIKE ? OR cast LIKE ?) ORDER BY title";
        
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            
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
}