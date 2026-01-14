package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Seat {
    private Integer seatId;
    private Integer roomId;
    private String seatCode;
    private String seatType = "NORMAL";
    private String rowNumber;
    private Integer seatNumber;
    private String status = "AVAILABLE";
    private LocalDateTime createdAt;
}