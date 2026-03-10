package controllers.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import models.CinemaBranch;
import repositories.CinemaBranches;
import repositories.Showtimes;

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

        CinemaBranches branchesRepo = null;
        Showtimes showtimesRepo = null;
        try {
            branchesRepo = new CinemaBranches();
            showtimesRepo = new Showtimes();

            // Week range (Monday..Sunday) around referenceDate
            LocalDate weekStart = referenceDate.with(DayOfWeek.MONDAY);
            List<Map<String, String>> weekDays = new ArrayList<>();
            DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd/MM");
            for (int i = 0; i < 7; i++) {
                LocalDate d = weekStart.plusDays(i);
                Map<String, String> day = new HashMap<>();
                day.put("key", d.toString()); // used as map key
                String dow = d.getDayOfWeek().getDisplayName(TextStyle.SHORT, new Locale("en", "US"));
                day.put("label", dow + " " + d.format(labelFmt));
                weekDays.add(day);
            }

            // Lấy tất cả chi nhánh đang active
            List<CinemaBranch> branches = branchesRepo.getActiveBranches();

            // Map<branchId, Map<dateKey, List<showtimeRow>>>
            Map<Integer, Map<String, List<Map<String, Object>>>> scheduleByBranch = new HashMap<>();

            for (CinemaBranch b : branches) {
                // Cập nhật trạng thái showtime cho chi nhánh (SCHEDULED/ONGOING/COMPLETED)
                showtimesRepo.autoUpdateStatuses(b.getBranchId());

                Map<String, List<Map<String, Object>>> perDay = new HashMap<>();
                for (int i = 0; i < 7; i++) {
                    LocalDate d = weekStart.plusDays(i);
                    String key = d.toString();
                    List<Map<String, Object>> showtimeRows = showtimesRepo.getShowtimesByBranch(
                            b.getBranchId(),
                            d,
                            null, // no status filter
                            null  // no movie keyword filter
                    );
                    perDay.put(key, showtimeRows);
                }
                scheduleByBranch.put(b.getBranchId(), perDay);
            }

            String weekLabel = weekStart.format(labelFmt) + " - " + weekStart.plusDays(6).format(labelFmt);

            request.setAttribute("branches", branches);
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("scheduleByBranch", scheduleByBranch);
            request.setAttribute("referenceDateStr", referenceDate.format(DATE_FMT));
            request.setAttribute("weekLabel", weekLabel);

            request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading schedule: " + e.getMessage());
            request.getRequestDispatcher("/pages/staff/schedule.jsp").forward(request, response);
        } finally {
            if (branchesRepo != null) {
                branchesRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}

