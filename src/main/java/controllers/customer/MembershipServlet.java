package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.MembershipTier;
import models.PointHistory;
import models.User;
import repositories.MembershipTiers;
import repositories.PointHistories;
import repositories.Users;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "MembershipServlet", urlPatterns = {"/customer/membership"})
public class MembershipServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Users userRepo = new Users();
        MembershipTiers tierRepo = new MembershipTiers();
        PointHistories historyRepo = new PointHistories();

        // Freshen user data from DB
        User user = userRepo.getUserById(sessionUser.getUserId());
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/logout");
            return;
        }

        List<MembershipTier> allTiers = tierRepo.getAllTiers();
        List<PointHistory> history = historyRepo.getHistoryByUserId(user.getUserId());

        MembershipTier currentTier = null;
        MembershipTier nextTier = null;

        for (int i = 0; i < allTiers.size(); i++) {
            if (allTiers.get(i).getTierId().equals(user.getTierId())) {
                currentTier = allTiers.get(i);
                if (i + 1 < allTiers.size()) {
                    nextTier = allTiers.get(i + 1);
                }
                break;
            }
        }

        double progress = 0;
        if (nextTier != null && nextTier.getMinPointsRequired() > 0) {
            // (total_accumulated_points / min_points_của_hạng_tiếp_theo) * 100
            progress = (double) user.getTotalAccumulatedPoints() / nextTier.getMinPointsRequired() * 100;
            if (progress > 100) progress = 100;
        } else {
            progress = 100; // Max tier
        }

        request.setAttribute("user", user);
        request.setAttribute("currentTier", currentTier);
        request.setAttribute("nextTier", nextTier);
        request.setAttribute("allTiers", allTiers);
        request.setAttribute("progress", Math.round(progress * 100.0) / 100.0);
        request.setAttribute("pointHistory", history);

        request.getRequestDispatcher("/pages/customer/membership.jsp").forward(request, response);
    }
}
