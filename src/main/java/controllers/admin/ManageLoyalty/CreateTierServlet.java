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

@WebServlet(name = "CreateTierServlet", urlPatterns = { "/admin/create-tier" })
public class CreateTierServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pages/admin/create-tier.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MembershipTiers dao = new MembershipTiers();

        try {
            MembershipTier tier = new MembershipTier();
            tier.setTierName(request.getParameter("tierName"));
            tier.setMinPointsRequired(Integer.parseInt(request.getParameter("minPoints")));
            tier.setPointMultiplier(new BigDecimal(request.getParameter("multiplier")));

            if (dao.insert(tier)) {
                request.getSession().setAttribute("success", "Thêm hạng thành viên thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Không thể thêm hạng.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
    }
}
