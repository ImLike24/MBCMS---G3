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
import models.User;
import services.StaffScheduleService;

@WebServlet(name = "staffSchedule", urlPatterns = {"/staff/schedule"})
public class StaffScheduleServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        User currentUser = (User) session.getAttribute("user");
        Integer branchId = currentUser.getBranchId();

        if (branchId == null) {
            request.setAttribute("branchWarning",
                    "Tài khoản của bạn chưa được gán chi nhánh. Vui lòng liên hệ quản lý.");
            request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);
            return;
        }

        LocalDate referenceDate = LocalDate.now();
        String dateParam = request.getParameter("date");
        if (dateParam != null && !dateParam.isBlank()) {
            try {
                referenceDate = LocalDate.parse(dateParam, DATE_FMT);
            } catch (DateTimeParseException ignored) {
                // keep today
            }
        }

        StaffScheduleService service = new StaffScheduleService();
        StaffScheduleService.ScheduleResult result = service.buildSchedule(referenceDate, currentUser.getUserId(), branchId);

        request.setAttribute("weekDays", result.getWeekDays());
        request.setAttribute("scheduleByDay", result.getScheduleByDay());
        request.setAttribute("referenceDateStr", result.getReferenceDateStr());
        request.setAttribute("weekLabel", result.getWeekLabel());
        request.setAttribute("branch", result.getBranch());

        request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);
    }
}
