package models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private Integer userId;
    private Integer roleId;
    private String username;
    private String email;
    private String password;
    private String fullName;
    private LocalDateTime birthday;
    private String phone;
    private String avatarUrl;
    private String status = "ACTIVE";
    private Integer points = 0;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLogin;
}