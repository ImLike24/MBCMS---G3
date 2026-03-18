package controllers.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.CinemaBranch;
import models.StaffSchedule;
import models.User;
import repositories.CinemaBranches;
import repositories.StaffSchedules;
import repositories.Users;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;

@WebServlet(name = "AdminScheduleServlet", urlPatterns = {"/admin/staff-schedule"})
public class AdminScheduleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        CinemaBranches branchDao = new CinemaBranches();
        StaffSchedules schedulesDao = new StaffSchedules();
        Users usersDao = new Users();

        try {
            List<CinemaBranch> allBranches = branchDao.getActiveBranches();

            // Resolve selected branch
            Integer selectedBranchId = null;
            String branchParam = request.getParameter("branchId");
            if (branchParam != null && !branchParam.isBlank()) {
                try { selectedBranchId = Integer.parseInt(branchParam); } catch (NumberFormatException ignored) {}
            }
            if (selectedBranchId == null && !allBranches.isEmpty()) {
                selectedBranchId = allBranches.get(0).getBranchId();
            }

            // Resolve reference date
            LocalDate referenceDate = LocalDate.now();
            String dateParam = request.getParameter("date");
            if (dateParam != null && !dateParam.isBlank()) {
                try { referenceDate = LocalDate.parse(dateParam); } catch (Exception ignored) {}
            }

            LocalDate weekStart = referenceDate.with(DayOfWeek.MONDAY);
            DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd/MM");

            // Build weekDays list
            List<Map<String, String>> weekDays = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                LocalDate d = weekStart.plusDays(i);
                Map<String, String> day = new HashMap<>();
                day.put("key", d.toString());
                String dow = d.getDayOfWeek().getDisplayName(TextStyle.SHORT, new Locale("vi", "VN"));
                day.put("label", dow + " " + d.format(labelFmt));
                weekDays.add(day);
            }

            // Staff & schedules for selected branch
            List<User> staffList = Collections.emptyList();
            Map<Integer, Map<String, List<StaffSchedule>>> scheduleMap = new HashMap<>();

            if (selectedBranchId != null) {
                staffList = usersDao.getStaffByBranch(selectedBranchId);
                List<StaffSchedule> schedules = schedulesDao.getByBranchAndWeek(selectedBranchId, weekStart);
                for (StaffSchedule s : schedules) {
                    scheduleMap
                        .computeIfAbsent(s.getStaffId(), k -> new HashMap<>())
                        .computeIfAbsent(s.getWorkDate().toString(), k -> new ArrayList<>())
                        .add(s);
                }
            }

            String weekLabel = weekStart.format(labelFmt) + " - " + weekStart.plusDays(6).format(labelFmt);

            request.setAttribute("allBranches", allBranches);
            request.setAttribute("selectedBranchId", selectedBranchId);
            request.setAttribute("staffList", staffList);
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("scheduleMap", scheduleMap);
            request.setAttribute("weekLabel", weekLabel);
            request.setAttribute("referenceDateStr", referenceDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));

            request.getRequestDispatcher("/pages/admin/staff-schedule.jsp").forward(request, response);
        } finally {
            branchDao.closeConnection();
            schedulesDao.closeConnection();
            usersDao.closeConnection();
        }
    }
}
