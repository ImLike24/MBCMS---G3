package controllers.admin.ManageConcession;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Concession;
import services.ConcessionService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/concessions")
public class ListConcession extends HttpServlet {
    private final ConcessionService service = new ConcessionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Concession> concessions = service.getAllConcessions();
        request.setAttribute("concessions", concessions);
        request.getRequestDispatcher("/pages/admin/manage-concession/manage-concession.jsp")
               .forward(request, response);
    }
}