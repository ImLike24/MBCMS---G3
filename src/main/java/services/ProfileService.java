package services;

import com.cloudinary.utils.ObjectUtils;
import config.CloudinaryConfig;
import models.User;
import repositories.Users;

import java.util.Map;

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

    /**
     * Upload avatar lên Cloudinary và lưu URL vào DB
     * 
     * @param fileBytes byte[] của file ảnh
     * @param fileName  tên file gốc
     * @param userId    ID người dùng
     * @return URL secure mới nếu thành công, null nếu thất bại
     */
    @SuppressWarnings("unchecked")
    public String uploadAvatar(byte[] fileBytes, String fileName, int userId) {
        try {
            Map<String, Object> uploadParams = ObjectUtils.asMap(
                    "folder", CloudinaryConfig.getUploadFolder(),
                    "public_id", "user_avatar_" + userId,
                    "overwrite", true,
                    "resource_type", "image",
                    "allowed_formats", new String[] { "jpg", "jpeg", "png" });

            Map<String, Object> uploadResult = CloudinaryConfig.getCloudinary().uploader().upload(fileBytes,
                    uploadParams);
            String avatarUrl = (String) uploadResult.get("secure_url");

            boolean updated = userRepo.updateAvatarUrl(userId, avatarUrl);
            return updated ? avatarUrl : null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

}