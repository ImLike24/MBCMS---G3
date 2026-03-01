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

@WebServlet("/admin/movies/detail")
public class MovieDetail extends HttpServlet {

    private final MovieService movieService = new MovieService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        Integer id = parseId(idStr);

        if (id == null) {
            request.setAttribute("errorMessage", "ID phim không hợp lệ");
            request.getRequestDispatcher("/pages/admin/manage-movie/manage-movie.jsp").forward(request, response);
            return;
        }

        Movie movie = movieService.getMovieById(id);
        if (movie == null) {
            request.setAttribute("errorMessage", "Không tìm thấy phim");
        } else {
            request.setAttribute("movie", movie);
        }

        request.getRequestDispatcher("/pages/admin/manage-movie/movie-detail.jsp")
                .forward(request, response);
    }

    private boolean isAdminLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }

    private Integer parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}