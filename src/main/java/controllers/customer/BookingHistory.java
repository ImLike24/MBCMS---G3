package controllers.customer;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import repositories.BookingHistories;

@WebServlet(name = "BookingHistory", urlPatterns = {"/customer/booking-history"})
public class BookingHistory extends HttpServlet {

    // force update
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

        // Lọc theo phim (danh sách hóa đơn có vé xem phim đó)
        String movieTitle = request.getParameter("movie");
        if (movieTitle != null && movieTitle.isBlank()) {
            movieTitle = null;
        }

        BookingHistories repo = new BookingHistories();
        try {
            List<String> movieList = repo.getDistinctMovieTitlesByUserId(userId);

            int totalCount = repo.countBookingsByUserIdInRange(userId, from, to, movieTitle);
            int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (totalPages > 0 && page > totalPages) page = totalPages;

            int offset = (page - 1) * PAGE_SIZE;
            List<Map<String, Object>> bookings = repo.getBookingsByUserIdInRange(
                    userId, offset, PAGE_SIZE, from, to, movieTitle);

            List<Integer> bookingIds = bookings.stream()
                    .map(m -> {
                        Object id = m.get("bookingId");
                        if (id instanceof Number) return ((Number) id).intValue();
                        return id != null ? Integer.parseInt(id.toString()) : 0;
                    })
                    .filter(id -> id > 0)
                    .collect(Collectors.toList());
            // seat items
            Map<Integer, List<Map<String, Object>>> itemsByBooking = repo.getSeatItemsByBookingIds(bookingIds).stream()
                    .collect(Collectors.groupingBy(item -> (Integer) item.get("bookingId")));

            for (Map<String, Object> booking : bookings) {
                Integer bookingId = (Integer) booking.get("bookingId");
                List<Map<String, Object>> items = itemsByBooking.getOrDefault(bookingId, List.of());
                booking.put("items", items != null ? items : List.of());

                // concessionTotal = totalAmount (grandTotal trong DB) - ticketTotal - discountAmount
                BigDecimal totalAmount = booking.get("totalAmount") != null
                        ? (BigDecimal) booking.get("totalAmount")
                        : BigDecimal.ZERO;
                BigDecimal discountAmount = booking.get("discountAmount") != null
                        ? (BigDecimal) booking.get("discountAmount")
                        : BigDecimal.ZERO;
                BigDecimal ticketTotal = BigDecimal.ZERO;
                if (items != null && !items.isEmpty()) {
                    ticketTotal = items.stream()
                            .map(i -> i.get("amount"))
                            .filter(v -> v instanceof BigDecimal)
                            .map(v -> (BigDecimal) v)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                }
                BigDecimal concessionTotal = totalAmount.subtract(ticketTotal).subtract(discountAmount);
                if (concessionTotal.compareTo(BigDecimal.ZERO) < 0) {
                    concessionTotal = BigDecimal.ZERO;
                }
                booking.put("concessionTotal", concessionTotal);
            }

            request.setAttribute("bookings", bookings);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("range", range);
            request.setAttribute("movieList", movieList != null ? movieList : List.of());
            request.setAttribute("selectedMovie", movieTitle);

            request.getRequestDispatcher("/pages/customer/booking-history.jsp").forward(request, response);
        } finally {
            repo.closeConnection();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
