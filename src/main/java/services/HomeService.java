package services;

import java.util.List;
import models.Movie;
import models.Genre;
import repositories.Movies;
import repositories.Genres;

public class HomeService {

    private final Movies movieDao = new Movies();

    public List<Movie> getNowShowingMovies() {
        return movieDao.getNowShowing();
    }

    public List<Movie> getComingSoonMovies() {
        return movieDao.getComingSoon();
    }

    public List<Movie> getTopRatedMovies() {
        return movieDao.getTopRated(8);
    }
}