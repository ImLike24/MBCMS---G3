package controllers.manager.report.revenue;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.RevenueReports;
import repositories.RevenueReports.Row;
import services.AuthService;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "RevenueReportIndex", urlPatterns = { "/manager/report/revenue" })
public class RevenueReportIndex extends HttpServlet {

    private static final String FLASH_REPORT_FILTER = "reportFilterError";

    private final AuthService authService = new AuthService();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final RevenueReports report = new RevenueReports();

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

    private static String buildRevenueRedirectUrl(HttpServletRequest req) {
        StringBuilder sb = new StringBuilder(req.getContextPath()).append("/manager/report/revenue");
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
        String fp = request.getParameter("from");
        String tp = request.getParameter("to");
        if (fp != null && !fp.isBlank()) {
            try { fromDate = LocalDate.parse(fp.trim()); } catch (DateTimeParseException ignored) { }
        }
        if (tp != null && !tp.isBlank()) {
            try { toDate = LocalDate.parse(tp.trim()); } catch (DateTimeParseException ignored) { }
        }
        if (fromDate.isAfter(toDate)) {
            session.setAttribute(FLASH_REPORT_FILTER,
                    "Không được để khoảng thời gian bên trái lớn hơn khoảng thời gian bên phải!");
            response.sendRedirect(buildRevenueRedirectUrl(request));
            return;
        }
        if (toDate.isAfter(today)) {
            session.setAttribute(FLASH_REPORT_FILTER, "Chỉ có thể để thời gian hiện tại!");
            response.sendRedirect(buildRevenueRedirectUrl(request));
            return;
        }

        Integer filterBranchId = null;
        String bp = request.getParameter("branchId");
        if (bp != null && !bp.isBlank() && !"all".equalsIgnoreCase(bp.trim())) {
            try {
                int bid = Integer.parseInt(bp.trim());
                if (managedBranches.stream()
                        .anyMatch(b -> b.getBranchId() != null && b.getBranchId().equals(bid))) {
                    filterBranchId = bid;
                }
            } catch (NumberFormatException ignored) { }
        }

        List<Integer> branchIds = new ArrayList<>();
        for (CinemaBranch b : managedBranches) {
            if (b.getBranchId() != null) branchIds.add(b.getBranchId());
        }
        if (filterBranchId != null) {
            branchIds = List.of(filterBranchId);
        }

        List<Row> rows = report.listByBranches(branchIds, fromDate, toDate);
        BigDecimal total = rows.stream().map(Row::getTotalRevenue).reduce(BigDecimal.ZERO, BigDecimal::add);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", filterBranchId);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("todayMaxDate", today.toString());
        request.setAttribute("totalRevenue", total);
        request.setAttribute("ticketRevenueRows", rows);
        request.getRequestDispatcher("/pages/manager/report/revenue/revenue.jsp").forward(request, response);
    }
}
