package controllers.users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.User;
import repositories.Users;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet(name = "UserProfile", urlPatterns = {"/profile"})
public class UserProfile extends HttpServlet {

    private final Users userRepo = new Users();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("u", user);
        request.getRequestDispatcher("/pages/user/profile.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đảm bảo xử lý tiếng Việt và ký tự đặc biệt
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int userId = currentUser.getUserId();

        // Lấy dữ liệu từ form
        String fullName     = request.getParameter("fullName");
        String email        = request.getParameter("email");
        String phone        = request.getParameter("phone");
        String birthdayStr  = request.getParameter("birthday");
        String newPassword  = request.getParameter("password");
        String confirmPass  = request.getParameter("confirmPassword");

        String error = null;

        // Validate cơ bản
        if (fullName == null || fullName.trim().isEmpty()) {
            error = "Họ và tên không được để trống.";
        } else if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            error = "Email không đúng định dạng.";
        } else if (newPassword != null && !newPassword.trim().isEmpty()) {
            if (!newPassword.equals(confirmPass)) {
                error = "Mật khẩu xác nhận không khớp.";
            }
            if (newPassword.length() < 6) {
                error = "Mật khẩu mới phải có ít nhất 6 ký tự.";
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("u", currentUser); // giữ dữ liệu cũ để hiển thị lại form
            request.getRequestDispatcher("/pages/user/profile.jsp").forward(request, response);
            return;
        }

        // Tạo đối tượng User để cập nhật (dựa trên user hiện tại)
        User updatedUser = new User();
        updatedUser.setUserId(userId);

        // Giữ nguyên các trường không cho phép thay đổi từ form
        updatedUser.setRoleId(currentUser.getRoleId());
        updatedUser.setUsername(currentUser.getUsername());
        updatedUser.setStatus(currentUser.getStatus());
        updatedUser.setPoints(currentUser.getPoints());
        updatedUser.setCreatedAt(currentUser.getCreatedAt());
        updatedUser.setLastLogin(currentUser.getLastLogin());
        updatedUser.setAvatarUrl(currentUser.getAvatarUrl());

        // Cập nhật các trường từ form
        updatedUser.setFullName(fullName.trim());
        updatedUser.setEmail(email.trim());
        updatedUser.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);

        // Xử lý birthday
        if (birthdayStr != null && !birthdayStr.trim().isEmpty()) {
            try {
                LocalDate date = LocalDate.parse(birthdayStr);
                updatedUser.setBirthday(date.atStartOfDay());
            } catch (Exception e) {
                // Nếu ngày sinh không hợp lệ, giữ nguyên giá trị cũ
                updatedUser.setBirthday(currentUser.getBirthday());
            }
        } else {
            updatedUser.setBirthday(currentUser.getBirthday());
        }

        // Xử lý password
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            // Ở đây bạn NÊN hash password trước khi lưu
            // Ví dụ: updatedUser.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            updatedUser.setPassword(newPassword); // tạm thời để plain text (KHÔNG AN TOÀN)
        } else {
            updatedUser.setPassword(currentUser.getPassword());
        }

        // Thực hiện update
        boolean success = userRepo.updateUser(updatedUser);

        if (success) {
            // Lấy lại thông tin mới nhất từ DB và cập nhật session
            User freshUser = userRepo.findById(userId);
            if (freshUser != null) {
                session.setAttribute("user", freshUser);
            }
            request.setAttribute("message", "Cập nhật thông tin thành công!");
        } else {
            request.setAttribute("error", "Cập nhật thất bại, vui lòng thử lại.");
        }

        // Load lại trang (vẫn ở chế độ view)
        request.setAttribute("u", session.getAttribute("user"));
        request.getRequestDispatcher("/pages/user/profile.jsp").forward(request, response);
    }
}