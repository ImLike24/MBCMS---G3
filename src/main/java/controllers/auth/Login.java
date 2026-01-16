package controllers.auth;

import repositories.Roles;
import repositories.Users;
import models.Role;
import models.User;
import utils.Password;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "Login", urlPatterns = {"/login"})
public class Login extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Show success message if redirected from Register
        if ("true".equals(request.getParameter("success"))) {
            request.setAttribute("message", "Registration successful! Please login.");
        }
        request.getRequestDispatcher("/pages/auth/Login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 1. Basic Validate
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and Password are required.");
            request.getRequestDispatcher("/pages/auth/login.jsp").forward(request, response);
            return;
        }

        Users usersDao = new Users();
        User user = usersDao.findByUsername(username);

        // 2. Authenticate
        if (user == null || !Password.verifyPassword(password, user.getPassword())) {
            request.setAttribute("error", "Invalid username or password.");
            request.getRequestDispatcher("/pages/auth/Login.jsp").forward(request, response);
            return;
        }

        // 3. Check Status
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("error", "Your account is " + user.getStatus() + ". Please contact admin.");
            request.getRequestDispatcher("/pages/auth/Login.jsp").forward(request, response);
            return;
        }

        // 4. Login Success
        HttpSession session = request.getSession();

        // Get Role Name
        Roles rolesDao = new Roles();
        Role role = rolesDao.getRoleById(user.getRoleId());
        String roleName = (role != null) ? role.getRoleName().toUpperCase() : "GUEST";

        // Set Session
        session.setAttribute("user", user);
        session.setAttribute("role", roleName);

        // Update last login time
        usersDao.updateLastLogin(user.getUserId());

        // 5. Redirect based on Role
        // Priority: Saved URL > Role Based Dashboard
        String redirectUrl = (String) session.getAttribute("redirectUrl");
        if (redirectUrl != null) {
            session.removeAttribute("redirectUrl");
            response.sendRedirect(redirectUrl);
            return;
        }

        switch (roleName) {
            case "ADMIN":
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                break;
            case "BRANCH_MANAGER":
                response.sendRedirect(request.getContextPath() + "/manager/dashboard");
                break;
            case "CINEMA_STAFF":
                response.sendRedirect(request.getContextPath() + "/staff/pos");
                break;
            case "CUSTOMER":
            default:
                response.sendRedirect(request.getContextPath() + "/home");
                break;
        }
    }
}