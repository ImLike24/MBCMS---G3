package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PointHistory {
    private Integer historyId;
    private Integer userId;
    private Integer pointsChanged;
    private String transactionType;
    private String description;
    private Integer referenceId;
    private LocalDateTime createdAt;

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
