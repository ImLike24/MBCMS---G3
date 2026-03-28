package controllers.admin.ManageGenres;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Genre;
import services.GenreService;
import services.UserService;

import java.io.IOException;
import java.util.List;
import config.DBContext;
import models.User;
import models.Role;

@WebServlet("/admin/manage-genres")
public class ListGenres extends HttpServlet {

    private final GenreService genreService = new GenreService();
    private static final int DEFAULT_PAGE_SIZE = 10;
    private final UserService userService = new UserService();


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Role userRole = userService.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Xử lý các route con: /add, /edit, /detail
        if (pathInfo != null && !pathInfo.equals("/") && !pathInfo.equals("")) {
            if (pathInfo.equals("/add")) {
                request.getRequestDispatcher("/admin/genres/add.jsp").forward(request, response);
                return;
            }
            if (pathInfo.equals("/edit")) {
                String idStr = request.getParameter("id");
                try {
                    int id = Integer.parseInt(idStr);
                    Genre genre = genreService.getGenreById(id);
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
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Phân trang cho danh sách chính
        String pageStr = request.getParameter("page");
        String sizeStr = request.getParameter("size");

        int currentPage = 0;
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                currentPage = Integer.parseInt(pageStr);
                if (currentPage < 0) currentPage = 0;
            }
        } catch (NumberFormatException ignored) {}

        int pageSize = DEFAULT_PAGE_SIZE;
        try {
            if (sizeStr != null && !sizeStr.isEmpty()) {
                pageSize = Integer.parseInt(sizeStr);
                if (pageSize <= 0) pageSize = DEFAULT_PAGE_SIZE;
            }
        } catch (NumberFormatException ignored) {}

        List<Genre> allGenres = genreService.getAllGenres();
        int totalItems = allGenres.size();

        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;

        if (currentPage >= totalPages) {
            currentPage = totalPages - 1;
        }

        int start = currentPage * pageSize;
        int end = Math.min(start + pageSize, totalItems);

        List<Genre> pagedGenres = allGenres.subList(start, end);

        request.setAttribute("genres", pagedGenres);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        request.getRequestDispatcher("/pages/admin/manage-genres/manage-genres.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

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

            boolean success = genreService.addGenre(newGenre);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/genres?success=add");
            } else {
                request.setAttribute("error", "Thêm thể loại thất bại");
                request.getRequestDispatcher("/admin/genres/add.jsp").forward(request, response);
            }
            return;
        }

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

                boolean success = genreService.updateGenre(genre);
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

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            try {
                int id = Integer.parseInt(idStr);
                boolean success = genreService.deleteGenre(id);
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
        doPost(req, resp);
    }
}