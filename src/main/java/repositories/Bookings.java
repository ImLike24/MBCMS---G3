package repositories;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.math.BigDecimal;

import config.DBContext;

public class Bookings {

    private Connection conn;

    public Bookings() throws Exception {
        conn = new DBContext().getConnection();
    }
    
    public void closeConnection() {

        try {

            if (conn != null && !conn.isClosed()) {
                conn.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Update booking PAID
    public boolean updateBookingPaid(String bookingCode, BigDecimal amount) {

        String sql = """
            UPDATE bookings
            SET payment_status='PAID',
                status='CONFIRMED',
                total_amount=?,
                final_amount=?,
                payment_time=SYSDATETIME()
            WHERE booking_code=?
        """;

        try {

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setBigDecimal(1, amount);
            ps.setBigDecimal(2, amount);
            ps.setString(3, bookingCode);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Get bookingId
    public int getBookingId(String bookingCode) {

        String sql = "SELECT booking_id FROM bookings WHERE booking_code=?";

        try {

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, bookingCode);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("booking_id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    // Insert online ticket
    public void insertOnlineTicket(int bookingId,int showtimeId,int seatId) throws Exception {

        String sql = """
        INSERT INTO online_tickets
        (booking_id,showtime_id,seat_id)
        VALUES (?,?,?)
        """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setInt(1,bookingId);
        ps.setInt(2,showtimeId);
        ps.setInt(3,seatId);

        ps.executeUpdate();
    }

    // Delete booking
    public void deleteBooking(String bookingCode) throws Exception {

        String sql1 = """
        DELETE FROM online_tickets
        WHERE booking_id = (
            SELECT booking_id FROM bookings WHERE booking_code=?
        )
        """;

        PreparedStatement ps1 = conn.prepareStatement(sql1);
        ps1.setString(1,bookingCode);
        ps1.executeUpdate();


        String sql2 = "DELETE FROM bookings WHERE booking_code=?";

        PreparedStatement ps2 = conn.prepareStatement(sql2);
        ps2.setString(1,bookingCode);
        ps2.executeUpdate();
    }
        
    public int getShowtimeIdByCode(String bookingCode) throws Exception {
        String sql = "SELECT showtime_id FROM bookings WHERE booking_code=?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);

        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            return rs.getInt("showtime_id");
        }

        return 0;
    }
    
    public int getBookingIdByCode(String bookingCode) throws Exception {

        String sql = "SELECT booking_id FROM bookings WHERE booking_code = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            return rs.getInt("booking_id");
        }

        return 0;
    }
    
    public String getSeatIdsByBookingCode(String bookingCode) throws Exception {

        String sql = """
            SELECT seat_id
            FROM online_tickets
            WHERE booking_id = (
                SELECT booking_id
                FROM bookings
                WHERE booking_code = ?
            )
        """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, bookingCode);

        ResultSet rs = ps.executeQuery();

        StringBuilder seatIds = new StringBuilder();

        while(rs.next()){

            if(seatIds.length() > 0){
                seatIds.append(",");
            }

            seatIds.append(rs.getInt("seat_id"));
        }

        return seatIds.toString();
    }
    
    public int insertBooking(int userId,int showtimeId,String bookingCode,BigDecimal amount) throws Exception {
        String sql = """
        INSERT INTO bookings
        (user_id,showtime_id,booking_code,total_amount,final_amount,payment_status)
        VALUES (?,?,?, ?, ?, 'PENDING')
        """;

        PreparedStatement ps = conn.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS);

        ps.setInt(1,userId);
        ps.setInt(2,showtimeId);
        ps.setString(3,bookingCode);
        ps.setBigDecimal(4,amount);
        ps.setBigDecimal(5,amount);

        ps.executeUpdate();

        ResultSet rs = ps.getGeneratedKeys();

        if(rs.next()){
            return rs.getInt(1);
        }
        return 0;
    }
    
    public void confirmBooking(String bookingCode) throws Exception {
        String sql1 = """
        UPDATE bookings
        SET payment_status='PAID',
            status='CONFIRMED',
            payment_time=SYSDATETIME()
        WHERE booking_code=?
        """;

        PreparedStatement ps1 = conn.prepareStatement(sql1);
        ps1.setString(1,bookingCode);
        ps1.executeUpdate();
    }
}