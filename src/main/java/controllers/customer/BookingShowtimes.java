package controllers.customer;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Movie;
import models.Showtime;
import repositories.Movies;
import repositories.Showtimes;

@WebServlet(name = "ShowtimesListForChosenMovie", urlPatterns = {"/customer/booking-showtimes"})
public class BookingShowtimes extends HttpServlet {

    private final services.BookingService bookingService = new services.BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Đảm bảo user đã đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String movieIdParam = request.getParameter("movieId");
        String dateParam = request.getParameter("date");

        if (movieIdParam == null || movieIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        try {
            // 2. Giao toàn bộ việc nặng nhọc cho Service
            Map<String, Object> pageData = bookingService.getShowtimesPageData(movieIdParam, dateParam);

            // 3. Lấy kết quả từ Service set vào Request để View hiển thị
            request.setAttribute("movie", pageData.get("movie"));
            request.setAttribute("showtimes", pageData.get("showtimes"));
            request.setAttribute("availableSeatsMap", pageData.get("availableSeatsMap"));
            request.setAttribute("totalSeatsMap", pageData.get("totalSeatsMap"));
            request.setAttribute("selectedDate", pageData.get("selectedDate"));
            request.setAttribute("today", pageData.get("today"));
            request.setAttribute("dateList", pageData.get("dateList"));

            request.getRequestDispatcher("/pages/customer/booking-showtimes.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/movies?error=load");
        }
    }
}