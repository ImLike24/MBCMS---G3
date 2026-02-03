package controllers.users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.User;
import repositories.Users;
import java.io.IOException;
import utils.Password;

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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String birthdayStr = request.getParameter("birthday");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        // parse birthday
        if (birthdayStr != null && !birthdayStr.isEmpty()) {
            user.setBirthday(java.time.LocalDate.parse(birthdayStr).atStartOfDay());
        } else {
            user.setBirthday(null);
        }

        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);

        // nếu có đổi mật khẩu
        if (password != null && !password.isEmpty()) {

            if (!password.equals(confirm)) {
                request.setAttribute("error", "Password confirmation does not match");
                request.setAttribute("u", user);
                request.getRequestDispatcher("/pages/user/profile.jsp").forward(request, response);
                return;
            }

            if (!Password.isValidPassword(password)) {
                request.setAttribute("error", "Password must be at least 8 characters, include letter, number and special character");
                request.setAttribute("u", user);
                request.getRequestDispatcher("/pages/user/profile.jsp").forward(request, response);
                return;
            }

            String hashedPassword = Password.hashPassword(password);
            user.setPassword(hashedPassword);
        }

        userRepo.updateProfile(user);

        // cập nhật lại session
        session.setAttribute("user", user);

        response.sendRedirect(request.getContextPath() + "/profile");
    }

}