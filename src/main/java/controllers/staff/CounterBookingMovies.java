package controllers.staff;

import models.Movie;
import models.User;
import services.CounterBookingMoviesService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "counterBookingMovies", urlPatterns = { "/staff/counter-booking" })
public class CounterBookingMovies extends HttpServlet {

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

        // Mỗi request dùng connection riêng, tránh "connection is closed" khi nhiều
        // request đồng thời
        try {
            // Get date parameter
            // If no date param provided, default to TODAY (not show all)
            String dateParam = request.getParameter("date");
            LocalDate selectedDate;
            boolean showAllMovies = false;
            
            // Check if user explicitly requested "show all" via reset (special flag)
            String resetParam = request.getParameter("reset");
            if ("true".equals(resetParam)) {
                // User clicked Reset - show all movies
                showAllMovies = true;
                selectedDate = null;
            } else if (dateParam == null || dateParam.isEmpty()) {
                // First visit or no date provided - default to TODAY
                selectedDate = LocalDate.now();
            } else {
                // Date parameter provided - use it
                selectedDate = LocalDate.parse(dateParam);
            }

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
                    if (page < 1)
                        page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            CounterBookingMoviesService service = new CounterBookingMoviesService();

            // Lấy chi nhánh của staff (nếu có)
            User currentUser = (User) session.getAttribute("user");
            Integer branchId = currentUser != null ? currentUser.getBranchId() : null;
CounterBookingMoviesService.MoviesPage moviesPage = service.getMoviesForCounter(
                    selectedDate, showAllMovies, search, genre, ageRating, page, branchId);

            List<Movie> movies = moviesPage.movies;
            int totalMovies = moviesPage.totalMovies;
            int totalPages = moviesPage.totalPages;
            List<String> ageRatings = moviesPage.ageRatings;

            // Set attributes for JSP
            request.setAttribute("movies", movies);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", LocalDate.now());
            request.setAttribute("showAllMovies", showAllMovies);

            // Pagination attributes
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalMovies", totalMovies);
            request.setAttribute("pageSize", service.getPageSize());

            // Filter attributes
            request.setAttribute("ageRatings", ageRatings);
            request.setAttribute("genres", moviesPage.genres);
            request.setAttribute("selectedGenre", genre);
            request.setAttribute("selectedAgeRating", ageRating);
            request.setAttribute("searchQuery", search);

            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading movies: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/counter-booking-movies.jsp").forward(request, response);
        }
    }
}
