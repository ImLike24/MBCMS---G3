package controllers.admin;

import java.io.IOException;
import java.util.List;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Movie;
import models.Role;
import models.User;
import repositories.Movies;
import repositories.Roles;

@WebServlet("/admin/manage-movies")
public class ManageMoviesServlet extends HttpServlet {

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
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

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

        // Get search parameter
        String searchKeyword = request.getParameter("search");

        DBContext moviesDbContext = null;
        try {
            moviesDbContext = new DBContext();
            Movies moviesRepo = new Movies();

            // Get movies based on search
            List<Movie> movies;
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                movies = moviesRepo.searchMovies(searchKeyword.trim());
            } else {
                movies = moviesRepo.getAllMovies();
            }

            // Set attributes for JSP
            request.setAttribute("movies", movies);
            request.setAttribute("searchKeyword", searchKeyword);

            request.getRequestDispatcher("/pages/admin/manage-movies.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải hình ảnh: " + e.getMessage());
            request.getRequestDispatcher("/pages/admin/manage-movies.jsp").forward(request, response);
        } finally {
            if (moviesDbContext != null) {
                moviesDbContext.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

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

        // Get action and movieId
        String action = request.getParameter("action");
        String movieIdStr = request.getParameter("movieId");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Invalid request");
            return;
        }

        DBContext moviesDbContext = null;
        try {
            moviesDbContext = new DBContext();
            Movies moviesRepo = new Movies();

            boolean success = false;
            String message = "";

            switch (action) {
                case "delete":
                    if (movieIdStr == null) {
                        response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie ID required");
                        return;
                    }
                    int movieId = Integer.parseInt(movieIdStr);
                    success = moviesRepo.deleteMovie(movieId);
                    message = success ? "Xóa phim thành công" : "Không thể xóa phim";
                    break;
                case "toggle_status":
                    if (movieIdStr == null) {
                        response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie ID required");
                        return;
                    }
                    int toggleMovieId = Integer.parseInt(movieIdStr);
                    Movie movie = moviesRepo.getMovieById(toggleMovieId);
                    if (movie != null) {
                        movie.setActive(!movie.isActive());
                        success = moviesRepo.updateMovie(movie);
                        message = success ? "Cập nhật trạng thái phim thành công" : "Không thể cập nhật trạng thái phim";
                    } else {
                        message = "Không tìm thấy phim";
                    }
                    break;
                default:
                    message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?success=" + message);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=" + message);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Invalid movie ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=" + e.getMessage());
        } finally {
            if (moviesDbContext != null) {
                moviesDbContext.closeConnection();
            }
        }
    }
}