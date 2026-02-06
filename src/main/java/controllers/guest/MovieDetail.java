package controllers.guest;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Movie;
import models.Review;
import models.User;
import repositories.Movies;
import repositories.Reviews;

@WebServlet(name = "MovieDetail", urlPatterns = { "/pages/movie_detail" })
public class MovieDetail extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Movies movieDao = null;
        Reviews reviewDao = null;
        try {
            movieDao = new Movies();
            reviewDao = new Reviews();

            String movieIdParam = request.getParameter("movieId");
            int limit = 3;
            if (movieIdParam == null || movieIdParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            int movieId = Integer.parseInt(movieIdParam);
            Movie movie = movieDao.getMovieById(movieId);

            if (movie == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found");
                return;
            }
            List<Review> reviews = reviewDao.getReviewsByMovieId(movieId, limit, 0);

            request.setAttribute("movie", movie);
            request.setAttribute("reviews", reviews);

            request.getRequestDispatcher("/pages/movie_detail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error.");
        } finally {
            if (movieDao != null)
                movieDao.closeConnection();
            if (reviewDao != null)
                reviewDao.closeConnection();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Reviews reviewDao = null;
        try {
            reviewDao = new Reviews();

            String movieIdStr = request.getParameter("movieId");
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");
            int movieId = Integer.parseInt(movieIdStr);
            int rating = Integer.parseInt(ratingStr);

            if (rating > 0) {
                Review review = new Review();

                review.setUserId(user.getUserId());
                review.setMovieId(movieId);
                review.setRating(rating);
                review.setComment(comment);

                reviewDao.addReview(review);

                response.sendRedirect(
                        request.getContextPath() + "/movie?movieId=" + movieId + "&message=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/movie?movieId=" + movieId
                        + "&message=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error");
        } finally {
            if (reviewDao != null)
                reviewDao.closeConnection();
        }
    }
}
