package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SeatTypeSurcharge {
    private Integer surchargeId;
    private Integer branchId;
    private String seatType; // NORMAL, VIP, COUPLE
    private Double surchargeRate; // % surcharge (e.g. 50.0 means +50%)
    private LocalDateTime updatedAt;
}
