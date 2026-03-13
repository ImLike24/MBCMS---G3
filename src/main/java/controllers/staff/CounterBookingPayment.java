package controllers.staff;

import models.User;
import models.CounterTicket;
import models.Voucher;
import models.UserVoucher;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import services.CounterBookingService;
import services.CounterBookingPaymentPageService;

@WebServlet(name = "counterBookingPayment", urlPatterns = {"/staff/counter-booking-payment"})
public class CounterBookingPayment extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CounterBookingPayment.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check role
        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        // Get showtime ID
        String showtimeIdParam = request.getParameter("showtimeId");
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);

            // Get showtime details
            CounterBookingPaymentPageService pageService = new CounterBookingPaymentPageService();
            Map<String, Object> showtimeDetails = pageService.getShowtimeDetails(showtimeId);
            
            if (showtimeDetails.isEmpty()) {
                request.setAttribute("error", "Showtime not found");
                response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
                return;
            }

            // Set attributes for JSP
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));
            
            request.getRequestDispatcher("/pages/staff/counter-booking-payment.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading payment page: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-payment.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

        // Check role
        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\": false, \"message\": \"Access denied\"}");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int staffId = currentUser.getUserId();

        // Read JSON from request body
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
            CounterBookingService service = new CounterBookingService();
            JsonObject result = service.processPayment(requestData, staffId);
            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "[CounterBookingPayment] Payment error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            // resources are handled inside CounterBookingService
        }
    }

    /** Escape string for use inside JSON double-quoted value. */
    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    /**
     * Returns the string value of a JSON field, or null if the field is
     * absent or explicitly JSON null. Prevents JsonNull.getAsString() crash.
     */
    private static String getStringOrNull(JsonObject obj, String key) {
        if (!obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }
}
