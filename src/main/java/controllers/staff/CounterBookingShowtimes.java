package controllers.staff;

import models.Movie;
import models.Showtime;
import services.CounterBookingShowtimesService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "counterBookingShowtimes", urlPatterns = { "/staff/counter-booking-showtimes" })
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

        try {
            int movieId = Integer.parseInt(movieIdParam);
            LocalDate selectedDate = (dateParam != null && !dateParam.isEmpty())
                    ? LocalDate.parse(dateParam)
                    : LocalDate.now();

            CounterBookingShowtimesService service = new CounterBookingShowtimesService();
            CounterBookingShowtimesService.ShowtimesResult result =
                    service.getShowtimesForMovie(movieId, selectedDate);

            Movie movie = result != null ? result.movie : null;
            if (movie == null) {
                request.setAttribute("error", "Movie not found");
                response.sendRedirect(request.getContextPath() + "/staff/counter-booking");
                return;
            }

            List<Showtime> showtimes = result.showtimes;
            Map<Integer, Integer> availableSeatsMap = result.availableSeatsMap;
            Map<Integer, Integer> totalSeatsMap = result.totalSeatsMap;

            // Set attributes for JSP
            request.setAttribute("movie", movie);
            request.setAttribute("showtimes", showtimes);
            request.setAttribute("availableSeatsMap", availableSeatsMap);
            request.setAttribute("totalSeatsMap", totalSeatsMap);
            request.setAttribute("selectedDate", result.selectedDate);
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
        }
    }
}
