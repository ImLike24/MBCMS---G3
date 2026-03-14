package controllers.admin.ManageConcession;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import services.ConcessionService;

import java.io.IOException;

@WebServlet("/admin/concessions/delete")
public class DeleteConcession extends HttpServlet {
    private final ConcessionService service = new ConcessionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        try {
            int id = Integer.parseInt(idStr);
            if (service.deleteConcession(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/concessions?success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/concessions?error=delete");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/concessions?error=invalid");
        }
    }
}