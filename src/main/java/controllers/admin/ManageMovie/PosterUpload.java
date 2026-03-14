package controllers.admin.movies;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.User;
import services.MovieService;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;

@WebServlet(name = "PosterUpload", urlPatterns = {"/admin/movies/poster/upload"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1MB
    maxFileSize      = 1024 * 1024 * 10,   // 10MB
    maxRequestSize   = 1024 * 1024 * 15    // 15MB
)
public class PosterUpload extends HttpServlet {

    private final MovieService movieService = new MovieService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 2. Lấy movieId (nếu có – ở mode edit)
        String movieIdStr = request.getParameter("movieId");
        Integer movieId = null;
        if (movieIdStr != null && !movieIdStr.trim().isEmpty()) {
            try {
                movieId = Integer.parseInt(movieIdStr);
            } catch (NumberFormatException e) {
                out.print("{\"success\":false, \"message\":\"movieId không hợp lệ\"}");
                out.flush();
                return;
            }
        }

        // 3. Lấy file từ request
        Part filePart = request.getPart("posterFile");
        if (filePart == null || filePart.getSize() == 0) {
            out.print("{\"success\":false, \"message\":\"Không có file được chọn\"}");
            out.flush();
            return;
        }

        // 4. Đọc file thành byte[]
        try (InputStream is = filePart.getInputStream()) {
            byte[] bytes = is.readAllBytes();
            String fileName = filePart.getSubmittedFileName();

            // 5. Upload lên Cloudinary và lấy URL
            String newPosterUrl = movieService.uploadPoster(bytes, fileName, movieId);

            if (newPosterUrl != null) {
                // Trả về JSON cho AJAX
                out.print("{\"success\":true, \"posterUrl\":\"" + newPosterUrl + "\"}");
            } else {
                out.print("{\"success\":false, \"message\":\"Upload thất bại, vui lòng thử lại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false, \"message\":\"Lỗi server: " + e.getMessage() + "\"}");
        } finally {
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Chỉ hỗ trợ POST");
    }
}