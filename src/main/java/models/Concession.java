/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class Concession {
    private int concessionId;
    private String concessionType;
    private int quantity;
    private BigDecimal basePrice;
    private int addBy; // id cua staff/manager
    private LocalDateTime createdAt;
}
