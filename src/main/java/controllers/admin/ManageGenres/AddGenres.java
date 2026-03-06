package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Genre;
import services.GenreService;

import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/genres/add"})
public class AddGenres extends HttpServlet {

    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiển thị form thêm mới
        request.getRequestDispatcher("/pages/admin/manage-genres/genres-add.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String genreName = request.getParameter("genreName");
        String description = request.getParameter("description");
        boolean isActive = "on".equals(request.getParameter("isActive"));

        // Validation cơ bản
        if (genreName == null || genreName.trim().isEmpty()) {
            request.setAttribute("error", "Tên thể loại không được để trống");
            request.setAttribute("description", description);
            request.setAttribute("isActive", isActive);
            request.getRequestDispatcher("/pages/admin/manage-genres/genres-add.jsp").forward(request, response);
            return;
        }

        Genre genre = new Genre();
        genre.setGenreName(genreName.trim());
        genre.setDescription(description != null ? description.trim() : null);
        genre.setActive(isActive);

        boolean success = genreService.addGenre(genre);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-genres?success=add");
        } else {
            request.setAttribute("error", "Thêm thể loại thất bại. Vui lòng thử lại.");
            request.setAttribute("genre", genre);
            request.getRequestDispatcher("/pages/admin/manage-genres/genres-add.jsp").forward(request, response);
        }
    }
}