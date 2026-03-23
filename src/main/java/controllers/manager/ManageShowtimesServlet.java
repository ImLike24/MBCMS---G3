package controllers.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

import models.CinemaBranch;
import models.Movie;
import models.ScreeningRoom;
import models.Showtime;
import models.User;
import services.ShowtimeService;
import java.math.BigDecimal;

@WebServlet(name = "ManageShowtimesServlet", urlPatterns = { "/branch-manager/manage-showtimes" })
public class ManageShowtimesServlet extends HttpServlet {

    private final ShowtimeService showtimeService = new ShowtimeService();

    // ─────────────────────────────────────────────────────────────────────────
    // GET
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<CinemaBranch> managedBranches = showtimeService.getManagedBranches(user.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không quản lý chi nhánh nào.");
            return;
        }

        Integer selectedBranchId = null;
        String branchIdParam = request.getParameter("branchId");

        if (branchIdParam != null && !branchIdParam.isEmpty()) {
            selectedBranchId = Integer.parseInt(branchIdParam);
        } else if (session.getAttribute("selectedBranchId") != null) {
            selectedBranchId = (Integer) session.getAttribute("selectedBranchId");
        } else {
            selectedBranchId = managedBranches.get(0).getBranchId();
        }

        // Validate branch belongs to the manager
        final Integer finalSelectedId = selectedBranchId;
        boolean isValidBranch = managedBranches.stream().anyMatch(b -> b.getBranchId().equals(finalSelectedId));
        if (!isValidBranch) {
            selectedBranchId = managedBranches.get(0).getBranchId();
        }

