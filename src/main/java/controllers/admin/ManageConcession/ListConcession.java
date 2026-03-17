package controllers.admin.ManageConcession;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Concession;
import services.ConcessionService;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/concessions")
public class ListConcession extends HttpServlet {

    private final ConcessionService service = new ConcessionService();

    private static final int DEFAULT_PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy tham số phân trang từ request (query string)
        String pageStr = request.getParameter("page");
        String sizeStr = request.getParameter("size");

        // Xử lý số trang hiện tại (default = 0)
        int currentPage = 0;
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                currentPage = Integer.parseInt(pageStr);
                if (currentPage < 0) currentPage = 0;
            }
        } catch (NumberFormatException e) {
            currentPage = 0;
        }

        // Xử lý kích thước trang (default = 10)
        int pageSize = DEFAULT_PAGE_SIZE;
        try {
            if (sizeStr != null && !sizeStr.isEmpty()) {
                pageSize = Integer.parseInt(sizeStr);
                if (pageSize <= 0) pageSize = DEFAULT_PAGE_SIZE;
            }
        } catch (NumberFormatException e) {
            pageSize = DEFAULT_PAGE_SIZE;
        }

        // Lấy toàn bộ danh sách (hoặc tối ưu bằng COUNT + LIMIT sau)
        List<Concession> allConcessions = service.getAllConcessions();
        int totalItems = allConcessions.size();

        // Tính toán phân trang thủ công
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;

        // Giới hạn currentPage không vượt quá totalPages - 1
        if (currentPage >= totalPages) {
            currentPage = totalPages - 1;
        }

        // Cắt danh sách theo trang hiện tại
        int startIndex = currentPage * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalItems);

        List<Concession> concessionsForPage = allConcessions.subList(startIndex, endIndex);

        // Đặt các attribute cần cho JSP

        request.setAttribute("concessions", concessionsForPage);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        // Forward đến JSP
        request.getRequestDispatcher("/pages/admin/manage-concession/manage-concession.jsp")
               .forward(request, response);
    }
}