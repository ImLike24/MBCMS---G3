package services;

import models.User;
import models.MembershipTier;
import models.LoyaltyConfig;
import models.PointHistory;
import models.Movie;
import models.Showtime;
import models.Voucher;
import repositories.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BookingService {

    private final Showtimes showtimeDao = new Showtimes();
    private Bookings bookingDao;
    private final Movies movieDao = new Movies();
    private final Concessions concessionDao = new Concessions();
    private final SeatTypeSurcharges surchargeDao = new SeatTypeSurcharges();
    private final Vouchers voucherDao = new Vouchers();
    private final TicketPriceService ticketPriceService = new TicketPriceService();
    private final Seats seatDao = new Seats();

    public BookingService() {
        try {
            this.bookingDao = new Bookings();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ---------------------------------------------------------
    // LOGIC NGHIỆP VỤ THANH TOÁN
    // ---------------------------------------------------------

    // Xử lý khi thanh toán THÀNH CÔNG
    public void processSuccessfulPayment(String bookingCode) throws Exception {
        // Cập nhật trạng thái Booking
        bookingDao.confirmBooking(bookingCode);

        // Xử lý điểm thưởng & Hạng thành viên
        Map<String, Object> bookingInfo = bookingDao.getBookingInfoForPoints(bookingCode);
        if (bookingInfo != null) {
            int userId = (int) bookingInfo.get("userId");
            int bookingId = (int) bookingInfo.get("bookingId");
            BigDecimal finalAmount = (BigDecimal) bookingInfo.get("finalAmount");
            String appliedVoucherCode = (String) bookingInfo.get("voucherCode");

            Users userRepo = new Users();
            User currentUser = userRepo.getUserById(userId);

            BigDecimal pointMultiplier = BigDecimal.ONE;
            if (currentUser != null && currentUser.getTierId() != null) {
                MembershipTiers tierRepo = new MembershipTiers();
                MembershipTier tier = tierRepo.getTierById(currentUser.getTierId());
                if (tier != null && tier.getPointMultiplier() != null) {
                    pointMultiplier = tier.getPointMultiplier();
                }
            }

            // Tính toán và cộng điểm
            LoyaltyConfigs configRepo = new LoyaltyConfigs();
            LoyaltyConfig loyaltyConfig = configRepo.getConfig();

            BigDecimal earnRateAmount = new BigDecimal(1000);
            BigDecimal earnPointsBase = BigDecimal.ONE;

            if (loyaltyConfig != null && loyaltyConfig.getEarnRateAmount() != null
                    && loyaltyConfig.getEarnRateAmount().compareTo(BigDecimal.ZERO) > 0) {
                earnRateAmount = loyaltyConfig.getEarnRateAmount();
                earnPointsBase = new BigDecimal(loyaltyConfig.getEarnPoints());
            }

            BigDecimal basePoints = finalAmount.divide(earnRateAmount, 0, RoundingMode.DOWN).multiply(earnPointsBase);
            int earnedPoints = basePoints.multiply(pointMultiplier).intValue();

            if (earnedPoints > 0) {
                userRepo.addPoints(userId, earnedPoints);
                userRepo.updateTier(userId); // Cập nhật hạng

                PointHistories phRepo = new PointHistories();
                PointHistory ph = new PointHistory();
                ph.setUserId(userId);
                ph.setPointsChanged(earnedPoints);
                ph.setTransactionType("EARN");
                ph.setDescription("Tích điểm từ hóa đơn vé " + bookingCode);
                ph.setReferenceId(bookingId);
                phRepo.insert(ph);
            }

            // Xử lý Voucher (Nếu có dùng)
            if (appliedVoucherCode != null && !appliedVoucherCode.isEmpty()) {
                Vouchers voucherRepo = new Vouchers();
                UserVouchers uvRepo = new UserVouchers();
                voucherRepo.incrementVoucherUsage(appliedVoucherCode);
                uvRepo.deleteVoucherByCode(appliedVoucherCode);
            }
        }
    }

    // Xử lý khi thanh toán THẤT BẠI / HỦY
    public void processFailedPayment(String bookingCode) throws Exception {
        try {
            // Gọi hàm Hủy đơn + Nhả ghế cho another customer
            bookingDao.cancelFailedBooking(bookingCode);
            System.out.println("Đã hủy đơn hàng và giải phóng ghế cho mã: " + bookingCode);
        } catch (Exception e) {
            e.printStackTrace();
        }    }

    // -------------------------------------------------------------
    // MÀN HÌNH CHỌN SUẤT CHIẾU (BookingShowtimes)
    // -------------------------------------------------------------
    public Map<String, Object> getShowtimesPageData(String movieIdParam, String dateParam) throws Exception {
        Map<String, Object> result = new HashMap<>();

        int movieId = Integer.parseInt(movieIdParam);
        Movie movie = movieDao.getMovieById(movieId);
        if (movie == null) {
            throw new Exception("Movie not found");
        }
        result.put("movie", movie);

        // Logic xử lý ngày tháng
        LocalDate today = LocalDate.now();
        LocalDate selectedDate = today;
        if (dateParam != null && !dateParam.isEmpty()) {
            try {
                selectedDate = LocalDate.parse(dateParam);
                if (selectedDate.isBefore(today))
                    selectedDate = today;
            } catch (DateTimeParseException ignored) {
            }
        }
        result.put("today", today);
        result.put("selectedDate", selectedDate);

        // Logic tạo danh sách 7 ngày tới
        List<LocalDate> dateList = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            dateList.add(today.plusDays(i));
        }
        result.put("dateList", dateList);

        // Lấy danh sách suất chiếu và tính toán ghế trống
        List<Showtime> showtimes = showtimeDao.getShowtimesForMovieOnDate(movieId, selectedDate);
        Map<Integer, Integer> availableSeatsMap = new HashMap<>();
        Map<Integer, Integer> totalSeatsMap = new HashMap<>();

        for (Showtime st : showtimes) {
            int stId = st.getShowtimeId();
            availableSeatsMap.put(stId, showtimeDao.countAvailableSeats(stId));

            Map<String, Object> details = showtimeDao.getShowtimeDetails(stId);
            if (details.containsKey("totalSeats")) {
                totalSeatsMap.put(stId, (Integer) details.get("totalSeats"));
            }
        }

        result.put("showtimes", showtimes);
        result.put("availableSeatsMap", availableSeatsMap);
        result.put("totalSeatsMap", totalSeatsMap);

        return result;
    }

    // -------------------------------------------------------------
    // MÀN HÌNH CHỌN GHẾ VÀ BẮP NƯỚC (BookingTickets)
    // -------------------------------------------------------------
    public Map<String, Object> getBookingTicketsData(int showtimeId) throws Exception {

        // Dọn dẹp vé rác (quá 5p) TRƯỚC KHI lấy danh sách ghế
        bookingDao.cleanupExpiredBookings();

        Map<String, Object> data = new HashMap<>();

        // Lấy thông tin cơ bản
        models.Showtime showtime = showtimeDao.getShowtimeById(showtimeId);
        int branchId = showtimeDao.getBranchIdByShowtimeId(showtimeId);
        models.ScreeningRoom room = showtimeDao.getRoomByShowtimeId(showtimeId);

        data.put("showtime", showtime);
        data.put("movie", showtimeDao.getMovieByShowtimeId(showtimeId));
        data.put("room", showtimeDao.getRoomByShowtimeId(showtimeId));

        java.util.List<Integer> occupiedSeats = showtimeDao.getOccupiedSeats(showtimeId);
        data.put("occupiedSeats", occupiedSeats);

        if (room != null) {
            java.util.List<models.Seat> allSeats = seatDao.getSeatsByRoom(room.getRoomId());

            // Cấu trúc Map bọc List các Map con
            java.util.Map<String, java.util.List<java.util.Map<String, Object>>> seatsByRow = new java.util.LinkedHashMap<>();

            if (allSeats != null) {
                for (models.Seat s : allSeats) {
                    // Bọc thông tin ghế và trạng thái vào 1 Map con
                    java.util.Map<String, Object> seatInfo = new java.util.HashMap<>();
                    seatInfo.put("seat", s);

                    // Check xem ghế này có nằm trong danh sách đã bị đặt không
                    if (occupiedSeats.contains(s.getSeatId())) {
                        seatInfo.put("bookingStatus", "BOOKED"); // Bị mua rồi
                    } else {
                        seatInfo.put("bookingStatus", "AVAILABLE"); // Còn trống
                    }

                    // Gom vào mảng theo từng hàng (Row A, Row B...)
                    seatsByRow.computeIfAbsent(s.getRowNumber(), k -> new java.util.ArrayList<>()).add(seatInfo);
                }
            }
            // Đẩy ra Map đã hoàn chỉnh
            data.put("seatsByRow", seatsByRow);
        }

        // Lấy danh sách phụ phí và bắp nước
        data.put("surchargeList", surchargeDao.getSurchargesByBranch(branchId));

        data.put("concessions", concessionDao.getActiveConcessions());

        // Lấy phụ phí ghế và tạo chuỗi JSON cho Frontend Javascript
        java.util.List<models.SeatTypeSurcharge> surcharges = surchargeDao.getSurchargesByBranch(branchId);
        data.put("surchargeList", surcharges);

        StringBuilder surchargeJson = new StringBuilder("{");
        if (surcharges != null) {
            for (int i = 0; i < surcharges.size(); i++) {
                models.SeatTypeSurcharge s = surcharges.get(i);
                surchargeJson.append("\"").append(s.getSeatType()).append("\":").append(s.getSurchargeRate());
                if (i < surcharges.size() - 1)
                    surchargeJson.append(",");
            }
        }
        surchargeJson.append("}");
        data.put("surchargeRatesJson", surchargeJson.toString());

        // Lấy giá vé Người lớn & Trẻ em từ Database
        BigDecimal adultPrice = BigDecimal.ZERO;
        BigDecimal childPrice = BigDecimal.ZERO;

        if (showtime != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
            String dayType = ticketPriceService.getDayType(showtime.getShowDate());
            String timeSlot = ticketPriceService.getTimeSlot(showtime.getStartTime());

            repositories.TicketPrices priceDao = new repositories.TicketPrices();
            BigDecimal aPrice = priceDao.getTicketPrice(branchId, "ADULT", dayType, timeSlot, showtime.getShowDate());
            BigDecimal cPrice = priceDao.getTicketPrice(branchId, "CHILD", dayType, timeSlot, showtime.getShowDate());

            if (aPrice != null)
                adultPrice = aPrice;
            if (cPrice != null)
                childPrice = cPrice;
        }

        data.put("adultPrice", adultPrice.doubleValue());
        data.put("childPrice", childPrice.doubleValue());
        data.put("basePrice", adultPrice.doubleValue()); // Gửi kèm dự phòng

        return data;
    }

    // -------------------------------------------------------------
    // MÀN HÌNH TỔNG KẾT (BookingSummary)
    // -------------------------------------------------------------
    public Map<String, Object> calculateSummaryAndVoucher(Map<String, Object> bookingData, String voucherCode,
            int userId) throws Exception {
        Map<String, Object> summaryResult = new HashMap<>();

        BigDecimal totalAmount = (BigDecimal) bookingData.get("totalAmount");
        BigDecimal discountAmount = BigDecimal.ZERO;
        BigDecimal finalAmount = totalAmount;
        String voucherError = null;

        // Xử lý logic Voucher nếu khách có nhập
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            String code = voucherCode.trim();
            Voucher voucher = null;

            UserVouchers uvRepo = new UserVouchers();
            models.UserVoucher uv = uvRepo.getVoucherByCode(code);
            if (uv != null && uv.getUserId() == userId && "AVAILABLE".equals(uv.getStatus())
                    && uv.getExpiresAt() != null && uv.getExpiresAt().isAfter(java.time.LocalDateTime.now())) {
                voucher = voucherDao.getVoucherById(uv.getVoucherId());
            }

            if (voucher == null) {
                voucherError = "Mã giảm giá không tồn tại hoặc chưa được lưu!";
            } else if (voucher.getMaxUsageLimit() > 0 && voucher.getCurrentUsage() >= voucher.getMaxUsageLimit()) {
                voucherError = "Rất tiếc, mã giảm giá này đã hết lượt sử dụng.";
            } else {
                // Hợp lệ -> Tính tiền giảm
                discountAmount = voucher.getDiscountAmount();

                if (discountAmount.compareTo(totalAmount) > 0) {
                    // Nếu voucher giảm nhiều hơn cả số tiền khách phải trả,
                    // thì lượng tiền được giảm tối đa chỉ bằng đúng số tiền khách nợ.
                    discountAmount = totalAmount;
                }

                finalAmount = totalAmount.subtract(discountAmount);
                if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                    finalAmount = BigDecimal.ZERO; // Không để âm tiền
                }
                summaryResult.put("appliedVoucher", voucher);
            }
        }

        summaryResult.put("totalAmount", totalAmount);
        summaryResult.put("discountAmount", discountAmount);
        summaryResult.put("finalAmount", finalAmount);
        summaryResult.put("voucherError", voucherError);

        return summaryResult;
    }

    public Map<String, Object> getShowtimeDetails(int showtimeId) {
        return showtimeDao.getShowtimeDetails(showtimeId);
    }
}