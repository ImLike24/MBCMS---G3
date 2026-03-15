package controllers.guest;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.CinemaBranch;
import models.Movie;
import repositories.CinemaBranches;
import repositories.Showtimes;

@WebServlet(name = "ShowtimeList", urlPatterns = { "/showtimes" })
public class ShowtimesServlet extends HttpServlet {

    private CinemaBranches cinemaBranches = new CinemaBranches();
    private Showtimes showtimes = new Showtimes();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getParameter("branchId") == null || request.getParameter("date") == null) {
            List<Map<String, String>> dates = new ArrayList<>();
            LocalDate today = LocalDate.now();
            String[] day = { "Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy" };

            for (int i = 0; i < 7; i++) {
                LocalDate date = today.plusDays(i);
                Map<String, String> dateMap = new HashMap<>();

                String dayName;
                if (i == 0) {
                    dayName = "Hôm nay";
                } else if (i == 1) {
                    dayName = "Ngày mai";
                } else {
                    int dayIndex = date.getDayOfWeek().getValue() % 7;
                    dayName = day[dayIndex];
                }

                String dayStr = String.format("%02d/%02d", date.getDayOfMonth(), date.getMonthValue());
                String fullDate = date.toString();

                dateMap.put("dayName", dayName);
                dateMap.put("dayStr", dayStr);
                dateMap.put("fullDate", fullDate);
                dates.add(dateMap);
            }
            request.setAttribute("dates", dates);

            List<CinemaBranch> branches = cinemaBranches.getActiveBranches();
            request.setAttribute("branches", branches);

            request.getRequestDispatcher("/pages/showtimes.jsp").forward(request, response);
            return;
        }

        try {
            response.setContentType("text/html");
            response.setCharacterEncoding("UTF-8");
            try {
                int branchId = Integer.parseInt(request.getParameter("branchId"));
                String dateStr = request.getParameter("date");
                LocalDate date = LocalDate.parse(dateStr);

                List<Movie> movies = showtimes.getMoviesWithShowtimes(branchId, date);
                request.setAttribute("movies", movies);
                request.getRequestDispatcher("/components/fragments/showtime_list.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
