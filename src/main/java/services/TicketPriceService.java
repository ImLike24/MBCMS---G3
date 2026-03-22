package services;

import models.TicketPrice;
import repositories.TicketPrices;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;

public class TicketPriceService {

    private final TicketPrices priceDao = new TicketPrices();

    public TicketPrice getPriceById(int priceId) {
        return priceDao.findById(priceId);
    }

    public List<TicketPrice> getPricesWithFilterAndPagination(int branchId, String search, String dayType,
            String status, int page, int pageSize) {
        return priceDao.getPricesWithFilterAndPagination(branchId, search, dayType, status, page, pageSize);
    }

    public int countPricesWithFilter(int branchId, String search, String dayType, String status) {
        return priceDao.countPricesWithFilter(branchId, search, dayType, status);
    }

    // ----------------------------------------------------
    // CÁC HÀM CRUD
    // ----------------------------------------------------

    public void createTicketPrice(TicketPrice p) throws Exception {
        // Chạy hàm Validate tổng hợp
        validateTicketPrice(p, true);

        // Check xung đột cấu hình (Trùng lặp thời gian)
        checkOverlapConfig(p);

        if (!priceDao.insert(p)) {
            throw new Exception("Lỗi hệ thống: Không thể lưu cấu hình giá.");
        }
    }

    public void updateTicketPrice(TicketPrice p) throws Exception {
        TicketPrice oldPrice = priceDao.findById(p.getPriceId());
        if (oldPrice == null) {
            throw new Exception("Lỗi: Không tìm thấy cấu hình giá này.");
        }

        validateTicketPrice(p, false);
        checkOverlapConfig(p);

        if (!priceDao.update(p)) {
            throw new Exception("Lỗi hệ thống: Không thể cập nhật cấu hình giá.");
        }
    }

    public void deactivateTicketPrice(int priceId) throws Exception {
        if (!priceDao.deactivate(priceId)) {
            throw new Exception("Lỗi: Không thể vô hiệu hóa mức giá này.");
        }
    }

    public void deleteTicketPrice(int priceId) throws Exception {
        if (!priceDao.delete(priceId)) {
            throw new Exception("Lỗi: Không thể xóa mức giá này.");
        }
    }

    // ----------------------------------------------------
    // LOGIC VALIDATION
    // ----------------------------------------------------

    private void validateTicketPrice(TicketPrice p, boolean isCreate) throws Exception {
        // Validate Enum
        List<String> validTicketTypes = Arrays.asList("ADULT", "CHILD");
        List<String> validDayTypes = Arrays.asList("WEEKDAY", "WEEKEND", "HOLIDAY");
        List<String> validTimeSlots = Arrays.asList("MORNING", "AFTERNOON", "EVENING", "NIGHT");

        if (!validTicketTypes.contains(p.getTicketType()))
            throw new Exception("Loại khách không hợp lệ.");
        if (!validDayTypes.contains(p.getDayType()))
            throw new Exception("Loại ngày không hợp lệ.");
        if (!validTimeSlots.contains(p.getTimeSlot()))
            throw new Exception("Khung giờ không hợp lệ.");

        // Validate Giá tiền
        if (p.getPrice() == null)
            throw new Exception("Giá vé không được để trống.");

        BigDecimal minPrice = new BigDecimal("10000");
        BigDecimal maxPrice = new BigDecimal("500000");

        if (p.getPrice().compareTo(minPrice) < 0) {
            throw new Exception("Giá vé phải lớn hơn hoặc bằng 10,000 VNĐ.");
        }
        if (p.getPrice().compareTo(maxPrice) > 0) {
            throw new Exception("Giá vé cấu hình quá lớn (Tối đa 500,000 VNĐ). Kiểm tra lại lỗi gõ nhầm.");
        }
        // Kiểm tra bước giá (chia hết cho 1000)
        if (p.getPrice().remainder(new BigDecimal("1000")).compareTo(BigDecimal.ZERO) != 0) {
            throw new Exception("Giá vé phải là bội số của 1,000 VNĐ (VD: 45000, 50000).");
        }

        // Validate Thời gian
        if (p.getEffectiveFrom() == null) {
            throw new Exception("Ngày bắt đầu hiệu lực không được để trống.");
        }

        // Không cho phép tạo mới cấu hình bắt đầu ở quá khứ
        if (isCreate && p.getEffectiveFrom().isBefore(LocalDate.now())) {
            throw new Exception("Ngày áp dụng phải bắt đầu từ hôm nay hoặc tương lai.");
        }

        // Ngày kết thúc phải >= ngày bắt đầu
        if (p.getEffectiveTo() != null && p.getEffectiveTo().isBefore(p.getEffectiveFrom())) {
            throw new Exception("Ngày kết thúc không được nhỏ hơn ngày bắt đầu.");
        }
    }

