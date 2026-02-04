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

    private static final int PAGE_SIZE = 8; // Movies per page

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

        // Mỗi request dùng connection riêng, tránh "connection is closed" khi nhiều request đồng thời
        Movies moviesRepo = null;
        try {
            moviesRepo = new Movies();
            // Get date parameter (default to today)
            String dateParam = request.getParameter("date");
            LocalDate selectedDate = (dateParam != null && !dateParam.isEmpty()) 
                ? LocalDate.parse(dateParam) 
                : LocalDate.now();

            // Get search parameter
            String search = request.getParameter("search");
            
            // Get filter parameters
            String genre = request.getParameter("genre");
            String ageRating = request.getParameter("ageRating");
            
            // Get pagination parameter
            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            // Get movies with filter, search and pagination
            List<Movie> movies = moviesRepo.getMoviesShowingOnDateWithFilter(
                selectedDate, search, genre, ageRating, page, PAGE_SIZE);
            
            // Get total count for pagination
            int totalMovies = moviesRepo.countMoviesShowingOnDateWithFilter(
                selectedDate, search, genre, ageRating);
            int totalPages = (int) Math.ceil((double) totalMovies / PAGE_SIZE);
            
            // Get genres and age ratings for filter dropdowns
            List<String> genres = moviesRepo.getGenresShowingOnDate(selectedDate);
            List<String> ageRatings = moviesRepo.getAgeRatingsShowingOnDate(selectedDate);

            // Set attributes for JSP
            request.setAttribute("movies", movies);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", LocalDate.now());
            
            // Pagination attributes
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalMovies", totalMovies);
            request.setAttribute("pageSize", PAGE_SIZE);
            
            // Filter attributes
            request.setAttribute("genres", genres);
            request.setAttribute("ageRatings", ageRatings);
            request.setAttribute("selectedGenre", genre);
            request.setAttribute("selectedAgeRating", ageRating);
            request.setAttribute("searchQuery", search);
            
            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading movies: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);
        } finally {
            if (moviesRepo != null) {
                moviesRepo.closeConnection();
            }
        }
    }
}
