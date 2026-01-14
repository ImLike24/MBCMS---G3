package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OnlineTicket {
    private Integer ticketId;
    private Integer bookingId;
    private Integer showtimeId;
    private Integer seatId;
    private String ticketType;
    private String seatType;
    private BigDecimal price;
    private String eTicketCode;
    private boolean isCheckedIn = false;
    private LocalDateTime checkedInAt;
    private Integer checkedInBy;
    private LocalDateTime createdAt;
}