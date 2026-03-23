package controllers.manager.report.performance;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.PerformanceReports;
import repositories.PerformanceReports.BranchPerformanceRow;
import repositories.PerformanceReports.MovieTicketRow;
import services.AuthService;

@WebServlet(name = "PerformanceReportIndex", urlPatterns = {
        "/manager/report/performance",
        "/manager/report/performance/movies"
})
public class PerformanceReportIndex extends HttpServlet {

    private static final String FLASH_REPORT_FILTER = "reportFilterError";

    private final AuthService authService = new AuthService();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final PerformanceReports performanceRepo = new PerformanceReports();

    private static void consumeReportFlash(HttpServletRequest request, HttpSession session) {
        if (session == null) {
            return;
        }
        Object msg = session.getAttribute(FLASH_REPORT_FILTER);
        if (msg != null) {
            session.removeAttribute(FLASH_REPORT_FILTER);
            request.setAttribute(FLASH_REPORT_FILTER, msg);
        }
    }

    private static String buildReportRedirectUrl(HttpServletRequest req, String servletPath) {
        StringBuilder sb = new StringBuilder(req.getContextPath());
        if (servletPath != null && servletPath.endsWith("/movies")) {
            sb.append("/manager/report/performance/movies");
        } else {
            sb.append("/manager/report/performance");
        }
        String bp = req.getParameter("branchId");
        if (bp != null && !bp.isBlank() && !"all".equalsIgnoreCase(bp.trim())) {
            sb.append("?branchId=").append(URLEncoder.encode(bp.trim(), StandardCharsets.UTF_8));
        }
        return sb.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role;
        try {
            role = authService.getRoleName(user.getRoleId());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"BRANCH_MANAGER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        consumeReportFlash(request, session);

        int managerId = user.getUserId();
        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(managerId);
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không quản lý chi nhánh nào.");
            return;
        }

        LocalDate today = LocalDate.now();
        LocalDate fromDate = YearMonth.from(today).atDay(1);
        LocalDate toDate = today;

        String fromParam = request.getParameter("from");
        String toParam = request.getParameter("to");
        if (fromParam != null && !fromParam.isBlank()) {
            try {
                fromDate = LocalDate.parse(fromParam.trim());
            } catch (DateTimeParseException ignored) {
            }
        }
        if (toParam != null && !toParam.isBlank()) {
            try {
                toDate = LocalDate.parse(toParam.trim());
            } catch (DateTimeParseException ignored) {
            }
        }

        String servletPath = request.getServletPath();
        if (fromDate.isAfter(toDate)) {
            session.setAttribute(FLASH_REPORT_FILTER,
                    "Không được để khoảng thời gian bên trái lớn hơn khoảng thời gian bên phải!");
            response.sendRedirect(buildReportRedirectUrl(request, servletPath));
            return;
        }
        if (toDate.isAfter(today)) {
            session.setAttribute(FLASH_REPORT_FILTER, "Chỉ có thể để thời gian hiện tại!");
            response.sendRedirect(buildReportRedirectUrl(request, servletPath));
            return;
        }

        Integer filterBranchId = null;
        String branchParam = request.getParameter("branchId");
        if (branchParam != null && !branchParam.isBlank() && !"all".equalsIgnoreCase(branchParam.trim())) {
            try {
                int bid = Integer.parseInt(branchParam.trim());
                boolean allowed = managedBranches.stream()
                        .anyMatch(b -> b.getBranchId() != null && b.getBranchId().equals(bid));
                if (allowed) {
                    filterBranchId = bid;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        List<Integer> branchIds = new ArrayList<>();
        for (CinemaBranch b : managedBranches) {
            if (b.getBranchId() != null) {
                branchIds.add(b.getBranchId());
            }
        }
        if (filterBranchId != null) {
            branchIds = List.of(filterBranchId);
        }

        int totalShowtimes = performanceRepo.countShowtimes(branchIds, fromDate, toDate);
        int totalTicketsSold = performanceRepo.countTicketsSold(branchIds, fromDate, toDate);
        List<BranchPerformanceRow> byBranch = performanceRepo.listShowtimesByBranch(branchIds, fromDate, toDate);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", filterBranchId);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("todayMaxDate", today.toString());
        request.setAttribute("totalShowtimes", totalShowtimes);
        request.setAttribute("totalTicketsSold", totalTicketsSold);
        request.setAttribute("showtimesByBranch", byBranch);

        if (servletPath != null && servletPath.endsWith("/movies")) {
            List<MovieTicketRow> topMovies = performanceRepo.listTopMoviesByTickets(branchIds, fromDate, toDate);
            request.setAttribute("topMovies", topMovies);
            request.getRequestDispatcher("/pages/manager/report/performance/movies.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/pages/manager/report/performance/performance.jsp").forward(request, response);
    }
}
