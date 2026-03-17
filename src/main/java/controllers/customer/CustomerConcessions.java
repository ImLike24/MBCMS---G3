package controllers.customer;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.Concession;
import repositories.Concessions;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


@WebServlet(name = "CustomerConcessions", urlPatterns = { "/customer/concessions" })
public class CustomerConcessions extends HttpServlet {

    // force update
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Concessions repo = null;
        try {
            repo = new Concessions();
            List<Concession> list = repo.getConcessionsForSale();
            List<Map<String, Object>> out = new ArrayList<>();
            for (Concession c : list) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("concessionId", c.getConcessionId());
                m.put("concessionName", c.getConcessionName());
                m.put("concessionType", c.getConcessionType());
                m.put("priceBase", c.getPriceBase());
                m.put("quantity", c.getQuantity());
                out.add(m);
            }
            response.getWriter().write(new Gson().toJson(out));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("[]");
        } finally {
            if (repo != null) {
                repo.closeConnection();
            }
        }
    }
}
