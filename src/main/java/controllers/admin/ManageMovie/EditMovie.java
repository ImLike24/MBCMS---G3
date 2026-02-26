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
import models.Genre;

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

        // Load danh sách tên thể loại của phim để checked checkbox
        List<Genre> movieGenres = genreService.getGenresByMovieId(id);

        request.setAttribute("movie", movie);
        request.setAttribute("movieGenres", movieGenres);
        request.setAttribute("allGenres", genreService.getAllActiveGenres());
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        Integer id = parseId(request.getParameter("id"));
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/admin/movies?error=ID không hợp lệ");
            return;
        }

        Movie movie = readMovieFromRequest(request);
        movie.setMovieId(id);
        List<Integer> genreIds = readGenreIds(request);

        // Validation cơ bản
        StringBuilder errors = new StringBuilder();
        if (movie.getTitle() == null || movie.getTitle().trim().isEmpty()) {
            errors.append("Tên phim không được để trống. ");
        }
        if (movie.getDuration() <= 0) {
            errors.append("Thời lượng phải lớn hơn 0 phút. ");
        }
        if (movie.getRating() < 0 || movie.getRating() > 10) {
            errors.append("Đánh giá phải từ 0.0 đến 10.0. ");
        }

        if (errors.length() > 0) {
            request.setAttribute("errorMessage", errors.toString());
            request.setAttribute("movie", movie);
            request.setAttribute("movieGenres", genreService.getGenresByMovieId(id));
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp").forward(request, response);
            return;
        }

        try {
            movieService.updateMovie(movie, genreIds);
            response.sendRedirect(request.getContextPath() + "/admin/movies?message=Cập nhật phim thành công");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Cập nhật thất bại: " + e.getMessage());
            request.setAttribute("movie", movie);
            request.setAttribute("movieGenres", genreService.getGenresByMovieId(id));
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp").forward(request, response);
        }
    }

    // Helpers (giữ nguyên như code cũ của bạn)
    private Integer parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return null;
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
            } catch (Exception ignored) {}
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
                } catch (NumberFormatException ignored) {}
            }
        }
        return genreIds;
    }

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