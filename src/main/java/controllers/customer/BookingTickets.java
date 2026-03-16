package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

import models.Showtime;
import repositories.SeatTypeSurcharges;
import repositories.Showtimes;
import services.TicketPriceService;
import java.math.BigDecimal;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = { "/customer/booking-tickets" })
public class BookingTickets extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đảm bảo user đã đăng nhập trước khi đặt vé
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy showtimeId từ query string
        String showtimeIdParam = request.getParameter("showtimeId");
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        Showtimes showtimesRepo = null;
        try {
            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(showtimeId);
            int availableSeats = showtimesRepo.countAvailableSeats(showtimeId);

            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("seatsWithStatus", seatsWithStatus);
            request.setAttribute("availableSeats", availableSeats);
            request.setAttribute("showtimeId", showtimeId);

            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            request.setAttribute("showtime", showtime);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("moviePosterUrl", showtimeDetails.get("moviePosterUrl"));
            request.setAttribute("roomName", showtimeDetails.get("roomName"));
            request.setAttribute("totalSeats", showtimeDetails.get("totalSeats"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));

            // Lấy tỉ lệ phụ phí từng loại ghế cho chi nhánh
            Integer branchId = (Integer) showtimeDetails.get("branchId");
            if (branchId != null) {
                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
                var surchargeList = surchargesRepo.getSurchargesByBranch(branchId);
                request.setAttribute("surchargeList", surchargeList);
                surchargesRepo.closeConnection();
            }

            if (showtime != null) {
                if (showtime.getStartTime() != null) {
                    request.setAttribute("formattedStartTime",
                            showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
                if (showtime.getShowDate() != null) {
                    request.setAttribute("formattedShowDate",
                            showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

                // TÍNH TOÁN GIÁ VÉ LINH HOẠT THEO CẤU HÌNH MANAGER
                repositories.TicketPrices ticketPricesDao = new repositories.TicketPrices();
                BigDecimal adultPriceBD = null;
                BigDecimal childPriceBD = null;

                if (branchId != null && showtime.getShowDate() != null && showtime.getStartTime() != null) {
                    // Xác định Loại ngày (WEEKDAY / WEEKEND)
                    java.time.DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
                    String dayType = (dayOfWeek == java.time.DayOfWeek.SATURDAY || dayOfWeek == java.time.DayOfWeek.SUNDAY)
                            ? "WEEKEND" : "WEEKDAY";

                    // Xác định Khung giờ (MORNING, AFTERNOON, EVENING, NIGHT)
                    int hour = showtime.getStartTime().getHour();
                    String timeSlot;
                    if (hour >= 6 && hour < 12) timeSlot = "MORNING";
                    else if (hour >= 12 && hour < 17) timeSlot = "AFTERNOON";
                    else if (hour >= 17 && hour < 22) timeSlot = "EVENING";
                    else timeSlot = "NIGHT";

                    // Query Database lấy giá chuẩn
                    adultPriceBD = ticketPricesDao.getTicketPrice(branchId, "ADULT", dayType, timeSlot, showtime.getShowDate());
                    childPriceBD = ticketPricesDao.getTicketPrice(branchId, "CHILD", dayType, timeSlot, showtime.getShowDate());
                }

                // Trả dữ liệu sang Frontend (JSP) — dùng basePrice của suất chiếu khi chưa cấu hình giá ADULT/CHILD
                double fallbackPrice = (showtime.getBasePrice() != null) ? showtime.getBasePrice().doubleValue() : 0.0;
                double adultPrice = (adultPriceBD != null) ? adultPriceBD.doubleValue() : fallbackPrice;
                double childPrice = (childPriceBD != null) ? childPriceBD.doubleValue() : fallbackPrice;

                request.setAttribute("adultPrice", adultPrice);
                request.setAttribute("childPrice", childPrice);
                request.setAttribute("basePrice", adultPrice);
            } else {
                request.setAttribute("basePrice", 0.0);
            }

            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải sơ đồ ghế.");
            request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                    .forward(request, response);
        } finally {
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}
