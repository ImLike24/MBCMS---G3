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

            <div class="content-layout">
                    <!-- Left: movie info + seat map (form GET để "Cập nhật" hiển thị ghế đã chọn) -->
                    <form method="get" action="${pageContext.request.contextPath}/customer/booking-tickets">
                        <input type="hidden" name="showtimeId" value="${showtimeId}">
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
                                                        <c:set var="seatChecked" value="false"/>
                                                        <c:forEach var="sid" items="${selectedSeatIds}">
                                                            <c:if test="${sid == seat.seatId}"><c:set var="seatChecked" value="true"/></c:if>
                                                        </c:forEach>
                                                        <label class="seat available ${seat.seatType == 'VIP' ? 'vip' : ''} ${seat.seatType == 'COUPLE' ? 'couple' : ''}">
                                                            <input type="checkbox" name="seatIds" value="${seat.seatId}" class="seat-checkbox" <c:if test="${seatChecked}">checked="checked"</c:if>>
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
                            <div class="mt-3">
                                <button type="submit" class="btn btn-primary">Cập nhật — Hiển thị ghế đã chọn bên phải</button>
                            </div>
                        </div>
                    </div>
                    </form>

                    <!-- Right: booking summary (chỉ hiển thị khi đã chọn ghế và bấm Cập nhật) -->
                    <div>
                        <div class="booking-summary">
                            <h3><i class="fa fa-ticket"></i> Thông tin đặt vé</h3>

                            <div class="info-box mb-3">
                                <p class="mb-2">
                                    <strong><i class="fa fa-money"></i> Giá vé cơ bản:</strong>
                                    <fmt:formatNumber value="${basePrice}" type="number" maxFractionDigits="0"/> ₫
                                </p>
                                <c:choose>
                                    <c:when test="${not empty selectedSeatsInfo}">
                                        <p class="small text-muted mb-2">Chọn loại vé <strong>Người lớn</strong> / <strong>Trẻ em</strong> cho từng ghế, sau đó nhấn <strong>Tiếp tục</strong>:</p>
                                        <form method="post" action="${pageContext.request.contextPath}/customer/booking-tickets">
                                            <input type="hidden" name="showtimeId" value="${showtimeId}">
                                            <div class="selected-seats-list mb-2">
                                                <c:forEach var="seatInfo" items="${selectedSeatsInfo}">
                                                    <div class="seat-summary-row">
                                                        <span class="seat-code">${seatInfo.seatCode}</span>
                                                        <input type="hidden" name="seatIds" value="${seatInfo.seatId}">
                                                        <select name="ticketType_${seatInfo.seatId}" class="form-select form-select-sm ticket-type-select">
                                                            <option value="ADULT">Người lớn</option>
                                                            <option value="CHILD">Trẻ em (giảm 30%)</option>
                                                        </select>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                            <div class="action-buttons mt-3">
                                                <button type="submit" class="btn-proceed">Tiếp tục</button>
                                            </div>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted small mb-2">Chọn ghế bên trái, sau đó nhấn <strong>Cập nhật</strong> để hiển thị danh sách ghế và chọn loại vé (Người lớn / Trẻ em) cho từng ghế.</p>
                                    </c:otherwise>
                                </c:choose>
                                <p class="mb-0 small text-muted mt-2">
                                    <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=${showtime.movieId}&date=${showtime.showDate}" class="text-decoration-none">&laquo; Quay lại chọn suất chiếu</a>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
        </div>

        <style>
            .seat-checkbox { display: none; }
            .seat input:checked + span,
            label.seat:has(.seat-checkbox:checked) {
                background: #d96c2c !important;
                color: #fff !important;
            }
            .selected-seats-list .seat-summary-row {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 8px;
                padding: 6px 0;
                border-bottom: 1px solid #eee;
            }
            .selected-seats-list .seat-summary-row:last-child {
                border-bottom: none;
            }
            .selected-seats-list .seat-summary-check {
                display: flex;
                align-items: center;
                gap: 6px;
                min-width: 60px;
            }
            .selected-seats-list .seat-summary-check .seat-code {
                font-weight: 600;
            }
            .selected-seats-list .ticket-type-select {
                flex: 1;
                max-width: 180px;
            }
        </style>

        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
