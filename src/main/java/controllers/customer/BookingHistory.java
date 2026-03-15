package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import repositories.Invoices;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "BookingHistory", urlPatterns = {"/customer/booking-history"})
public class BookingHistory extends HttpServlet {

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) { }
        }

        Invoices invoicesRepo = new Invoices();
        try {
            int totalCount = invoicesRepo.countInvoicesByUserId(userId);
            int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (totalPages > 0 && page > totalPages) page = totalPages;

            int offset = (page - 1) * PAGE_SIZE;
            List<Map<String, Object>> invoices = invoicesRepo.getInvoicesByUserId(userId, offset, PAGE_SIZE);

            List<Integer> invoiceIds = invoices.stream()
                    .map(m -> (Integer) m.get("invoiceId"))
                    .collect(Collectors.toList());
            Map<Integer, List<Map<String, Object>>> itemsByInvoice = invoicesRepo.getInvoiceItemsByInvoiceIds(invoiceIds);

            for (Map<String, Object> inv : invoices) {
                int invId = (Integer) inv.get("invoiceId");
                inv.put("items", itemsByInvoice.getOrDefault(invId, List.of()));
            }

            request.setAttribute("invoices", invoices);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/pages/customer/booking-history.jsp").forward(request, response);
        } finally {
            invoicesRepo.closeConnection();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
