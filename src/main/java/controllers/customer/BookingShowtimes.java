package controllers.customer;

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

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ShowtimesListForChosenMovie", urlPatterns = {"/customer/booking-showtimes"})
public class BookingShowtimes extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đảm bảo user đã đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy movieId và ngày được chọn
        String movieIdParam = request.getParameter("movieId");
        String dateParam = request.getParameter("date");

        if (movieIdParam == null || movieIdParam.isEmpty()) {
            // Không có movieId thì quay lại danh sách phim
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        try {
            int movieId = Integer.parseInt(movieIdParam);
            LocalDate today = LocalDate.now();
            LocalDate selectedDate = (dateParam != null && !dateParam.isEmpty())
                    ? LocalDate.parse(dateParam)
                    : today;

            // movieId không hợp lệ hoặc phim thử nghiệm -> quay lại danh sách phim
            if (movieId <= 0 || movieId == 999) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            Movies moviesRepo = new Movies();
            Showtimes showtimesRepo = new Showtimes();

            // Lấy thông tin phim
            Movie movie = moviesRepo.getMovieById(movieId);
            if (movie == null) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            // Lấy danh sách suất chiếu theo ngày đã chọn
            List<Showtime> showtimes = showtimesRepo.getShowtimesForMovieOnDate(movieId, selectedDate);

            // Lọc bỏ suất chiếu đã qua thời gian (server-side, không dùng JavaScript)
            LocalDateTime now = LocalDateTime.now();
            showtimes = showtimes.stream()
                    .filter(st -> {
                        if (st.getShowDate() == null || st.getStartTime() == null) return true;
                        LocalDateTime start = LocalDateTime.of(st.getShowDate(), st.getStartTime());
                        return start.isAfter(now);
                    })
                    .toList();

            // Giống CounterBooking: tính số ghế còn lại / tổng ghế cho từng suất chiếu
            Map<Integer, Integer> availableSeatsMap = new HashMap<>();
            Map<Integer, Integer> totalSeatsMap = new HashMap<>();
            for (Showtime st : showtimes) {
                int stId = st.getShowtimeId();
                int available = showtimesRepo.countAvailableSeats(stId);
                availableSeatsMap.put(stId, available);

                Map<String, Object> details = showtimesRepo.getShowtimeDetails(stId);
                if (details.containsKey("totalSeats")) {
                    totalSeatsMap.put(stId, (Integer) details.get("totalSeats"));
                }
            }

            // Tạo danh sách các ngày (ví dụ: hôm nay + 6 ngày tới) để user chọn nhanh
            List<LocalDate> dateList = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                dateList.add(today.plusDays(i));
            }

            // Gửi dữ liệu sang JSP
            request.setAttribute("movie", movie);
            request.setAttribute("showtimes", showtimes);
            request.setAttribute("availableSeatsMap", availableSeatsMap);
            request.setAttribute("totalSeatsMap", totalSeatsMap);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", today);
            request.setAttribute("dateList", dateList);

            request.getRequestDispatcher("/pages/customer/booking-showtimes.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/movies");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/movies?error=load");
        }
    }
}