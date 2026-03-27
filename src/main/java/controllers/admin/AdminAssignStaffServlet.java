package controllers.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.CinemaBranch;
import models.Role;
import models.User;
import repositories.CinemaBranches;
import repositories.Users;
import services.UserService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAssignStaffServlet", urlPatterns = {"/admin/assign-staff"})
public class AdminAssignStaffServlet extends HttpServlet {

    private final Users usersDao = new Users();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        List<CinemaBranch> allBranches = branchDao.getActiveBranches();

        // Branch được chọn (từ param hoặc tất cả)
        String branchIdParam = request.getParameter("branchId");
        Integer selectedBranchId = null;
        if (branchIdParam != null && !branchIdParam.isBlank()) {
            try { selectedBranchId = Integer.parseInt(branchIdParam); } catch (NumberFormatException ignored) {}
        }

        // Lấy danh sách nhân viên chưa phân công
        List<User> unassignedStaff = usersDao.getUnassignedStaff();
        List<User> unassignedManagers = usersDao.getUnassignedManagers();

        // Nếu có branch được chọn, lấy nhân viên đang thuộc branch đó
        List<User> assignedStaff = null;
        CinemaBranch selectedBranch = null;
        if (selectedBranchId != null) {
            selectedBranch = branchDao.findById(selectedBranchId);
            assignedStaff = usersDao.getStaffByBranch(selectedBranchId);
        }

        request.setAttribute("allBranches", allBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);
        request.setAttribute("selectedBranch", selectedBranch);
        request.setAttribute("unassignedStaff", unassignedStaff);
        request.setAttribute("unassignedManagers", unassignedManagers);
        request.setAttribute("assignedStaff", assignedStaff);

        request.getRequestDispatcher("/pages/admin/user/assign-staff.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        String branchIdParam = request.getParameter("branchId");
        String userIdParam = request.getParameter("userId");

        int branchId = 0;
        int userId = 0;
        try {
            branchId = Integer.parseInt(branchIdParam);
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/assign-staff?error=invalid_params");
            return;
        }

        switch (action == null ? "" : action) {
            case "assign" -> handleAssign(request, response, userId, branchId);
            case "unassign" -> handleUnassign(request, response, userId, branchId);
            case "assign-manager" -> handleAssignManager(request, response, userId, branchId);
            case "unassign-manager" -> handleUnassignManager(request, response, userId, branchId);
            default -> response.sendRedirect(request.getContextPath() + "/admin/assign-staff?branchId=" + branchId);
        }
    }

    private void handleAssign(HttpServletRequest request, HttpServletResponse response,
                               int userId, int branchId) throws IOException {
        usersDao.updateBranchAssignment(userId, branchId);
        response.sendRedirect(request.getContextPath()
                + "/admin/assign-staff?branchId=" + branchId + "&message=assigned");
    }

    private void handleUnassign(HttpServletRequest request, HttpServletResponse response,
                                 int userId, int branchId) throws IOException {
        usersDao.updateBranchAssignment(userId, null);
        response.sendRedirect(request.getContextPath()
                + "/admin/assign-staff?branchId=" + branchId + "&message=unassigned");
    }

    private void handleAssignManager(HttpServletRequest request, HttpServletResponse response,
                                      int userId, int branchId) throws IOException {
        CinemaBranch branch = branchDao.findById(branchId);
        // Mỗi branch chỉ có 1 manager — từ chối nếu đã có manager khác
        if (branch != null && branch.getManagerId() != null) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/assign-staff?branchId=" + branchId + "&error=branch_has_manager");
            return;
        }
        usersDao.updateBranchAssignment(userId, branchId);
        if (branch != null) {
            branch.setManagerId(userId);
            branchDao.update(branch);
        }
        response.sendRedirect(request.getContextPath()
                + "/admin/assign-staff?branchId=" + branchId + "&message=manager_assigned");
    }

    private void handleUnassignManager(HttpServletRequest request, HttpServletResponse response,
                                        int userId, int branchId) throws IOException {
        // Gỡ manager: xóa branch_id của user + xóa manager_id của branch
        usersDao.updateBranchAssignment(userId, null);
        CinemaBranch branch = branchDao.findById(branchId);
        if (branch != null && Integer.valueOf(userId).equals(branch.getManagerId())) {
            branch.setManagerId(null);
            branchDao.update(branch);
        }
        response.sendRedirect(request.getContextPath()
                + "/admin/assign-staff?branchId=" + branchId + "&message=manager_unassigned");
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/login"); return false; }
        User user = (User) session.getAttribute("user");
        if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return false; }
        Role role = userService.getRoleById(user.getRoleId());
        if (role == null || !"ADMIN".equals(role.getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return false;
        }
        return true;
    }
}
