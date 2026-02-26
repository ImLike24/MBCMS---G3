package controllers;

import models.CinemaBranch;
import models.Movie;
import repositories.CinemaBranches;
import repositories.Showtimes;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShowtimeList", urlPatterns = { "/showtimes" })
public class ShowtimesServlet extends HttpServlet {

    private CinemaBranches cinemaBranches = new CinemaBranches();
    private Showtimes showtimes = new Showtimes();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            request.getRequestDispatcher("/pages/showtimes.jsp").forward(request, response);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if ("get_branches".equals(action)) {
                // Public: trả về toàn bộ chi nhánh đang hoạt động để customer chọn
                List<CinemaBranch> branches = cinemaBranches.getActiveBranches();

                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < branches.size(); i++) {
                    CinemaBranch b = branches.get(i);
                    json.append("{");
                    json.append("\"branchId\":").append(b.getBranchId()).append(",");
                    json.append("\"branchName\":\"").append(b.getBranchName().replace("\"", "\\\"")).append("\"");
                    json.append("}");
                    if (i < branches.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("]");
                out.print(json.toString());
            } else if ("get_schedule".equals(action)) {
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
                    out.print("Invalid parameters");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
