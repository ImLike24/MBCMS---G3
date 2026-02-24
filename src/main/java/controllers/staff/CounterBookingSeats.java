package controllers.staff;

import models.Showtime;
import repositories.Showtimes;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
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

        Showtimes showtimesRepo = null;
        
        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);
            showtimesRepo = new Showtimes();

            // Get showtime details (includes movie, room, branch info)
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            
            if (showtimeDetails.isEmpty()) {
                request.setAttribute("error", "Showtime not found");
                response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
                return;
            }

            // Get all seats with their booking status
            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            
            // Count available seats
            int availableSeats = showtimesRepo.countAvailableSeats(showtimeId);
            
            // Set attributes for JSP
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("seatsWithStatus", seatsWithStatus);
            request.setAttribute("availableSeats", availableSeats);
            request.setAttribute("showtimeId", showtimeId);
            
            // Extract useful info for easier access in JSP
            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            request.setAttribute("showtime", showtime);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("moviePosterUrl", showtimeDetails.get("moviePosterUrl"));
            request.setAttribute("roomName", showtimeDetails.get("roomName"));
            request.setAttribute("totalSeats", showtimeDetails.get("totalSeats"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            // Pre-format LocalTime / LocalDate so JSP EL can display them directly
            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    request.setAttribute("formattedStartTime",
                            showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
                if (showtime.getShowDate() != null) {
                    request.setAttribute("formattedShowDate",
                            showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }
            }
            
            request.getRequestDispatcher("/pages/staff/counter-booking-seats.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid showtime ID");
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading seat map: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-seats.jsp").forward(request, response);
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}
