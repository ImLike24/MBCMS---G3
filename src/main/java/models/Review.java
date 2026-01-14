package models;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Review {
    private Integer reviewId;
    private Integer userId;
    private Integer movieId;
    private Double rating;
    private String comment;
    private Integer helpfulCount = 0;
    private boolean isVerified = false;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}