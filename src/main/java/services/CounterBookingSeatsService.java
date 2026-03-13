package services;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import models.Showtime;
import repositories.Showtimes;

/**
 * Business logic for seat selection screen at counter booking.
 */
public class CounterBookingSeatsService {

    public static class SeatsResult {
        public Map<String, Object> showtimeDetails;
        public List<Map<String, Object>> seatsWithStatus;
        public int availableSeats;
        public Showtime showtime;
        public String formattedStartTime;
        public String formattedShowDate;
    }

    public SeatsResult getSeatsForShowtime(int showtimeId) throws Exception {
        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails.isEmpty()) {
                return null;
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            int availableSeats = showtimesRepo.countAvailableSeats(showtimeId);

            Showtime showtime = (Showtime) showtimeDetails.get("showtime");

            SeatsResult result = new SeatsResult();
            result.showtimeDetails = showtimeDetails;
            result.seatsWithStatus = seatsWithStatus;
            result.availableSeats = availableSeats;
            result.showtime = showtime;

            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    result.formattedStartTime = showtime.getStartTime()
                            .format(DateTimeFormatter.ofPattern("HH:mm"));
                }
                if (showtime.getShowDate() != null) {
                    result.formattedShowDate = showtime.getShowDate()
                            .format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                }
            }
            return result;
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}

