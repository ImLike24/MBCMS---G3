<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn suất chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <!-- Tái sử dụng CSS booking/showtimes từ khu vực staff/counter -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
</head>
<body>

<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-5 pt-4 mb-5">
    <c:if test="${not empty movie}">
        <!-- Thong tin phim -->
        <div class="movie-info-card mb-4">
            <div class="movie-info-content">
                <div class="movie-poster-container">
                    <c:set var="defaultPoster" value="${pageContext.request.contextPath}/images/default_poster.jpg" />
                    <c:set var="posterSrc" value="${not empty movie.posterUrl ? movie.posterUrl : defaultPoster}" />
                    <img src="${posterSrc}"
                         alt="${movie.title}"
                         class="movie-poster-img"
                         onerror="this.onerror=null; this.src='${defaultPoster}';">
                </div>
                <div class="movie-details">
                    <h2>${movie.title}</h2>
                    <div class="movie-meta">
                        <div class="movie-meta-item">
                            <i class="fa fa-clock-o"></i>
                            <span>${movie.duration} phút</span>
                        </div>
                        <c:if test="${not empty movie.ageRating}">
                            <div class="movie-meta-item">
                                <i class="fa fa-user"></i>
                                <span class="badge">${movie.ageRating}</span>
                            </div>
                        </c:if>
                        <c:if test="${not empty movie.director}">
                            <div class="movie-meta-item">
                                <i class="fa fa-video-camera"></i>
                                <span>Đạo diễn: ${movie.director}</span>
                            </div>
                        </c:if>
                    </div>
                    <c:if test="${not empty movie.genres}">
                        <p class="movie-description mb-2">
                            <strong>Thể loại:</strong>
                            <c:forEach var="g" items="${movie.genres}" varStatus="s">
                                ${g}<c:if test="${!s.last}">, </c:if>
                            </c:forEach>
                        </p>
                    </c:if>
                    <c:if test="${not empty movie.description}">
                        <p class="movie-description">${movie.description}</p>
                    </c:if>
                </div>
            </div>
        </div>
    </c:if>

    <div class="showtimes-section">
        <!-- Chọn ngày chiếu theo style date-display -->
        <h3>
            <i class="fa fa-calendar"></i>
            Chọn ngày chiếu
        </h3>

        <div class="mb-3">
            <div class="d-flex flex-wrap gap-2 mt-2">
                <c:forEach var="d" items="${dateList}">
                    <c:set var="isSelected" value="${d eq selectedDate}" />
                    <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=${movie.movieId}&date=${d}"
                       class="btn ${isSelected ? 'btn-primary' : 'btn-outline-primary'} btn-sm"
                       title="Ngày chiếu: <fmt:formatDate value='${java.sql.Date.valueOf(d)}' pattern='dd/MM/yyyy'/>">
                        <fmt:formatDate value="${java.sql.Date.valueOf(d)}" pattern="dd/MM/yyyy"/>
                        <br/>
                        <small>
                            <fmt:formatDate value="${java.sql.Date.valueOf(d)}" pattern="EEE"/>
                        </small>
                    </a>
                </c:forEach>
            </div>
        </div>

        <!-- Ngày đang chọn -->
        <div class="date-display mb-4">
            <i class="fa fa-clock-o"></i>
            Suất chiếu ngày
            <strong>
                <fmt:formatDate value="${java.sql.Date.valueOf(selectedDate)}" pattern="dd/MM/yyyy"/>
            </strong>
        </div>

        <!-- Danh sách suất chiếu dạng card -->
        <c:choose>
            <c:when test="${not empty showtimes}">
                <div class="showtimes-grid">
                    <c:forEach var="showtime" items="${showtimes}">
                        <div class="showtime-card">
                            <div class="showtime-time">
                                <i class="fa fa-clock-o"></i>
                                <span>
                                    <fmt:formatDate value="${java.sql.Time.valueOf(showtime.startTime)}" pattern="HH:mm"/>
                                </span>
                            </div>

                            <div class="seat-availability">
                                <div class="seat-availability-label">
                                    <i class="fa fa-chair"></i>
                                    <span>Suất chiếu khả dụng</span>
                                </div>
                                <div class="seat-count">
                                    Vé còn lại: ?
                                </div>
                            </div>

                            <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=${showtime.showtimeId}"
                               class="btn-select-showtime">
                                Chọn suất này
                            </a>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <p class="text-muted mt-2">
                    Hiện chưa có suất chiếu nào cho ngày
                    <fmt:formatDate value="${java.sql.Date.valueOf(selectedDate)}" pattern="dd/MM/yyyy"/>.
                </p>

                <!-- Dữ liệu thử nghiệm khi chưa có suất chiếu trong DB -->
                <div class="showtimes-grid mt-3">
                    <div class="showtime-card">
                        <div class="showtime-time">
                            <i class="fa fa-clock-o"></i>
                            <span>09:10</span>
                        </div>
                        <div class="seat-availability">
                            <div class="seat-availability-label">
                                <i class="fa fa-chair"></i>
                                <span>Suất chiếu thử nghiệm</span>
                            </div>
                            <div class="seat-count">Demo</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=1"
                           class="btn-select-showtime">
                            Chọn suất này
                        </a>
                    </div>
                    <div class="showtime-card">
                        <div class="showtime-time">
                            <i class="fa fa-clock-o"></i>
                            <span>11:00</span>
                        </div>
                        <div class="seat-availability">
                            <div class="seat-availability-label">
                                <i class="fa fa-chair"></i>
                                <span>Suất chiếu thử nghiệm</span>
                            </div>
                            <div class="seat-count">Demo</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=2"
                           class="btn-select-showtime">
                            Chọn suất này
                        </a>
                    </div>
                    <div class="showtime-card">
                        <div class="showtime-time">
                            <i class="fa fa-clock-o"></i>
                            <span>13:00</span>
                        </div>
                        <div class="seat-availability">
                            <div class="seat-availability-label">
                                <i class="fa fa-chair"></i>
                                <span>Suất chiếu thử nghiệm</span>
                            </div>
                            <div class="seat-count">Demo</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=3"
                           class="btn-select-showtime">
                            Chọn suất này
                        </a>
                    </div>
                    <div class="showtime-card">
                        <div class="showtime-time">
                            <i class="fa fa-clock-o"></i>
                            <span>15:30</span>
                        </div>
                        <div class="seat-availability">
                            <div class="seat-availability-label">
                                <i class="fa fa-chair"></i>
                                <span>Suất chiếu thử nghiệm</span>
                            </div>
                            <div class="seat-count">Demo</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=4"
                           class="btn-select-showtime">
                            Chọn suất này
                        </a>
                    </div>
                    <div class="showtime-card">
                        <div class="showtime-time">
                            <i class="fa fa-clock-o"></i>
                            <span>19:45</span>
                        </div>
                        <div class="seat-availability">
                            <div class="seat-availability-label">
                                <i class="fa fa-chair"></i>
                                <span>Suất chiếu thử nghiệm</span>
                            </div>
                            <div class="seat-count">Demo</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=5"
                           class="btn-select-showtime">
                            Chọn suất này
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-3">
                ${error}
            </div>
        </c:if>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>

