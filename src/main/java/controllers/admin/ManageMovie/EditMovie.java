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

        // Xử lý thông báo từ upload poster (nếu có)
        String success = request.getParameter("success");
        if ("poster_updated".equals(success)) {
            request.setAttribute("message", "Cập nhật poster thành công!");
        }

        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorMessage", "Lỗi upload poster: " + error);
        }

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
            request.setAttribute("errorMessage", "ID phim không hợp lệ");
            forwardWithData(request, response);
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
        if (movie.getRating() < 0 || movie.getRating() > 5) {
            errors.append("Đánh giá phải từ 0.0 đến 5.0. ");
        }

        // Log để debug posterUrl
        System.out.println("Poster URL nhận được khi edit: " + movie.getPosterUrl());

        if (errors.length() > 0) {
            request.setAttribute("errorMessage", errors.toString());
            forwardWithData(request, response);
            return;
        }

        try {
            boolean updated = movieService.updateMovie(movie, genreIds);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/admin/movies?message=success");
            } else {
                request.setAttribute("errorMessage", "Cập nhật phim thất bại (không tìm thấy bản ghi hoặc lỗi DB)");
                forwardWithData(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Cập nhật thất bại: " + e.getMessage());
            forwardWithData(request, response);
        }
    }

    // Helper: forward lại trang với dữ liệu hiện tại khi có lỗi
    private void forwardWithData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer id = parseId(request.getParameter("id"));
        if (id != null) {
            Movie movie = movieService.getMovieById(id);
            List<Genre> movieGenres = genreService.getGenresByMovieId(id);
            request.setAttribute("movie", movie);
            request.setAttribute("movieGenres", movieGenres);
            request.setAttribute("allGenres", genreService.getAllActiveGenres());
        }
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/pages/admin/manage-movie/movie-form.jsp").forward(request, response);
    }

    // Helpers (đã được giữ nguyên và bổ sung)
    private Integer parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(idStr.trim());
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

        // Quan trọng: Đọc posterUrl từ hidden field (đây là nơi nhận giá trị mới từ AJAX upload)
        String posterUrl = getParameterSafe(req, "posterUrl");
        m.setPosterUrl(posterUrl != null && !posterUrl.trim().isEmpty() ? posterUrl : null);

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