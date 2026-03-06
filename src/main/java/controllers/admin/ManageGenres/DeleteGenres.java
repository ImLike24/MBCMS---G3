package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import services.GenreService;

import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/genres/delete"})
public class DeleteGenres extends HttpServlet {

    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            boolean success = genreService.deleteGenre(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=delete");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-genres?error=invalid");
        }
    }
}