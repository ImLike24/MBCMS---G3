package services;

import java.util.List;
import models.Movie;
import repositories.Movies;


/**
 *
 * @author ImLike
 */
public class MovieService {
    private final Movies movieDao = new Movies();
    
    public List<Movie> getAllMovies() {
        return movieDao.getAllMovies();
    }
    
    public Movie getMovieById(int id) {
        return movieDao.getMovieById(id);
    }
}
