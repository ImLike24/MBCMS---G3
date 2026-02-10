package controllers.staff;

import models.Movie;
import models.Showtime;
import repositories.Movies;
import repositories.Showtimes;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "counterBookingShowtimes", urlPatterns = {"/staff/counter-booking-showtimes"})
public class CounterBookingShowtimes extends HttpServlet {

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

        // Get parameters
        String movieIdParam = request.getParameter("movieId");
        String dateParam = request.getParameter("date");
        
        if (movieIdParam == null || movieIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
            return;
        }

        Movies moviesRepo = null;
        Showtimes showtimesRepo = null;
        
        try {
            int movieId = Integer.parseInt(movieIdParam);
            LocalDate selectedDate = (dateParam != null && !dateParam.isEmpty()) 
                ? LocalDate.parse(dateParam) 
                : LocalDate.now();

            moviesRepo = new Movies();
            showtimesRepo = new Showtimes();

            // Get movie details
            Movie movie = moviesRepo.getMovieById(movieId);
            if (movie == null) {
                request.setAttribute("error", "Movie not found");
                response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
                return;
            }

            // Get showtimes for this movie on the selected date
            List<Showtime> showtimes = showtimesRepo.getShowtimesForMovieOnDate(movieId, selectedDate);
            
            // Get available seat count for each showtime
            Map<Integer, Integer> availableSeatsMap = new HashMap<>();
            Map<Integer, Integer> totalSeatsMap = new HashMap<>();
            
            for (Showtime showtime : showtimes) {
                int availableSeats = showtimesRepo.countAvailableSeats(showtime.getShowtimeId());
                availableSeatsMap.put(showtime.getShowtimeId(), availableSeats);
                
                // Get total seats from showtime details
                Map<String, Object> details = showtimesRepo.getShowtimeDetails(showtime.getShowtimeId());
                if (details.containsKey("totalSeats")) {
                    totalSeatsMap.put(showtime.getShowtimeId(), (Integer) details.get("totalSeats"));
                }
            }

            // Set attributes for JSP
            request.setAttribute("movie", movie);
            request.setAttribute("showtimes", showtimes);
            request.setAttribute("availableSeatsMap", availableSeatsMap);
            request.setAttribute("totalSeatsMap", totalSeatsMap);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", LocalDate.now());
            
            request.getRequestDispatcher("/pages/staff/counter-booking-showtimes.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid movie ID");
            response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading showtimes: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-showtimes.jsp").forward(request, response);
        } finally {
            if (moviesRepo != null) {
                moviesRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}
