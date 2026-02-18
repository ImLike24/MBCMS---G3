package repositories;

import config.DBContext;
import models.Genre;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Genres extends DBContext {

    // Get all active genres
    public List<Genre> getAllActiveGenres() {
        List<Genre> list = new ArrayList<>();

        String sql = """
            SELECT genre_id, genre_name, description, is_active
            FROM genres
            WHERE is_active = 1
            ORDER BY genre_name
            """;

        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Genre g = new Genre();
                g.setGenreId(rs.getInt("genre_id"));
                g.setGenreName(rs.getString("genre_name"));
                g.setDescription(rs.getString("description"));
                g.setActive(rs.getBoolean("is_active"));
                list.add(g);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // Get genres by movie id
    public List<Genre> getGenresByMovieId(int movieId) {
        List<Genre> list = new ArrayList<>();

        String sql = """
            SELECT g.genre_id, g.genre_name, g.description, g.is_active
            FROM genres g
            INNER JOIN movie_genres mg ON g.genre_id = mg.genre_id
            WHERE mg.movie_id = ?
              AND g.is_active = 1
            ORDER BY g.genre_name
            """;

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, movieId);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Genre g = new Genre();
                    g.setGenreId(rs.getInt("genre_id"));
                    g.setGenreName(rs.getString("genre_name"));
                    g.setDescription(rs.getString("description"));
                    g.setActive(rs.getBoolean("is_active"));
                    list.add(g);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public List<Genre> getAllGenres() {
        List<Genre> list = new ArrayList<>();
        String sql = "SELECT * FROM genres ORDER BY genre_name";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Genre g = mapRowToGenre(rs);
                list.add(g);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Genre getGenreById(int id) {
        String sql = "SELECT * FROM genres WHERE genre_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapRowToGenre(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addGenre(Genre genre) {
        String sql = "INSERT INTO genres (genre_name, description, is_active) VALUES (?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, genre.getGenreName());
            st.setString(2, genre.getDescription());
            st.setBoolean(3, genre.isActive());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateGenre(Genre genre) {
        String sql = "UPDATE genres SET genre_name = ?, description = ?, is_active = ?, updated_at = SYSDATETIME() WHERE genre_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, genre.getGenreName());
            st.setString(2, genre.getDescription());
            st.setBoolean(3, genre.isActive());
            st.setInt(4, genre.getGenreId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteGenre(int id) {
        // Soft delete (khuyến nghị)
        String sql = "UPDATE genres SET is_active = 0, updated_at = SYSDATETIME() WHERE genre_id = ?";
        // Hoặc hard delete: "DELETE FROM genres WHERE genre_id = ?"
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Genre mapRowToGenre(ResultSet rs) throws SQLException {
        Genre g = new Genre();
        g.setGenreId(rs.getInt("genre_id"));
        g.setGenreName(rs.getString("genre_name"));
        g.setDescription(rs.getString("description"));
        g.setActive(rs.getBoolean("is_active"));
        // Nếu model có created_at, updated_at thì map thêm
        // g.setCreatedAt(rs.getTimestamp("created_at"));
        // g.setUpdatedAt(rs.getTimestamp("updated_at"));
        return g;
    }
}