package services;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
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
 * Business logic for staff working schedule view.
 */
public class StaffScheduleService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static class ScheduleResult {
        public List<CinemaBranch> branches;
        public List<Map<String, String>> weekDays;
        public Map<Integer, Map<String, List<Map<String, Object>>>> scheduleByBranch;
        public String referenceDateStr;
        public String weekLabel;
    }

    public ScheduleResult buildSchedule(LocalDate referenceDate) throws Exception {
        CinemaBranches branchesRepo = null;
        Showtimes showtimesRepo = null;

        try {
            branchesRepo = new CinemaBranches();
            showtimesRepo = new Showtimes();

            LocalDate weekStart = referenceDate.with(DayOfWeek.MONDAY);
            List<Map<String, String>> weekDays = new ArrayList<>();
            DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd/MM");
            for (int i = 0; i < 7; i++) {
                LocalDate d = weekStart.plusDays(i);
                Map<String, String> day = new HashMap<>();
                day.put("key", d.toString());
                String dow = d.getDayOfWeek().getDisplayName(TextStyle.SHORT, new Locale("en", "US"));
                day.put("label", dow + " " + d.format(labelFmt));
                weekDays.add(day);
            }

            List<CinemaBranch> branches = branchesRepo.getActiveBranches();

            Map<Integer, Map<String, List<Map<String, Object>>>> scheduleByBranch = new HashMap<>();

            for (CinemaBranch b : branches) {
                showtimesRepo.autoUpdateStatuses(b.getBranchId());

                Map<String, List<Map<String, Object>>> perDay = new HashMap<>();
                for (int i = 0; i < 7; i++) {
                    LocalDate d = weekStart.plusDays(i);
                    String key = d.toString();
                    List<Map<String, Object>> showtimeRows = showtimesRepo.getShowtimesByBranch(
                            b.getBranchId(),
                            d,
                            null,
                            null);
                    perDay.put(key, showtimeRows);
                }
                scheduleByBranch.put(b.getBranchId(), perDay);
            }

            String weekLabel = weekStart.format(labelFmt) + " - " + weekStart.plusDays(6).format(labelFmt);

            ScheduleResult result = new ScheduleResult();
            result.branches = branches;
            result.weekDays = weekDays;
            result.scheduleByBranch = scheduleByBranch;
            result.referenceDateStr = referenceDate.format(DATE_FMT);
            result.weekLabel = weekLabel;
            return result;

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

