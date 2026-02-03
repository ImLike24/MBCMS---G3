package business;

import models.User;
import repositories.Users;

public class ProfileService {

    private final Users userRepo = new Users();

    /**
     * Lấy thông tin profile của user dựa vào username (thường lấy từ session)
     */
    public User getUserProfile(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        return userRepo.findByUsername(username);
    }

    /**
     * Cập nhật thời gian đăng nhập cuối (nếu cần gọi khi xem profile)
     */
    public void updateLastLoginIfNeeded(User user) {
        if (user != null && user.getUserId() != null) {
            userRepo.updateLastLogin(user.getUserId());
        }
    }
}