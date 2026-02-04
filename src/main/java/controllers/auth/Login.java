package controllers.auth;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import services.AuthService;

@WebServlet(name = "login", urlPatterns = { "/login" })
public class Login extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("true".equals(request.getParameter("success"))) {
            request.setAttribute("message", "Registration successful! Please login.");
        }
        request.getRequestDispatcher("/pages/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Basic Validation
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and Password are required.");
            request.getRequestDispatcher("/pages/auth/login.jsp").forward(request, response);
            return;
        }

        try {
            // Call Service
            User user = authService.loginUser(username, password);

            // Get Session
            HttpSession session = request.getSession();

            // Get role's name
            String roleName = authService.getRoleName(user.getRoleId());

            session.setAttribute("user", user);
            session.setAttribute("role", roleName);

            // Redirect
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
                    response.sendRedirect(request.getContextPath() + "/branch-manager/dashboard");
                    break;
                case "CINEMA_STAFF":
                    response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                    break;
                case "CUSTOMER":
                default:
                    response.sendRedirect(request.getContextPath() + "/home");
                    break;
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/pages/auth/login.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error occurred.");
            request.getRequestDispatcher("/pages/auth/login.jsp").forward(request, response);
        }
    }
}