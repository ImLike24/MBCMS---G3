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
import models.User;
import services.LoyaltyService;

/**
 * API để xem thông tin loyalty (points) của khách tại quầy theo số điện thoại.
 */
@WebServlet(name = "counterCustomerLoyalty", urlPatterns = {"/staff/counter-customer-loyalty"})
public class CounterCustomerLoyaltyServlet extends HttpServlet {

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

        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }

        Gson gson = new Gson();
        JsonObject requestData = gson.fromJson(jsonBuilder.toString(), JsonObject.class);

        String phone = getStringOrNull(requestData, "customerPhone");
        if (phone == null || phone.trim().isEmpty()) {
            response.getWriter()
                    .write("{\"success\":false,\"message\":\"Customer phone is required to lookup points\"}");
            return;
        }

        LoyaltyService service = new LoyaltyService();
        LoyaltyService.LoyaltyInfo info = service.getLoyaltyInfoByPhone(phone);

        if (info == null || info.user == null) {
            response.getWriter()
                    .write("{\"success\":false,\"message\":\"No customer found with this phone number\"}");
            return;
        }

        JsonObject resp = new JsonObject();
        resp.addProperty("success", true);
        resp.addProperty("points", info.points);
        resp.addProperty("totalAccumulatedPoints", info.totalAccumulatedPoints);
        if (info.tierId != null) {
            resp.addProperty("tierId", info.tierId);
        }

        User u = info.user;
        if (u.getFullName() != null) {
            resp.addProperty("fullName", u.getFullName());
        }

        response.getWriter().write(gson.toJson(resp));
    }

    private static String getStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) {
            return null;
        }
        return obj.get(key).getAsString();
    }
}

