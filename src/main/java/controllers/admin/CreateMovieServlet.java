package controllers.admin;

import java.io.IOException;
import java.time.LocalDate;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import models.Movie;
import models.Role;
import models.User;
import repositories.Movies;
import repositories.Roles;
import services.StorageImageService;

@WebServlet("/admin/create-movie")
public class CreateMovieServlet extends HttpServlet {

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

        // Forward to create movie page
        request.getRequestDispatcher("/pages/admin/create-movie.jsp").forward(request, response);
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
        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Title is required");
            return;
        }

        if (genre == null || genre.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Genre is required");
            return;
        }

        if (durationStr == null || durationStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Duration is required");
            return;
        }

        // Handle poster upload
        String finalPosterUrl = null;
        try {
            StorageImageService imageService = new StorageImageService();

            if ("url".equals(posterType)) {
                // Validate URL
                if (posterUrl == null || posterUrl.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Poster URL is required");
                    return;
                }
                if (!imageService.isValidImageUrl(posterUrl.trim())) {
                    response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Invalid poster URL format");
                    return;
                }
                finalPosterUrl = posterUrl.trim();
            } else if ("file".equals(posterType)) {
                // Handle file upload
                Part filePart = request.getPart("posterFile");
                if (filePart == null || filePart.getSize() == 0) {
                    response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Poster file is required");
                    return;
                }
                finalPosterUrl = imageService.uploadImage(filePart);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Invalid poster type");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Failed to upload poster: " + e.getMessage());
            return;
        }

        DBContext moviesDbContext = null;
        try {
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

            // Create movie object
            Movie movie = new Movie();
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
            moviesDbContext = new DBContext();
            Movies moviesRepo = new Movies();
            boolean success = moviesRepo.insertMovie(movie);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-movies?success=Movie created successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Failed to create movie");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=Invalid duration format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/create-movie?error=" + e.getMessage());
        } finally {
            if (moviesDbContext != null) {
                moviesDbContext.closeConnection();
            }
        }
    }
}