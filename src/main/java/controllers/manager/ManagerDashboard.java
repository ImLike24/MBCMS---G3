package controllers.manager;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import services.AuthService;
import services.BranchManagerDashboardService;

@WebServlet(name = "ManagerDashboard", urlPatterns = { "/branch-manager/dashboard" })
public class ManagerDashboard extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final BranchManagerDashboardService dashboardService = new BranchManagerDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = "";
        try {
            role = authService.getRoleName(user.getRoleId());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"BRANCH_MANAGER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(user.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn chưa được gán chi nhánh.");
            return;
        }

        List<Integer> managedIds = managedBranches.stream()
                .map(CinemaBranch::getBranchId)
                .collect(Collectors.toList());

        String branchParam = request.getParameter("branchId");
        List<Integer> branchIds = new ArrayList<>();
        Integer selectedBranchId = null;

        if (branchParam != null && !branchParam.isBlank() && !"all".equalsIgnoreCase(branchParam)) {
            try {
                int bid = Integer.parseInt(branchParam.trim());
                if (managedIds.contains(bid)) {
                    branchIds.add(bid);
                    selectedBranchId = bid;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        if (branchIds.isEmpty()) {
            branchIds.addAll(managedIds);
        }

        try {
            Map<String, Object> dashboardData = dashboardService.getDashboardData(branchIds, managedBranches);
            request.setAttribute("dashboard", dashboardData);
            request.setAttribute("revenueByBranchJson", dashboardService.toJson(dashboardData.get("revenueByBranch")));
            request.setAttribute("topMoviesJson", dashboardService.toJson(dashboardData.get("topMovies")));
            request.setAttribute("revenueTrendJson", dashboardService.toJson(dashboardData.get("revenueTrend")));
            request.setAttribute("managedBranches", managedBranches);
            request.setAttribute("selectedBranchId", selectedBranchId);

            request.getRequestDispatcher("/pages/manager/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không tải được dữ liệu dashboard.");
        }
    }
}
