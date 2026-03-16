package services;

import java.time.LocalDate;
import java.util.List;
import models.Movie;
import models.Genre;
import repositories.Movies;
import services.GenreService;

/**
 * Business logic for listing movies for counter booking (staff).
 */
public class CounterBookingMoviesService {

    public static class MoviesPage {
        public List<Movie> movies;
        public int totalMovies;
        public int totalPages;
        public List<String> ageRatings;
        public LocalDate selectedDate;
        public boolean showAllMovies;
        public List<Genre> genres;
    }

    private static final int PAGE_SIZE = 8;

    public MoviesPage getMoviesForCounter(LocalDate selectedDate,
                                          boolean showAllMovies,
                                          String search,
                                          String genre,
                                          String ageRating,
                                          int page) throws Exception {
            Movies moviesRepo = null;
            GenreService genreService = new GenreService();
        try {
            moviesRepo = new Movies();

            List<Movie> movies;
            int totalMovies;
            List<String> ageRatings;

            if (showAllMovies) {
                List<Movie> allActive = moviesRepo.getAllActiveMovies();
                LocalDate today = LocalDate.now();
                for (Movie movie : allActive) {
                    int showtimeCount = moviesRepo.countShowtimesForMovieOnDate(movie.getMovieId(), today);
                    movie.setHasShowtimesToday(showtimeCount > 0);
                }

                if (search != null && !search.trim().isEmpty()) {
                    String q = search.trim().toLowerCase();
                    allActive = allActive.stream()
                            .filter(m -> (m.getTitle() != null && m.getTitle().toLowerCase().contains(q))
                                    || (m.getDirector() != null && m.getDirector().toLowerCase().contains(q))
                                    || (m.getCast() != null && m.getCast().toLowerCase().contains(q)))
                            .toList();
                }
                if (genre != null && !genre.trim().isEmpty()) {
                    String g = genre.trim().toLowerCase();
                    allActive = allActive.stream()
                            .filter(m -> m.getGenres() != null && m.getGenres().stream()
                                    .anyMatch(ge -> ge != null && ge.toLowerCase().contains(g)))
                            .toList();
                }
                if (ageRating != null && !ageRating.trim().isEmpty()) {
                    allActive = allActive.stream()
                            .filter(m -> ageRating.trim().equalsIgnoreCase(m.getAgeRating()))
                            .toList();
                }
                totalMovies = allActive.size();
                int from = (page - 1) * PAGE_SIZE;
                int to = Math.min(from + PAGE_SIZE, totalMovies);
                movies = from < totalMovies ? allActive.subList(from, to) : List.of();
                ageRatings = moviesRepo.getAgeRatingsFromActiveMovies();
            } else {
                movies = moviesRepo.getMoviesShowingOnDateWithFilter(
                        selectedDate, search, genre, ageRating, page, PAGE_SIZE);
                totalMovies = moviesRepo.countMoviesShowingOnDateWithFilter(
                        selectedDate, search, genre, ageRating);
                ageRatings = moviesRepo.getAgeRatingsShowingOnDate(selectedDate);
            }

            int totalPages = (int) Math.ceil((double) totalMovies / PAGE_SIZE);

            MoviesPage result = new MoviesPage();
            result.movies = movies;
            result.totalMovies = totalMovies;
            result.totalPages = totalPages;
            result.ageRatings = ageRatings;
            result.selectedDate = selectedDate;
            result.showAllMovies = showAllMovies;
            result.genres = genreService.getAllActiveGenres();
            return result;
        } finally {
            if (moviesRepo != null) {
                moviesRepo.closeConnection();
            }
        }
    }

    public int getPageSize() {
        return PAGE_SIZE;
    }
}

