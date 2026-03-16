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

            if ("00".equals(transactionStatus)) {
                //Call confirmBooking
                bookingRepo.confirmBooking(bookingCode);

                // Gửi phản hồi về cho VNPay biết là đã xử lý xong
                response.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
            } else {
                // Nếu thanh toán thất bại/hủy -> Xóa Booking và giải phóng ghế
                bookingRepo.deleteBooking(bookingCode);
                System.out.println("TransactionStatus Failed: " + transactionStatus);
                response.getWriter().write("FAILED");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}