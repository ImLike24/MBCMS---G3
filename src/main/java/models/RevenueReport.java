package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RevenueReport {
    private Integer reportId;
    private Integer branchId;
    private LocalDate reportDate;
    private String saleChannel;
    private Integer onlineTicketsCount = 0;
    private BigDecimal onlineRevenue = BigDecimal.ZERO;
    private Integer counterTicketsCount = 0;
    private BigDecimal counterRevenue = BigDecimal.ZERO;
    private Integer totalTicketsCount = 0;
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private Integer adultTickets = 0;
    private Integer childTickets = 0;
    private Integer normalSeats = 0;
    private Integer vipSeats = 0;
    private Integer coupleSeats = 0;
    private LocalDateTime generatedAt;
    private Integer generatedBy;
}