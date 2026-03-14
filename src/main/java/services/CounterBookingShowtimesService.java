package services;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Movie;
import models.Showtime;
import repositories.Movies;
import repositories.Showtimes;

/**
 * Business logic for listing showtimes for a movie at counter booking.
 */
public class CounterBookingShowtimesService {

    public static class ShowtimesResult {
        public Movie movie;
        public List<Showtime> showtimes;
        public Map<Integer, Integer> availableSeatsMap;
        public Map<Integer, Integer> totalSeatsMap;
        public LocalDate selectedDate;
    }

    public ShowtimesResult getShowtimesForMovie(int movieId, LocalDate selectedDate) throws Exception {
        Movies moviesRepo = null;
        Showtimes showtimesRepo = null;

        try {
            moviesRepo = new Movies();
            showtimesRepo = new Showtimes();

            Movie movie = moviesRepo.getMovieById(movieId);
            if (movie == null) {
                return null;
            }

            List<Showtime> showtimes = showtimesRepo.getShowtimesForMovieOnDate(movieId, selectedDate);

            Map<Integer, Integer> availableSeatsMap = new HashMap<>();
            Map<Integer, Integer> totalSeatsMap = new HashMap<>();

            for (Showtime showtime : showtimes) {
                int availableSeats = showtimesRepo.countAvailableSeats(showtime.getShowtimeId());
                availableSeatsMap.put(showtime.getShowtimeId(), availableSeats);

                Map<String, Object> details = showtimesRepo.getShowtimeDetails(showtime.getShowtimeId());
                if (details.containsKey("totalSeats")) {
                    totalSeatsMap.put(showtime.getShowtimeId(), (Integer) details.get("totalSeats"));
                }
            }

            ShowtimesResult result = new ShowtimesResult();
            result.movie = movie;
            result.showtimes = showtimes;
            result.availableSeatsMap = availableSeatsMap;
            result.totalSeatsMap = totalSeatsMap;
            result.selectedDate = selectedDate;
            return result;
        } finally {
            if (moviesRepo != null) {
                moviesRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}

