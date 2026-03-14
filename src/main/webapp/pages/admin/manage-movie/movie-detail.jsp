<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Phim - ${movie.title}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
            background-color: #f8f9fa;
        }

        .genre-checkbox {
            min-width: 120px;
        }
      
        .movie-detail-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .movie-poster {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.12);
            background: #fff;
        }
        .movie-poster img {
            width: 100%;
            height: auto;
            object-fit: cover;
        }
        .no-poster {
            height: 500px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e9ecef, #dee2e6);
            color: #6c757d;
            border-radius: 12px;
        }
        .info-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        .info-header {
            background: linear-gradient(90deg, #0d6efd, #0b5ed7);
            color: white;
            padding: 1.25rem 1.5rem;
            font-weight: 600;
        }
        .list-group-item {
            border: none;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #e9ecef;
        }
        .list-group-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: 600;
            color: #495057;
            min-width: 140px;
            display: inline-block;
        }
        .status-badge {
            font-size: 0.95rem;
            padding: 0.5em 1.2em;
        }
        .genre-badge {
            font-size: 0.9rem;
            padding: 0.45em 0.9em;
            margin: 0 0.35em 0.35em 0;
        }
        .action-btns .btn {
            min-width: 140px;
        }
        @media (max-width: 992px) {
            .movie-poster { margin-bottom: 2rem; }
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/>
</jsp:include>

<main class="movie-detail-container py-4 px-3 px-md-4">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
        <div>
            <h3 class="mb-1 fw-bold">Chi tiết phim: ${movie.title}</h3>
        </div>
        <a href="${pageContext.request.contextPath}/admin/movies" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-2"></i> Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty movie}">
        <div class="row g-4">
            <!-- Poster -->
            <div class="col-lg-4 col-xl-3">
                <div class="movie-poster">
                    <c:choose>
                        <c:when test="${not empty movie.posterUrl}">
                            <img src="${movie.posterUrl}" alt="${movie.title}" class="img-fluid">
                        </c:when>
                        <c:otherwise>
                            <div class="no-poster">
                                <div class="text-center">
                                    <i class="fas fa-film fa-5x mb-3 text-muted"></i>
                                    <h5>Chưa có poster</h5>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Thông tin chính -->
            <div class="col-lg-8 col-xl-9">
                <div class="card info-card">
                    <div class="info-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Thông tin phim</h5>
                        <span class="status-badge badge ${movie.active ? 'bg-success' : 'bg-secondary'}">
                            <i class="fas ${movie.active ? 'fa-check-circle' : 'fa-ban'} me-1"></i>
                            ${movie.active ? 'HOẠT ĐỘNG' : 'TẮT'}
                        </span>
                    </div>

                    <ul class="list-group list-group-flush">
                        <li class="list-group-item">
                            <span class="label">Tên phim:</span>
                            <strong>${movie.title}</strong>
                        </li>
                        <li class="list-group-item">
                            <span class="label">Thời lượng:</span>
                            ${movie.duration} phút
                        </li>
                        <li class="list-group-item">
                            <span class="label">Đánh giá:</span>
                            <span class="text-warning fw-bold">${movie.rating} ★</span>
                        </li>
                        <li class="list-group-item">
                            <span class="label">Độ tuổi:</span>
                            ${empty movie.ageRating ? 'Chưa cập nhật' : movie.ageRating}
                        </li>
                        <li class="list-group-item">
                            <span class="label">Đạo diễn:</span>
                            ${empty movie.director ? 'Chưa cập nhật' : movie.director}
                        </li>
                        <li class="list-group-item">
                            <span class="label">Diễn viên:</span>
                            ${empty movie.cast ? 'Chưa cập nhật' : movie.cast}
                        </li>
                        <li class="list-group-item">
                            <span class="label">Ngày phát hành:</span>
                            ${movie.releaseDate != null ? movie.releaseDate : 'Chưa cập nhật'}
                        </li>
                        <li class="list-group-item">
                            <span class="label">Thể loại:</span>
                            <div class="d-inline">
                                <c:forEach var="g" items="${movie.genres}">
                                    <span class="badge bg-primary genre-badge">${g}</span>
                                </c:forEach>
                                <c:if test="${empty movie.genres}">
                                    <span class="text-muted">Chưa có thể loại</span>
                                </c:if>
                            </div>
                        </li>
                        <li class="list-group-item">
                            <span class="label">Mô tả:</span>
                            <div class="mt-2 text-muted">
                                ${empty movie.description ? 'Chưa có mô tả chi tiết.' : movie.description}
                            </div>
                        </li>
                    </ul>
                </div>

                <!-- Nút hành động -->
                <div class="mt-4 action-btns d-flex gap-3 flex-wrap">
                    <a href="${pageContext.request.contextPath}/admin/movies/edit?id=${movie.movieId}"
                       class="btn btn-warning btn-lg">
                        <i class="fas fa-edit me-2"></i> Chỉnh sửa phim
                    </a>
                    <!-- Có thể thêm nút khác nếu cần, ví dụ: Xem lịch chiếu, Xóa (cẩn thận) -->
                    <!-- <button class="btn btn-outline-danger btn-lg"><i class="fas fa-trash-alt me-2"></i>Xóa</button> -->
                </div>
            </div>
        </div>
    </c:if>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>