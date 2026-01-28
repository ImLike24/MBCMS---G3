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

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ManageUsers", urlPatterns = { "/admin/manage-users" })
public class ManageUsers extends HttpServlet {

    private final Users usersRepo = new Users();
    private final Roles rolesRepo = new Roles();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check
        if (!isAdmin(request, response))
            return;

        // 2. Extract Filters
        String statusFilter = request.getParameter("status");
        String roleIdParam = request.getParameter("roleId");
        Integer roleIdFilter = null;

        if (roleIdParam != null && !roleIdParam.isEmpty()) {
            try {
                roleIdFilter = Integer.parseInt(roleIdParam);
            } catch (NumberFormatException ignored) {
            }
        }

        // 3. Fetch Data
        List<User> users;
        if (isNotEmpty(statusFilter) || roleIdFilter != null) {
            users = usersRepo.getUsersWithFilters(statusFilter, roleIdFilter);
        } else {
            users = usersRepo.getAllUsers();
        }

        List<Role> roles = rolesRepo.getAllRoles();

        // 4. Prepare View Data
        Map<Integer, String> roleMap = new HashMap<>();
        if (roles != null) {
            for (Role r : roles) {
                roleMap.put(r.getRoleId(), r.getRoleName());
            }
        }

        // 5. Set Attributes
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("roleMap", roleMap);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("roleIdFilter", roleIdFilter);

        // 6. Forward
        request.getRequestDispatcher("/pages/admin/manage-users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check
        if (!isAdmin(request, response))
            return;

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String currentStatusFilter = request.getParameter("currentStatusFilter");
        String currentRoleIdFilter = request.getParameter("currentRoleIdFilter");

        if ("updateStatus".equals(action)) {
            handleUpdateStatus(request, session);
        }

        // 2. Redirect with Persistence
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/manage-users");
        boolean hasLocalParams = false;

        if (isNotEmpty(currentStatusFilter)) {
            redirectUrl.append("?status=").append(URLEncoder.encode(currentStatusFilter, StandardCharsets.UTF_8));
            hasLocalParams = true;
        }

        if (isNotEmpty(currentRoleIdFilter)) {
            redirectUrl.append(hasLocalParams ? "&" : "?")
                    .append("roleId=").append(URLEncoder.encode(currentRoleIdFilter, StandardCharsets.UTF_8));
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpSession session) {
        String userIdParam = request.getParameter("userId");
        String newStatus = request.getParameter("status");

        if (userIdParam == null || newStatus == null)
            return;

        try {
            int userId = Integer.parseInt(userIdParam);
            User currentUser = (User) session.getAttribute("user");

            // Prevent Self-Lockout
            if (currentUser != null && currentUser.getUserId() == userId && "LOCKED".equals(newStatus)) {
                session.setAttribute("errorMessage", "Action denied: You cannot lock your own administrative account.");
                return;
            }

            // Execute Update
            boolean success = usersRepo.updateUserStatus(userId, newStatus);
            if (success) {
                session.setAttribute("successMessage", "User status updated to " + newStatus);
            } else {
                session.setAttribute("errorMessage", "Failed to update status. Database error.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid User ID format.");
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    private boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }
}
