package models;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Concession {
    private Integer concessionId;
    private String concessionType;  
    private String concessionName;
    private Integer quantity;           
    private Double priceBase;           
    private Integer addedBy;            
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
