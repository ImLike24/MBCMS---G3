package repositories;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import config.DBContext;
import models.dtos.BookingHistoryDTO;

public class BookingHistories extends DBContext {

    public int countHistory(int userId, String fromDate, String toDate) {
        String sql = """
                SELECT COUNT(*)
                FROM bookings b
                JOIN showtimes st ON b.showtime_id = st.showtime_id
                JOIN movies m ON st.movie_id = m.movie_id
                JOIN screening_rooms r ON st.room_id = r.room_id
                JOIN cinema_branches cb ON r.branch_id = cb.branch_id
                WHERE b.user_id = ?
                  AND (? IS NULL OR b.booking_time >= ?)
                  AND (? IS NULL OR b.booking_time < DATEADD(day, 1, ?))
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setObject(2, fromDate);
            ps.setObject(3, fromDate);
            ps.setObject(4, toDate);
            ps.setObject(5, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BookingHistoryDTO> getHistory(int userId, String fromDate, String toDate, int offset, int limit) {
        List<BookingHistoryDTO> list = new ArrayList<>();

        String sql = """
                SELECT
                    b.booking_code AS transactionCode,
                    b.booking_time AS transactionDate,
                    cb.branch_name AS branchName,
                    b.payment_method AS paymentMethod,
                    CAST(b.final_amount AS FLOAT) AS totalAmount,
                    'ONLINE' AS transactionType,
                    m.title AS movieTitle,
                    (SELECT STRING_AGG(s.seat_code, ', ')
                     FROM online_tickets ot
                     JOIN seats s ON ot.seat_id = s.seat_id
                     WHERE ot.booking_id = b.booking_id) AS seatCodes,
                    (SELECT STRING_AGG(s.seat_type, ', ')
                     FROM online_tickets ot
                     JOIN seats s ON ot.seat_id = s.seat_id
                     WHERE ot.booking_id = b.booking_id) AS seatTypes
                FROM bookings b
                JOIN showtimes st ON b.showtime_id = st.showtime_id
                JOIN movies m ON st.movie_id = m.movie_id
                JOIN screening_rooms r ON st.room_id = r.room_id
                JOIN cinema_branches cb ON r.branch_id = cb.branch_id
                WHERE b.user_id = ?
                  AND (? IS NULL OR b.booking_time >= ?)
                  AND (? IS NULL OR b.booking_time < DATEADD(day, 1, ?))

                ORDER BY transactionDate DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setObject(2, fromDate);
            ps.setObject(3, fromDate);
            ps.setObject(4, toDate);
            ps.setObject(5, toDate);
            ps.setInt(6, offset);
            ps.setInt(7, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookingHistoryDTO dto = new BookingHistoryDTO(
                    rs.getString("transactionCode"),
                        rs.getTimestamp("transactionDate"),
                        rs.getString("branchName"),
                        rs.getString("paymentMethod"),
                        rs.getDouble("totalAmount"),
                        rs.getString("transactionType"),
                        rs.getString("movieTitle"),
                        rs.getString("seatCodes"),
                        rs.getString("seatTypes"));
                        list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
