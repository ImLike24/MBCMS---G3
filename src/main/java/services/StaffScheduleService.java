package services;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import models.CinemaBranch;
import models.StaffSchedule;
import repositories.CinemaBranches;
import repositories.StaffSchedules;

/**
 * Business logic for staff working schedule view.
 * Reads shift data from staff_schedules table.
 */
public class StaffScheduleService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static class ScheduleResult {
        private List<Map<String, String>> weekDays;
        private Map<String, List<StaffSchedule>> scheduleByDay;
        private String referenceDateStr;
        private String weekLabel;
        private CinemaBranch branch;

        public List<Map<String, String>> getWeekDays() { return weekDays; }
        public void setWeekDays(List<Map<String, String>> weekDays) { this.weekDays = weekDays; }
        public Map<String, List<StaffSchedule>> getScheduleByDay() { return scheduleByDay; }
        public void setScheduleByDay(Map<String, List<StaffSchedule>> scheduleByDay) { this.scheduleByDay = scheduleByDay; }
        public String getReferenceDateStr() { return referenceDateStr; }
        public void setReferenceDateStr(String referenceDateStr) { this.referenceDateStr = referenceDateStr; }
        public String getWeekLabel() { return weekLabel; }
        public void setWeekLabel(String weekLabel) { this.weekLabel = weekLabel; }
        public CinemaBranch getBranch() { return branch; }
        public void setBranch(CinemaBranch branch) { this.branch = branch; }
    }

    /**
     * @param referenceDate any date in the desired week
     * @param staffId       the logged-in staff's user_id
     * @param branchId      the staff's branch_id (from users.branch_id)
     */
    public ScheduleResult buildSchedule(LocalDate referenceDate, int staffId, Integer branchId) {
        CinemaBranches branchesRepo = new CinemaBranches();
        StaffSchedules schedulesRepo = new StaffSchedules();
        try {

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

            // Fetch schedules for this staff in the week
            List<StaffSchedule> schedules = schedulesRepo.getByStaffAndWeek(staffId, weekStart);

            // Group by date string
            Map<String, List<StaffSchedule>> scheduleByDay = new LinkedHashMap<>();
            for (int i = 0; i < 7; i++) {
                scheduleByDay.put(weekStart.plusDays(i).toString(), new ArrayList<>());
            }
            for (StaffSchedule s : schedules) {
                String key = s.getWorkDate().toString();
                scheduleByDay.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
            }

            CinemaBranch branch = null;
            if (branchId != null) {
                branch = branchesRepo.findById(branchId);
            }

            String weekLabel = weekStart.format(labelFmt) + " - " + weekStart.plusDays(6).format(labelFmt);

            ScheduleResult result = new ScheduleResult();
            result.setWeekDays(weekDays);
            result.setScheduleByDay(scheduleByDay);
            result.setReferenceDateStr(referenceDate.format(DATE_FMT));
            result.setWeekLabel(weekLabel);
            result.setBranch(branch);
            return result;
        } finally {
            branchesRepo.closeConnection();
            schedulesRepo.closeConnection();
        }
    }
}
