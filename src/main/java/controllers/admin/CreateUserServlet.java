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
import services.UserService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/create-user")
public class CreateUserServlet extends HttpServlet {

    private final UserService userService = new UserService();

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
            Role userRole = userService.getRoleById(currentUser.getRoleId());

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
            List<Role> creatableRoles = userService.getCreatableRoles();

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
            Role userRole = userService.getRoleById(currentUser.getRoleId());

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
        try {
            usersDbContext = new DBContext();
            
            int roleId = Integer.parseInt(roleIdStr);
            userService.createUser(username.trim(), email.trim(), password, fullName.trim(), phone != null ? phone.trim() : null, birthdayStr, roleId);
            
            response.sendRedirect(request.getContextPath() + "/admin/manage-users?success=User created successfully");
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid role selection");
            doGet(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error creating user: " + e.getMessage());
            doGet(request, response);
        } finally {
            if (usersDbContext != null) {
                usersDbContext.closeConnection();
            }
        }
    }
}
