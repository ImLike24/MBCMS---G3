package services;

import com.cloudinary.utils.ObjectUtils;
import config.CloudinaryConfig;
import java.util.List;
import java.util.Map;
import models.Movie;
import repositories.Movies;

public class MovieService {

    private final Movies movieDao = new Movies();

    public List<Movie> getAllMovies() {
        return movieDao.getAllMovies();
    }

    public Movie getMovieById(int id) {
        return movieDao.getMovieById(id);
    }
    
    public String addNewMovie(Movie movie, List<Integer> genreIds) {
        try {
            movieDao.insertMovieWithGenres(movie, genreIds);
            return null; // Thành công
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi thêm phim: " + e.getMessage();
        }
    }
    
    public boolean updateMovie(Movie movie, List<Integer> genreIds) {
        if (movie == null || movie.getMovieId() == null || movie.getMovieId() <= 0) {
            System.err.println("ID phim không hợp lệ");
            return false;
        }
        if (movie.getTitle() == null || movie.getTitle().trim().isEmpty()) {
            System.err.println("Tên phim không được để trống");
            return false;
        }
        if (movie.getDuration() <= 0) {
            System.err.println("Thời lượng phải lớn hơn 0 phút");
            return false;
        }
        if (movie.getRating() < 0 || movie.getRating() > 5) {
            System.err.println("Đánh giá phải từ 0.0 đến 5.0");
            return false;
        }

        try {
            movieDao.updateMovieWithGenres(movie, genreIds);
            return true;  // Thành công
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Lỗi khi cập nhật phim: " + e.getMessage());
            return false;
        }
    }
    
    public String deleteMovie(int movieId) {
        if (movieId <= 0) {
            return "ID phim không hợp lệ";
        }

        boolean success = movieDao.deleteMovie(movieId);

        if (success) {
            return null;
        } else {
            return "Không thể xóa phim. Có thể phim đang có lịch chiếu hoặc đã có vé bán.";
        }
    }
    
    public String uploadPoster(byte[] fileBytes, String fileName, Integer movieId) {
        try {
            String publicId;
            if (movieId != null) {
                publicId = "movies/posters/poster_" + movieId;
            } else {
                publicId = "movies/posters/temp_" + System.currentTimeMillis();
            }

            Map uploadParams = ObjectUtils.asMap(
                "public_id", publicId,
                "folder", "movies/posters",
                "overwrite", true,
                "resource_type", "image"
            );

            Map uploadResult = CloudinaryConfig.getCloudinary().uploader().upload(fileBytes, uploadParams);
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}