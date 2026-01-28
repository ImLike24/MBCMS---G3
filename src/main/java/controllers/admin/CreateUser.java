package controllers.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Role;
import models.User;
import repositories.Roles;
import repositories.Users;
import utils.Password;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "CreateUser", urlPatterns = { "/admin/create-user" })
public class CreateUser extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Get all roles for dropdown
        Roles rolesRepo = new Roles();
        List<Role> roles = rolesRepo.getAllRoles();

        request.setAttribute("roles", roles);
        request.getRequestDispatcher("/pages/admin/create-user.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Get form parameters
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String birthdayStr = request.getParameter("birthday");
        String roleIdParam = request.getParameter("roleId");

        // Validation
        if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                roleIdParam == null || roleIdParam.trim().isEmpty()) {

            session.setAttribute("errorMessage", "Please fill in all required fields.");
            response.sendRedirect(request.getContextPath() + "/admin/create-user");
            return;
        }

        try {
            int roleId = Integer.parseInt(roleIdParam);

            Users usersRepo = new Users();

            // Check if username already exists
            if (usersRepo.findByUsername(username) != null) {
                session.setAttribute("errorMessage", "Username already exists.");
                response.sendRedirect(request.getContextPath() + "/admin/create-user");
                return;
            }

            // Check if email already exists
            if (usersRepo.findByEmail(email) != null) {
                session.setAttribute("errorMessage", "Email already exists.");
                response.sendRedirect(request.getContextPath() + "/admin/create-user");
                return;
            }

            // Check if phone already exists (if provided)
            if (phone != null && !phone.trim().isEmpty() && usersRepo.findByPhone(phone) != null) {
                session.setAttribute("errorMessage", "Phone number already exists.");
                response.sendRedirect(request.getContextPath() + "/admin/create-user");
                return;
            }

            // Create new user
            User newUser = new User();
            newUser.setRoleId(roleId);
            newUser.setUsername(username.trim());
            newUser.setEmail(email.trim());
            newUser.setPassword(Password.hashPassword(password));
            newUser.setFullName(fullName != null ? fullName.trim() : null);
            newUser.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);

            // Parse birthday if provided
            if (birthdayStr != null && !birthdayStr.trim().isEmpty()) {
                try {
                    LocalDateTime birthday = LocalDateTime.parse(birthdayStr + "T00:00:00");
                    newUser.setBirthday(birthday);
                } catch (Exception e) {
                    // Invalid date format, ignore
                }
            }

            newUser.setStatus("ACTIVE");
            newUser.setPoints(0);

            // Insert user
            boolean success = usersRepo.insert(newUser);

            if (success) {
                session.setAttribute("successMessage", "User created successfully!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-users");
            } else {
                session.setAttribute("errorMessage", "Failed to create user. Please try again.");
                response.sendRedirect(request.getContextPath() + "/admin/create-user");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid role selected.");
            response.sendRedirect(request.getContextPath() + "/admin/create-user");
        }
    }
}
