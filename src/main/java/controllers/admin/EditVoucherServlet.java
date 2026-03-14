package controllers.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Voucher;
import repositories.Vouchers;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "EditVoucherServlet", urlPatterns = {"/admin/edit-voucher"})
public class EditVoucherServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Vouchers voucherRepo = new Vouchers();
            Voucher voucher = voucherRepo.getVoucherById(id);

            if (voucher == null) {
                request.getSession().setAttribute("error", "Không tìm thấy voucher!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
                return;
            }

            request.setAttribute("voucher", voucher);
            request.getRequestDispatcher("/pages/admin/manage-loyalty/edit-voucher.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            String voucherName = request.getParameter("voucherName");
            String voucherType = request.getParameter("voucherType");
            String voucherCode = request.getParameter("voucherCode");
            BigDecimal discountAmount = new BigDecimal(request.getParameter("discountAmount"));
            int currentUsage = Integer.parseInt(request.getParameter("currentUsage"));
            int maxUsage = Integer.parseInt(request.getParameter("maxUsage"));
            
            int pointsCost = 0;
            if ("LOYALTY".equals(voucherType)) {
                String cost = request.getParameter("pointsCost");
                if (cost != null && !cost.isEmpty()) {
                    pointsCost = Integer.parseInt(cost);
                }
            }
            int validDays = Integer.parseInt(request.getParameter("validDays"));
            boolean isActive = "1".equals(request.getParameter("isActive"));

            Voucher v = new Voucher();
            v.setVoucherId(voucherId);
            v.setVoucherName(voucherName);
            v.setVoucherType(voucherType);
            v.setVoucherCode(voucherCode);
            v.setDiscountAmount(discountAmount);
            v.setCurrentUsage(currentUsage);
            v.setMaxUsageLimit(maxUsage);
            v.setPointsCost(pointsCost);
            v.setValidDays(validDays);
            v.setIsActive(isActive);

            Vouchers voucherRepo = new Vouchers();
            boolean success = voucherRepo.update(v);

            if (success) {
                request.getSession().setAttribute("success", "Cập nhật voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
            } else {
                request.setAttribute("errorMessage", "Cập nhật thất bại. Vui lòng kiểm tra lại!");
                request.setAttribute("voucher", v);
                request.getRequestDispatcher("/pages/admin/manage-loyalty/edit-voucher.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đã có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
