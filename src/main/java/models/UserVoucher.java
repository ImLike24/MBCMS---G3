package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVoucher {
    private Integer id;
    private Integer userId;
    private Integer voucherId;
    private String voucherCode;
    private String status;
    private LocalDateTime redeemedAt;
    private LocalDateTime expiresAt;
    private LocalDateTime usedAt;
}
