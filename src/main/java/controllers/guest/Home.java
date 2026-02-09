package controllers.guest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import services.HomeService;

import java.io.IOException;

@WebServlet(name = "Home", urlPatterns = {"/home"})
public class Home extends HttpServlet {

    private HomeService homeService = new HomeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("nowShowing", homeService.getNowShowingMovies());
        request.setAttribute("comingSoon", homeService.getComingSoonMovies());
        request.setAttribute("topRated", homeService.getTopRatedMovies());
        request.setAttribute("genres", homeService.getActiveGenres());

        request.getRequestDispatcher("/pages/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home");
    }
}