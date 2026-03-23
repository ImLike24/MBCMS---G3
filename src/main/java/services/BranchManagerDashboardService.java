package services;

import com.google.gson.Gson;
import models.CinemaBranch;
import repositories.DashboardRepository;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BranchManagerDashboardService {

    private final DashboardRepository dashboardRepo = new DashboardRepository();
    private final Gson gson = new Gson();

    /**
     * Dashboard scoped to the given branches (one or all managed).
     * KPIs and charts use the same month/year as the admin dashboard (current month).
     */
    public Map<String, Object> getDashboardData(List<Integer> branchIds, List<CinemaBranch> managedBranches) {
        Map<String, Object> dto = new HashMap<>();

        LocalDate today = LocalDate.now();
        int currentMonth = today.getMonthValue();
        int currentYear = today.getYear();

        LocalDate lastMonthDate = today.minusMonths(1);
        int lastMonth = lastMonthDate.getMonthValue();
        int lastMonthYear = lastMonthDate.getYear();

        Map<String, Object> kpi = new HashMap<>();

        Double revenueThisMonth = dashboardRepo.getTotalRevenueForMonthByBranches(branchIds, currentMonth, currentYear);
        Double revenueLastMonth = dashboardRepo.getTotalRevenueForMonthByBranches(branchIds, lastMonth, lastMonthYear);
        kpi.put("totalRevenueMonth", revenueThisMonth);

        if (revenueLastMonth > 0) {
            double change = ((revenueThisMonth - revenueLastMonth) / revenueLastMonth) * 100;
            kpi.put("revenueChange", change);
            kpi.put("revenueIncreased", change >= 0);
        } else {
            kpi.put("revenueChange", 0.0);
            kpi.put("revenueIncreased", true);
        }

        int ticketsThisMonth = dashboardRepo.getTicketsSoldForMonthByBranches(branchIds, currentMonth, currentYear);
        int ticketsLastMonth = dashboardRepo.getTicketsSoldForMonthByBranches(branchIds, lastMonth, lastMonthYear);
        kpi.put("ticketsSoldMonth", ticketsThisMonth);
        kpi.put("ticketsChange", ticketsThisMonth - ticketsLastMonth);

        kpi.put("newCustomersMonth", dashboardRepo.getNewCustomersCount(currentMonth, currentYear));

        long activeCount = managedBranches.stream().filter(CinemaBranch::isActive).count();
        kpi.put("activeBranches", (int) activeCount);
        kpi.put("totalBranches", managedBranches.size());

        dto.put("kpi", kpi);
        dto.put("revenueByBranch", dashboardRepo.getRevenueByBranchForMonth(branchIds, currentMonth, currentYear));
        dto.put("topMovies", dashboardRepo.getTopMoviesForBranches(5, branchIds, currentMonth, currentYear));
        dto.put("revenueTrend", dashboardRepo.getRevenueTrendForBranches(6, branchIds));
        dto.put("recentTransactions", dashboardRepo.getRecentTransactionsForBranches(10, branchIds));
        dto.put("movieStatus", dashboardRepo.getMovieStatus());

        return dto;
    }

    public String toJson(Object object) {
        return gson.toJson(object);
    }
}
