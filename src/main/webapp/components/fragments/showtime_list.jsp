<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

            <c:if test="${empty movies}">
                <div class="text-center p-5 bg-light rounded">
                    <h4>Không có suất chiếu nào trong ngày này.</h4>
                </div>
            </c:if>

            <c:forEach var="movie" items="${movies}">
                <div class="movie-group">
                    <img src="${not empty movie.posterUrl ? movie.posterUrl : 'images/default-poster.jpg'}"
                        class="movie-poster" alt="${movie.title}">
                    <div class="movie-info">
                        <div class="movie-title">
                            <a href="${pageContext.request.contextPath}/movie?movieId=${movie.movieId}"
                                class="text-decoration-none text-black">${movie.title}</a>
                        </div>
                        <p>
                            <span class="badge bg-warning text-dark">${not empty movie.ageRating ? movie.ageRating :
                                'G'}</span>
                            ${movie.duration} phút
                        </p>
                        <div class="showtime-list">
                            <c:choose>
                                <c:when test="${not empty movie.showtimes}">
                                    <c:forEach var="st" items="${movie.showtimes}">
                                        <c:set var="timeStr" value="${st.startTime.toString().substring(0, 5)}" />
                                        <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=${st.showtimeId}"
                                            class="showtime-btn">${timeStr}</a>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Hết suất chiếu</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>