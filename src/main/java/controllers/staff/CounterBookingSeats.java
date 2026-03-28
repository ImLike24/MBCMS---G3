package controllers.staff;

import models.Showtime;
import models.Concession;
import repositories.Concessions;
import services.CounterBookingSeatsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "counterBookingSeats", urlPatterns = {"/staff/counter-booking-seats"})
public class CounterBookingSeats extends HttpServlet {

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

        // Get showtime ID parameter
        String showtimeIdParam = request.getParameter("showtimeId");
        
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);
            CounterBookingSeatsService service = new CounterBookingSeatsService();
            CounterBookingSeatsService.SeatsResult result = service.getSeatsForShowtime(showtimeId);

            if (result == null || result.showtimeDetails == null || result.showtimeDetails.isEmpty()) {
                request.setAttribute("error", "Showtime not found");
                response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
                return;
            }

            Map<String, Object> showtimeDetails = result.showtimeDetails;

            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("seatsWithStatus", result.seatsWithStatus);
            request.setAttribute("availableSeats", result.availableSeats);
            request.setAttribute("showtimeId", showtimeId);

            // Dynamic ticket prices & surcharges
            request.setAttribute("adultPrice", result.adultPrice);
            request.setAttribute("childPrice", result.childPrice);
            request.setAttribute("surchargeList", result.surchargeList);
            
            Showtime showtime = result.showtime;
            request.setAttribute("showtime", showtime);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("moviePosterUrl", showtimeDetails.get("moviePosterUrl"));
            request.setAttribute("roomName", showtimeDetails.get("roomName"));
            request.setAttribute("totalSeats", showtimeDetails.get("totalSeats"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            if (result.formattedStartTime != null) {
                request.setAttribute("formattedStartTime", result.formattedStartTime);
            }
            if (result.formattedShowDate != null) {
                request.setAttribute("formattedShowDate", result.formattedShowDate);
            }

            // Load concessions for sale
            Concessions concessionsRepo = new Concessions();
            List<Concession> concessionsList = concessionsRepo.getConcessionsForSale();
            concessionsRepo.closeConnection();
            if (concessionsList == null) concessionsList = new ArrayList<>();
            request.setAttribute("concessionsList", concessionsList);

            request.getRequestDispatcher("/pages/staff/counter-booking-seats.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid showtime ID");
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading seat map: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-seats.jsp").forward(request, response);
        }
    }
}
