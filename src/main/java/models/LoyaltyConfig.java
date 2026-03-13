package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoyaltyConfig {
    private Integer configId;
    private BigDecimal earnRateAmount;
    private Integer earnPoints;
    private Integer minRedeemPoints;
    private LocalDateTime updatedAt;
    private Integer updatedBy;
}
