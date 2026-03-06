package models;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.time.format.DateTimeFormatter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Movie {
    private Integer movieId;
    private String title;
    private String description;
    private List<String> genres;
    private Integer duration;
    private LocalDate releaseDate;
    private LocalDate endDate;
    private Double rating = 0.0;
    private String ageRating;
    private String director;
    private String cast;
    private String posterUrl;
    private boolean isActive = true;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // For Showtimes view
    private java.util.List<Showtime> showtimes = new java.util.ArrayList<>();
    
    // For counter booking - indicates if movie has showtimes on selected date
    private boolean hasShowtimesToday = false;

    public String getReleaseDateFormatted() {
        if (releaseDate == null)
            return "";
        return releaseDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public String getGenre() {
        if (genres == null || genres.isEmpty()) {
            return "";
        }
        return String.join(", ", genres);
    }
}