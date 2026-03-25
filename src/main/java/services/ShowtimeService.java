package services;

import models.CinemaBranch;
import models.Movie;
import models.ScreeningRoom;
import models.Showtime;
import repositories.CinemaBranches;
import repositories.Movies;
import repositories.ScreeningRooms;
import repositories.Showtimes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

public class ShowtimeService {

    private final Showtimes showtimesDao = new Showtimes();
    private final Movies moviesDao = new Movies();
    private final ScreeningRooms roomsDao = new ScreeningRooms();
    private final CinemaBranches branchDao = new CinemaBranches();
    private final TicketPriceService ticketPriceService = new TicketPriceService();

    public List<CinemaBranch> getManagedBranches(int managerId) {
        return branchDao.findListByManagerId(managerId);
    }
    
    public List<Movie> getAllActiveMovies() {
        return moviesDao.getAllActiveMovies();
    }
    
    public Movie getMovieById(int movieId) {
        return moviesDao.getMovieById(movieId);
    }
    
    public List<ScreeningRoom> getRoomsByBranch(int branchId) {
        return roomsDao.getAllRoomsByBranch(branchId);
    }
    
    public ScreeningRoom getRoomById(int roomId) {
        return roomsDao.getRoomById(roomId);
    }
    
    public Showtime getShowtimeById(int showtimeId) {
        return showtimesDao.getShowtimeById(showtimeId);
    }
    
    public void autoUpdateStatuses(int branchId) {
        showtimesDao.autoUpdateStatuses(branchId);
    }
    
    public List<Map<String, Object>> getShowtimesByBranch(int branchId, LocalDate filterDate, String statusFilter, String movieKw) {
        List<Map<String, Object>> allShowtimes = showtimesDao.getShowtimesByBranch(branchId, filterDate, statusFilter, movieKw);
        
        // Overwrite base price dynamically
        for (Map<String, Object> showtimeMap : allShowtimes) {
            LocalDate showDate = (LocalDate) showtimeMap.get("showDate");
            LocalTime startTime = (LocalTime) showtimeMap.get("startTime");
            if (showDate != null && startTime != null) {
                BigDecimal basePrice = ticketPriceService.getBasePriceForShowtime(branchId, showDate, startTime);
                showtimeMap.put("basePrice", basePrice);
            }
        }
        return allShowtimes;
    }
    
    public Map<String, Integer> countShowtimesByBranch(int branchId) {
        return showtimesDao.countShowtimesByBranch(branchId);
    }
    
    public Map<String, Object> getActiveShowtimeDetail(int showtimeId, int branchId, Showtime showtime) {
        Map<String, Object> detail = showtimesDao.getActiveShowtimeDetail(showtimeId);
        
        // Calculate dynamic base price for active showtime
        if (showtime.getShowDate() != null && showtime.getStartTime() != null) {
            repositories.TicketPrices ticketPricesDao = new repositories.TicketPrices();

            // Determine if weekend or weekday
            java.time.DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
            String dayType = (dayOfWeek == java.time.DayOfWeek.SATURDAY || dayOfWeek == java.time.DayOfWeek.SUNDAY)
                    ? "WEEKEND"
                    : "WEEKDAY";

            // Determine time slot based on hour
            int hour = showtime.getStartTime().getHour();
            String timeSlot;
            if (hour >= 6 && hour < 12)
                timeSlot = "MORNING";
            else if (hour >= 12 && hour < 17)
                timeSlot = "AFTERNOON";
            else if (hour >= 17 && hour < 22)
                timeSlot = "EVENING";
            else
                timeSlot = "NIGHT";

            BigDecimal dynamicPrice = ticketPricesDao.getTicketPrice(
                    branchId, "ADULT", dayType, timeSlot, showtime.getShowDate());

            if (dynamicPrice != null) {
                showtime.setBasePrice(dynamicPrice);
                if (detail != null) {
                    detail.put("basePrice", dynamicPrice);
                }
            }
        }
        return detail;
    }
    
    public Map<String, Object> getCancelledShowtimeDetail(int showtimeId) {
        return showtimesDao.getCancelledShowtimeDetail(showtimeId);
    }
    
    public BigDecimal getBasePriceForShowtime(int branchId, LocalDate date, LocalTime time) {
        return ticketPriceService.getBasePriceForShowtime(branchId, date, time);
    }
    
    public List<Map<String, Object>> getBookingsByShowtime(int showtimeId) {
        return showtimesDao.getBookingsByShowtime(showtimeId);
    }

