package services;

import java.time.DayOfWeek;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import models.Showtime;
import repositories.Showtimes;
import repositories.TicketPrices;
import repositories.SeatTypeSurcharges;
import java.math.BigDecimal;

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
        public Double adultPrice;
        public Double childPrice;
        public java.util.List<models.SeatTypeSurcharge> surchargeList;
    }

    public SeatsResult getSeatsForShowtime(int showtimeId) throws Exception {
        Showtimes showtimesRepo = null;
        TicketPrices ticketPricesRepo = null;
        SeatTypeSurcharges seatTypeSurchargesRepo = null;
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

                // ===== Load dynamic ticket prices & seat-type surcharges for this showtime =====
                Integer branchId = (Integer) showtimeDetails.get("branchId");
                BigDecimal adultPriceBD = null;
                BigDecimal childPriceBD = null;

                if (branchId != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
                    DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
                    String dayType = (dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY)
                            ? "WEEKEND"
                            : "WEEKDAY";

                    int hour = showtime.getStartTime().getHour();
                    String timeSlot;
                    if (hour >= 6 && hour < 12) timeSlot = "MORNING";
                    else if (hour >= 12 && hour < 17) timeSlot = "AFTERNOON";
                    else if (hour >= 17 && hour < 22) timeSlot = "EVENING";
                    else timeSlot = "NIGHT";

                    ticketPricesRepo = new TicketPrices();
                    adultPriceBD = ticketPricesRepo.getTicketPrice(branchId, "ADULT", dayType, timeSlot,
                            showtime.getShowDate());
                    childPriceBD = ticketPricesRepo.getTicketPrice(branchId, "CHILD", dayType, timeSlot,
                            showtime.getShowDate());

                    seatTypeSurchargesRepo = new SeatTypeSurcharges();
                    result.surchargeList = seatTypeSurchargesRepo.getSurchargesByBranch(branchId);
                }

                double adultPrice = (adultPriceBD != null) ? adultPriceBD.doubleValue() : 0.0;
                double childPrice = (childPriceBD != null) ? childPriceBD.doubleValue() : 0.0;

                if (adultPrice == 0.0 && showtime.getBasePrice() != null) {
                    adultPrice = showtime.getBasePrice().doubleValue();
                }
                if (childPrice == 0.0) {
                    childPrice = adultPrice;
                }

                result.adultPrice = adultPrice;
                result.childPrice = childPrice;
            }
            return result;
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
            if (ticketPricesRepo != null) {
                ticketPricesRepo.closeConnection();
            }
            if (seatTypeSurchargesRepo != null) {
                seatTypeSurchargesRepo.closeConnection();
            }
        }
    }
}

