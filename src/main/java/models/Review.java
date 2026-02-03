package models;

import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Review {
    private Integer reviewId;
    private Integer userId;
    private Integer movieId;
    private Integer rating;
    private String comment;
    private Integer helpfulCount = 0;
    private boolean isVerified = false;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String username;
    private String avatarUrl;

    public String getCreatedAtFormatted() {
        if(createdAt != null){
            return createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        }
        return null;
    }
}