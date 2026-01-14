package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketPrice {
    private Integer priceId;
    private String seatType;
    private String ticketType;
    private String dayType;
    private String timeSlot;
    private BigDecimal price;
    private LocalDate effectiveFrom;
    private LocalDate effectiveTo;
    private boolean isActive = true;
    private LocalDateTime createdAt;
}