package controllers;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repositories.Movies;

@WebServlet("/movies")
public class MovieList extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Movies moviesRepo = new Movies();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        LocalDate toDate = today.plusDays(6);
        List<Movies.DayGroup> dayGroups = moviesRepo.getMoviesWithShowtimesGroupedByDayOfWeek(today, toDate);
        request.setAttribute("dayGroups", dayGroups);
        request.setAttribute("fromDate", today);
        request.setAttribute("toDate", toDate);
        request.setAttribute("fromDateStr", today.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        request.setAttribute("toDateStr", toDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        request.getRequestDispatcher("/pages/movie_list.jsp").forward(request, response);
    }
}
