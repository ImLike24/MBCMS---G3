package payment;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

import repositories.Bookings;

@WebServlet("/FinalizeBooking")
public class FinalizeBooking extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            
            Bookings bookingRepo = new Bookings();
            
            String bookingCode = request.getParameter("vnp_TxnRef");
            String transactionStatus = request.getParameter("vnp_TransactionStatus");
            String seatIds = bookingRepo.getSeatIdsByBookingCode(bookingCode);
            
            if ("00".equals(transactionStatus)) {
                
                bookingRepo.confirmBooking(bookingCode);

                int bookingId = bookingRepo.getBookingIdByCode(bookingCode);
                int showtimeId = bookingRepo.getShowtimeIdByCode(bookingCode);

                for(String seat : seatIds.split(",")){
                    if(seat == null || seat.trim().isEmpty()){
                        continue;
                    }
                    int seatId = Integer.parseInt(seat.trim());
                    bookingRepo.insertOnlineTicket(
                        bookingId,
                        showtimeId,
                        seatId
                    );
                }
            } else {

                bookingRepo.deleteBooking(bookingCode);
                System.out.println("TransactionStatus: " + transactionStatus);
                response.getWriter().write("FAILED");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}