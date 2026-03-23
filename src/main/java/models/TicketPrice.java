package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketPrice {
    private Integer priceId;
    private Integer branchId;
    private String ticketType;   // CHILD, ADULT
    private String dayType;      // HOLIDAY, WEEKEND, WEEKDAY
    private String timeSlot;     // NIGHT, EVENING, AFTERNOON, MORNING
    private BigDecimal price;
    private LocalDate effectiveFrom;
    private LocalDate effectiveTo;
    private boolean isActive = true;
    private LocalDateTime createdAt;
}