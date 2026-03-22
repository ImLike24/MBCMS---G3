package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StaffSchedule {
    private Integer scheduleId;
    private Integer staffId;
    private Integer branchId;
    private LocalDate workDate;
    private String shift;       // MORNING / AFTERNOON / EVENING / NIGHT
    private String status;      // SCHEDULED / CANCELLED
    private String note;
    private Integer createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Extra fields joined from other tables (not stored in DB)
    private String staffName;
    private String branchName;
    private String createdByName;
}
