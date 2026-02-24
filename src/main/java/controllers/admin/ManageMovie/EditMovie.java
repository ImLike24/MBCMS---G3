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

@WebServlet("/admin/movies/edit")
public class EditMovie extends HttpServlet {

    private final MovieService movieService = new MovieService();
    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        Integer id = parseId(idStr);

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/movies?error=ID không hợp lệ");
            return;
        }

        Movie movie = movieService.getMovieById(id);
        if (movie == null) {
            response.sendRedirect(request.getContextPath() + "/admin/movies?error=Không tìm thấy phim");
            return;
        }

        request.setAttribute("movie", movie);
        request.setAttribute("movieGenres", genreService.getGenresByMovieId(id));
        request.setAttribute("allGenres", genreService.getAllActiveGenres());
        request.setAttribute("mode", "edit");

        request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        Integer id = parseId(idStr);

        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/movies?error=ID không hợp lệ");
            return;
        }

        Movie movie = readMovieFromRequest(request);
        movie.setMovieId(id);

        List<Integer> genreIds = readGenreIds(request);

        try {
            movieService.updateMovie(movie, genreIds);
            response.sendRedirect(request.getContextPath() + "/admin/movies?message=Cập nhật phim thành công");
        } catch (Exception e) {
            // Nếu có lỗi (ví dụ: database error), có thể forward lại form với thông báo lỗi
            request.setAttribute("errorMessage", "Cập nhật thất bại: " + e.getMessage());
            request.setAttribute("movie", movie);
            request.setAttribute("movieGenres", genreService.getGenresByMovieId(id));
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp").forward(request, response);
        }
    }

    private Integer parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Movie readMovieFromRequest(HttpServletRequest req) {
        Movie m = new Movie();

        m.setTitle(getParameterSafe(req, "title"));
        m.setDescription(getParameterSafe(req, "description"));
        m.setDuration(parseIntSafe(req.getParameter("duration"), 120));
        m.setRating(parseDoubleSafe(req.getParameter("rating"), 0.0));
        m.setAgeRating(getParameterSafe(req, "ageRating"));
        m.setDirector(getParameterSafe(req, "director"));
        m.setCast(getParameterSafe(req, "cast"));
        m.setPosterUrl(getParameterSafe(req, "posterUrl"));
        m.setActive("on".equals(req.getParameter("active")));

        String releaseDateStr = req.getParameter("releaseDate");
        if (releaseDateStr != null && !releaseDateStr.trim().isEmpty()) {
            try {
                m.setReleaseDate(LocalDate.parse(releaseDateStr));
            } catch (Exception ignored) {
                // giữ nguyên releaseDate cũ nếu parse lỗi
            }
        }

        return m;
    }

    private List<Integer> readGenreIds(HttpServletRequest req) {
        String[] genreIdsRaw = req.getParameterValues("genreIds");
        List<Integer> genreIds = new ArrayList<>();
        if (genreIdsRaw != null) {
            for (String gid : genreIdsRaw) {
                try {
                    genreIds.add(Integer.parseInt(gid.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return genreIds;
    }

    // Helper nhỏ để tránh NullPointerException khi lấy parameter
    private String getParameterSafe(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value != null ? value.trim() : null;
    }

    private int parseIntSafe(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private double parseDoubleSafe(String value, double defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}