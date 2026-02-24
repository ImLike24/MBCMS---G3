package services;

import java.util.List;
import models.Movie;
import repositories.Movies;

public class MovieService {

    private final Movies movieDao = new Movies();

    public List<Movie> getAllMovies() {
        return movieDao.getAllMovies();
    }

    public Movie getMovieById(int id) {
        try {
            return movieDao.getMovieById(id);
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    public String addNewMovie(Movie movie, List<Integer> genreIds) {
        // Validation
        if (movie == null) return "Dữ liệu phim không hợp lệ";
        if (movie.getTitle() == null || movie.getTitle().trim().isEmpty()) return "Tên phim không được để trống";
        if (movie.getDuration() <= 0) return "Thời lượng phải lớn hơn 0 phút";
        if (movie.getRating() < 0 || movie.getRating() > 10) return "Đánh giá phải từ 0.0 đến 10.0";
        if (genreIds == null || genreIds.isEmpty()) return "Vui lòng chọn ít nhất một thể loại";

        try {
            movieDao.insertMovieWithGenres(movie, genreIds);
            return null; // Thành công
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi thêm phim: " + e.getMessage();
        }
    }
    
    public String updateMovie(Movie movie, List<Integer> genreIds) {
        // Validation cơ bản
        if (movie == null || movie.getMovieId() == null || movie.getMovieId() <= 0) {
            return "ID phim không hợp lệ";
        }
        if (movie.getTitle() == null || movie.getTitle().trim().isEmpty()) {
            return "Tên phim không được để trống";
        }
        if (movie.getDuration() <= 0) {
            return "Thời lượng phải lớn hơn 0 phút";
        }
        if (movie.getRating() < 0 || movie.getRating() > 5) {
            return "Đánh giá phải từ 0.0 đến 5.0";
        }

        try {
            movieDao.updateMovieWithGenres(movie, genreIds);
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi cập nhật phim: " + e.getMessage();
        }
    }
}