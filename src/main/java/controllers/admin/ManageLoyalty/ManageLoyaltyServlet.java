package controllers.admin.ManageLoyalty;

import models.LoyaltyConfig;
import repositories.LoyaltyConfigs;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "ManageLoyaltyServlet", urlPatterns = { "/admin/loyalty-config" })
public class ManageLoyaltyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LoyaltyConfigs dao = new LoyaltyConfigs();
        LoyaltyConfig config = dao.getConfig();

        request.setAttribute("config", config);
        request.getRequestDispatcher("/pages/admin/loyalty-config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            BigDecimal earnRate = new BigDecimal(request.getParameter("earnRatio"));
            int earnPoints = Integer.parseInt(request.getParameter("earnPoints"));
            int minRedeem = Integer.parseInt(request.getParameter("minRedeem"));

            models.User adminUser = (models.User) request.getSession().getAttribute("user");
            Integer adminId = adminUser != null ? adminUser.getUserId() : null;

            LoyaltyConfig config = new LoyaltyConfig();
            config.setEarnRateAmount(earnRate);
            config.setEarnPoints(earnPoints);
            config.setMinRedeemPoints(minRedeem);
            config.setUpdatedBy(adminId);

            LoyaltyConfigs dao = new LoyaltyConfigs();
            boolean success = dao.updateConfig(config);

            if (success) {
                request.getSession().setAttribute("success", "Cấu hình tích điểm đã được cập nhật thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Cập nhật không thành công.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi dữ liệu đầu vào không hợp lệ!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/loyalty-config");
    }
}
