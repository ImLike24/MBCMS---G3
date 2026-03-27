package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import models.User;
import models.dtos.BookingHistoryDTO;
import repositories.BookingHistories;

@WebServlet(name = "BookingHistory", urlPatterns = { "/customer/booking-history" })
public class BookingHistory extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fromDate = request.getParameter("fromDate");
        if (fromDate != null && fromDate.trim().isEmpty()) fromDate = null;
        String toDate = request.getParameter("toDate");
        if (toDate != null && toDate.trim().isEmpty()) toDate = null;

        int page = 1;
        int pageSize = 5;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        BookingHistories repo = null;
        try {
            repo = new BookingHistories();
            int totalCount = repo.countHistory(user.getUserId(), fromDate, toDate);
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            if (page > totalPages && totalPages > 0) page = totalPages;
            int offset = (page - 1) * pageSize;

            List<BookingHistoryDTO> historyList = repo.getHistory(user.getUserId(), fromDate, toDate, offset, pageSize);

            request.setAttribute("historyList", historyList);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            
            request.getRequestDispatcher("/pages/customer/booking-history.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading history: " + e.getMessage());
        } finally {
            if (repo != null) {
                repo.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
