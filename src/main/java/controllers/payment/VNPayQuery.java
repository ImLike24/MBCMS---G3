package controllers.payment;

import services.VNPayService;
import utils.VNPay;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/payment/vnpayquery/*")
public class VNPayQuery extends HttpServlet {

    private final VNPayService vnpayService = new VNPayService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // Nhận các tham số cần thiết từ Frontend
        String orderId = req.getParameter("order_id");
        String transDate = req.getParameter("trans_date");
        String ipAddr = VNPay.getIpAddress(req);

        // Call Service đi xử lý API mạng
        String result = vnpayService.queryTransaction(orderId, transDate, ipAddr);

        // Trả thẳng kết quả JSON cho Client
        resp.getWriter().write(result);
    }
}