package controllers.staff;

import com.google.gson.Gson;
import models.User;
import services.StaffDashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "cinemaStaffDashboard", urlPatterns = {"/staff/dashboard"})
public class CinemaStaffDashboard extends HttpServlet {

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

        User user = (User) session.getAttribute("user");
        request.setAttribute("user", user);

        Integer branchId = user.getBranchId();
        if (branchId == null) {
            request.setAttribute("noBranch", true);
            request.getRequestDispatcher("/pages/staff/dashboard.jsp").forward(request, response);
            return;
        }

        StaffDashboardService svc = null;
        try {
            svc = new StaffDashboardService(branchId);
            Gson gson = new Gson();

            request.setAttribute("todaySummary",       svc.getTodaySummary());
            request.setAttribute("ticketsByHourJson",  gson.toJson(svc.getTicketsByHourToday()));
            request.setAttribute("revenueLast7Json",   gson.toJson(svc.getRevenueLast7Days()));
            request.setAttribute("topMoviesJson",      gson.toJson(svc.getTopMoviesByTickets()));
            request.setAttribute("todayShowtimes",     svc.getTodayShowtimes());
            request.setAttribute("recentTransactions", svc.getRecentTransactions());
        } finally {
            if (svc != null) svc.closeConnection();
        }

        request.getRequestDispatcher("/pages/staff/dashboard.jsp").forward(request, response);
    }
}
