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
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PerformanceReportIndex", urlPatterns = {"/manager/report/performance"})
public class PerformanceReportIndex extends HttpServlet {

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

        String periodType = request.getParameter("periodType");
        if (periodType == null || periodType.isEmpty()) periodType = "day";
        if (!List.of("day", "month", "year").contains(periodType)) periodType = "day";

        LocalDate now = LocalDate.now();
        LocalDate fromDate;
        LocalDate toDate;
        String periodLabel;

        if ("month".equals(periodType)) {
            int year = parseInt(request.getParameter("year"), now.getYear());
            int month = parseInt(request.getParameter("month"), now.getMonthValue());
            YearMonth ym = YearMonth.of(year, month);
            fromDate = ym.atDay(1);
            toDate = ym.atEndOfMonth();
            periodLabel = "Tháng %d/%d".formatted(month, year);
        } else if ("year".equals(periodType)) {
            int year = parseInt(request.getParameter("year"), now.getYear());
            fromDate = LocalDate.of(year, 1, 1);
            toDate = LocalDate.of(year, 12, 31);
            periodLabel = "Năm %d".formatted(year);
        } else {
            fromDate = parseDate(request.getParameter("fromDate"), now.minusDays(30));
            toDate = parseDate(request.getParameter("toDate"), now);
            if (fromDate.isAfter(toDate)) fromDate = toDate.minusDays(30);
            periodLabel = "%s - %s".formatted(
                    fromDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                    toDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        }

        var branchRows = perfRepo.getTotalShowtimesByBranch(branchIds, fromDate, toDate);
        var seatMetrics = perfRepo.getSeatUtilizationMetrics(branchIds, fromDate, toDate);
        var peakLow = perfRepo.getPeakAndLowHours(branchIds, fromDate, toDate);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("branchRows", branchRows);
        request.setAttribute("seatMetrics", seatMetrics);
        request.setAttribute("peakLow", peakLow);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("periodType", periodType);
        request.setAttribute("periodLabel", periodLabel);
        if ("month".equals(periodType) || "year".equals(periodType)) {
            request.setAttribute("selectedYear", request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(fromDate.getYear()));
            request.setAttribute("selectedMonth", "month".equals(periodType) ? (request.getParameter("month") != null ? request.getParameter("month") : String.valueOf(fromDate.getMonthValue())) : null);
        } else {
            request.setAttribute("selectedYear", null);
            request.setAttribute("selectedMonth", null);
        }

        request.getRequestDispatcher("/pages/manager/report//index.jsp").forward(request, response);
    }

    private LocalDate parseDate(String value, LocalDate defaultVal) {
        if (value == null || value.trim().isEmpty()) return defaultVal;
        try {
            return LocalDate.parse(value);
        } catch (Exception e) {
            return defaultVal;
        }
    }

    private int parseInt(String value, int defaultVal) {
        if (value == null || value.trim().isEmpty()) return defaultVal;
        try {
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return defaultVal;
        }
    }
}
