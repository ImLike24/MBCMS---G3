package repositories;

import config.DBContext;
import models.Review;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Reviews extends DBContext {

    public List<Review> getReviewsByMovieId(int movieId, int limit, int offset) {
        List<Review> list = new ArrayList<>();
        // Join with users to get username and avatar
        String sql = "SELECT r.*, u.username, u.avatarURL " +
                "FROM reviews r " +
                "JOIN users u ON r.user_id = u.user_id " +
                "WHERE r.movie_id = ? " +
                "ORDER BY r.created_at DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, movieId);
            st.setInt(2, offset);
            st.setInt(3, limit);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setMovieId(rs.getInt("movie_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setHelpfulCount(rs.getInt("helpful_count"));
                    r.setVerified(rs.getBoolean("is_verified"));

                    if (rs.getTimestamp("created_at") != null)
                        r.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    if (rs.getTimestamp("updated_at") != null)
                        r.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());

                    // Set joined user info
                    r.setUsername(rs.getString("username"));
                    r.setAvatarUrl(rs.getString("avatarURL"));

                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addReview(Review r) {
        String sql = "INSERT INTO reviews (user_id, movie_id, rating, comment, is_verified, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, r.getUserId());
            st.setInt(2, r.getMovieId());
            st.setDouble(3, r.getRating());
            st.setString(4, r.getComment());
            st.setBoolean(5, r.isVerified());
            st.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));

            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
