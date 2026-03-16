package controllers.customer;

import java.io.IOException;
import models.Showtime;
import repositories.Showtimes;

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
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.User;
import repositories.Bookings;

@WebServlet(name = "BookingPayment", urlPatterns = {"/customer/booking-payment"})
public class BookingPayment extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingPayment.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        String showtimeIdParam = request.getParameter("showtimeId");

        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        Showtimes showtimesRepo = null;

        try {

            int showtimeId = Integer.parseInt(showtimeIdParam);

            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);

            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
                return;
            }

            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            Showtime st = (Showtime) showtimeDetails.get("showtime");

            if (st != null) {

                if (st.getShowDate() != null) {
                    request.setAttribute("showDateFormatted",
                            st.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

                if (st.getStartTime() != null) {
                    request.setAttribute("showTimeFormatted",
                            st.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
            }

            request.getRequestDispatcher("/pages/customer/booking-payment.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("error", e.getMessage());

            request.getRequestDispatcher("/pages/customer/booking-payment.jsp")
                    .forward(request, response);

        } finally {

            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {

            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false}");

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
        String txnRef = requestData.get("txnRef").getAsString();
        Showtimes showtimesRepo = null;

        try {

            int showtimeId = requestData.get("showtimeId").getAsInt();

            JsonArray seatsArray = requestData.getAsJsonArray("seats");

            BigDecimal totalAmount = new BigDecimal(requestData.get("totalAmount").getAsString());

            showtimesRepo = new Showtimes();
            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seat = seatsArray.get(i).getAsJsonObject();
                int seatId = seat.get("seatId").getAsInt();
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    response.getWriter().write("{\"success\": false}");
                    return;
                }
            }
            
            Bookings bookingRepo = new Bookings();
            
            int bookingId = bookingRepo.insertBooking(
                   ((User) session.getAttribute("user")).getUserId(),
                    showtimeId,
                    txnRef,
                    totalAmount
            );
            
            List<Integer> seatIds = new ArrayList<>();
            for(Integer seatId : seatIds){
                bookingRepo.insertOnlineTicket(
                        bookingId,
                        showtimeId,
                        seatId
                );
            }
            JsonObject respJson = new JsonObject();

            respJson.addProperty("success", true);
            respJson.addProperty("bookingCode", txnRef);

            response.getWriter().write(gson.toJson(respJson));

        } catch (Exception e) {

            e.printStackTrace();

            LOGGER.log(Level.SEVERE, "Payment error", e);

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            response.getWriter().write("{\"success\": false}");

        } finally {

            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}