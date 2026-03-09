package controllers.admin.ManageLoyalty;

import models.MembershipTier;
import repositories.MembershipTiers;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "EditTierServlet", urlPatterns = { "/admin/edit-tier" })
public class EditTierServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            MembershipTiers dao = new MembershipTiers();
            MembershipTier tier = dao.getTierById(id);

            if (tier == null) {
                request.getSession().setAttribute("error", "Không tìm thấy hạng thành viên.");
                response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
                return;
            }

            request.setAttribute("tier", tier);
            request.getRequestDispatcher("/pages/admin/manage-loyalty/edit-tier.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MembershipTiers dao = new MembershipTiers();

        try {
            int id = Integer.parseInt(request.getParameter("tierId"));
            MembershipTier tier = new MembershipTier();
            tier.setTierId(id);
            tier.setTierName(request.getParameter("tierName"));
            tier.setMinPointsRequired(Integer.parseInt(request.getParameter("minPoints")));
            tier.setPointMultiplier(new BigDecimal(request.getParameter("multiplier")));

            if (dao.update(tier)) {
                request.getSession().setAttribute("success", "Cập nhật hạng thành viên thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Cập nhật thất bại.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
    }
}
