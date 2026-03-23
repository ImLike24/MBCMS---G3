package services;

import models.User;
import repositories.Users;

/**
 * Simple loyalty-related operations (points lookup, etc.).
 */
public class LoyaltyService {

    public static class LoyaltyInfo {
        public User user;
        public int points;
        public int totalAccumulatedPoints;
        public Integer tierId;
    }

    public LoyaltyInfo getLoyaltyInfoByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null;
        }

        Users usersRepo = null;
        try {
            usersRepo = new Users();
            User user = usersRepo.findByPhone(phone.trim());
            if (user == null) {
                return null;
            }
            LoyaltyInfo info = new LoyaltyInfo();
            info.user = user;
            info.points = user.getPoints() != null ? user.getPoints() : 0;
            info.totalAccumulatedPoints =
                    user.getTotalAccumulatedPoints() != null ? user.getTotalAccumulatedPoints() : 0;
            info.tierId = user.getTierId();
            return info;
        } finally {
            if (usersRepo != null) {
                usersRepo.closeConnection();
            }
        }
    }
}

