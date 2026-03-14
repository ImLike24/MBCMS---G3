package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MembershipTier {
    private Integer tierId;
    private String tierName;
    private Integer minPointsRequired;
    private BigDecimal pointMultiplier;
    private LocalDateTime createdAt;
}
