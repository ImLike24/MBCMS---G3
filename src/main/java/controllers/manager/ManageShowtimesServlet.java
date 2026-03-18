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
import repositories.CinemaBranches;
import repositories.Movies;
import repositories.ScreeningRooms;
import repositories.Showtimes;
import services.TicketPriceService;
import java.math.BigDecimal;

@WebServlet(name = "ManageShowtimesServlet", urlPatterns = { "/branch-manager/manage-showtimes" })
public class ManageShowtimesServlet extends HttpServlet {

    private final Showtimes showtimesDao = new Showtimes();
    private final Movies moviesDao = new Movies();
    private final ScreeningRooms roomsDao = new ScreeningRooms();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final TicketPriceService ticketPriceService = new TicketPriceService();

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

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(user.getUserId());
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

        String branchName = managedBranches.stream().filter(b -> b.getBranchId() == finalSelectedId).findFirst().map(CinemaBranch::getBranchName).orElse("N/A");
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
        showtimesDao.autoUpdateStatuses(branchId);

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

        List<Map<String, Object>> allShowtimes = showtimesDao.getShowtimesByBranch(branchId, filterDate, statusFilter,
                movieKw);

        // Overwrite base price dynamically
        for (Map<String, Object> showtimeMap : allShowtimes) {
            LocalDate showDate = (LocalDate) showtimeMap.get("showDate");
            LocalTime startTime = (LocalTime) showtimeMap.get("startTime");
            if (showDate != null && startTime != null) {
                BigDecimal basePrice = ticketPriceService.getBasePriceForShowtime(branchId, showDate, startTime);
                showtimeMap.put("basePrice", basePrice);
            }
        }

        Map<String, Integer> stats = showtimesDao.countShowtimesByBranch(branchId);

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

        List<Movie> movies = moviesDao.getAllActiveMovies();
        List<ScreeningRoom> rooms = roomsDao.getAllRoomsByBranch(branchId);

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

        Showtime showtime = showtimesDao.getShowtimeById(Integer.parseInt(idStr));
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

        List<Movie> movies = moviesDao.getAllActiveMovies();
        List<ScreeningRoom> rooms = roomsDao.getAllRoomsByBranch(branchId);

        // Get movie info for current showtime (for duration display)
        Movie currentMovie = moviesDao.getMovieById(showtime.getMovieId());

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

            // If overnight, end is on the next calendar day
            LocalDate endDate = overnight ? date.plusDays(1) : date;

            // Validate room belongs to this branch
            ScreeningRoom room = roomsDao.getRoomById(roomId);
            if (room == null || room.getBranchId() != branchId) {
                forwardWithError(request, response, "create", branchId,
                        "Phòng không hợp lệ.", movieId, roomId, date, start, null);
                return;
            }

            // Validate end is after start (using LocalDateTime to handle overnight)
            java.time.LocalDateTime startDT = java.time.LocalDateTime.of(date, start);
            java.time.LocalDateTime endDT = java.time.LocalDateTime.of(endDate, end);
            if (!endDT.isAfter(startDT)) {
                forwardWithError(request, response, "create", branchId,
                        "Giờ kết thúc phải sau giờ bắt đầu.", movieId, roomId, date, start, null);
                return;
            }

            // Check date not in the past
            if (date.isBefore(LocalDate.now())) {
                forwardWithError(request, response, "create", branchId,
                        "Ngày chiếu không được ở trong quá khứ.", movieId, roomId, date, start, null);
                return;
            }

            // Check scheduling conflict (pass endDate so overnight conflicts are caught)
            if (showtimesDao.hasSchedulingConflict(roomId, date, start, end, null)) {
                forwardWithError(request, response, "create", branchId,
                        "Phòng đã có suất chiếu trong khung giờ này. Vui lòng chọn giờ khác.",
                        movieId, roomId, date, start, null);
                return;
            }

            Showtime st = new Showtime();
            st.setMovieId(movieId);
            st.setRoomId(roomId);
            st.setShowDate(date);
            st.setStartTime(start);
            st.setEndTime(end);
            st.setStatus("SCHEDULED");

