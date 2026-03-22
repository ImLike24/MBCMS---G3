package controllers.admin.ManageConcession;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Concession;
import services.ConcessionService;

import java.io.IOException;

@WebServlet("/admin/concessions/edit")
public class EditConcession extends HttpServlet {
    private final ConcessionService service = new ConcessionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            Concession c = service.getConcessionById(id);
            if (c != null) {
                request.setAttribute("concession", c);
                request.getRequestDispatcher("/pages/admin/manage-concession/concession-edit.jsp")
                       .forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/concessions?error=notfound");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/concessions?error=invalid");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("concessionId");
        String type = request.getParameter("concessionType");
        String qtyStr = request.getParameter("quantity");
        String priceStr = request.getParameter("priceBase");

        try {
            int id = Integer.parseInt(idStr);
            Concession c = new Concession();
            c.setConcessionId(id);
            c.setConcessionType(type);
            c.setQuantity(Integer.parseInt(qtyStr));
            c.setPriceBase(Double.parseDouble(priceStr));

            if (service.updateConcession(c)) {
                response.sendRedirect(request.getContextPath() + "/admin/concessions?success=update");
            } else {
                request.setAttribute("error", "Cập nhật thất bại");
                request.setAttribute("concession", c);
                request.getRequestDispatcher("/pages/admin/manage-concession/concession-edit.jsp")
                       .forward(request, response);
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/concessions?error=invalid");
        }
    }
}