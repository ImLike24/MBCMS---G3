package controllers.admin.ManageMovie;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Movie;
import services.GenreService;
import services.MovieService;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/movies/add")
public class AddMovie extends HttpServlet {

    private final MovieService movieService = new MovieService();
    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("allGenres", genreService.getAllActiveGenres());
        request.setAttribute("mode", "add");
        request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        Movie movie = readMovieFromRequest(request);
        List<Integer> genreIds = readGenreIds(request);

        // Validation server-side
        StringBuilder errors = new StringBuilder();
        if (movie.getTitle() == null || movie.getTitle().trim().isEmpty()) {
            errors.append("Tên phim không được để trống. ");
        }
        if (movie.getDuration() <= 0) {
            errors.append("Thời lượng phải lớn hơn 0 phút. ");
        }
        if (movie.getRating() < 0 || movie.getRating() > 5) {
            errors.append("Đánh giá phải từ 0.0 đến 5.0. ");
        }
        if (genreIds.isEmpty()) {
            errors.append("Vui lòng chọn ít nhất một thể loại. ");
        }

        if (errors.length() > 0) {
            request.setAttribute("errorMessage", errors.toString());
            request.setAttribute("movie", movie);
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
            request.setAttribute("mode", "add");
            request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp")
                    .forward(request, response);
            return;
        }

        // Gọi service
        String error = movieService.addNewMovie(movie, genreIds);

        if (error == null) {
            response.sendRedirect(request.getContextPath() + "/admin/movies?message=Thêm phim thành công");
        } else {
            request.setAttribute("errorMessage", error);
            request.setAttribute("movie", movie);
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
            request.setAttribute("mode", "add");
            request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp").forward(request, response);
        }
    }

    // Helpers
    private boolean isAdminLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }

    private Movie readMovieFromRequest(HttpServletRequest req) {
        Movie m = new Movie();
        m.setTitle(getTrimmedParam(req, "title"));
        m.setDescription(getTrimmedParam(req, "description"));

        String ratingStr = getTrimmedParam(req, "rating");
        double rating = 0.0;
        if (ratingStr != null && !ratingStr.isEmpty()) {
            try {
                rating = Double.parseDouble(ratingStr);
                rating = Math.max(0.0, Math.min(10.0, rating));
                rating = Math.round(rating * 10.0) / 10.0;
            } catch (NumberFormatException e) {
                rating = 0.0; // nếu nhập chữ hoặc sai định dạng
            }
        }
        m.setRating(rating);

        m.setDuration(parseInt(req.getParameter("duration"), 120));
        m.setAgeRating(getTrimmedParam(req, "ageRating"));
        m.setDirector(getTrimmedParam(req, "director"));
        m.setCast(getTrimmedParam(req, "cast"));
        m.setPosterUrl(getTrimmedParam(req, "posterUrl"));
        m.setActive("on".equals(req.getParameter("active")));

        String releaseStr = req.getParameter("releaseDate");
        if (releaseStr != null && !releaseStr.trim().isEmpty()) {
            try {
                m.setReleaseDate(LocalDate.parse(releaseStr));
            } catch (Exception ignored) {}
        }
        return m;
    }

    private List<Integer> readGenreIds(HttpServletRequest req) {
        String[] ids = req.getParameterValues("genreIds");
        List<Integer> list = new ArrayList<>();
        if (ids != null) {
            for (String id : ids) {
                try {
                    list.add(Integer.parseInt(id.trim()));
                } catch (NumberFormatException ignored) {}
            }
        }
        return list;
    }

    private String getTrimmedParam(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return (value != null) ? value.trim() : null;
    }

    private int parseInt(String s, int defaultVal) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return defaultVal; }
    }
}