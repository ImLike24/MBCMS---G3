package services;

import repositories.Showtimes;
import repositories.Seats;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class BookingService {

    //SHOWTIMES LIST

    // Lay danh sach Showtime
    private Showtimes showtimeList = new Showtimes();
    public List<?> getShowtimesForMovieOnDate(int movieId, LocalDate date){
        return showtimeList.getShowtimesForMovieOnDate(movieId, date);
    }

    // lay suat chieu theo ID
    public Object getShowtimeById(int showtimeId){
        return showtimeList.getShowtimeById(showtimeId);
    }

    //lay danh sach chi tiet suat chieu (phong, chi nhanh cu the, phim chieu)
    public Map<String, Object> getShowtimeDetails(int showtimeId){
        return showtimeList.getShowtimeDetails(showtimeId);
    }

    //SEATS

    // dem so ghe con trong dua vao suat chieu
    // cu the, chon thoi gian chieu -> tuong ung voi phong chieu theo thoi gian do
    public int countAvailableSeats(int showtimeId){
        return showtimeList.countAvailableSeats(showtimeId);
    }

    // lay danh sach ghe con trong theo suat chieu

    public List<?> getAvailableSeats(int showtimeId){
        return showtimeList.getAvailableSeats(showtimeId);
    }

    // lay danh sach ghe va trang thai dat theo suat chieu
    public List<Map<String, Object>> getSeatWithBookingStatus(int showtimeId){
        return showtimeList.getSeatsWithBookingStatus(showtimeId);
    }

    // TICKETS

    // 
}