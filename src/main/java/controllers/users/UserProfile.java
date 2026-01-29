package controllers.users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.User;

@WebServlet(name = "UserProfile", urlPatterns = {"/profile"})
public class UserProfile extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        request.setAttribute("u", user);
        request.getRequestDispatcher("/pages/user/profile.jsp")
               .forward(request, response);
    }
}
