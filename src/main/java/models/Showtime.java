package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Showtime {
    private Integer showtimeId;
    private Integer movieId;
    private Integer roomId;
    private LocalDate showDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private BigDecimal basePrice;
    private String status = "SCHEDULED";
    private LocalDateTime createdAt;
}