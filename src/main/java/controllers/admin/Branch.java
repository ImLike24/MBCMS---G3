package controllers.admin;

import models.CinemaBranch;
import models.User;
import repositories.Users;
import services.BranchService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BranchController", urlPatterns = {"/admin/branches"})
public class Branch extends HttpServlet {

    private final BranchService branchService = new BranchService();
    private final Users usersDao = new Users();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "create":
                    showCreateForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteBranch(request, response);
                    break;
                default:
                    listBranches(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "create":
                    insertBranch(request, response);
                    break;
                case "update":
                    updateBranch(request, response);
                    break;
                default:
                    response.sendRedirect("branches");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            listBranches(request, response);
        }
    }

    // --- Helper Methods ---

    private void listBranches(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy tham số tìm kiếm & lọc
        String search = request.getParameter("search");
        String statusStr = request.getParameter("status");

        // Xử lý status (null: all, true: active, false: inactive)
        Boolean isActive = null;
        if (statusStr != null && !statusStr.isEmpty()) {
            isActive = Boolean.parseBoolean(statusStr);
        }

        // 2. Xử lý phân trang
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Integer.parseInt(pageStr);
        } catch (Exception e) { page = 1; }

        int pageSize = 5;

        // 3. Gọi Service
        List<CinemaBranch> list = branchService.getBranches(search, isActive, page, pageSize);
        int totalPages = branchService.getTotalPages(search, isActive, pageSize);

        // 4. Gửi dữ liệu sang JSP
        request.setAttribute("branches", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        // Quan trọng: Gửi lại từ khóa để giữ trên thanh tìm kiếm
        request.setAttribute("currentSearch", search);
        request.setAttribute("currentStatus", statusStr);

        request.getRequestDispatcher("/pages/admin/branch/list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy danh sách manager để đổ vào dropdown
        List<User> managers = usersDao.findUsersByRoleName("BRANCH_MANAGER");
        request.setAttribute("managers", managers);

        request.getRequestDispatcher("/pages/admin/branch/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        CinemaBranch existingBranch = branchService.getBranchById(id);

        // Lấy danh sách manager
        List<User> managers = usersDao.findUsersByRoleName("BRANCH_MANAGER");
        request.setAttribute("managers", managers);

        request.setAttribute("branch", existingBranch);
        request.getRequestDispatcher("/pages/admin/branch/form.jsp").forward(request, response);
    }

    private void deleteBranch(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            branchService.deleteBranch(id);
            response.sendRedirect("branches?message=deleted");
        } catch (Exception e) {
            response.sendRedirect("branches?error=delete_failed");
        }
    }

    private void insertBranch(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            CinemaBranch newBranch = extractBranchFromRequest(request);
            branchService.createBranch(newBranch);
            response.sendRedirect("branches?message=created");
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            // Giữ lại dữ liệu cũ khi lỗi
            request.setAttribute("branch", extractBranchFromRequest(request));
            showCreateForm(request, response);
        }
    }

    private void updateBranch(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            CinemaBranch branch = extractBranchFromRequest(request);
            int id = Integer.parseInt(request.getParameter("branchId"));
            branch.setBranchId(id);

            branchService.updateBranch(branch);
            response.sendRedirect("branches?message=updated");
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("branch", extractBranchFromRequest(request));
            request.getRequestDispatcher("/pages/admin/branch/form.jsp").forward(request, response);
        }
    }

    // Hàm phụ để lấy dữ liệu từ form map vào object
    private CinemaBranch extractBranchFromRequest(HttpServletRequest request) {
        CinemaBranch b = new CinemaBranch();
        b.setBranchName(request.getParameter("branchName"));
        b.setAddress(request.getParameter("address"));
        b.setPhone(request.getParameter("phone"));
        b.setEmail(request.getParameter("email"));

        // Xử lý Manager ID (nếu input rỗng thì là null)
        String mgrIdStr = request.getParameter("managerId");
        if (mgrIdStr != null && !mgrIdStr.isEmpty()) {
            b.setManagerId(Integer.parseInt(mgrIdStr));
        } else {
            b.setManagerId(null);
        }

        // Checkbox: nếu tick -> gửi "on", không tick -> null
        b.setActive(request.getParameter("isActive") != null);
        return b;
    }
}