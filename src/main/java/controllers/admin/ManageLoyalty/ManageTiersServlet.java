package controllers.admin.ManageLoyalty;

import models.MembershipTier;
import repositories.MembershipTiers;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageTiersServlet", urlPatterns = { "/admin/manage-tiers" })
public class ManageTiersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        MembershipTiers dao = new MembershipTiers();
        List<MembershipTier> tiers = dao.getAllTiers();
        request.setAttribute("tiers", tiers);
        request.getRequestDispatcher("/pages/admin/manage-loyalty/manage-tiers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MembershipTiers dao = new MembershipTiers();

        try {
            int id = Integer.parseInt(request.getParameter("tierId"));
            if (dao.delete(id)) {
                request.getSession().setAttribute("success", "Xóa hạng thành viên thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Xóa thất bại. Hạng có thể đang được người dùng sử dụng.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
    }
}
