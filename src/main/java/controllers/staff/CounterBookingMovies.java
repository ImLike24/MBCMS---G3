package controllers.staff;

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

@WebServlet(name = "counterBookingMovies", urlPatterns = { "/staff/counter-booking" })
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

        // Mỗi request dùng connection riêng, tránh "connection is closed" khi nhiều
        // request đồng thời
        Movies moviesRepo = null;
        try {
            moviesRepo = new Movies();
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

            // Get movies with filter, search and pagination
            List<Movie> movies;
            int totalMovies;
            List<String> ageRatings;
            
            if (showAllMovies) {
                // Show all active movies (no date filter - e.g. after Reset)
                // Use getAllActiveMovies() then filter/paginate in Java for reliability
                List<Movie> allActive = moviesRepo.getAllActiveMovies();
                if (search != null && !search.trim().isEmpty()) {
                    String q = search.trim().toLowerCase();
                    allActive = allActive.stream()
                            .filter(m -> (m.getTitle() != null && m.getTitle().toLowerCase().contains(q))
                                    || (m.getDirector() != null && m.getDirector().toLowerCase().contains(q))
                                    || (m.getCast() != null && m.getCast().toLowerCase().contains(q)))
                            .toList();
                }
                if (genre != null && !genre.trim().isEmpty()) {
                    String g = genre.trim().toLowerCase();
                    allActive = allActive.stream()
                            .filter(m -> m.getGenres() != null && m.getGenres().stream()
                                    .anyMatch(ge -> ge != null && ge.toLowerCase().contains(g)))
                            .toList();
                }
                if (ageRating != null && !ageRating.trim().isEmpty()) {
                    allActive = allActive.stream()
                            .filter(m -> ageRating.trim().equalsIgnoreCase(m.getAgeRating()))
                            .toList();
                }
                totalMovies = allActive.size();
                int from = (page - 1) * PAGE_SIZE;
                int to = Math.min(from + PAGE_SIZE, totalMovies);
                movies = from < totalMovies ? allActive.subList(from, to) : List.of();
                ageRatings = moviesRepo.getAgeRatingsFromActiveMovies();
            } else {
                // Show movies for specific date
                movies = moviesRepo.getMoviesShowingOnDateWithFilter(
                        selectedDate, search, genre, ageRating, page, PAGE_SIZE);
                totalMovies = moviesRepo.countMoviesShowingOnDateWithFilter(
                        selectedDate, search, genre, ageRating);
                ageRatings = moviesRepo.getAgeRatingsShowingOnDate(selectedDate);
            }
            
            int totalPages = (int) Math.ceil((double) totalMovies / PAGE_SIZE);

            // Set attributes for JSP
            request.setAttribute("movies", movies);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", LocalDate.now());
            request.setAttribute("showAllMovies", showAllMovies);

            // Pagination attributes
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalMovies", totalMovies);
            request.setAttribute("pageSize", PAGE_SIZE);

            // Filter attributes
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
