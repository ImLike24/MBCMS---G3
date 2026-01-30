package controllers.staff;

import models.User;
import models.Movie;
import repositories.Movies;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "counterBookingMovies", urlPatterns = {"/staff/counter-booking"})
public class CounterBookingMovies extends HttpServlet {

    private final Movies moviesRepo = new Movies();

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

        try {
            // Get date parameter (default to today)
            String dateParam = request.getParameter("date");
            LocalDate selectedDate = (dateParam != null && !dateParam.isEmpty()) 
                ? LocalDate.parse(dateParam) 
                : LocalDate.now();

            // Get movies showing on selected date
            List<Movie> movies;
            if (selectedDate.equals(LocalDate.now())) {
                movies = moviesRepo.getMoviesShowingToday();
            } else {
                movies = moviesRepo.getMoviesShowingOnDate(selectedDate);
            }

            request.setAttribute("movies", movies);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", LocalDate.now());
            
            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading movies: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);
        } finally {
            moviesRepo.closeConnection();
        }
    }
}
