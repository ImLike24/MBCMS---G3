package controllers.admin;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.Movie;
import repositories.Movies;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/manage-movie/manage-movies")
public class ManageMovie extends HttpServlet {

    private Movies movieRepo = new Movies();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam != null) {
            int id = Integer.parseInt(idParam);
            Movie movie = movieRepo.getMovieById(id);
            request.setAttribute("movie", movie);
        }

        List<Movie> movies = movieRepo.getAllMovies();
        request.setAttribute("movies", movies);

        request.getRequestDispatcher("/pages/admin/manage-movie/manage-movie.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            Movie m = new Movie();
            m.setTitle(request.getParameter("title"));
            m.setGenre(request.getParameter("genre"));
            m.setDuration(Integer.parseInt(request.getParameter("duration")));
            m.setRating(Double.parseDouble(request.getParameter("rating")));
            m.setActive(true);
//            movieRepo.insertMovie(m);

        } else if ("update".equals(action)) {
            Movie m = new Movie();
            m.setMovieId(Integer.parseInt(request.getParameter("id")));
            m.setTitle(request.getParameter("title"));
            m.setGenre(request.getParameter("genre"));
            m.setDuration(Integer.parseInt(request.getParameter("duration")));
            m.setRating(Double.parseDouble(request.getParameter("rating")));
            m.setActive(Boolean.parseBoolean(request.getParameter("active")));
//            movieRepo.updateMovie(m);

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
//            movieRepo.deleteMovie(id);
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-movie/manage-movies");
    }
}
