<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết Phim - ${movie.title}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
        }
        .genre-checkbox {
            min-width: 120px;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/>
</jsp:include>

<main class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Chi tiết phim: ${movie.title}</h3>
        <a href="${pageContext.request.contextPath}/admin/movies" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">${errorMessage}</div>
    </c:if>

    <c:if test="${not empty movie}">
        <div class="row">
            <div class="col-md-4">
                <c:choose>
                    <c:when test="${not empty movie.posterUrl}">
                        <img src="${movie.posterUrl}" class="img-fluid rounded shadow" alt="${movie.title}">
                    </c:when>
                    <c:otherwise>
                        <div class="bg-light text-center p-5 rounded shadow">
                            <i class="fas fa-film fa-5x text-muted"></i>
                            <p class="mt-3">Chưa có poster</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="col-md-8">
                <table class="table table-borderless">
                    <tr><th width="180">Tên phim</th><td>${movie.title}</td></tr>
                    <tr><th>Thời lượng</th><td>${movie.duration} phút</td></tr>
                    <tr><th>Đánh giá</th><td>${movie.rating} ★</td></tr>
                    <tr><th>Độ tuổi</th><td>${empty movie.ageRating ? '-' : movie.ageRating}</td></tr>
                    <tr><th>Đạo diễn</th><td>${empty movie.director ? 'Chưa cập nhật' : movie.director}</td></tr>
                    <tr><th>Diễn viên</th><td>${empty movie.cast ? 'Chưa cập nhật' : movie.cast}</td></tr>
                    <tr><th>Ngày phát hành</th><td>${movie.releaseDate != null ? movie.releaseDate : '-'}</td></tr>
                    <tr><th>Trạng thái</th><td>
                        <span class="badge ${movie.active ? 'bg-success' : 'bg-secondary'} px-3 py-2">
                            ${movie.active ? 'HOẠT ĐỘNG' : 'TẮT'}
                        </span>
                    </td></tr>
                    <tr><th>Thể loại</th><td>
                        <c:forEach var="g" items="${movie.genres}">
                            <span class="badge bg-secondary me-1 mb-1">${g}</span>
                        </c:forEach>
                        <c:if test="${empty movie.genres}">-</c:if>
                    </td></tr>
                    <tr><th>Mô tả</th><td>${empty movie.description ? 'Chưa có mô tả' : movie.description}</td></tr>
                </table>

                <div class="mt-4">
                    <a href="${pageContext.request.contextPath}/admin/movies/edit?id=${movie.movieId}"
                       class="btn btn-warning">
                        <i class="fas fa-pencil-alt me-2"></i>Chỉnh sửa
                    </a>
                </div>
            </div>
        </div>
    </c:if>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>