package controllers.admin;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.time.LocalDate;
import models.Movie;
import models.Role;
import models.User;
import repositories.Movies;
import repositories.Roles;

import java.io.IOException;
import services.StorageImageService;

@WebServlet("/admin/edit-movie")
public class EditMovieServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Get movie ID from parameter
        String movieIdStr = request.getParameter("id");
        if (movieIdStr == null || movieIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie ID is required");
            return;
        }

        DBContext moviesDbContext = null;
        try {
            int movieId = Integer.parseInt(movieIdStr);

            moviesDbContext = new DBContext();
            Movies moviesRepo = new Movies();
            Movie movie = moviesRepo.getMovieById(movieId);

            if (movie == null) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie not found");
                return;
            }

            request.setAttribute("movie", movie);
            request.getRequestDispatcher("/pages/admin/edit-movie.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Invalid movie ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=" + e.getMessage());
        } finally {
            if (moviesDbContext != null) {
                moviesDbContext.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is admin
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"ADMIN".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Get form parameters (multipart)
        String movieIdStr = request.getParameter("movieId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String genre = request.getParameter("genre");
        String durationStr = request.getParameter("duration");
        String releaseDateStr = request.getParameter("releaseDate");
        String endDateStr = request.getParameter("endDate");
        String ageRating = request.getParameter("ageRating");
        String director = request.getParameter("director");
        String cast = request.getParameter("cast");
        String posterType = request.getParameter("posterType");
        String posterUrl = request.getParameter("posterUrl");
        String isActiveStr = request.getParameter("isActive");

        // Validate required fields
        if (movieIdStr == null || movieIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie ID is required");
            return;
        }

        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Title is required");
            return;
        }

        if (genre == null || genre.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Genre is required");
            return;
        }

        if (durationStr == null || durationStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Duration is required");
            return;
        }

        // Handle poster upload
        String finalPosterUrl = null;
        try {
            StorageImageService imageService = new StorageImageService();

            if ("url".equals(posterType)) {
                // Validate URL
                if (posterUrl == null || posterUrl.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Poster URL is required");
                    return;
                }
                if (!imageService.isValidImageUrl(posterUrl.trim())) {
                    response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Invalid poster URL format");
                    return;
                }
                finalPosterUrl = posterUrl.trim();
            } else if ("file".equals(posterType)) {
                // Handle file upload
                Part filePart = request.getPart("posterFile");
                if (filePart == null || filePart.getSize() == 0) {
                    response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Poster file is required");
                    return;
                }
                finalPosterUrl = imageService.uploadImage(filePart);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Invalid poster type");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Failed to upload poster: " + e.getMessage());
            return;
        }

        DBContext moviesDbContext = null;
        try {
            // Parse movie ID
            int movieId = Integer.parseInt(movieIdStr);

            // Parse duration
            int duration = Integer.parseInt(durationStr.trim());

            // Parse dates
            LocalDate releaseDate = null;
            if (releaseDateStr != null && !releaseDateStr.trim().isEmpty()) {
                releaseDate = LocalDate.parse(releaseDateStr);
            }

            LocalDate endDate = null;
            if (endDateStr != null && !endDateStr.trim().isEmpty()) {
                endDate = LocalDate.parse(endDateStr);
            }

            // Parse active status
            boolean isActive = "on".equals(isActiveStr) || "true".equals(isActiveStr);

            // Get existing movie
            moviesDbContext = new DBContext();
            Movies moviesRepo = new Movies();
            Movie movie = moviesRepo.getMovieById(movieId);

            if (movie == null) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?error=Movie not found");
                return;
            }

            // Update movie object
            movie.setTitle(title.trim());
            movie.setDescription(description != null ? description.trim() : null);
            movie.setGenre(genre.trim());
            movie.setDuration(duration);
            movie.setReleaseDate(releaseDate);
            movie.setEndDate(endDate);
            movie.setAgeRating(ageRating != null ? ageRating.trim() : null);
            movie.setDirector(director != null ? director.trim() : null);
            movie.setCast(cast != null ? cast.trim() : null);
            movie.setPosterUrl(finalPosterUrl);
            movie.setActive(isActive);

            // Save to database
            boolean success = moviesRepo.updateMovie(movie);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?success=Movie updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieId + "&error=Failed to update movie");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=Invalid number format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/edit-movie?id=" + movieIdStr + "&error=" + e.getMessage());
        } finally {
            if (moviesDbContext != null) {
                moviesDbContext.closeConnection();
            }
        }
    }
}