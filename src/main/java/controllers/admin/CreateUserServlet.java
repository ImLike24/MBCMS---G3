package controllers.admin;

import config.DBContext;
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

@WebServlet("/admin/create-user")
public class CreateUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Get creatable roles for dropdown
        DBContext rolesDbContext = null;
        try {
            rolesDbContext = new DBContext();
            Roles rolesRepo = new Roles();
            List<Role> creatableRoles = rolesRepo.getCreatableRoles();

            request.setAttribute("creatableRoles", creatableRoles);
            request.getRequestDispatcher("/pages/admin/user/create-user.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading roles: " + e.getMessage());
            request.getRequestDispatcher("/pages/admin/user/create-user.jsp").forward(request, response);
        } finally {
            if (rolesDbContext != null) {
                rolesDbContext.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext authDbContext = null;
        try {
            authDbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (authDbContext != null) {
                authDbContext.closeConnection();
            }
        }

        // Get form parameters
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String birthdayStr = request.getParameter("birthday");
        String roleIdStr = request.getParameter("roleId");

        // Validation
        StringBuilder errors = new StringBuilder();

        if (username == null || username.trim().isEmpty()) {
            errors.append("Username is required. ");
        }
        if (email == null || email.trim().isEmpty()) {
            errors.append("Email is required. ");
        }
        if (password == null || password.trim().isEmpty()) {
            errors.append("Password is required. ");
        }
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.append("Full name is required. ");
        }
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            errors.append("Role is required. ");
        }

        if (errors.length() > 0) {
            request.setAttribute("error", errors.toString());
            doGet(request, response);
            return;
        }

        DBContext usersDbContext = null;
        DBContext rolesDbContext = null;

        try {
            usersDbContext = new DBContext();
            rolesDbContext = new DBContext();

            Users usersRepo = new Users();
            Roles rolesRepo = new Roles();

            // Check for duplicates
            if (usersRepo.checkUsernameExists(username.trim())) {
                request.setAttribute("error", "Username already exists");
                doGet(request, response);
                return;
            }

            if (usersRepo.checkEmailExists(email.trim())) {
                request.setAttribute("error", "Email already exists");
                doGet(request, response);
                return;
            }

            if (phone != null && !phone.trim().isEmpty() && usersRepo.checkPhoneExists(phone.trim())) {
                request.setAttribute("error", "Phone number already exists");
                doGet(request, response);
                return;
            }

            // Validate role is ADMIN, CINEMA_STAFF, STAFF or BRANCH_MANAGER
            int roleId = Integer.parseInt(roleIdStr);
            Role selectedRole = rolesRepo.getRoleById(roleId);

            if (selectedRole == null ||
                    (!selectedRole.getRoleName().equals("ADMIN") &&
                            !selectedRole.getRoleName().equals("CINEMA_STAFF") &&
                            !selectedRole.getRoleName().equals("STAFF") &&
                            !selectedRole.getRoleName().equals("BRANCH_MANAGER"))) {
                request.setAttribute("error", "Invalid role selection");
                doGet(request, response);
                return;
            }

            // Create new user
            User newUser = new User();
            newUser.setRoleId(roleId);
            newUser.setUsername(username.trim());
            newUser.setEmail(email.trim());
            newUser.setPassword(Password.hashPassword(password)); // Hash password
            newUser.setFullName(fullName.trim());
            newUser.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);

            // Parse birthday if provided
            if (birthdayStr != null && !birthdayStr.trim().isEmpty()) {
                try {
                    LocalDateTime birthday = LocalDateTime.parse(birthdayStr + "T00:00:00");
                    newUser.setBirthday(birthday);
                } catch (Exception e) {
                    // Invalid date format, skip
                }
            }

            newUser.setStatus("ACTIVE");
            newUser.setPoints(0);

            // Insert user
            boolean success = usersRepo.insert(newUser);

            if (success) {
                response.sendRedirect(request.getContextPath() +
                        "/admin/manage-users?success=User created successfully");
            } else {
                request.setAttribute("error", "Failed to create user");
                doGet(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid role selection");
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error creating user: " + e.getMessage());
            doGet(request, response);
        } finally {
            if (usersDbContext != null) {
                usersDbContext.closeConnection();
            }
            if (rolesDbContext != null) {
                rolesDbContext.closeConnection();
            }
        }
    }
}
