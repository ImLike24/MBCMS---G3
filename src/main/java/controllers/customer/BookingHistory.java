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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
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

        // Lọc theo khoảng thời gian
        String range = request.getParameter("range");
        if (range == null || range.isBlank()) {
            range = "all";
        }
        LocalDateTime from = null;
        LocalDateTime to = null;
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();
        switch (range) {
            case "week" -> {
                from = now.minusWeeks(1);
                to = now;
            }
            case "month" -> {
                LocalDate firstDay = today.withDayOfMonth(1);
                from = firstDay.atStartOfDay();
                to = firstDay.plusMonths(1).atStartOfDay();
            }
            case "year" -> {
                LocalDate firstDayYear = today.withDayOfYear(1);
                from = firstDayYear.atStartOfDay();
                to = firstDayYear.plusYears(1).atStartOfDay();
            }
            default -> {
                from = null;
                to = null;
                range = "all";
            }
        }

        Invoices invoicesRepo = new Invoices();
        try {
            int totalCount = invoicesRepo.countInvoicesByUserIdInRange(userId, from, to);
            int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (totalPages > 0 && page > totalPages) page = totalPages;

            int offset = (page - 1) * PAGE_SIZE;
            List<Map<String, Object>> invoices = invoicesRepo.getInvoicesByUserIdInRange(userId, offset, PAGE_SIZE, from, to);

            List<Integer> invoiceIds = invoices.stream()
                    .map(m -> {
                        Object id = m.get("invoiceId");
                        if (id instanceof Number) return ((Number) id).intValue();
                        return id != null ? Integer.parseInt(id.toString()) : 0;
                    })
                    .filter(id -> id > 0)
                    .collect(Collectors.toList());
            Map<Integer, List<Map<String, Object>>> itemsByInvoice = invoicesRepo.getInvoiceItemsByInvoiceIds(invoiceIds);

            for (Map<String, Object> inv : invoices) {
                Object idObj = inv.get("invoiceId");
                int invId = idObj instanceof Number ? ((Number) idObj).intValue() : (idObj != null ? Integer.parseInt(idObj.toString()) : 0);
                List<Map<String, Object>> items = itemsByInvoice.getOrDefault(invId, List.of());
                inv.put("items", items != null ? items : List.of());
            }

            request.setAttribute("invoices", invoices);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("range", range);

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