    public void createShowtime(int branchId, int movieId, int roomId, LocalDate date, LocalTime start, LocalTime end, boolean overnight) throws Exception {
        LocalDate endDate = overnight ? date.plusDays(1) : date;

        // Verify room belongs to branch
        ScreeningRoom room = roomsDao.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Phòng không hợp lệ.");
        }

        // Validate end time is after start time
        java.time.LocalDateTime startDT = java.time.LocalDateTime.of(date, start);
        java.time.LocalDateTime endDT = java.time.LocalDateTime.of(endDate, end);
        if (!endDT.isAfter(startDT)) {
            throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu.");
        }

        // Prevent scheduling in the past
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("Ngày chiếu không được ở trong quá khứ.");
        }

        // Check for schedule overlaps in the same room
        if (showtimesDao.hasSchedulingConflict(roomId, date, start, end, null)) {
            throw new IllegalArgumentException("Phòng đã có suất chiếu trong khung giờ này. Vui lòng chọn giờ khác.");
        }

        // Create new showtime object
        Showtime st = new Showtime();
        st.setMovieId(movieId);
        st.setRoomId(roomId);
        st.setShowDate(date);
        st.setStartTime(start);
        st.setEndTime(end);
        st.setStatus("SCHEDULED");

        // Insert showtime to database
        int newId = showtimesDao.createShowtime(st);
        if (newId <= 0) {
            throw new RuntimeException("Lỗi khi tạo suất chiếu. Vui lòng thử lại.");
        }
    }
    
    public void updateShowtime(int showtimeId, int branchId, int movieId, int roomId, LocalDate date, LocalTime start, LocalTime end, boolean overnight) throws Exception {
        // Only allow edits for SCHEDULED showtimes
        Showtime existing = showtimesDao.getShowtimeById(showtimeId);
        if (existing == null || !"SCHEDULED".equals(existing.getStatus())) {
            throw new IllegalArgumentException("Khong the sua."); // Will handle specific error in servlet
        }

        // Verify room belongs to branch
        ScreeningRoom room = roomsDao.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Phòng không hợp lệ.");
        }

        // Validate end time is after start time
        LocalDate endDate = overnight ? date.plusDays(1) : date;
        java.time.LocalDateTime startDT = java.time.LocalDateTime.of(date, start);
        java.time.LocalDateTime endDT = java.time.LocalDateTime.of(endDate, end);
        if (!endDT.isAfter(startDT)) {
            throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu.");
        }

        // Check for schedule overlaps, excluding the current showtime
        if (showtimesDao.hasSchedulingConflict(roomId, date, start, end, showtimeId)) {
            throw new IllegalArgumentException("Phòng đã có suất chiếu trong khung giờ này. Vui lòng chọn giờ khác.");
        }

        // Update showtime details
        boolean updated = showtimesDao.updateShowtime(showtimeId, date, start, end, null);
        if (updated) {
            // Update room if it was changed
            if (existing.getRoomId() != roomId) {
                showtimesDao.updateShowtimeRoom(showtimeId, roomId);
            }
        } else {
            throw new RuntimeException("Lỗi khi cập nhật suất chiếu.");
        }
    }
    
    public Map<String, Object> cancelShowtimeWithRefund(int showtimeId, String reason) throws Exception {
        // Only allow cancellation for SCHEDULED showtimes
        Showtime existing = showtimesDao.getShowtimeById(showtimeId);
        if (existing == null || !"SCHEDULED".equals(existing.getStatus())) {
            throw new IllegalArgumentException("noteditable");
        }

        // Perform cancellation and process refunds
        return showtimesDao.cancelShowtimeWithRefund(showtimeId, reason);
    }
    
    public void deleteShowtime(int showtimeId, int branchId) throws Exception {
        Showtime existing = showtimesDao.getShowtimeById(showtimeId);
        if (existing == null) {
            throw new IllegalArgumentException("notfound");
        }

        // Check if room belongs to branch before deleting
        ScreeningRoom room = roomsDao.getRoomById(existing.getRoomId());
        if (room == null || room.getBranchId() != branchId) {
            throw new SecurityException("forbidden");
        }

        // Only allow deleting COMPLETED or CANCELLED showtimes
        String status = existing.getStatus();
        if (!"COMPLETED".equals(status) && !"CANCELLED".equals(status)) {
            throw new IllegalArgumentException("notdeletable");
        }

        boolean deleted;
        if ("CANCELLED".equals(status)) {
            // Force delete for cancelled showtime
            deleted = showtimesDao.forceDeleteCancelledShowtime(showtimeId);
        } else {
            // Normal delete for completed showtime
            deleted = showtimesDao.deleteShowtime(showtimeId);
        }

        if (!deleted) {
            throw new RuntimeException("deletefailed");
        }
    }
}
