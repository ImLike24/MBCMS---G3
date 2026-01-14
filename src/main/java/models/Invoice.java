package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Invoice {
    private Integer invoiceId;
    private String invoiceCode;
    private LocalDateTime invoiceDate;
    private Integer bookingId;
    private String saleChannel;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private Integer branchId;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal finalAmount;
    private String paymentMethod;
    private String paymentStatus = "PAID";
    private String status = "ACTIVE";
    private Integer createdBy;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<InvoiceItem> items;
}