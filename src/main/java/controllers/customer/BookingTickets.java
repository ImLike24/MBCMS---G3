package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = {"/customer/booking-tickets"})
public class BookingTickets extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Đảm bảo user đã đăng nhập trước khi đặt vé
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy showtimeId từ query string
        String showtimeIdParam = request.getParameter("showtimeId");
        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            // Không có showtimeId -> quay lại danh sách phim
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId;
        try {
            showtimeId = Integer.parseInt(showtimeIdParam);
        } catch (NumberFormatException e) {
            // Giá trị không hợp lệ -> quay lại danh sách phim
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        // ======== DỮ LIỆU THỬ NGHIỆM (KHÔNG CẦN DB) ========
        // Với các showtimeId test (1..5) từ trang booking-showtimes.jsp,
        // ta tạo sẵn thông tin phim, suất chiếu và sơ đồ ghế.

        // Thông tin phim demo
        String movieTitle = "Phim Thử Nghiệm";

        // Ngày chiếu demo: hôm nay
        LocalDate showDate = LocalDate.now();

        // Giờ chiếu demo tùy theo showtimeId
        LocalTime startTime;
        switch (showtimeId) {
            case 1 -> startTime = LocalTime.of(9, 10);
            case 2 -> startTime = LocalTime.of(11, 0);
            case 3 -> startTime = LocalTime.of(13, 0);
            case 4 -> startTime = LocalTime.of(15, 30);
            case 5 -> startTime = LocalTime.of(19, 45);
            default -> startTime = LocalTime.of(20, 0);
        }

        // Phòng chiếu demo
        String roomName = "Screening Room A";

        // Tạo sơ đồ ghế demo: 5 hàng (A-E), mỗi hàng 10 ghế (1-10)
        List<String> seatRows = new ArrayList<>();
        seatRows.add("A");
        seatRows.add("B");
        seatRows.add("C");
        seatRows.add("D");
        seatRows.add("E");

        int seatsPerRow = 10;

        // Đánh dấu một vài ghế đã được đặt (demo)
        // key: mã ghế (ví dụ: "B5"), value: true = đã đặt
        Map<String, Boolean> reservedSeats = new HashMap<>();
        reservedSeats.put("B5", true);
        reservedSeats.put("C7", true);
        reservedSeats.put("D2", true);

        // Đặt các biến vào request để JSP render
        request.setAttribute("movieTitle", movieTitle);
        request.setAttribute("showDate", showDate);
        request.setAttribute("startTime", startTime);
        request.setAttribute("roomName", roomName);
        request.setAttribute("seatRows", seatRows);
        request.setAttribute("seatsPerRow", seatsPerRow);
        request.setAttribute("reservedSeats", reservedSeats);
        request.setAttribute("showtimeId", showtimeId);

        // Chuyển tới trang chọn ghế
        request.getRequestDispatcher("/pages/customer/booking-tickets.jsp")
                .forward(request, response);
    }

}
