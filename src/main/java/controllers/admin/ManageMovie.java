package controllers.admin;

import config.DBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.Movie;
import repositories.Movies;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Role;
import models.User;
import repositories.Roles;
import repositories.Users;

@WebServlet("/admin/manage-movies")
public class ManageMovie extends HttpServlet {

    private Movies movieRepo = new Movies();

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

        // Get filter parameters
        String roleFilter = request.getParameter("roleFilter");
        String statusFilter = request.getParameter("statusFilter");
        String searchKeyword = request.getParameter("search");

        DBContext usersDbContext = null;
        DBContext rolesDbContext = null;

        try {
            usersDbContext = new DBContext();
            rolesDbContext = new DBContext();

            Users usersRepo = new Users();
            Roles rolesRepo = new Roles();

            // Get users based on filters
            List<User> users;
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                users = usersRepo.searchUsers(searchKeyword.trim());
            } else if (roleFilter != null && !roleFilter.isEmpty()) {
                users = usersRepo.getUsersByRole(Integer.parseInt(roleFilter));
            } else if (statusFilter != null && !statusFilter.isEmpty()) {
                users = usersRepo.getUsersByStatus(statusFilter);
            } else {
                users = usersRepo.getAllUsers();
            }

            // Get all roles for filter dropdown
            List<Role> allRoles = rolesRepo.getAllRoles();

            // Create a map of roleId -> roleName for display
            Map<Integer, String> roleMap = new HashMap<>();
            for (Role role : allRoles) {
                roleMap.put(role.getRoleId(), role.getRoleName());
            }

            // Set attributes for JSP
            request.setAttribute("users", users);
            request.setAttribute("allRoles", allRoles);
            request.setAttribute("roleMap", roleMap);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("searchKeyword", searchKeyword);

            request.getRequestDispatcher("/pages/admin/manage-movie.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading users: " + e.getMessage());
            request.getRequestDispatcher("/pages/admin/manage-movie.jsp").forward(request, response);
        } finally {
            if (usersDbContext != null) {
                usersDbContext.closeConnection();
            }
            if (rolesDbContext != null) {
                rolesDbContext.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            Movie m = new Movie();
            m.setTitle(request.getParameter("title"));
            m.setGenre(request.getParameter("genre"));
            m.setDuration(Integer.parseInt(request.getParameter("duration")));
            m.setRating(Double.parseDouble(request.getParameter("rating")));
            movieRepo.insertMovie(m);

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            movieRepo.deleteMovie(id);
        }

        response.sendRedirect("ManageMovie");
    }
}
