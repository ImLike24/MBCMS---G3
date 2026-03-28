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
        Voucher v = new Voucher();

        try {
            v.setVoucherName(request.getParameter("voucherName"));
            v.setVoucherType(request.getParameter("voucherType"));

            String code = request.getParameter("voucherCode");
            v.setVoucherCode(code != null ? code.trim() : "");

            String discountStr = request.getParameter("discountAmount");
            if (discountStr != null && !discountStr.isEmpty()) {
                v.setDiscountAmount(new BigDecimal(discountStr));
            }

            String maxUsageStr = request.getParameter("maxUsage");
            if (maxUsageStr != null && !maxUsageStr.isEmpty()) {
                v.setMaxUsageLimit(Integer.parseInt(maxUsageStr));
            }

            String validDaysStr = request.getParameter("validDays");
            if (validDaysStr != null && !validDaysStr.isEmpty()) {
                v.setValidDays(Integer.parseInt(validDaysStr));
            }

            if ("LOYALTY".equals(v.getVoucherType())) {
                String pointsCostStr = request.getParameter("pointsCost");
                if (pointsCostStr != null && !pointsCostStr.isEmpty()) {
                    v.setPointsCost(Integer.parseInt(pointsCostStr));
                }
            } else {
                v.setPointsCost(0);
            }

            if (dao.isVoucherCodeExists(v.getVoucherCode(), null)) {
                request.setAttribute("voucherCodeError", "Mã Voucher này đã tồn tại.");
                request.setAttribute("voucher", v);
                request.getRequestDispatcher("/pages/admin/manage-loyalty/create-voucher.jsp").forward(request,
                        response);
                return;
            }

            if (dao.insert(v)) {
                request.getSession().setAttribute("success", "Thêm Voucher mới thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
            } else {
                request.setAttribute("error", "Lỗi: Không thể thêm Voucher vào cơ sở dữ liệu.");
                request.setAttribute("voucher", v);
                request.getRequestDispatcher("/pages/admin/manage-loyalty/create-voucher.jsp").forward(request,
                        response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu đầu vào không hợp lệ: " + e.getMessage());
            request.setAttribute("voucher", v);
            request.getRequestDispatcher("/pages/admin/manage-loyalty/create-voucher.jsp").forward(request, response);
        }
    }
}
