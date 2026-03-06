package controllers.staff;

import models.User;
import models.CounterTicket;
import repositories.CounterTickets;
import repositories.Showtimes;
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
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

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

        Showtimes showtimesRepo = null;
        
        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);
            showtimesRepo = new Showtimes();

            // Get showtime details
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            
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
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
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

        CounterTickets counterTicketsRepo = null;
        Showtimes showtimesRepo = null;
        
        try {
            // Parse request data
            int showtimeId = requestData.get("showtimeId").getAsInt();
            System.out.println("[CounterBookingPayment] POST payment: showtimeId=" + showtimeId + " seats=" + requestData.getAsJsonArray("seats").size());
            String paymentMethod = requestData.get("paymentMethod").getAsString();
            String customerName  = getStringOrNull(requestData, "customerName");
            String customerPhone = getStringOrNull(requestData, "customerPhone");
            String customerEmail = getStringOrNull(requestData, "customerEmail");
            
            JsonArray seatsArray = requestData.getAsJsonArray("seats");
            
            // Validate payment method
            if (!"CASH".equals(paymentMethod) && !"BANKING".equals(paymentMethod)) {
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid payment method\"}");
                return;
            }

            counterTicketsRepo = new CounterTickets();
            showtimesRepo = new Showtimes();

            // Generate unique ticket code for this transaction
            String ticketCode = counterTicketsRepo.generateTicketCode();
            
            // Get showtime details for price calculation
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            BigDecimal basePrice = ((models.Showtime) showtimeDetails.get("showtime")).getBasePrice();

            // Create counter tickets
            List<Integer> ticketIds = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;

            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seatObj = seatsArray.get(i).getAsJsonObject();
                
                int seatId = seatObj.get("seatId").getAsInt();
                String seatType = seatObj.get("seatType").getAsString();
                String ticketType = seatObj.get("ticketType").getAsString();
                
                // Verify seat is still available
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Seat " + seatObj.get("seatCode").getAsString() + " is no longer available\"}");
                    return;
                }

                // Calculate price
                BigDecimal price = basePrice;
                
                // Adjust for seat type
                if ("VIP".equals(seatType)) {
                    price = price.multiply(new BigDecimal("1.5"));
                } else if ("COUPLE".equals(seatType)) {
                    price = price.multiply(new BigDecimal("2.0"));
                }
                
                // Adjust for ticket type
                if ("CHILD".equals(ticketType)) {
                    price = price.multiply(new BigDecimal("0.7"));
                }
                
                // Round to 2 decimal places
                price = price.setScale(2, BigDecimal.ROUND_HALF_UP);
                
                // Create counter ticket
                CounterTicket ticket = new CounterTicket();
                ticket.setShowtimeId(showtimeId);
                ticket.setSeatId(seatId);
                ticket.setTicketType(ticketType);
                ticket.setSeatType(seatType);
                ticket.setPrice(price);
                ticket.setTicketCode(ticketCode);
                ticket.setSoldBy(staffId);
                ticket.setPaymentMethod(paymentMethod);
                ticket.setCustomerName(customerName);
                ticket.setCustomerPhone(customerPhone);
                ticket.setCustomerEmail(customerEmail);
                // Unique ticket_code per row (DB has UNIQUE constraint); base code + index for receipt grouping
                ticket.setTicketCode(ticketCode + "-" + (i + 1));
                
                int ticketId = counterTicketsRepo.createCounterTicket(ticket);
                
                if (ticketId > 0) {
                    ticketIds.add(ticketId);
                    totalAmount = totalAmount.add(price);
                } else {
                    String dbError = counterTicketsRepo.getLastErrorMessage();
                    String msg = dbError != null ? "Failed to create ticket: " + dbError : "Failed to create ticket";
                    LOGGER.log(Level.SEVERE, "[CounterBookingPayment] createCounterTicket failed for seatId={0}, ticketCode={1}, dbError={2}",
                            new Object[]{seatId, ticket.getTicketCode(), dbError});
                    System.err.println("[CounterBookingPayment] FAIL create ticket: seatId=" + seatId + " ticketCode=" + ticket.getTicketCode() + " dbError=" + dbError);
                    response.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(msg) + "\"}");
                    return;
                }
            }

            // Success response
            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("message", "Booking completed successfully");
            successResponse.addProperty("ticketCode", ticketCode);
            successResponse.addProperty("totalAmount", totalAmount.toString());
            successResponse.addProperty("ticketCount", ticketIds.size());
            
            JsonArray ticketIdsArray = new JsonArray();
            for (Integer id : ticketIds) {
                ticketIdsArray.add(id);
            }
            successResponse.add("ticketIds", ticketIdsArray);
            
            response.getWriter().write(gson.toJson(successResponse));
            
        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "[CounterBookingPayment] Payment error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            if (counterTicketsRepo != null) {
                counterTicketsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
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
