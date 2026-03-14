<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn ghế - ${movieTitle}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
</head>
<body>

<jsp:include page="/components/layout/Sidebar.jsp" />
<jsp:include page="/components/layout/Header.jsp" />

<div class="container mt-5 pt-4 mb-5">
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/customer/booking-tickets">
        <input type="hidden" name="showtimeId" value="${showtimeId}">

        <div class="content-layout">
            <!-- Left: movie info + seat map -->
            <div>
                <div class="movie-info-header">
                    <c:set var="defaultPoster" value="${pageContext.request.contextPath}/images/default_poster.jpg" />
                    <c:set var="posterSrc" value="${not empty moviePosterUrl ? moviePosterUrl : defaultPoster}" />
                    <img src="${posterSrc}" alt="${movieTitle}" class="movie-poster-small"
                         onerror="this.onerror=null; this.src='${defaultPoster}';">
                    <div class="movie-info-text">
                        <h2 class="mb-1">${movieTitle}</h2>
                        <div class="movie-info-meta">
                            <span><i class="fa fa-door-open-o"></i> ${roomName}</span>
                            <span><i class="fa fa-clock-o"></i> ${formattedStartTime}</span>
                            <span><i class="fa fa-calendar"></i> ${formattedShowDate}</span>
                            <span><i class="fa fa-map-marker"></i> ${branchName}</span>
                            <span class="text-muted">
                                <i class="fa fa-info-circle"></i>
                                Còn trống: ${availableSeats} / ${totalSeats}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="seat-map-section">
                    <div class="section-header">
                        <h3><i class="fa fa-chair"></i> Chọn ghế ngồi</h3>
                    </div>

                    <div class="screen"></div>

                    <div class="seat-map" id="seatMap">
                        <c:forEach var="rowEntry" items="${seatsByRow}">
                            <div class="seat-row">
                                <div class="row-label">${rowEntry.key}</div>
                                <div class="seats-container">
                                    <c:forEach var="seatInfo" items="${rowEntry.value}">
                                        <c:set var="seat" value="${seatInfo.seat}" />
                                        <c:set var="status" value="${seatInfo.bookingStatus}" />
                                        <c:choose>
                                            <c:when test="${status == 'AVAILABLE'}">
                                                <label class="seat available ${seat.seatType == 'VIP' ? 'vip' : ''} ${seat.seatType == 'COUPLE' ? 'couple' : ''}">
                                                    <input type="checkbox" name="seatIds" value="${seat.seatId}" class="seat-checkbox">
                                                    <span>${seat.seatCode}</span>
                                                </label>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="seat booked ${seat.seatType == 'VIP' ? 'vip' : ''} ${seat.seatType == 'COUPLE' ? 'couple' : ''}" title="Ghế đã được đặt">
                                                    ${seat.seatCode}
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <div class="row-label">${rowEntry.key}</div>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="seat-legend mt-3">
                        <div class="legend-item">
                            <div class="legend-box available"></div>
                            <span>Ghế trống</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-box selected"></div>
                            <span>Ghế đã chọn</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-box booked"></div>
                            <span>Ghế đã đặt</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-box vip"></div>
                            <span>VIP</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-box couple"></div>
                            <span>Couple</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right: booking summary -->
            <div>
                <div class="booking-summary">
                    <h3><i class="fa fa-ticket"></i> Thông tin đặt vé</h3>

                    <div class="info-box mb-3">
                        <p class="mb-2">
                            <strong><i class="fa fa-money"></i> Giá vé cơ bản:</strong>
                            <fmt:formatNumber value="${basePrice}" type="number" maxFractionDigits="0"/> ₫
                        </p>
                        <div class="mb-2">
                            <label class="form-label"><strong>Loại vé (áp dụng cho tất cả ghế):</strong></label>
                            <select name="ticketType" class="form-select">
                                <option value="ADULT">Người lớn</option>
                                <option value="CHILD">Trẻ em (giảm 30%)</option>
                            </select>
                        </div>
                        <p class="mb-0 small text-muted">
                            <i class="fa fa-info-circle"></i>
                            Chọn ghế ở bên trái, sau đó nhấn <strong>Tiếp tục</strong> để sang bước thanh toán.
                        </p>
                    </div>

                    <div class="action-buttons mt-3">
                        <button type="submit" class="btn-proceed">
                            Tiếp tục
                        </button>
                        <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=${showtime.movieId}&date=${showtime.showDate}" class="btn btn-link text-decoration-none mt-2">
                            &laquo; Quay lại chọn suất chiếu
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<style>
    .seat-checkbox { display: none; }
    .seat input:checked + span,
    label.seat:has(.seat-checkbox:checked) { background: #d96c2c !important; color: #fff !important; }
</style>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
