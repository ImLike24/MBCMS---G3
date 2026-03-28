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
import services.UserService;

import models.User;
import models.Role;
import config.DBContext;

@WebServlet("/admin/movies")
public class ListMovie extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Role userRole = userService.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

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
}