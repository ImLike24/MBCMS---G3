package repositories;

import config.DBContext;
import models.Movie;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Movies extends DBContext {
    
        // Liệt kê movie
        public List<Movie> getAllMovies() {
            List<Movie> list = new ArrayList<>();
            String sql = "SELECT * FROM movies";

            try (PreparedStatement st = connection.prepareStatement(sql);
                 ResultSet rs = st.executeQuery()) {

                while (rs.next()) {
                    Movie m = new Movie();
                    m.setMovieId(rs.getInt("movie_id"));
                    m.setTitle(rs.getString("title"));
                    m.setGenre(rs.getString("genre"));
                    m.setDuration(rs.getInt("duration"));
                    m.setRating(rs.getDouble("rating"));
                    m.setActive(rs.getBoolean("is_active"));
                    list.add(m);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return list;
        }
        
         // Tìm movie qua id
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
        
        // Thêm movie
        public void insertMovie(Movie m) {
            String sql = """
                INSERT INTO movies(title, genre, duration, rating, is_active, created_at)
                VALUES (?, ?, ?, ?, ?, GETDATE())
            """;
            try (PreparedStatement st = connection.prepareStatement(sql)) {
                st.setString(1, m.getTitle());
                st.setString(2, m.getGenre());
                st.setInt(3, m.getDuration());
                st.setDouble(4, m.getRating());
                st.setBoolean(5, m.isActive());
                st.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Cập nhật movie
        public void updateMovie(Movie m) {
            String sql = """
                UPDATE movies
                SET title=?, genre=?, duration=?, rating=?, is_active=?, updated_at=GETDATE()
                WHERE movie_id=?
            """;
            try (PreparedStatement st = connection.prepareStatement(sql)) {
                st.setString(1, m.getTitle());
                st.setString(2, m.getGenre());
                st.setInt(3, m.getDuration());
                st.setDouble(4, m.getRating());
                st.setBoolean(5, m.isActive());
                st.setInt(6, m.getMovieId());
                st.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Xóa movie
        public void deleteMovie(int id) {
            String sql = "DELETE FROM movies WHERE movie_id = ?";
            try (PreparedStatement st = connection.prepareStatement(sql)) {
                st.setInt(1, id);
                st.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
}
