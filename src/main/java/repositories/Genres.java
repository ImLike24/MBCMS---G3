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
}