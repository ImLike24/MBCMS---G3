package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Voucher {
    private Integer voucherId;
    private String voucherName;
    private String voucherType;
    private String voucherCode;
    private Integer pointsCost;
    private BigDecimal discountAmount;
    private Integer maxUsageLimit;
    private Integer validDays;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
