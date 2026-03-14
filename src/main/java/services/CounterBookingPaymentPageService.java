package services;

import java.util.Map;
import repositories.Showtimes;

/**
 * Business logic for loading counter booking payment page data.
 */
public class CounterBookingPaymentPageService {

    public Map<String, Object> getShowtimeDetails(int showtimeId) throws Exception {
        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();
            return showtimesRepo.getShowtimeDetails(showtimeId);
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}

