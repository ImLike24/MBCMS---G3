package payment;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

import repositories.Bookings;

@WebServlet("/FinalizeBooking")
public class FinalizeBooking extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Khởi tạo Service
            services.BookingService bookingService = new services.BookingService();

            String bookingCode = request.getParameter("vnp_TxnRef");
            String transactionStatus = request.getParameter("vnp_TransactionStatus");

            if ("00".equals(transactionStatus)) {
                // Nhờ Service xử lý toàn bộ logic phức tạp
                bookingService.processSuccessfulPayment(bookingCode);

                // Trả kết quả cho VNPay
                response.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");

            } else {
                // Nhờ Service xử lý dọn dẹp khi thất bại
                bookingService.processFailedPayment(bookingCode);

                System.out.println("TransactionStatus Failed: " + transactionStatus);
                response.getWriter().write("FAILED");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}