            int newId = showtimesDao.createShowtime(st);
            if (newId > 0) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-showtimes?message=created");
            } else {
                forwardWithError(request, response, "create", branchId,
                        "Lỗi khi tạo suất chiếu. Vui lòng thử lại.",
                        movieId, roomId, date, start, null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=invalid");
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

            // Verify showtime exists and is SCHEDULED
            Showtime existing = showtimesDao.getShowtimeById(showtimeId);
            if (existing == null || !"SCHEDULED".equals(existing.getStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-showtimes?error=noteditable");
                return;
            }

            // Validate room belongs to this branch
            ScreeningRoom room = roomsDao.getRoomById(roomId);
            if (room == null || room.getBranchId() != branchId) {
                forwardWithError(request, response, "edit", branchId,
                        "Phòng không hợp lệ.", movieId, roomId, date, start, showtimeId);
                return;
            }

            // Validate end > start
            if (!end.isAfter(start)) {
                forwardWithError(request, response, "edit", branchId,
                        "Giờ kết thúc phải sau giờ bắt đầu.", movieId, roomId, date, start, showtimeId);
                return;
            }

            // Check scheduling conflict (exclude current showtime)
            if (showtimesDao.hasSchedulingConflict(roomId, date, start, end, showtimeId)) {
                forwardWithError(request, response, "edit", branchId,
                        "Phòng đã có suất chiếu trong khung giờ này. Vui lòng chọn giờ khác.",
                        movieId, roomId, date, start, showtimeId);
                return;
            }

            // base_price is NOT updated here — managed by the ticket price config screen
            boolean updated = showtimesDao.updateShowtime(showtimeId, date, start, end, null);
            if (updated) {
                // Also update room if changed
                if (existing.getRoomId() != roomId) {
                    // updateShowtime only changes date/time/price – we need to update room too
                    updateShowtimeRoom(showtimeId, roomId);
                }
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-showtimes?message=updated");
            } else {
                forwardWithError(request, response, "edit", branchId,
                        "Lỗi khi cập nhật suất chiếu.", movieId, roomId, date, start, showtimeId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=invalid");
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

        Showtime showtime = showtimesDao.getShowtimeById(showtimeId);
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

        // Dynamically compute base price
        // Lấy thông tin chi tiết (Map) từ Database lên trước
        java.util.Map<String, Object> detail = showtimesDao.getActiveShowtimeDetail(showtimeId);

        // Dynamically compute base price (Tính toán lại giá động)
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            repositories.TicketPrices ticketPricesDao = new repositories.TicketPrices();

            // 1. Xác định Loại ngày (WEEKDAY / WEEKEND)
            java.time.DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
            String dayType = (dayOfWeek == java.time.DayOfWeek.SATURDAY || dayOfWeek == java.time.DayOfWeek.SUNDAY)
                    ? "WEEKEND" : "WEEKDAY";

            // 2. Xác định Khung giờ
            int hour = showtime.getStartTime().getHour();
            String timeSlot;
            if (hour >= 6 && hour < 12) timeSlot = "MORNING";
            else if (hour >= 12 && hour < 17) timeSlot = "AFTERNOON";
            else if (hour >= 17 && hour < 22) timeSlot = "EVENING";
            else timeSlot = "NIGHT";

            // Query Database lấy giá vé mặc định (ADULT)
            BigDecimal dynamicPrice = ticketPricesDao.getTicketPrice(
                    branchId,
                    "ADULT",
                    dayType,
                    timeSlot,
                    showtime.getShowDate()
            );

            // Ghi đè giá trị mới vào cả 2 object để đảm bảo JSP gọi cái nào cũng đúng
            if (dynamicPrice != null) {
                showtime.setBasePrice(dynamicPrice);
                if (detail != null) {
                    detail.put("base_price", dynamicPrice); // Ghi đè vào Map
                }
            }
        }

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

        Showtime showtime = showtimesDao.getShowtimeById(showtimeId);
        if (showtime == null || !"CANCELLED".equals(showtime.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notfound");
            return;
        }

        // Dynamically compute base price
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            BigDecimal price = ticketPriceService.getBasePriceForShowtime(branchId, showtime.getShowDate(),
                    showtime.getStartTime());
            showtime.setBasePrice(price);
        }

        Movie movie = moviesDao.getMovieById(showtime.getMovieId());
        java.util.Map<String, Object> detail = showtimesDao.getCancelledShowtimeDetail(showtimeId);

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

        Showtime showtime = showtimesDao.getShowtimeById(showtimeId);
        if (showtime == null || !"SCHEDULED".equals(showtime.getStatus())) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=noteditable");
            return;
        }

        // Dynamically compute base price
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            BigDecimal price = ticketPriceService.getBasePriceForShowtime(branchId, showtime.getShowDate(),
                    showtime.getStartTime());
            showtime.setBasePrice(price);
        }

        // Fetch movie name for display
        Movie movie = moviesDao.getMovieById(showtime.getMovieId());
        // Fetch affected bookings/tickets
        java.util.List<java.util.Map<String, Object>> affected = showtimesDao.getBookingsByShowtime(showtimeId);

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

            // Validate showtime belongs to this branch (security check)
            Showtime existing = showtimesDao.getShowtimeById(showtimeId);
            if (existing == null || !"SCHEDULED".equals(existing.getStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-showtimes?error=noteditable");
                return;
            }

            java.util.Map<String, Object> result = showtimesDao.cancelShowtimeWithRefund(showtimeId, reason);

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

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST: Delete
    // ─────────────────────────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws IOException {
        try {
            int showtimeId = Integer.parseInt(request.getParameter("showtimeId"));

            // Verify showtime exists
            Showtime existing = showtimesDao.getShowtimeById(showtimeId);
            if (existing == null) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notfound");
                return;
            }

            // Verify room belongs to this branch (security)
            ScreeningRoom room = roomsDao.getRoomById(existing.getRoomId());
            if (room == null || room.getBranchId() != branchId) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // Only COMPLETED or CANCELLED can be deleted
            String status = existing.getStatus();
            if (!"COMPLETED".equals(status) && !"CANCELLED".equals(status)) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=notdeletable");
                return;
            }

            boolean deleted;
            if ("CANCELLED".equals(status)) {
                // Force-delete: cascade-remove all associated tickets/bookings first
                deleted = showtimesDao.forceDeleteCancelledShowtime(showtimeId);
            } else {
                // COMPLETED: simple delete (no pending tickets expected)
                deleted = showtimesDao.deleteShowtime(showtimeId);
            }

            if (deleted) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?message=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=deletefailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-showtimes?error=invalid");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: update room_id for a showtime
    // ─────────────────────────────────────────────────────────────────────────
    private void updateShowtimeRoom(int showtimeId, int roomId) {
        showtimesDao.updateShowtimeRoom(showtimeId, roomId);
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

        List<Movie> movies = moviesDao.getAllActiveMovies();
        List<ScreeningRoom> rooms = roomsDao.getAllRoomsByBranch(branchId);
        request.setAttribute("movies", movies);
        request.setAttribute("rooms", rooms);

        if ("edit".equals(formType) && showtimeId != null) {
            Showtime st = showtimesDao.getShowtimeById(showtimeId);
            Movie currentMovie = moviesDao.getMovieById(movieId);
            request.setAttribute("showtime", st);
            request.setAttribute("currentMovie", currentMovie);
            request.getRequestDispatcher("/pages/manager/manage-showtimes/edit.jsp")
                    .forward(request, response);
        } else {
            request.getRequestDispatcher("/pages/manager/manage-showtimes/schedule.jsp")
                    .forward(request, response);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Removed: getBranchOfCurrentUser method is no longer used since branchId is taken from session attribute
    // ─────────────────────────────────────────────────────────────────────────
}