        session.setAttribute("selectedBranchId", selectedBranchId);
        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);

        String branchName = managedBranches.stream().filter(b -> b.getBranchId() == finalSelectedId).findFirst()
                .map(CinemaBranch::getBranchName).orElse("N/A");
        request.setAttribute("currentBranchName", branchName);

        String action = request.getParameter("action");
        if (action == null)
            action = "list";

        switch (action) {
            case "view-detail":
                showActiveDetail(request, response, selectedBranchId);
                break;
            case "create":
                showScheduleForm(request, response, selectedBranchId);
                break;
            case "edit":
                showEditForm(request, response, selectedBranchId);
                break;
            case "cancel-preview":
                showCancelPreview(request, response, selectedBranchId);
                break;
            case "view-cancelled":
                showCancelledDetail(request, response, selectedBranchId);
                break;
            default:
                listShowtimes(request, response, selectedBranchId);
                break;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Integer selectedBranchId = (Integer) session.getAttribute("selectedBranchId");
        if (selectedBranchId == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            handleCreate(request, response, selectedBranchId);
        } else if ("update".equals(action)) {
            handleUpdate(request, response, selectedBranchId);
        } else if ("cancel".equals(action)) {
            handleCancelWithRefund(request, response, selectedBranchId);
        } else if ("delete".equals(action)) {
            handleDelete(request, response, selectedBranchId);
        } else {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST
    // ─────────────────────────────────────────────────────────────────────────
    private void listShowtimes(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        // Auto-update statuses for this branch (fresh connection)
        showtimeService.autoUpdateStatuses(branchId);

        // Read optional filters
        String dateStr = request.getParameter("filterDate");
        String statusFilter = request.getParameter("filterStatus");
        String movieKw = request.getParameter("filterMovie");

        LocalDate filterDate = null;
        if (dateStr != null && !dateStr.isBlank()) {
            try {
                filterDate = LocalDate.parse(dateStr);
            } catch (Exception ignored) {
            }
        }

        List<Map<String, Object>> allShowtimes = showtimeService.getShowtimesByBranch(branchId, filterDate, statusFilter, movieKw);
        Map<String, Integer> stats = showtimeService.countShowtimesByBranch(branchId);

        // ── Pagination ────────────────────────────────────────────────────
        int pageSize = 5;
        int totalShowtimes = allShowtimes.size();
        int totalPages = (int) Math.ceil((double) totalShowtimes / pageSize);
        if (totalPages == 0)
            totalPages = 1;

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isBlank()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (currentPage < 1)
            currentPage = 1;
        if (currentPage > totalPages)
            currentPage = totalPages;

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalShowtimes);
        List<Map<String, Object>> showtimes = allShowtimes.subList(fromIndex, toIndex);
        // ─────────────────────────────────────────────────────────────────

        request.setAttribute("showtimes", showtimes);
        request.setAttribute("stats", stats);
        request.setAttribute("filterDate", dateStr);
        request.setAttribute("filterStatus", statusFilter);
        request.setAttribute("filterMovie", movieKw);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalShowtimes", totalShowtimes);

        request.getRequestDispatcher("/pages/manager/manage-showtimes/list.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SCHEDULE (create) form
    // ─────────────────────────────────────────────────────────────────────────
    private void showScheduleForm(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        List<Movie> movies = showtimeService.getAllActiveMovies();
        List<ScreeningRoom> rooms = showtimeService.getRoomsByBranch(branchId);

        request.setAttribute("movies", movies);
        request.setAttribute("rooms", rooms);

        request.getRequestDispatcher("/pages/manager/manage-showtimes/schedule.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EDIT form
    // ─────────────────────────────────────────────────────────────────────────
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        Showtime showtime = showtimeService.getShowtimeById(Integer.parseInt(idStr));
        if (showtime == null) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=notfound");
            return;
        }

        // Only SCHEDULED showtimes can be edited
        if (!"SCHEDULED".equals(showtime.getStatus())) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=noteditable");
            return;
        }

        List<Movie> movies = showtimeService.getAllActiveMovies();
        List<ScreeningRoom> rooms = showtimeService.getRoomsByBranch(branchId);

        // Get movie info for current showtime (for duration display)
        Movie currentMovie = showtimeService.getMovieById(showtime.getMovieId());

        request.setAttribute("showtime", showtime);
        request.setAttribute("movies", movies);
        request.setAttribute("rooms", rooms);
        request.setAttribute("currentMovie", currentMovie);

        request.getRequestDispatcher("/pages/manager/manage-showtimes/edit.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Create
    // ─────────────────────────────────────────────────────────────────────────
    private void handleCreate(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            LocalDate date = LocalDate.parse(request.getParameter("showDate"));
            LocalTime start = LocalTime.parse(request.getParameter("startTime"));
            LocalTime end = LocalTime.parse(request.getParameter("endTime"));
            boolean overnight = "1".equals(request.getParameter("overnight"));

            try {
                showtimeService.createShowtime(branchId, movieId, roomId, date, start, end, overnight);
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?message=created");
            } catch (RuntimeException e) {
                forwardWithError(request, response, "create", branchId, e.getMessage(), movieId, roomId, date, start, null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Update
    // ─────────────────────────────────────────────────────────────────────────
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        try {
            int showtimeId = Integer.parseInt(request.getParameter("showtimeId"));
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            LocalDate date = LocalDate.parse(request.getParameter("showDate"));
            LocalTime start = LocalTime.parse(request.getParameter("startTime"));
            LocalTime end = LocalTime.parse(request.getParameter("endTime"));
            boolean overnight = "1".equals(request.getParameter("overnight"));

            try {
                showtimeService.updateShowtime(showtimeId, branchId, movieId, roomId, date, start, end, overnight);
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?message=updated");
            } catch (IllegalArgumentException e) {
                if ("Khong the sua.".equals(e.getMessage())) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=noteditable");
                } else {
                    forwardWithError(request, response, "edit", branchId, e.getMessage(), movieId, roomId, date, start, showtimeId);
                }
            } catch (RuntimeException e) {
                forwardWithError(request, response, "edit", branchId, e.getMessage(), movieId, roomId, date, start, showtimeId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET: View Active Showtime Detail (SCHEDULED / ONGOING / COMPLETED)
    // ─────────────────────────────────────────────────────────────────────────
    private void showActiveDetail(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }
        int showtimeId;
        try {
            showtimeId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        Showtime showtime = showtimeService.getShowtimeById(showtimeId);
        if (showtime == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notfound");
            return;
        }

        // Only allow SCHEDULED, ONGOING, COMPLETED
        String status = showtime.getStatus();
        if (!"SCHEDULED".equals(status) && !"ONGOING".equals(status) && !"COMPLETED".equals(status)) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        java.util.Map<String, Object> detail = showtimeService.getActiveShowtimeDetail(showtimeId, branchId, showtime);

        request.setAttribute("showtime", showtime);
        request.setAttribute("detail", detail);
        request.getRequestDispatcher("/pages/manager/manage-showtimes/detail.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET: View Cancelled Showtime Detail
    // ─────────────────────────────────────────────────────────────────────────
    private void showCancelledDetail(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }
        int showtimeId;
        try {
            showtimeId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        Showtime showtime = showtimeService.getShowtimeById(showtimeId);
        if (showtime == null || !"CANCELLED".equals(showtime.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notfound");
            return;
        }

        // Dynamically compute base price
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            BigDecimal price = showtimeService.getBasePriceForShowtime(branchId, showtime.getShowDate(), showtime.getStartTime());
            showtime.setBasePrice(price);
        }

        Movie movie = showtimeService.getMovieById(showtime.getMovieId());
        java.util.Map<String, Object> detail = showtimeService.getCancelledShowtimeDetail(showtimeId);

        request.setAttribute("showtime", showtime);
        request.setAttribute("movie", movie);
        request.setAttribute("detail", detail);
        request.getRequestDispatcher("/pages/manager/manage-showtimes/cancelled-detail.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET: Cancel Preview
    // ─────────────────────────────────────────────────────────────────────────
    private void showCancelPreview(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes");
            return;
        }

        Showtime showtime = showtimeService.getShowtimeById(showtimeId);
        if (showtime == null || !"SCHEDULED".equals(showtime.getStatus())) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=noteditable");
            return;
        }

        // Dynamically compute base price
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            BigDecimal price = showtimeService.getBasePriceForShowtime(branchId, showtime.getShowDate(), showtime.getStartTime());
            showtime.setBasePrice(price);
        }

        // Fetch movie name for display
        Movie movie = showtimeService.getMovieById(showtime.getMovieId());
        // Fetch affected bookings/tickets
        java.util.List<java.util.Map<String, Object>> affected = showtimeService.getBookingsByShowtime(showtimeId);

        request.setAttribute("showtime", showtime);
        request.setAttribute("movie", movie);
        request.setAttribute("affected", affected);
        request.getRequestDispatcher("/pages/manager/manage-showtimes/cancel.jsp")
                .forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Cancel with Refund
    // ─────────────────────────────────────────────────────────────────────────
    private void handleCancelWithRefund(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int showtimeId = Integer.parseInt(request.getParameter("showtimeId"));
            String reason = request.getParameter("reason");

            try {
                java.util.Map<String, Object> result = showtimeService.cancelShowtimeWithRefund(showtimeId, reason);

                if (Boolean.TRUE.equals(result.get("success"))) {
                    int online = (int) result.get("onlineRefunds");
                    int counter = (int) result.get("counterRefunds");
                    java.math.BigDecimal refundAmt = (java.math.BigDecimal) result.get("totalRefundAmount");
                    String amt = refundAmt != null ? refundAmt.toPlainString() : "0";
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-showtimes?message=cancelled"
                            + "&onlineRefunds=" + online
                            + "&counterRefunds=" + counter
                            + "&refundAmt=" + amt);
                } else {
                    String err = (String) result.getOrDefault("errorMsg", "unknown");
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-showtimes?error=cancelfailed&detail="
                            + java.net.URLEncoder.encode(err, "UTF-8"));
                }
            } catch (IllegalArgumentException e) {
                if ("noteditable".equals(e.getMessage())) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=noteditable");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Delete
    // ─────────────────────────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int showtimeId = Integer.parseInt(request.getParameter("showtimeId"));

            try {
                showtimeService.deleteShowtime(showtimeId, branchId);
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?message=deleted");
            } catch (IllegalArgumentException e) {
                if ("notfound".equals(e.getMessage())) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notfound");
                } else if ("notdeletable".equals(e.getMessage())) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notdeletable");
                }
            } catch (SecurityException e) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            } catch (RuntimeException e) {
                if ("deletefailed".equals(e.getMessage())) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=deletefailed");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: redirect back to form with error message and pre-filled values
    // ─────────────────────────────────────────────────────────────────────────
    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
            String formType, int branchId, String errorMsg,
            int movieId, int roomId, LocalDate date, LocalTime startTime,
            Integer showtimeId)
            throws ServletException, IOException {

        request.setAttribute("errorMsg", errorMsg);
        request.setAttribute("prefMovieId", movieId);
        request.setAttribute("prefRoomId", roomId);
        request.setAttribute("prefDate", date);
        request.setAttribute("prefStartTime", startTime);

        List<Movie> movies = showtimeService.getAllActiveMovies();
        List<ScreeningRoom> rooms = showtimeService.getRoomsByBranch(branchId);
        request.setAttribute("movies", movies);
        request.setAttribute("rooms", rooms);

        if ("edit".equals(formType) && showtimeId != null) {
            Showtime st = showtimeService.getShowtimeById(showtimeId);
            Movie currentMovie = showtimeService.getMovieById(movieId);
            request.setAttribute("showtime", st);
            request.setAttribute("currentMovie", currentMovie);
            request.getRequestDispatcher("/pages/manager/manage-showtimes/edit.jsp")
                    .forward(request, response);
        } else {
            request.getRequestDispatcher("/pages/manager/manage-showtimes/schedule.jsp")
                    .forward(request, response);
        }
    }
}
