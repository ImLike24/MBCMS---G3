package services;

import java.util.List;
import models.Genre;
import repositories.Genres;

public class GenreService {

    private final Genres genreDao = new Genres();

    public List<Genre> getAllActiveGenres() {
        return genreDao.getAllActiveGenres();
    }

    public List<Genre> getGenresByMovieId(int movieId) {
        return genreDao.getGenresByMovieId(movieId);
    }
}