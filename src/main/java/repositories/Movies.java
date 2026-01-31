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

    /**
     * Get all active movies
     */
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

    /**
     * Get movies showing today (with showtimes)
     */
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
}