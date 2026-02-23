package services;

import java.util.List;
import models.Movie;
import repositories.Movies;

public class MovieService {

    private final Movies movieDao = new Movies();

    public List<Movie> getAllMovies() {
        return movieDao.getAllMovies();
    }

    public Movie getMovieById(int id) {
        try {
            return movieDao.getMovieById(id);
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public void insertMovie(Movie m, List<Integer> genreIds) {
        movieDao.insertMovieWithGenres(m, genreIds);
    }

    public void updateMovie(Movie m, List<Integer> genreIds) {
        movieDao.updateMovieWithGenres(m, genreIds);
    }

    public void deleteMovie(int movieId) {
        movieDao.deleteMovieWithGenres(movieId);
    }
}