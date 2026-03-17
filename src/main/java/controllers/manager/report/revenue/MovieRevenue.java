package controllers.manager.report.revenue;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.RevenueReportRepository;

@WebServlet(name = "MovieRevenue", urlPatterns = {"/manager/report/revenue/movie-report"})
public class MovieRevenue extends HttpServlet {

    private final CinemaBranches branchDao = new CinemaBranches();
    private final RevenueReportRepository revenueRepo = new RevenueReportRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        var user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(user.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

        List<Integer> allBranchIds = new ArrayList<>();
        for (CinemaBranch b : managedBranches) {
            allBranchIds.add(b.getBranchId());
        }

        String branchIdParam = request.getParameter("branchId");
        Integer selectedBranchId = null;
        List<Integer> branchIds = new ArrayList<>(allBranchIds);
        if (branchIdParam != null && !branchIdParam.isBlank() && !"all".equals(branchIdParam)) {
            try {
                int bid = Integer.parseInt(branchIdParam.trim());
                if (allBranchIds.contains(bid)) {
                    branchIds.clear();
                    branchIds.add(bid);
                    selectedBranchId = bid;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        LocalDate fromDate = parseDate(request.getParameter("fromDate"), LocalDate.now().minusDays(30));
        LocalDate toDate = parseDate(request.getParameter("toDate"), LocalDate.now());

        var rows = revenueRepo.getRevenueByMovie(branchIds, fromDate, toDate);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);
        request.setAttribute("rows", rows);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.getRequestDispatcher("/pages/manager/report/revenue/movie-report.jsp").forward(request, response);
    }

    private LocalDate parseDate(String value, LocalDate defaultVal) {
        if (value == null || value.trim().isEmpty()) return defaultVal;
        try {
            return LocalDate.parse(value);
        } catch (Exception e) {
            return defaultVal;
        }
    }
}
