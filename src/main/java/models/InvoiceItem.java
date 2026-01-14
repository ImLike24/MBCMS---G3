package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceItem {
    private Integer itemId;
    private Integer invoiceId;
    private String itemType;
    private Integer onlineTicketId;
    private Integer counterTicketId;
    private String itemDescription;
    private String movieTitle;
    private LocalDate showtimeDate;
    private LocalTime showtimeTime;
    private String roomName;
    private String seatCode;
    private String ticketType;
    private String seatType;
    private Integer quantity = 1;
    private BigDecimal unitPrice;
    private BigDecimal amount;
    private LocalDateTime createdAt;
}