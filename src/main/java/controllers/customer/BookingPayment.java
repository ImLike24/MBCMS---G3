/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers.customer;

import java.io.IOException;
import java.io.PrintWriter;

import models.User;
import models.OnlineTicket;

// repositories
import repositories.Showtimes;
import repositories.OnlineTickets;
import repositories.Bookings;

import com.google.gson.JsonObject;
import com.google.gson.Gson;
import com.google.gson.JsonArray;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;

import java.math.BigDecimal;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author ducanhtran
 */
@WebServlet(name = "BookingPayment", urlPatterns = {"/customer/booking-payment"})
public class BookingPayment extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(BookingPayment.class.getName());
    
    @Override
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("user") == null){
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if(!"CUSTOMER".equals(role)){
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }
        
        String showtimeIdParam = request.getParameter("showtimeId");
        if(showtimeIdParam == null || showtimeIdParam.isEmpty()){
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }
        
        Showtimes showtimesRepo = null;
        
        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);
            showtimesRepo = new Showtimes();
            
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            
            if(showtimeDetails.isEmpty()) {
                request.setAttribute("error", "Showtime not found");
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
                return;
            }
            
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading payment page: " + e.getMessage());
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
        } finally {
            if(showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("user") == null){
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if(!"CUSTOMER".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\": false, \"message\": \"Access denied\"}");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        int customerId = currentUser.getUserId();
        
        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }
        
        Gson gson = new Gson();
        JsonObject requestData = gson.fromJson(jsonBuilder.toString(), JsonObject.class);
        
        Showtimes showtimesRepo = null;
        OnlineTickets onlineTicketsRepo = null;
        Bookings bookingsRepo = null;
        try {
            int showtimeId = requestData.get("showtimeId").getAsInt();
            JsonArray seatsArray = requestData.has("seats") ? requestData.getAsJsonArray("seats") : new JsonArray();
            BigDecimal totalAmount = requestData.has("totalAmount")
                    ? new BigDecimal(requestData.get("totalAmount").getAsString())
                    : BigDecimal.ZERO;

            if (seatsArray.size() == 0) {
                response.getWriter().write("{\"success\": false, \"message\": \"No seats selected\"}");
                return;
            }

            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Showtime not found\"}");
                return;
            }

            // Only ONLINE payment for customer
            String paymentMethod = "BANKING";

            bookingsRepo = new Bookings();
            String bookingCode = bookingsRepo.generateBookingCode();
            int bookingId = bookingsRepo.createOnlineBooking(customerId, showtimeId, paymentMethod, bookingCode);
            if (bookingId <= 0) {
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to create booking\"}");
                return;
            }

            onlineTicketsRepo = new OnlineTickets();

            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seatObj = seatsArray.get(i).getAsJsonObject();

                int seatId = seatObj.get("seatId").getAsInt();
                String seatType = seatObj.get("seatType").getAsString();
                String ticketType = seatObj.get("ticketType").getAsString();

                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Seat "
                            + seatObj.get("seatCode").getAsString() + " đã được đặt trước\"}");
                    return;
                }

                BigDecimal price = seatObj.has("price")
                        ? new BigDecimal(seatObj.get("price").getAsString())
                        : BigDecimal.ZERO;

                onlineTicketsRepo.insertOnlineTicket(bookingId, showtimeId, seatId, ticketType, seatType, price);
            }

            JsonObject respJson = new JsonObject();
            respJson.addProperty("success", true);
            respJson.addProperty("message", "Thanh toán thành công.");
            respJson.addProperty("eTicketCode", bookingCode);
            respJson.addProperty("totalAmount", totalAmount.toPlainString());

            response.getWriter().write(gson.toJson(respJson));

        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "[OnlineBookingPayment] Payment error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Payment error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            if (onlineTicketsRepo != null) {
                onlineTicketsRepo.closeConnection();
            }
            if (bookingsRepo != null) {
                bookingsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
    
}
