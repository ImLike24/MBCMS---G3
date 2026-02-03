package controllers.customer;

import models.Review;
import repositories.Reviews;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "LoadReviewsServlet", urlPatterns = { "/load-reviews" })
public class LoadReviews extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        response.setContentType("text/html;charset=UTF-8");

        Reviews reviewDao = null;
        try {
            reviewDao = new Reviews();

            String movieIdStr = request.getParameter("movieId");
            String offsetStr = request.getParameter("offset");
            String limitStr = request.getParameter("limit");

            if (movieIdStr == null || movieIdStr.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int movieId = Integer.parseInt(movieIdStr);
            int offset = Integer.parseInt(offsetStr);
            int limit = Integer.parseInt(limitStr);

            List<Review> reviews = reviewDao.getReviewsByMovieId(movieId, limit, offset);

            request.setAttribute("reviews", reviews);

            
            request.getRequestDispatcher("/components/fragments/list-reviews.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (reviewDao != null)
                reviewDao.closeConnection();
        }
    }
}
