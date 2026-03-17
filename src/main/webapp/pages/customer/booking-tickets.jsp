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
                    <!-- Left: form GET – chọn ghế rồi bấm "Cập nhật ghế đã chọn" -->
                    <form method="get" action="${pageContext.request.contextPath}/customer/booking-tickets" id="formSeatMap">
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
                            <div class="mt-3 text-end">
                                <button type="submit" class="btn btn-sm btn-outline-warning px-4 seat-update-btn">
                                    <i class="fa fa-sync"></i> Cập nhật ghế đã chọn
                                </button>
                            </div>
                            <div class="concession-counter mt-4">
                                <h4 class="mb-2"><i class="fa fa-coffee"></i> Quầy đồ ăn / Thức uống</h4>
                                <c:choose>
                                    <c:when test="${not empty concessionsList}">
                                        <p class="small text-muted mb-2">Chọn số lượng bên dưới, sau khi chọn ghế bấm <strong>Cập nhật ghế đã chọn</strong> hoặc xem tổng ở <strong>Thông tin mua hàng</strong> bên phải.</p>
                                        <div class="concession-list">
                                            <c:forEach var="c" items="${concessionsList}">
                                                <div class="concession-row">
                                                    <span class="concession-name">${c.concessionName}</span>
                                                    <span class="concession-type small text-muted">(${c.concessionType})</span>
                                                    <span class="concession-price"><fmt:formatNumber value="${c.priceBase}" type="number" maxFractionDigits="0"/> ₫</span>
                                                    <input type="number" name="concession_${c.concessionId}" value="${concessionQty[c.concessionId] != null ? concessionQty[c.concessionId] : 0}" min="0" class="form-control form-control-sm concession-qty">
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="concession-empty text-muted mb-0"><i class="fa fa-info-circle"></i> Hiện đồ ăn / thức uống chưa được bán!</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    </form>

                    <!-- Right: thông tin mua hàng (vé + đồ ăn/thức uống), form POST khi Tiếp tục -->
                    <div>
                        <div class="booking-summary">
                            <h3><i class="fa fa-shopping-cart"></i> Thông tin mua hàng</h3>

                            <div class="info-box mb-3">
                                <p class="mb-2">
                                    <strong><i class="fa fa-money"></i> Giá vé cơ bản:</strong>
                                    <fmt:formatNumber value="${basePrice}" type="number" maxFractionDigits="0"/> ₫
                                </p>
                                <c:choose>
                                    <c:when test="${not empty selectedSeatsInfo}">
                                        <form method="post" action="${pageContext.request.contextPath}/customer/booking-tickets">
                                            <input type="hidden" name="showtimeId" value="${showtimeId}">
                                            <div class="selected-seats-list mb-2">
                                                <c:forEach var="seatInfo" items="${selectedSeatsInfo}">
                                                    <div class="selected-seat-item">
                                                        <input type="hidden" name="seatIds" value="${seatInfo.seatId}">
                                                        <div class="seat-item-header">
                                                            <span class="seat-code">${seatInfo.seatCode}</span>
                                                            <span class="seat-price"><fmt:formatNumber value="${seatInfo.price}" type="number" maxFractionDigits="0"/> ₫</span>
                                                            <c:url var="removeSeatUrl" value="/customer/booking-tickets">
                                                                <c:param name="showtimeId" value="${showtimeId}"/>
                                                                <c:forEach var="other" items="${selectedSeatsInfo}">
                                                                    <c:if test="${other.seatId != seatInfo.seatId}">
                                                                        <c:param name="seatIds" value="${other.seatId}"/>
                                                                        <c:param name="ticketType_${other.seatId}" value="${other.ticketType}"/>
                                                                    </c:if>
                                                                </c:forEach>
                                                                <c:forEach var="c" items="${concessionsList}">
                                                                    <c:param name="concession_${c.concessionId}" value="${concessionQty[c.concessionId] != null ? concessionQty[c.concessionId] : 0}"/>
                                                                </c:forEach>
                                                            </c:url>
                                                            <a href="${removeSeatUrl}" class="btn-remove-seat" title="Bỏ ghế này" data-seat-id="${seatInfo.seatId}">&times;</a>
                                                        </div>
                                                        <div class="ticket-type-selector">
                                                            <label class="ticket-type-btn ${seatInfo.ticketType == 'ADULT' ? 'active' : ''}">
                                                                <input type="radio" name="ticketType_${seatInfo.seatId}" value="ADULT" ${seatInfo.ticketType == 'ADULT' ? 'checked' : ''}>
                                                                <i class="fa fa-user"></i> Người lớn
                                                            </label>
                                                            <label class="ticket-type-btn ${seatInfo.ticketType == 'CHILD' ? 'active' : ''}">
                                                                <input type="radio" name="ticketType_${seatInfo.seatId}" value="CHILD" ${seatInfo.ticketType == 'CHILD' ? 'checked' : ''}>
                                                                <i class="fa fa-child"></i> Trẻ em
                                                            </label>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                            <c:if test="${not empty concessionsList}">
                                                <div class="concession-section mt-3 mb-3">
                                                    <h4 class="mb-2"><i class="fa fa-coffee"></i> Đồ ăn / Thức uống</h4>
                                                    <div class="concession-list">
                                                        <c:forEach var="c" items="${concessionsList}">
                                                            <div class="concession-row">
                                                                <span class="concession-name">${c.concessionName}</span>
                                                                <span class="concession-type small text-muted">(${c.concessionType})</span>
                                                                <span class="concession-price"><fmt:formatNumber value="${c.priceBase}" type="number" maxFractionDigits="0"/> ₫</span>
                                                                <input type="number" name="concession_${c.concessionId}" value="${concessionQty[c.concessionId] != null ? concessionQty[c.concessionId] : 0}" min="0" class="form-control form-control-sm concession-qty">
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:if>
                                            <div class="price-summary">
                                                <div class="price-row">
                                                    <span>Tổng vé:</span>
                                                    <span class="price-amount"><fmt:formatNumber value="${ticketTotal}" type="number" maxFractionDigits="0"/> ₫</span>
                                                </div>
                                                <c:if test="${not empty concessionsList}">
                                                    <div class="price-row">
                                                        <span>Tổng đồ ăn / thức uống:</span>
                                                        <span class="price-amount"><fmt:formatNumber value="${concessionTotal}" type="number" maxFractionDigits="0"/> ₫</span>
                                                    </div>
                                                </c:if>
                                                <div class="price-row total">
                                                    <span>Tổng cộng:</span>
                                                    <span class="price-amount"><fmt:formatNumber value="${totalAmount}" type="number" maxFractionDigits="0"/> ₫</span>
                                                </div>
                                            </div>
                                            <p class="small text-muted mb-2">Đổi loại vé hoặc số lượng đồ ăn rồi bấm <strong>Cập nhật tổng</strong> để xem lại tiền.</p>
                                            <div class="action-buttons mt-3">
                                                <button type="submit"
                                                        name="action"
                                                        value="update"
                                                        formmethod="get"
                                                        formaction="${pageContext.request.contextPath}/customer/booking-tickets"
                                                        class="btn btn-sm btn-outline-light btn-update-total">
                                                    <i class="fa fa-calculator"></i> Cập nhật tổng
                                                </button>
                                                <button type="submit" class="btn btn-sm btn-warning btn-proceed px-4">
                                                    Tiếp tục
                                                </button>
                                            </div>
                                        </form>
                                        <p class="mb-2 mt-2">
                                            <a href="${pageContext.request.contextPath}/customer/booking-tickets?showtimeId=${showtimeId}" class="btn btn-sm btn-outline-danger btn-clear-all">
                                                Xóa toàn bộ ghế đã chọn
                                            </a>
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted small mb-2">Chọn ghế bên trái, bấm <strong>Cập nhật ghế đã chọn</strong> để hiển thị danh sách và chọn loại vé (Người lớn / Trẻ em).</p>
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
            .content-layout {
                display: grid;
                grid-template-columns: minmax(0, 2.2fr) minmax(0, 1.1fr);
                gap: 24px;
                align-items: flex-start;
            }

            .booking-summary {
                background: #121212;
                border-radius: 16px;
                padding: 18px 20px;
                box-shadow: 0 12px 30px rgba(0, 0, 0, 0.55);
                border: 1px solid rgba(255, 255, 255, 0.06);
            }

            .booking-summary h3 {
                font-size: 18px;
                margin-bottom: 14px;
            }

            .info-box {
                background: linear-gradient(145deg, #191919, #101010);
                border-radius: 12px;
                padding: 14px 16px;
            }

            .seat-map-section {
                background: #111;
                border-radius: 16px;
                padding: 16px 18px 18px;
                box-shadow: 0 10px 24px rgba(0, 0, 0, 0.45);
                border: 1px solid rgba(255, 255, 255, 0.05);
            }

            .seat-checkbox { display: none; }
            .seat input:checked + span,
            label.seat:has(.seat-checkbox:checked) {
                background: #d96c2c !important;
                color: #fff !important;
            }
            /* Giống counter-booking: nút Người lớn / Trẻ em */
            .booking-summary .ticket-type-selector {
                display: flex;
                gap: 8px;
            }
            .booking-summary .ticket-type-selector input[type="radio"] {
                display: none;
            }
            .booking-summary .ticket-type-selector .ticket-type-btn {
                flex: 1;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                padding: 8px 12px;
                border: 2px solid #262625;
                background: transparent;
                color: #ccc;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.3s;
                font-size: 13px;
                font-weight: 500;
                margin: 0;
            }
            .booking-summary .ticket-type-selector .ticket-type-btn:hover {
                border-color: #d96c2c;
                color: #d96c2c;
            }
            .booking-summary .ticket-type-selector .ticket-type-btn.active,
            .booking-summary .ticket-type-selector label:has(input:checked) {
                background: #d96c2c;
                border-color: #d96c2c;
                color: #fff;
            }
            .booking-summary .selected-seat-item .seat-item-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }
            .booking-summary .selected-seat-item .seat-price {
                margin-left: 0;
            }
            .price-summary {
                border-top: 1px solid #eee;
                padding-top: 8px;
                margin-top: 4px;
                font-size: 14px;
            }
            .price-row.total {
                display: flex;
                justify-content: space-between;
                font-weight: 600;
            }
            .price-amount {
                color: #d96c2c;
            }
            .btn-remove-seat {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 22px;
                height: 22px;
                border-radius: 999px;
                border: 1px solid #ff4b5c;
                color: #ff4b5c;
                background: transparent;
                cursor: pointer;
                font-size: 13px;
                padding: 0;
                text-decoration: none;
            }
            .btn-remove-seat:hover {
                background: #ff4b5c;
                color: #ffffff;
            }
            .seat-price {
                margin-left: auto;
                font-weight: 600;
                color: #d96c2c;
            }
            .btn-update-total {
                border-radius: 999px;
                padding-inline: 16px;
            }
            .btn-proceed {
                border-radius: 999px;
                font-weight: 600;
            }
            .btn-clear-all {
                border-radius: 999px;
                padding-inline: 16px;
            }
            .seat-update-btn {
                border-radius: 999px;
                font-size: 13px;
            }
            .concession-counter {
                background: rgba(255,255,255,0.04);
                border-radius: 12px;
                padding: 14px 16px;
                border: 1px solid rgba(255,255,255,0.08);
            }
            .concession-counter h4 { font-size: 16px; }
            .concession-empty { font-size: 14px; padding: 10px 0; }
            .concession-section h4 { font-size: 15px; }
            .concession-list { max-height: 200px; overflow-y: auto; }
            .concession-row {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 6px 0;
                border-bottom: 1px solid rgba(255,255,255,0.06);
            }
            .concession-row:last-child { border-bottom: none; }
            .concession-name { flex: 1; font-weight: 500; }
            .concession-price { color: #d96c2c; min-width: 70px; text-align: right; }
            .concession-qty { width: 64px; text-align: center; }
        </style>

        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
