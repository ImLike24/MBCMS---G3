<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="models.Movie" %>

<%
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
 %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Danh Sách Phim</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-5">
    <h2 class="text-center mb-4">Danh Sách Phim</h2>
    <div class="row">
        <c:forEach var="movie" items="${movies}">
            <div class="col-md-4 mb-4">
                <div class="card h-100">
                    <img src="${movie.posterUrl}" class="card-img-top" alt="${movie.title}" style="height: 300px; object-fit: cover;">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">${movie.title}</h5>
                        <p class="card-text">${movie.description}</p>
                        <p class="card-text"><small class="text-muted">Thể loại: ${movie.genre}</small></p>
                        <p class="card-text"><small class="text-muted">Đạo diễn: ${movie.director}</small></p>
                        <p class="card-text"><small class="text-muted">Thời lượng: ${movie.duration} phút</small></p>
                        <p class="card-text">
    <small class="text-muted">
        Ngày phát hành:
        <%
            Movie m = (Movie) pageContext.getAttribute("movie");
            if (m != null && m.getReleaseDate() != null) {
                out.print(m.getReleaseDate().format(formatter));
            }
        %>
    </small>
</p>

                        <div class="mt-auto">
                            <a href="${pageContext.request.contextPath}/pages/movie_detail.jsp?movieId=${movie.movieId}" class="btn btn-primary">Xem Chi Tiết</a>
                            <a href="${pageContext.request.contextPath}/customer/online-booking-showtimes?movieId=${movie.movieId}" class="btn btn-success ms-2">Đặt Vé</a>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    <c:if test="${empty movies}">
        <p class="text-center">Không có phim nào.</p>
    </c:if>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>