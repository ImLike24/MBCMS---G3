package models.dtos;

import java.sql.Timestamp;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingHistoryDTO {
    private String transactionCode;
    private Timestamp transactionDate;
    private String branchName;
    private String paymentMethod;
    private double totalAmount;
    private String transactionType;
    private String movieTitle;
    private String seatCodes;
    private String seatTypes;
}
