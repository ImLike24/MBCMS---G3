package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Genre;
import services.GenreService;

import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/genres/edit"})
public class EditGenres extends HttpServlet {

    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            Genre genre = genreService.getGenreById(id);
            if (genre != null) {
                request.setAttribute("genre", genre);
                request.getRequestDispatcher("/pages/admin/manage-genres/genres-edit.jsp")
                       .forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=invalid");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("genreId");
        String genreName = request.getParameter("genreName");
        String description = request.getParameter("description");
        boolean isActive = "on".equals(request.getParameter("isActive"));

        try {
            int id = Integer.parseInt(idStr);
            Genre genre = genreService.getGenreById(id);
            if (genre == null) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=notfound");
                return;
            }

            if (genreName == null || genreName.trim().isEmpty()) {
                request.setAttribute("error", "Tên thể loại không được để trống");
                request.setAttribute("genre", genre);
                request.getRequestDispatcher("/pages/admin/manage-genres/genres-edit.jsp").forward(request, response);
                return;
            }

            genre.setGenreName(genreName.trim());
            genre.setDescription(description != null ? description.trim() : null);
            genre.setActive(isActive);

            boolean success = genreService.updateGenre(genre);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?success=update");
            } else {
                request.setAttribute("error", "Cập nhật thất bại");
                request.setAttribute("genre", genre);
                request.getRequestDispatcher("/pages/admin/manage-genres/genres-edit.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=invalid");
        }
    }
}