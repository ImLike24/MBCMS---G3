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
        request.getRequestDispatcher("/pages/admin/manage-loyalty/create-tier.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MembershipTiers dao = new MembershipTiers();
        MembershipTier tier = new MembershipTier();

        try {
            tier.setTierName(request.getParameter("tierName"));
            
            String minPointsStr = request.getParameter("minPoints");
            if (minPointsStr != null && !minPointsStr.isEmpty()) {
                tier.setMinPointsRequired(Integer.parseInt(minPointsStr));
            }
            
            String multiplierStr = request.getParameter("multiplier");
            if (multiplierStr != null && !multiplierStr.isEmpty()) {
                tier.setPointMultiplier(new BigDecimal(multiplierStr));
            }

            if (dao.isTierNameExists(tier.getTierName(), null)) {
                request.setAttribute("tierNameError", "Tên hạng này đã tồn tại.");
                request.setAttribute("tier", tier);
                request.getRequestDispatcher("/pages/admin/manage-loyalty/create-tier.jsp").forward(request, response);
                return;
            }

            if (dao.insert(tier)) {
                request.getSession().setAttribute("success", "Thêm hạng thành viên thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-tiers");
            } else {
                request.setAttribute("error", "Lỗi: Không thể thêm hạng vào cơ sở dữ liệu.");
                request.setAttribute("tier", tier);
                request.getRequestDispatcher("/pages/admin/manage-loyalty/create-tier.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            request.setAttribute("tier", tier);
            request.getRequestDispatcher("/pages/admin/manage-loyalty/create-tier.jsp").forward(request, response);
        }
    }
}
