package controllers.staff;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import services.CounterVoucherService;

@WebServlet(name = "counterValidateVoucher", urlPatterns = {"/staff/counter-validate-voucher"})
public class CounterValidateVoucherServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Not authenticated\"}");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\":false,\"message\":\"Access denied\"}");
            return;
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        Gson gson = new Gson();
        JsonObject req = gson.fromJson(sb.toString(), JsonObject.class);

        String voucherCode   = getStr(req, "voucherCode");
        String customerPhone = getStr(req, "customerPhone");
        String totalAmountStr = getStr(req, "totalAmount");

        BigDecimal totalAmount = BigDecimal.ZERO;
        if (totalAmountStr != null && !totalAmountStr.trim().isEmpty()) {
            try { totalAmount = new BigDecimal(totalAmountStr.trim()); } catch (NumberFormatException ignored) {}
        }

        CounterVoucherService service = new CounterVoucherService();
        JsonObject result = service.validateVoucherCode(voucherCode, customerPhone, totalAmount);
        response.getWriter().write(gson.toJson(result));
    }

    private static String getStr(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }
}
