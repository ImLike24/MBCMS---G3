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
import java.util.ArrayList;
import java.util.List;

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

            // Trường hợp TEST: movieId = 999 -> tạo dữ liệu giả, không cần DB
            if (movieId == 999) {
                Movie fakeMovie = new Movie();
                fakeMovie.setMovieId(999);
                fakeMovie.setTitle("Phim Thử Nghiệm");
                fakeMovie.setDescription("Phim mẫu dùng để test luồng chọn suất chiếu.");
                fakeMovie.setDuration(120);
                fakeMovie.setAgeRating("T13");
                fakeMovie.setDirector("Demo Director");
                fakeMovie.setPosterUrl("https://via.placeholder.com/400x300?text=Sample+Movie");

                // Danh sách thể loại thử nghiệm
                List<String> genres = new ArrayList<>();
                genres.add("Hành động");
                genres.add("Viễn tưởng");
                fakeMovie.setGenres(genres);

                // Không có suất chiếu thật -> để showtimes rỗng để JSP hiển thị các giờ test
                List<Showtime> showtimes = new ArrayList<>();

                // Tạo danh sách 7 ngày (hôm nay + 6 ngày tới)
                List<LocalDate> dateList = new ArrayList<>();
                for (int i = 0; i < 7; i++) {
                    dateList.add(today.plusDays(i));
                }

                request.setAttribute("movie", fakeMovie);
                request.setAttribute("showtimes", showtimes);
                request.setAttribute("selectedDate", selectedDate);
                request.setAttribute("today", today);
                request.setAttribute("dateList", dateList);

                request.getRequestDispatcher("/pages/customer/booking-showtimes.jsp")
                        .forward(request, response);
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

            // Tạo danh sách các ngày (ví dụ: hôm nay + 6 ngày tới) để user chọn nhanh
            List<LocalDate> dateList = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                dateList.add(today.plusDays(i));
            }

            // Gửi dữ liệu sang JSP
            request.setAttribute("movie", movie);
            request.setAttribute("showtimes", showtimes);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("today", today);
            request.setAttribute("dateList", dateList);

            request.getRequestDispatcher("/pages/customer/booking-showtimes.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            // movieId không hợp lệ
            response.sendRedirect(request.getContextPath() + "/movies");
        } catch (Exception e) {
            // Lỗi bất ngờ khác
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải danh sách suất chiếu.");
            request.getRequestDispatcher("/pages/customer/booking-showtimes.jsp")
                    .forward(request, response);
        }
    }
}