    // Validate Chống xung đột (Overlap)
    private void checkOverlapConfig(TicketPrice newConfig) throws Exception {
        // Nếu cấu hình đang lưu là INACTIVE thì không cần check xung đột
        if (!newConfig.isActive())
            return;

        List<TicketPrice> existingPrices = priceDao.findByBranchId(newConfig.getBranchId());

        for (TicketPrice existing : existingPrices) {
            // Bỏ qua chính nó (khi đang update)
            if (newConfig.getPriceId() != null && newConfig.getPriceId().equals(existing.getPriceId()))
                continue;

            // Chỉ xét các cấu hình đang Active
            if (!existing.isActive())
                continue;

            // Bị trùng lặp Cùng đối tượng, ngày, giờ
            boolean isSameTarget = existing.getTicketType().equals(newConfig.getTicketType())
                    && existing.getDayType().equals(newConfig.getDayType())
                    && existing.getTimeSlot().equals(newConfig.getTimeSlot());

            if (isSameTarget) {
                // Kiểm tra xem thời gian có đè lên nhau không (Overlap Dates)
                // Công thức 2 đoạn [A, B] và [C, D] giao nhau: (Start1 <= End2) AND (Start2 <=
                // End1)

                LocalDate start1 = newConfig.getEffectiveFrom();
                LocalDate end1 = newConfig.getEffectiveTo() != null ? newConfig.getEffectiveTo() : LocalDate.MAX;

                LocalDate start2 = existing.getEffectiveFrom();
                LocalDate end2 = existing.getEffectiveTo() != null ? existing.getEffectiveTo() : LocalDate.MAX;

                if (!start1.isAfter(end2) && !start2.isAfter(end1)) {
                    throw new Exception("XUNG ĐỘT GIÁ: Đã có mức giá đang hoạt động cho tổ hợp ["
                            + newConfig.getTicketType() + " - " + newConfig.getDayType() + " - "
                            + newConfig.getTimeSlot()
                            + "] trong khoảng thời gian này. Vui lòng vô hiệu hóa giá cũ trước khi tạo giá mới.");
                }
            }
        }
    }

    // ----------------------------------------------------
    // HELPER METHODS FOR SHOWTIME PRICING
    // ----------------------------------------------------

    public String getDayType(LocalDate date) {
        // Simple logic: Saturday and Sunday are WEEKEND, others are WEEKDAY.
        // HOLIDAY logic could be added here if there was a table of holidays.
        DayOfWeek day = date.getDayOfWeek();
        if (day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY) {
            return "WEEKEND";
        }
        return "WEEKDAY";
    }

    public String getTimeSlot(LocalTime time) {
        int hour = time.getHour();
        if (hour >= 0 && hour < 12) {
            return "MORNING";
        } else if (hour >= 12 && hour < 17) {
            return "AFTERNOON";
        } else if (hour >= 17 && hour < 21) {
            return "EVENING";
        } else {
            return "NIGHT";
        }
    }

    public BigDecimal getBasePriceForShowtime(int branchId, LocalDate date, LocalTime time) {
        String dayType = getDayType(date);
        String timeSlot = getTimeSlot(time);

        List<TicketPrice> prices = priceDao.findByBranchId(branchId);
        for (TicketPrice p : prices) {
            if (p.isActive()
                    && "ADULT".equals(p.getTicketType())
                    && p.getDayType().equals(dayType)
                    && p.getTimeSlot().equals(timeSlot)) {

                // Check date constraints
                LocalDate start = p.getEffectiveFrom();
                LocalDate end = p.getEffectiveTo() != null ? p.getEffectiveTo() : LocalDate.MAX;
                if (!date.isBefore(start) && !date.isAfter(end)) {
                    return p.getPrice(); // Returns the valid configured price
                }
            }
        }

        // Fallback standard price if no configuration is found
        return BigDecimal.ZERO;
    }
}