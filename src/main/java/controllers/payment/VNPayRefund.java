package controllers.payment;

import services.VNPayService;
import utils.VNPay;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/payment/vnpayrefund/*")
public class VNPayRefund extends HttpServlet {

    private final VNPayService vnpayService = new VNPayService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // Nhận các tham số cần thiết
        String orderId = req.getParameter("order_id");
        String transType = req.getParameter("trantype");
        String transDate = req.getParameter("trans_date");
        String user = req.getParameter("user");
        String ipAddr = VNPay.getIpAddress(req);

        long amount = 0;
        try {
            // Ép kiểu an toàn, tránh lỗi chữ/rỗng làm sập Server
            amount = Long.parseLong(req.getParameter("amount"));
        } catch (NumberFormatException ignored) {}

        // Call Service xử lý và lấy chuỗi JSON trả về
        String result = vnpayService.refundTransaction(orderId, transType, amount, transDate, user, ipAddr);

        // Phản hồi cho Frontend
        resp.getWriter().write(result);
    }
}