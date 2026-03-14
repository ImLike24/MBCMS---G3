package controllers.admin.ManageLoyalty;

import models.Voucher;
import repositories.Vouchers;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "CreateVoucherServlet", urlPatterns = { "/admin/create-voucher" })
public class CreateVoucherServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pages/admin/manage-loyalty/create-voucher.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Vouchers dao = new Vouchers();

        try {
            Voucher v = new Voucher();
            v.setVoucherName(request.getParameter("voucherName"));
            v.setVoucherType(request.getParameter("voucherType"));

            String code = request.getParameter("voucherCode");
            v.setVoucherCode(code != null ? code.trim() : "");

            v.setDiscountAmount(new BigDecimal(request.getParameter("discountAmount")));
            v.setMaxUsageLimit(Integer.parseInt(request.getParameter("maxUsage")));
            v.setValidDays(Integer.parseInt(request.getParameter("validDays")));

            if ("LOYALTY".equals(v.getVoucherType())) {
                v.setPointsCost(Integer.parseInt(request.getParameter("pointsCost")));
            } else {
                v.setPointsCost(0);
            }

            if (dao.insert(v)) {
                request.getSession().setAttribute("success", "Thêm Voucher mới thành công!");
            } else {
                request.getSession().setAttribute("error", "Lỗi: Không thể thêm Voucher.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu đầu vào không hợp lệ: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
    }
}
