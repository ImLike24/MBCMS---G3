package models;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReportedComment {
    private Integer reportId;
    private Integer reviewId;
    private Integer reportedBy;
    private String reason;
    private String status = "PENDING";
    private Integer resolvedBy;
    private LocalDateTime resolvedAt;
    private String resolutionNote;
    private LocalDateTime createdAt;
}