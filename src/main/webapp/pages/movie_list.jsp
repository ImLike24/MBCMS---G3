<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Phim - MyCinema</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Platypi:ital,wght@0,300..800;1,300..800&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --dark: #212529; --orange: #d96c2c; --orange-hover: #b95a22; }
        body { background: #111; color: #fff; padding-top: 56px; min-height: 100vh; }
        .movies-hero {
            background: linear-gradient(135deg, #000 0%, #212529 50%, #1a1a1a 100%);
            padding: 50px 30px;
            border-radius: 12px;
            margin-bottom: 40px;
            border-left: 6px solid var(--orange);
        }
        .movies-hero h1 { font-size: 2rem; font-weight: 700; }
        .movies-hero .col_oran { color: var(--orange) !important; }
        .section-day {
            margin-bottom: 50px;
        }
        .section-day-title {
            border-left: 6px solid var(--orange);
            padding-left: 16px;
            margin-bottom: 24px;
            font-size: 1.4rem;
            font-weight: 600;
            color: #fff;
        }
        .movie-card-movies {
            background: var(--dark);
            border-radius: 12px;
            overflow: hidden;
            transition: 0.3s;
            height: 100%;
            border: 1px solid rgba(255,255,255,0.1);
        }
        .movie-card-movies:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 30px rgba(217,108,44,0.25);
            border-color: var(--orange);
        }
        .movie-card-movies .poster-wrap {
            position: relative;
            overflow: hidden;
            height: 320px;
        }
        .movie-card-movies .poster-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s;
        }
        .movie-card-movies:hover .poster-wrap img {
            transform: scale(1.05);
        }
        .movie-card-movies .poster-wrap::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 80px;
            background: linear-gradient(transparent, rgba(0,0,0,0.9));
        }
        .movie-card-movies .poster-wrap .badge-age {
            position: absolute;
            top: 12px;
            right: 12px;
            z-index: 2;
            background: var(--orange);
            color: #fff;
            padding: 4px 10px;
            font-size: 12px;
        }
        .movie-card-movies .movie-info {
            padding: 20px;
        }
        .movie-card-movies .movie-title {
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 10px;
            line-height: 1.3;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .movie-card-movies .movie-meta {
            font-size: 13px;
            color: #aaa;
            margin-bottom: 12px;
        }
        .movie-card-movies .movie-meta i {
            color: var(--orange);
            width: 18px;
            margin-right: 4px;
        }
        .movie-card-movies .movie-desc {
            font-size: 13px;
            color: #999;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            margin-bottom: 16px;
        }
        .movie-card-movies .btn-group-movie {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .movie-card-movies .btn-detail {
            background: transparent;
            border: 2px solid var(--orange);
            color: var(--orange);
            padding: 10px 20px;
            font-weight: 600;
            border-radius: 8px;
            transition: 0.3s;
        }
        .movie-card-movies .btn-detail:hover {
            background: var(--orange);
            color: #fff;
            border-color: var(--orange);
        }
        .movie-card-movies .btn-booking {
            background: var(--orange);
            border: 2px solid var(--orange);
            color: #fff;
            padding: 10px 20px;
            font-weight: 600;
            border-radius: 8px;
            transition: 0.3s;
        }
        .movie-card-movies .btn-booking:hover {
            background: var(--orange-hover);
            border-color: var(--orange-hover);
            color: #fff;
        }
        .movie-card-movies .btn-group-movie .btn {
            flex: 1;
            min-width: 120px;
        }
        .empty-day-msg {
            color: #888;
            font-style: italic;
            padding: 20px;
        }
        .sample-card {
            border: 2px dashed rgba(217,108,44,0.5) !important;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-4 mb-5">
    <div class="movies-hero">
        <h1><i class="fa fa-film col_oran"></i> Danh Sách Phim</h1>
        <p class="lead text-white-50 mb-0 mt-2">
            Phim đã lên lịch, đang chiếu theo ngày trong tuần
            <span class="text-white">(từ ${fromDateStr} đến ${toDateStr})</span>
        </p>
    </div>

    <c:forEach var="dayGroup" items="${dayGroups}">
        <div class="section-day">
            <h3 class="section-day-title"><i class="fa fa-calendar me-2"></i>${dayGroup.dayName}</h3>
            <div class="row">
                <c:forEach var="movie" items="${dayGroup.movies}">
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="movie-card-movies">
                            <div class="poster-wrap">
                                <c:set var="posterSrc" value="${not empty movie.posterUrl ? movie.posterUrl : pageContext.request.contextPath.concat('/images/default_poster.jpg')}"/>
                                <img src="${posterSrc}" alt="${movie.title}" onerror="this.src='https://via.placeholder.com/300x450?text=No+Image'">
                                <c:if test="${not empty movie.ageRating}">
                                    <span class="badge badge-age">${movie.ageRating}</span>
                                </c:if>
                            </div>
                            <div class="movie-info">
                                <h5 class="movie-title">${movie.title}</h5>
                                <div class="movie-meta">
                                    <span><i class="fa fa-clock-o"></i>${movie.duration} phút</span>
                                    <c:if test="${not empty movie.genres}">
                                        <span class="ms-2"><i class="fa fa-tags"></i> <c:forEach var="g" items="${movie.genres}" varStatus="s">${g}<c:if test="${!s.last}">, </c:if></c:forEach></span>
                                    </c:if>
                                </div>
                                <c:if test="${not empty movie.description}">
                                    <p class="movie-desc">${movie.description}</p>
                                </c:if>
                                <div class="btn-group-movie">
                                    <a href="${pageContext.request.contextPath}/movie?movieId=${movie.movieId}" class="btn btn-detail">
                                        <i class="fa fa-eye me-1"></i>Chi tiết
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=${movie.movieId}" class="btn btn-booking">
                                        <i class="fa fa-ticket me-1"></i>Đặt vé
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            <c:if test="${empty dayGroup.movies}">
                <p class="empty-day-msg"><i class="fa fa-info-circle"></i> Không có phim chiếu vào ${dayGroup.dayName} trong tuần này.</p>
            </c:if>
        </div>
    </c:forEach>

    <!-- Phim mẫu khi không có dữ liệu -->
    <c:set var="hasAnyMovie" value="false"/>
    <c:forEach var="dg" items="${dayGroups}">
        <c:if test="${not empty dg.movies}"><c:set var="hasAnyMovie" value="true"/></c:if>
    </c:forEach>
    <c:if test="${not hasAnyMovie}">
        <div class="section-day">
            <h3 class="section-day-title"><i class="fa fa-info-circle me-2"></i>Phim mẫu</h3>
            <div class="row">
                <div class="col-md-4 col-lg-3 mb-4">
                    <div class="movie-card-movies sample-card">
                        <div class="poster-wrap">
                            <img src="https://via.placeholder.com/300x450?text=Sample+Movie" alt="Phim thử nghiệm">
                            <span class="badge badge-age">T13</span>
                        </div>
                        <div class="movie-info">
                            <h5 class="movie-title">Phim Thử Nghiệm</h5>
                            <div class="movie-meta">
                                <span><i class="fa fa-clock-o"></i>120 phút</span>
                                <span class="ms-2"><i class="fa fa-tags"></i> Hành động, Viễn tưởng</span>
                            </div>
                            <p class="movie-desc">Đây là phim mẫu. Thêm phim và suất chiếu trong DB để đặt vé.</p>
                            <p class="text-white-50 small mb-0"><i class="fa fa-wrench"></i> Phim mẫu - chưa có dữ liệu thật.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

</div>

<jsp:include page="/components/layout/Footer.jsp"/>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
