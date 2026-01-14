package controllers.auth;

import repositories.Roles;
import repositories.Users;
import models.User;
import utils.Password;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pages/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get Params
        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String birthdayStr = request.getParameter("birthday"); // yyyy-MM-dd

        // 2. Validate Empty
        if (isBlank(username) || isBlank(fullName) || isBlank(email) || isBlank(phone) || isBlank(password)) {
            returnError(request, response, "Please fill in all fields.");
            return;
        }

        // 3. Validate Password Regex
        if (!PasswordUtil.isStrongPassword(password)) {
            returnError(request, response, "Password must be 8+ chars, contain letter, number & special char.");
            return;
        }

        UsersDao usersDao = new UsersDao();

        // 4. Check Duplicates
        if (usersDao.findByUsername(username) != null) {
            returnError(request, response, "Username is already taken.");
            return;
        }
        if (usersDao.findByEmail(email) != null) {
            returnError(request, response, "Email is already registered.");
            return;
        }
        if (usersDao.findByPhone(phone) != null) {
            returnError(request, response, "Phone number is already used.");
            return;
        }

        // 5. Get Customer Role ID
        RolesDao rolesDao = new RolesDao();
        Integer roleId = rolesDao.getRoleIdByName("CUSTOMER");
        if (roleId == null) {
            returnError(request, response, "System Error: Role 'CUSTOMER' not found.");
            return;
        }

        // 6. Create User Object
        User u = new User();
        u.setRoleId(roleId);
        u.setUsername(username);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setPassword(PasswordUtil.hashPassword(password)); // Hash Password
        u.setStatus("ACTIVE");
        u.setPoints(0);

        if (birthdayStr != null && !birthdayStr.isEmpty()) {
            u.setBirthday(LocalDate.parse(birthdayStr).atStartOfDay());
        }

        // 7. Insert
        if (usersDao.insert(u)) {
            response.sendRedirect(request.getContextPath() + "/login?success=true");
        } else {
            returnError(request, response, "Registration failed. Please try again.");
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void returnError(HttpServletRequest request, HttpServletResponse response, String msg) throws ServletException, IOException {
        request.setAttribute("error", msg);
        // Keep inputs
        request.setAttribute("username", request.getParameter("username"));
        request.setAttribute("fullName", request.getParameter("fullName"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("phone", request.getParameter("phone"));
        request.setAttribute("birthday", request.getParameter("birthday"));
        request.getRequestDispatcher("/pages/auth/register.jsp").forward(request, response);
    }
}