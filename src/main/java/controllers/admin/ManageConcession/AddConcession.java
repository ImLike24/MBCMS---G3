package controllers.admin.ManageConcession;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Concession;
import services.ConcessionService;

import java.io.IOException;

@WebServlet("/admin/concessions/add")
public class AddConcession extends HttpServlet {
    
    private final ConcessionService service = new ConcessionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu có dữ liệu lỗi từ trước, giữ lại (nhưng lần đầu GET thì không có)
        request.getRequestDispatcher("/pages/admin/manage-concession/concession-add.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String concessionName = request.getParameter("concessionName");
        String type           = request.getParameter("concessionType");
        String qtyStr         = request.getParameter("quantity");
        String priceStr       = request.getParameter("priceBase");

        // Validate cơ bản phía server (có thể mở rộng thêm)
        if (concessionName == null || concessionName.trim().isEmpty()) {
            request.setAttribute("error", "Tên sản phẩm không được để trống.");
            forwardWithConcession(request, response, concessionName, type, qtyStr, priceStr);
            return;
        }

        Concession c = new Concession();
        c.setConcessionName(concessionName.trim());
        c.setConcessionType(type);

        try {
            int quantity = (qtyStr != null && !qtyStr.trim().isEmpty()) 
                           ? Integer.parseInt(qtyStr.trim()) : 0;
            c.setQuantity(quantity >= 0 ? quantity : 0);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Số lượng tồn kho không hợp lệ.");
            forwardWithConcession(request, response, concessionName, type, qtyStr, priceStr);
            return;
        }

        try {
            double price = (priceStr != null && !priceStr.trim().isEmpty()) 
                        ? Double.parseDouble(priceStr.trim()) : 0;
            c.setPriceBase(price / 1000);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Giá cơ bản không hợp lệ.");
            forwardWithConcession(request, response, concessionName, type, qtyStr, priceStr);
            return;
        }

        // Giả sử bạn cần set addedBy từ session (user đang đăng nhập)
        // Ví dụ: 
        // Integer userId = (Integer) request.getSession().getAttribute("userId");
        // c.setAddedBy(userId != null ? userId : 1); // fallback

        if (service.addConcession(c)) {
            response.sendRedirect(request.getContextPath() + "/admin/concessions?success=add");
        } else {
            request.setAttribute("error", "Thêm thất bại. Vui lòng kiểm tra lại dữ liệu hoặc liên hệ admin.");
            forwardWithConcession(request, response, concessionName, type, qtyStr, priceStr);
        }
    }

    private void forwardWithConcession(HttpServletRequest request, HttpServletResponse response,
                                       String name, String type, String qty, String price)
            throws ServletException, IOException {
        Concession c = new Concession();
        c.setConcessionName(name);
        c.setConcessionType(type);
        try { c.setQuantity(qty != null && !qty.isEmpty() ? Integer.parseInt(qty) : 0); } 
        catch (Exception ignored) { c.setQuantity(0); }
        try { c.setPriceBase(price != null && !price.isEmpty() ? Double.parseDouble(price) : 0.0); } 
        catch (Exception ignored) { c.setPriceBase(0.0); }
        
        request.setAttribute("concession", c);
        request.getRequestDispatcher("/pages/admin/manage-concession/concession-add.jsp")
               .forward(request, response);
    }
}