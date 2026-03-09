package controllers.admin.ManageLoyalty;

import models.Voucher;
import repositories.Vouchers;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageVouchersServlet", urlPatterns = { "/admin/manage-vouchers" })
public class ManageVouchersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Vouchers dao = new Vouchers();
        List<Voucher> vouchers = dao.getAllActiveVouchers();
        request.setAttribute("vouchers", vouchers);
        request.getRequestDispatcher("/pages/admin/manage-loyalty/manage-vouchers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Vouchers dao = new Vouchers();

        try {
            int id = Integer.parseInt(request.getParameter("voucherId"));
            if (dao.delete(id)) {
                request.getSession().setAttribute("success", "Xóa Voucher thành công!");
            } else {
                request.getSession().setAttribute("error","Lỗi: Không thể xóa. Mã này có thể đang được người dùng sử dụng.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu đầu vào không hợp lệ!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-vouchers");
    }
}
