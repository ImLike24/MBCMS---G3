package controllers.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import models.CinemaBranch;
import models.User;
import services.StaffScheduleService;

/**
 * Staff view working schedule (showtimes) per branch and date.
 */
@WebServlet(name = "staffSchedule", urlPatterns = {"/staff/schedule"})
public class StaffScheduleServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        // Parse date param (default: today)
        LocalDate today = LocalDate.now();
        LocalDate referenceDate = today;
        String dateParam = request.getParameter("date");
        if (dateParam != null && !dateParam.isBlank()) {
            try {
                referenceDate = LocalDate.parse(dateParam, DATE_FMT);
            } catch (DateTimeParseException ignored) {
                referenceDate = today;
            }
        }

        try {
            StaffScheduleService service = new StaffScheduleService();
            User currentUser = (User) session.getAttribute("user");
            Integer branchId = currentUser != null ? currentUser.getBranchId() : null;
            if (branchId == null) {
                request.setAttribute("branchWarning",
                        "Tài khoản nhân viên chưa được gán chi nhánh (branch). Hệ thống sẽ hiển thị lịch của tất cả chi nhánh.");
            }
            StaffScheduleService.ScheduleResult result = service.buildSchedule(referenceDate, branchId);

            List<CinemaBranch> branches = result.branches;
            List<Map<String, String>> weekDays = result.weekDays;
            Map<Integer, Map<String, List<Map<String, Object>>>> scheduleByBranch = result.scheduleByBranch;

            request.setAttribute("branches", branches);
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("scheduleByBranch", scheduleByBranch);
            request.setAttribute("referenceDateStr", result.referenceDateStr);
            request.setAttribute("weekLabel", result.weekLabel);

            request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading schedule: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);
        }
    }
}

