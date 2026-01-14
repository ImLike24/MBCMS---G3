package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Booking {
    private Integer bookingId;
    private Integer userId;
    private Integer showtimeId;
    private String bookingCode;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private BigDecimal discountAmount = BigDecimal.ZERO;
    private BigDecimal finalAmount = BigDecimal.ZERO;
    private String paymentMethod;
    private String paymentStatus = "PENDING";
    private LocalDateTime bookingTime;
    private LocalDateTime paymentTime;
    private String status = "PENDING";
    private String cancellationReason;
    private LocalDateTime cancelledAt;
}