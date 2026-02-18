package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Genre;
import services.GenreService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/manage-genres")
public class ManageGenres extends HttpServlet {

    private final GenreService genreService = new GenreService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String servletPath = request.getServletPath();

        // Trường hợp: /admin/genres (danh sách)
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("")) {

            List<Genre> genres = genreService.getAllGenres();

            request.setAttribute("genres", genres);
            request.getRequestDispatcher("/pages/admin/manage-genres/manage-genres.jsp")
                   .forward(request, response);
            return;
        }

        // Trường hợp: /admin/genres/add → form thêm mới
        if (pathInfo.equals("/add")) {
            request.getRequestDispatcher("/admin/genres/add.jsp").forward(request, response);
            return;
        }

        // Trường hợp: /admin/genres/edit?id=5 → form sửa
        if (pathInfo.equals("/edit")) {
            String idStr = request.getParameter("id");
            try {
                int id = Integer.parseInt(idStr);
                Genre genre = genreService.getGenreById(id); // cần thêm method này
                if (genre != null) {
                    request.setAttribute("genre", genre);
                    request.getRequestDispatcher("/admin/genres/edit.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thể loại");
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
            }
            return;
        }

        // Trường hợp: /admin/genres/detail?id=5 → xem chi tiết (tùy chọn)
        if (pathInfo.equals("/detail")) {
            String idStr = request.getParameter("id");
            try {
                int id = Integer.parseInt(idStr);
                Genre genre = genreService.getGenreById(id);
                if (genre != null) {
                    request.setAttribute("genre", genre);
                    request.getRequestDispatcher("/admin/genres/detail.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        // Không khớp route nào
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Thêm mới thể loại
        if ("add".equals(action)) {
            String genreName = request.getParameter("genreName");
            String description = request.getParameter("description");
            String isActiveStr = request.getParameter("isActive");

            if (genreName == null || genreName.trim().isEmpty()) {
                request.setAttribute("error", "Tên thể loại không được để trống");
                request.getRequestDispatcher("/admin/genres/add.jsp").forward(request, response);
                return;
            }

            Genre newGenre = new Genre();
            newGenre.setGenreName(genreName.trim());
            newGenre.setDescription(description != null ? description.trim() : null);
            newGenre.setActive(isActiveStr != null && isActiveStr.equals("on"));

            boolean success = genreService.addGenre(newGenre); // cần implement method này

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/genres?success=add");
            } else {
                request.setAttribute("error", "Thêm thể loại thất bại");
                request.getRequestDispatcher("/admin/genres/add.jsp").forward(request, response);
            }
            return;
        }

        // Cập nhật thể loại
        if ("update".equals(action)) {
            String idStr = request.getParameter("genreId");
            String genreName = request.getParameter("genreName");
            String description = request.getParameter("description");
            String isActiveStr = request.getParameter("isActive");

            try {
                int id = Integer.parseInt(idStr);
                Genre genre = genreService.getGenreById(id);

                if (genre == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                genre.setGenreName(genreName.trim());
                genre.setDescription(description != null ? description.trim() : null);
                genre.setActive(isActiveStr != null && isActiveStr.equals("on"));

                boolean success = genreService.updateGenre(genre); // cần implement

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/genres?success=update");
                } else {
                    request.setAttribute("error", "Cập nhật thất bại");
                    request.setAttribute("genre", genre);
                    request.getRequestDispatcher("/admin/genres/edit.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        // Xóa (soft delete)
        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            try {
                int id = Integer.parseInt(idStr);
                boolean success = genreService.deleteGenre(id); // soft delete hoặc hard delete

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/genres?success=delete");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/genres?error=delete");
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        doGet(request, response);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Có thể xử lý AJAX delete ở đây nếu cần
        doPost(req, resp);
    }
}