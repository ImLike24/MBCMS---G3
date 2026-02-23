<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>MyCinema - Trang Chủ</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <style>
        :root {
            --dark: #212529;
            --orange: #d96c2c;
        }
        body {
            background: #111;
            color: #fff;
        }
        /* HERO */
        .hero {
            background: linear-gradient(120deg, #000, #212529);
            padding: 60px;
            border-radius: 12px;
            margin-bottom: 40px;
        }
        /* SECTION */
        .section-title {
            border-left: 6px solid var(--orange);
            padding-left: 12px;
            margin: 40px 0 20px;
            font-size: 26px;
            font-weight: bold;
        }
        /* MOVIE CARD */
        .movie-card {
            background: var(--dark);
            border-radius: 12px;
            overflow: hidden;
            transition: 0.3s;
            height: 100%;
        }
        .movie-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 10px 25px rgba(217,108,44,0.3);
        }
        .movie-card img {
            width: 100%;
            height: 350px;
            object-fit: cover;
        }
        .movie-info {
            padding: 15px;
        }
        .movie-title {
            font-weight: bold;
            font-size: 16px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 5px;
        }
        .movie-rating {
            color: var(--orange);
            font-size: 14px;
        }
    </style>
</head>

<body>

<jsp:include page="/components/layout/Header.jsp" />

<div class="container mt-4">

    <div class="hero">
        <h1>🎬 Welcome to <span style="color:#d96c2c">MyCinema</span></h1>
        <p class="lead">Đặt vé nhanh chóng. Khám phá điện ảnh. Tận hưởng cảm xúc.</p>
    </div>

    <div class="section-title">Phim Đang Chiếu</div>
    <div class="row">
        <c:choose>
            <c:when test="${not empty nowShowing}">
                <c:forEach var="m" items="${nowShowing}">
                    <div class="col-md-3 mb-4">
                        <div class="movie-card">
                            <a href="${pageContext.request.contextPath}/movie-detail?id=${m.movieId}">
                                <img src="${m.posterUrl}" alt="${m.title}" onerror="this.src='https://via.placeholder.com/300x450?text=No+Image'">
                            </a>
                            <div class="movie-info">
                                <div class="movie-title" title="${m.title}">${m.title}</div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="movie-rating">
                                        <i class="fa fa-star"></i> ${m.rating > 0 ? m.rating : 'N/A'}
                                    </div>
                                    <span class="badge bg-secondary">${m.ageRating}</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/movie-detail?id=${m.movieId}"
                                   class="btn btn-sm btn-warning w-100 mt-3 fw-bold">
                                    Đặt Vé Ngay
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="text-muted">Hiện chưa có phim đang chiếu.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-title">Phim Sắp Chiếu</div>
    <div class="row">
        <c:choose>
            <c:when test="${not empty comingSoon}">
                <c:forEach var="m" items="${comingSoon}">
                    <div class="col-md-3 mb-4">
                        <div class="movie-card">
                            <a href="${pageContext.request.contextPath}/movie-detail?id=${m.movieId}">
                                <img src="${m.posterUrl}" alt="${m.title}" onerror="this.src='https://via.placeholder.com/300x450?text=No+Image'">
                            </a>
                            <div class="movie-info">
                                <div class="movie-title" title="${m.title}">${m.title}</div>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <small class="text-muted">
                                        <i class="fa fa-calendar"></i> ${m.releaseDateFormatted}
                                    </small>
                                </div>
                                <span class="badge bg-secondary w-100 py-2">Sắp ra mắt</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="text-muted">Chưa có phim sắp chiếu.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-title">Phim Hay Nhất</div>
    <div class="row">
        <c:choose>
            <c:when test="${not empty topRated}">
                <c:forEach var="m" items="${topRated}">
                    <div class="col-md-3 mb-4">
                        <div class="movie-card">
                            <a href="${pageContext.request.contextPath}/movie-detail?id=${m.movieId}">
                                <img src="${m.posterUrl}" alt="${m.title}">
                            </a>
                            <div class="movie-info">
                                <div class="movie-title" title="${m.title}">${m.title}</div>
                                <div class="movie-rating">
                                    <i class="fa fa-star"></i> ${m.rating}/10
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="text-muted">Chưa có dữ liệu xếp hạng.</p>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<jsp:include page="/components/layout/Footer.jsp"/>

</body>
</html>