package controllers.manager.report.performance;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.PerformanceReportRepository;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ScreeningRoomPerformance", urlPatterns = {"/manager/report/performance/screening-room"})
public class ScreeningRoomPerformance extends HttpServlet {

    private final CinemaBranches branchDao = new CinemaBranches();
    private final PerformanceReportRepository perfRepo = new PerformanceReportRepository();

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

        List<Integer> branchIds = new ArrayList<>();
        for (CinemaBranch b : managedBranches) {
            branchIds.add(b.getBranchId());
        }

        LocalDate fromDate = parseDate(request.getParameter("fromDate"), LocalDate.now().minusDays(30));
        LocalDate toDate = parseDate(request.getParameter("toDate"), LocalDate.now());

        var rows = perfRepo.getScreeningRoomPerformance(branchIds, fromDate, toDate);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("rows", rows);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.getRequestDispatcher("/pages/manager/report/performance/screening-room.jsp").forward(request, response);
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
