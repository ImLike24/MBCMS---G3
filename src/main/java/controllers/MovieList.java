package controllers;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Movie;
import repositories.Movies;

@WebServlet("/movies")
public class MovieList extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Movies moviesRepo = new Movies();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Movie> movies = moviesRepo.getMockUpMovies();
        request.setAttribute("movies", movies);
        request.getRequestDispatcher("/pages/movie_list.jsp").forward(request, response);
    }
}
