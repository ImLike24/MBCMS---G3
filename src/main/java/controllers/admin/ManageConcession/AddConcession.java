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
        request.getRequestDispatcher("/pages/admin/manage-concession/concession-add.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String type = request.getParameter("concessionType");
        String qtyStr = request.getParameter("quantity");
        String priceStr = request.getParameter("priceBase");

        Concession c = new Concession();
        c.setConcessionType(type);
        c.setQuantity(qtyStr != null && !qtyStr.isEmpty() ? Integer.parseInt(qtyStr) : 0);
        c.setPriceBase(priceStr != null && !priceStr.isEmpty() ? Double.parseDouble(priceStr) : 0.0);

        if (service.addConcession(c)) {
            response.sendRedirect(request.getContextPath() + "/admin/concessions?success=add");
        } else {
            request.setAttribute("error", "Thêm thất bại. Vui lòng kiểm tra dữ liệu.");
            request.setAttribute("concession", c);
            request.getRequestDispatcher("/pages/admin/manage-concession/concession-add.jsp")
                   .forward(request, response);
        }
    }
}