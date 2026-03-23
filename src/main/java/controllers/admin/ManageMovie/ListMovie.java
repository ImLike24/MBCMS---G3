package controllers.admin.ManageMovie;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Movie;
import services.MovieService;

import java.io.IOException;
import java.util.List;
import repositories.Movies;

@WebServlet("/admin/movies")
public class ListMovie extends HttpServlet {
    private final MovieService movieService = new MovieService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MovieService movieService = new MovieService();
        Movies movieRepo = new Movies(); 

        // Lấy tham số trang, mặc định là 1
        String pageStr = request.getParameter("page");
        int page = 1;
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        int pageSize = 5;
        List<Movie> movies = movieRepo.getMoviesWithPagination(page, pageSize);
        int totalMovies = movieRepo.getTotalMoviesCount();

        // Tính tổng số trang
        int totalPages = (int) Math.ceil((double) totalMovies / pageSize);

        // Gửi dữ liệu sang JSP
        request.setAttribute("movies", movies);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalMovies", totalMovies);

        request.getRequestDispatcher("/pages/admin/manage-movie/manage-movie.jsp").forward(request, response);
    }

    private boolean isAdminLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }
}