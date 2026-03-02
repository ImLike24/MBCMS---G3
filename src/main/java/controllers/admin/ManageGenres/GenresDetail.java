package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Genre;
import services.GenreService;

import java.io.IOException;

@WebServlet(name = "GenreDetailServlet", urlPatterns = {"/admin/genres/detail"})
public class GenresDetail extends HttpServlet {

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
                request.getRequestDispatcher("/pages/admin/manage-genres/genres-detail.jsp")
                       .forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=invalid");
        }
    }
}