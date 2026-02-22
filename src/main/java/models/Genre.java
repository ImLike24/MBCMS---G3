package models;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Genre {
    private Integer genreId;
    private String genreName;
    private String description;
    private boolean isActive;
}