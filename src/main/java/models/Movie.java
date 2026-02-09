package models;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

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
}