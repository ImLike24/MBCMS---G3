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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.math.BigDecimal;
import services.CounterVoucherService;

/**
 * API cho quầy (counter) dùng để:
 * - Lấy danh sách voucher còn hiệu lực của khách (qua số điện thoại).
 * - Tự động chọn voucher "hời nhất" dựa trên tổng bill.
 */
@WebServlet(name = "counterBestVoucher", urlPatterns = {"/staff/counter-best-voucher"})
public class CounterBestVoucherServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CounterBestVoucherServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }

        Gson gson = new Gson();
        JsonObject requestData = gson.fromJson(jsonBuilder.toString(), JsonObject.class);

        try {
            String customerPhone = getStringOrNull(requestData, "customerPhone");
            String totalAmountStr = getStringOrNull(requestData, "totalAmount");

            BigDecimal totalAmount = (totalAmountStr != null && !totalAmountStr.trim().isEmpty())
                    ? new BigDecimal(totalAmountStr.trim())
                    : BigDecimal.ZERO;

            CounterVoucherService service = new CounterVoucherService();
            JsonObject result = service.findBestVoucher(customerPhone, totalAmount);
            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[CounterBestVoucher] Error selecting best voucher", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Error selecting vouchers: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            // no-op: resources handled in service
        }
    }

    private static String getStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) {
            return null;
        }
        return obj.get(key).getAsString();
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

