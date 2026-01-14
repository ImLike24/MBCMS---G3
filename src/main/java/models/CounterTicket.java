package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CounterTicket {
    private Integer ticketId;
    private Integer showtimeId;
    private Integer seatId;
    private String ticketType;
    private String seatType;
    private BigDecimal price;
    private String ticketCode;
    private Integer soldBy;
    private String paymentMethod;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private String notes;
    private LocalDateTime soldAt;
}