package controllers.manager;

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
import java.util.*;

@WebServlet(name = "ManageStaffServlet", urlPatterns = {"/branch-manager/manage-staff"})
public class ManageStaffServlet extends HttpServlet {

    private final Users usersDao = new Users();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final StaffSchedules schedulesDao = new StaffSchedules();

    // ─────────────────────────────────────────────────────────────────────────
    // GET
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User manager = getManagerOrForbid(request, response);
        if (manager == null) return;

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(manager.getUserId());

        String action = request.getParameter("action");
        if (action == null) action = "list";

        if (managedBranches == null || managedBranches.isEmpty()) {
            request.setAttribute("noBranchAssigned", true);
            String jspPage = "schedule".equals(action)
                    ? "/pages/manager/manage-staff/schedule.jsp"
                    : "/pages/manager/manage-staff/list.jsp";
            request.getRequestDispatcher(jspPage).forward(request, response);
            return;
        }

        Integer selectedBranchId = resolveSelectedBranch(request, managedBranches);
        request.getSession().setAttribute("selectedBranchId", selectedBranchId);
        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);

        switch (action) {
            case "schedule" -> showSchedule(request, response, selectedBranchId, manager);
            default         -> listStaff(request, response, selectedBranchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User manager = getManagerOrForbid(request, response);
        if (manager == null) return;

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(manager.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-staff");
            return;
        }

        Integer selectedBranchId = resolveSelectedBranch(request, managedBranches);
        request.getSession().setAttribute("selectedBranchId", selectedBranchId);

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "assign"         -> handleAssign(request, response, selectedBranchId);
            case "unassign"       -> handleUnassign(request, response, selectedBranchId);
            case "create-schedule" -> handleCreateSchedule(request, response, selectedBranchId, manager);
            case "cancel-schedule" -> handleCancelSchedule(request, response, selectedBranchId);
            case "delete-schedule" -> handleDeleteSchedule(request, response, selectedBranchId);
            default -> response.sendRedirect(request.getContextPath() + "/branch-manager/manage-staff");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST staff của branch
    // ─────────────────────────────────────────────────────────────────────────
    private void listStaff(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        List<User> staffInBranch = usersDao.getStaffByBranch(branchId);
        List<User> unassignedStaff = usersDao.getUnassignedStaff();

        request.setAttribute("staffInBranch", staffInBranch);
        request.setAttribute("unassignedStaff", unassignedStaff);
        request.getRequestDispatcher("/pages/manager/manage-staff/list.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SCHEDULE — xem/tạo lịch làm việc theo tuần
    // ─────────────────────────────────────────────────────────────────────────
    private void showSchedule(HttpServletRequest request, HttpServletResponse response,
                               int branchId, User manager)
            throws ServletException, IOException {

        String dateParam = request.getParameter("date");
        LocalDate referenceDate;
        try {
            referenceDate = (dateParam != null && !dateParam.isBlank())
                    ? LocalDate.parse(dateParam) : LocalDate.now();
        } catch (Exception e) {
            referenceDate = LocalDate.now();
        }

        LocalDate weekStart = referenceDate.with(DayOfWeek.MONDAY);

        // Build weekDays list
        DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd/MM");
        List<Map<String, String>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate d = weekStart.plusDays(i);
            Map<String, String> day = new HashMap<>();
            day.put("key", d.toString());
            String dow = d.getDayOfWeek().getDisplayName(java.time.format.TextStyle.SHORT,
                    new Locale("vi", "VN"));
            day.put("label", dow + " " + d.format(labelFmt));
            weekDays.add(day);
        }

        // Staff in branch
        List<User> staffList = usersDao.getStaffByBranch(branchId);

        // Schedules in week, grouped by staffId -> date -> list
        List<StaffSchedule> schedules = schedulesDao.getByBranchAndWeek(branchId, weekStart);
        Map<Integer, Map<String, List<StaffSchedule>>> scheduleMap = new HashMap<>();
        for (StaffSchedule s : schedules) {
            scheduleMap
                .computeIfAbsent(s.getStaffId(), k -> new HashMap<>())
                .computeIfAbsent(s.getWorkDate().toString(), k -> new ArrayList<>())
                .add(s);
        }

        String weekLabel = weekStart.format(labelFmt) + " - " + weekStart.plusDays(6).format(labelFmt);

        request.setAttribute("staffList", staffList);
        request.setAttribute("weekDays", weekDays);
        request.setAttribute("scheduleMap", scheduleMap);
        request.setAttribute("weekLabel", weekLabel);
        request.setAttribute("referenceDateStr", referenceDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        request.getRequestDispatcher("/pages/manager/manage-staff/schedule.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Assign staff vào branch
    // ─────────────────────────────────────────────────────────────────────────
    private void handleAssign(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            usersDao.updateBranchAssignment(staffId, branchId);
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?message=assigned&branchId=" + branchId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?error=assign_failed&branchId=" + branchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Unassign staff khỏi branch
    // ─────────────────────────────────────────────────────────────────────────
    private void handleUnassign(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            usersDao.updateBranchAssignment(staffId, null);
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?message=unassigned&branchId=" + branchId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?error=unassign_failed&branchId=" + branchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Tạo lịch làm việc
    // ─────────────────────────────────────────────────────────────────────────
    private void handleCreateSchedule(HttpServletRequest request, HttpServletResponse response,
                                       int branchId, User manager)
            throws IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            LocalDate workDate = LocalDate.parse(request.getParameter("workDate"));
            String shift = request.getParameter("shift");
            String note = request.getParameter("note");
            String dateParam = request.getParameter("date");

            // Validate workDate not in the past
            if (workDate.isBefore(LocalDate.now())) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=past_date&branchId=" + branchId
                        + (dateParam != null ? "&date=" + dateParam : ""));
                return;
            }

            // Validate shift value
            if (!List.of("MORNING", "AFTERNOON", "EVENING", "NIGHT").contains(shift)) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=invalid_shift&branchId=" + branchId
                        + (dateParam != null ? "&date=" + dateParam : ""));
                return;
            }

            // Validate staff belongs to this branch
            User staff = usersDao.getUserById(staffId);
            if (staff == null || !Integer.valueOf(branchId).equals(staff.getBranchId())) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=invalid_staff&branchId=" + branchId
                        + (dateParam != null ? "&date=" + dateParam : ""));
                return;
            }

            // Check duplicate
            if (schedulesDao.existsDuplicate(staffId, workDate, shift, null)) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=duplicate&branchId=" + branchId
                        + (dateParam != null ? "&date=" + dateParam : ""));
                return;
            }

            StaffSchedule s = new StaffSchedule();
            s.setStaffId(staffId);
            s.setBranchId(branchId);
            s.setWorkDate(workDate);
            s.setShift(shift);
            s.setStatus("SCHEDULED");
            s.setNote(note);
            s.setCreatedBy(manager.getUserId());

            boolean ok = schedulesDao.insert(s);
            String msg = ok ? "schedule_created" : "schedule_failed";
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&message=" + msg + "&branchId=" + branchId
                    + (dateParam != null ? "&date=" + dateParam : ""));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&error=invalid&branchId=" + branchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Hủy lịch làm việc
    // ─────────────────────────────────────────────────────────────────────────
    private void handleCancelSchedule(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String dateParam = request.getParameter("date");

            StaffSchedule s = schedulesDao.findById(scheduleId);
            if (s == null || s.getBranchId() != branchId) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=not_found&branchId=" + branchId);
                return;
            }

            schedulesDao.cancel(scheduleId);
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&message=schedule_cancelled&branchId=" + branchId
                    + (dateParam != null ? "&date=" + dateParam : ""));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&error=invalid&branchId=" + branchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Xóa lịch làm việc
    // ─────────────────────────────────────────────────────────────────────────
    private void handleDeleteSchedule(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
            String dateParam = request.getParameter("date");

            StaffSchedule s = schedulesDao.findById(scheduleId);
            if (s == null || s.getBranchId() != branchId) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-staff?action=schedule&error=not_found&branchId=" + branchId);
                return;
            }

            schedulesDao.delete(scheduleId);
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&message=schedule_deleted&branchId=" + branchId
                    + (dateParam != null ? "&date=" + dateParam : ""));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-staff?action=schedule&error=invalid&branchId=" + branchId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────
    private User getManagerOrForbid(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return null; }
        User user = (User) session.getAttribute("user");
        if (user == null) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return null; }
        return user;
    }

    private Integer resolveSelectedBranch(HttpServletRequest request, List<CinemaBranch> managedBranches) {
        HttpSession session = request.getSession();
        String param = request.getParameter("branchId");
        Integer selected = null;
        if (param != null && !param.isBlank()) {
            try { selected = Integer.parseInt(param); } catch (NumberFormatException ignored) {}
        } else if (session.getAttribute("selectedBranchId") != null) {
            selected = (Integer) session.getAttribute("selectedBranchId");
        }
        if (selected == null) return managedBranches.get(0).getBranchId();
        final int s = selected;
        boolean valid = managedBranches.stream().anyMatch(b -> b.getBranchId() == s);
        return valid ? selected : managedBranches.get(0).getBranchId();
    }
}
