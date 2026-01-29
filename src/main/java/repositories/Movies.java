package repositories;

import config.DBContext;
import models.Movie;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Movies extends DBContext {

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
}
