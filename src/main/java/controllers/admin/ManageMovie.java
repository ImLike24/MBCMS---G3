package controllers.admin;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.Movie;
import models.Genre;
import services.MovieService;
import services.GenreService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/manage-movie")
public class ManageMovie extends HttpServlet {

    private MovieService movieService = new MovieService();
    private GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Load movie for edit
        String idParam = request.getParameter("id");
        if (idParam != null) {
            int id = Integer.parseInt(idParam);
            Movie m = movieService.getMovieById(id);
            request.setAttribute("movie", m);

            // load genres of this movie (for checkbox selected)
            request.setAttribute("movieGenres",
                    genreService.getGenresByMovieId(id));
        }

        // Load all movies
        List<Movie> movies = movieService.getAllMovies();
        request.setAttribute("movies", movies);

        // Load all genres (for add/edit form)
        request.setAttribute("allGenres",
                genreService.getAllActiveGenres());

        request.getRequestDispatcher("/pages/admin/manage-movie/manage-movie.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String action = request.getParameter("action");

        // Lấy list genre_id từ form (checkbox multiple)
        String[] genreIdsRaw = request.getParameterValues("genreIds");
        List<Integer> genreIds = new ArrayList<>();
        if (genreIdsRaw != null) {
            for (String gid : genreIdsRaw) {
                genreIds.add(Integer.parseInt(gid));
            }
        }

        if ("add".equals(action)) {
            Movie m = new Movie();
            m.setTitle(request.getParameter("title"));
            m.setDuration(Integer.parseInt(request.getParameter("duration")));
            m.setRating(Double.parseDouble(request.getParameter("rating")));
            m.setActive(true);

            // insert movie + movie_genres
            movieService.insertMovie(m, genreIds);

        } else if ("update".equals(action)) {
            Movie m = new Movie();
            m.setMovieId(Integer.parseInt(request.getParameter("id")));
            m.setTitle(request.getParameter("title"));
            m.setDuration(Integer.parseInt(request.getParameter("duration")));
            m.setRating(Double.parseDouble(request.getParameter("rating")));
            m.setActive(Boolean.parseBoolean(request.getParameter("active")));

            movieService.updateMovie(m, genreIds);

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            movieService.deleteMovie(id);
        }

        // Redirect đúng servlet
        response.sendRedirect(request.getContextPath() + "/admin/manage-movie");
    }
}