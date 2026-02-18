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
    
    // Trong GenreService.java
    public List<Genre> getAllGenres() {          // không chỉ active
        return genreDao.getAllGenres();
    }

    public Genre getGenreById(int id) {
        return genreDao.getGenreById(id);
    }

    public boolean addGenre(Genre genre) {
        return genreDao.addGenre(genre);
    }

    public boolean updateGenre(Genre genre) {
        return genreDao.updateGenre(genre);
    }

    public boolean deleteGenre(int id) {
        return genreDao.deleteGenre(id); // có thể soft delete
    }
}