package controllers.admin;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.*;
import repositories.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/manage-cinema-branches")
public class ManageCinemaBranchesServlet extends HttpServlet {

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
        String statusFilter = request.getParameter("statusFilter");

        DBContext branchesDbContext = null;
        DBContext usersDbContext = null;

        try {
            branchesDbContext = new DBContext();
            usersDbContext = new DBContext();

            CinemaBranches branchesRepo = new CinemaBranches();
            Users usersRepo = new Users();

            // Get branches based on filter
            List<CinemaBranch> branches;
            if ("active".equals(statusFilter)) {
                branches = branchesRepo.getActiveBranches();
            } else if ("inactive".equals(statusFilter)) {
                // Get all and filter inactive
                branches = branchesRepo.findAll();
                branches.removeIf(CinemaBranch::isActive);
            } else {
                branches = branchesRepo.findAll();
            }

            // Get available branch managers for assignment
            List<User> availableManagers = usersRepo.getAvailableBranchManagers();
            List<User> allManagers = usersRepo.getAllBranchManagers();

            // Create manager map for display (userId -> fullName)
            Map<Integer, String> managerMap = new HashMap<>();
            for (User manager : allManagers) {
                managerMap.put(manager.getUserId(), manager.getFullName());
            }

            // Set attributes for JSP
            request.setAttribute("branches", branches);
            request.setAttribute("availableManagers", availableManagers);
            request.setAttribute("managerMap", managerMap);
            request.setAttribute("statusFilter", statusFilter);

            request.getRequestDispatcher("/pages/admin/manage-cinema-branches.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading branches: " + e.getMessage());
            request.getRequestDispatcher("/pages/admin/manage-cinema-branches.jsp").forward(request, response);
        } finally {
            if (branchesDbContext != null) {
                branchesDbContext.closeConnection();
            }
            if (usersDbContext != null) {
                usersDbContext.closeConnection();
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

        // Get action parameter
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-cinema-branches?error=Invalid request");
            return;
        }

        DBContext branchesDbContext = null;
        DBContext roomsDbContext = null;

        try {
            branchesDbContext = new DBContext();
            roomsDbContext = new DBContext();

            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();

            boolean success = false;
            String message = "";

            switch (action) {
                case "create":
                    success = handleCreate(request, branchesRepo, message);
                    message = success ? "Branch created successfully" : "Failed to create branch";
                    break;

                case "update":
                    success = handleUpdate(request, branchesRepo, message);
                    message = success ? "Branch updated successfully" : "Failed to update branch";
                    break;

                case "delete":
                    String branchIdStr = request.getParameter("branchId");
                    if (branchIdStr != null) {
                        int branchId = Integer.parseInt(branchIdStr);

                        // Check if branch has screening rooms
                        List<ScreeningRoom> rooms = roomsRepo.getAllRoomsByBranch(branchId);
                        if (!rooms.isEmpty()) {
                            message = "Cannot delete branch with existing screening rooms. Please delete all rooms first.";
                        } else {
                            success = branchesRepo.delete(branchId);
                            message = success ? "Branch deleted successfully" : "Failed to delete branch";
                        }
                    } else {
                        message = "Invalid branch ID";
                    }
                    break;

                case "toggleStatus":
                    String toggleBranchIdStr = request.getParameter("branchId");
                    String isActiveStr = request.getParameter("isActive");
                    if (toggleBranchIdStr != null && isActiveStr != null) {
                        int branchId = Integer.parseInt(toggleBranchIdStr);
                        boolean isActive = Boolean.parseBoolean(isActiveStr);
                        success = branchesRepo.updateBranchStatus(branchId, isActive);
                        message = success ? "Branch status updated successfully" : "Failed to update branch status";
                    } else {
                        message = "Invalid parameters";
                    }
                    break;

                default:
                    message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-cinema-branches?success=" + message);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-cinema-branches?error=" + message);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-cinema-branches?error=Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-cinema-branches?error=" + e.getMessage());
        } finally {
            if (branchesDbContext != null) {
                branchesDbContext.closeConnection();
            }
            if (roomsDbContext != null) {
                roomsDbContext.closeConnection();
            }
        }
    }

    private boolean handleCreate(HttpServletRequest request, CinemaBranches branchesRepo, String message) {
        String branchName = request.getParameter("branchName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String managerIdStr = request.getParameter("managerId");
        String isActiveStr = request.getParameter("isActive");

        // Validate required fields
        if (branchName == null || branchName.trim().isEmpty()) {
            return false;
        }

        // Check for duplicate name
        if (branchesRepo.branchNameExists(branchName, null)) {
            return false;
        }

        CinemaBranch branch = new CinemaBranch();
        branch.setBranchName(branchName.trim());
        branch.setAddress(address != null ? address.trim() : null);
        branch.setPhone(phone != null ? phone.trim() : null);
        branch.setEmail(email != null ? email.trim() : null);

        if (managerIdStr != null && !managerIdStr.isEmpty()) {
            branch.setManagerId(Integer.parseInt(managerIdStr));
        } else {
            branch.setManagerId(null);
        }

        branch.setActive(isActiveStr != null && isActiveStr.equals("on"));

        return branchesRepo.insert(branch);
    }

    private boolean handleUpdate(HttpServletRequest request, CinemaBranches branchesRepo, String message) {
        String branchIdStr = request.getParameter("branchId");
        String branchName = request.getParameter("branchName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String managerIdStr = request.getParameter("managerId");
        String isActiveStr = request.getParameter("isActive");

        if (branchIdStr == null || branchName == null || branchName.trim().isEmpty()) {
            return false;
        }

        int branchId = Integer.parseInt(branchIdStr);

        // Check for duplicate name (excluding current branch)
        if (branchesRepo.branchNameExists(branchName, branchId)) {
            return false;
        }

        CinemaBranch branch = branchesRepo.findById(branchId);
        if (branch == null) {
            return false;
        }

        branch.setBranchName(branchName.trim());
        branch.setAddress(address != null ? address.trim() : null);
        branch.setPhone(phone != null ? phone.trim() : null);
        branch.setEmail(email != null ? email.trim() : null);

        if (managerIdStr != null && !managerIdStr.isEmpty() && !managerIdStr.equals("")) {
            branch.setManagerId(Integer.parseInt(managerIdStr));
        } else {
            branch.setManagerId(null);
        }

        branch.setActive(isActiveStr != null && isActiveStr.equals("on"));

        return branchesRepo.update(branch);
    }
}
