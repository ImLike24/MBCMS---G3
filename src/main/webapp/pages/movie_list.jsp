<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh Sách Phim</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
</head>
<body>

<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-5 pt-4">
    <h2 class="text-center mb-4">Danh Sách Phim</h2>

    <div class="row">
        <!-- Danh sách phim từ DB -->
        <c:forEach var="movie" items="${movies}">
            <div class="col-md-4 mb-4">
                <div class="card h-100">

                    <img src="${movie.posterUrl}"
                         class="card-img-top"
                         alt="${movie.title}"
                         style="height:300px; object-fit:cover;">

                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">${movie.title}</h5>

                        <p class="card-text">${movie.description}</p>

                        <!-- GENRES -->
                        <p class="card-text">
                            <small class="text-muted">
                                Thể loại:
                                <c:forEach var="g" items="${movie.genres}" varStatus="s">
                                    ${g}<c:if test="${!s.last}">, </c:if>
                                </c:forEach>
                            </small>
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Đạo diễn: ${movie.director}</small>
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Thời lượng: ${movie.duration} phút</small>
                        </p>

                        <!-- RELEASE DATE -->
                        <p class="card-text">
                            <small class="text-muted">
                                Ngày phát hành: ${movie.releaseDateFormatted}
                            </small>
                        </p>

                        <div class="mt-auto">
                            <a href="${pageContext.request.contextPath}/pages/movie_detail?movieId=${movie.movieId}"
                               class="btn btn-primary">
                                Xem Chi Tiết
                            </a>

                            <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=${movie.movieId}"
                               class="btn btn-success ms-2">
                                Đặt Vé
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>

        <!-- Phim mẫu để thử nghiệm khi chưa có dữ liệu DB -->
        <c:if test="${empty movies}">
            <div class="col-md-4 mb-4">
                <div class="card h-100 border border-warning">
                    <img src="https://via.placeholder.com/400x300?text=Sample+Movie"
                         class="card-img-top"
                         alt="Phim thử nghiệm"
                         style="height:300px; object-fit:cover;">

                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">Phim Thử Nghiệm</h5>

                        <p class="card-text">
                            Đây là phim mẫu được tạo sẵn để test luồng đặt vé và chọn khung giờ.
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Thể loại: Hành động, Viễn tưởng</small>
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Đạo diễn: Demo Director</small>
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Thời lượng: 120 phút</small>
                        </p>

                        <p class="card-text">
                            <small class="text-muted">Ngày phát hành: 01/01/2025</small>
                        </p>

                        <div class="mt-auto">
                            <!-- movieId mẫu = 1, bạn có thể đổi cho khớp DB -->
                            <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=999"
                               class="btn btn-success">
                                Đặt Vé (Test)
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
    </div>

</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
