<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chọn ghế - ${movieTitle}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <!-- Tái sử dụng CSS sơ đồ ghế từ khu vực staff/counter -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
</head>
<body>

<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-5 pt-4 mb-5">
    <div class="content-layout">
        <!-- Bên trái: thông tin phim + sơ đồ ghế sử dụng seat-map-section -->
        <div>
            <div class="movie-info-header">
                <div>
                    <h2 class="mb-1">${movieTitle}</h2>
                    <div class="movie-info-meta">
                        <span>
                            <i class="fa fa-film"></i> Phòng: ${roomName}
                        </span>
                        <span>
                            <i class="fa fa-calendar"></i>
                            <fmt:formatDate value="${java.sql.Date.valueOf(showDate)}" pattern="dd/MM/yyyy"/>
                        </span>
                        <span>
                            <i class="fa fa-clock-o"></i>
                            <fmt:formatDate value="${java.sql.Time.valueOf(startTime)}" pattern="HH:mm"/>
                        </span>
                    </div>
                </div>
            </div>

            <div class="seat-map-section">
                <div class="section-header">
                    <h3>
                        <i class="fa fa-chair"></i>
                        Chọn ghế ngồi
                    </h3>
                </div>

                <div class="screen"></div>

                <div class="seat-map">
                    <c:forEach var="row" items="${seatRows}">
                        <div class="seat-row">
                            <div class="row-label">${row}</div>
                            <div class="seats-container">
                                <c:forEach var="col" begin="1" end="${seatsPerRow}">
                                    <c:set var="seatCode" value="${row}${col}"/>
                                    <c:set var="isReserved"
                                           value="${reservedSeats[seatCode] != null && reservedSeats[seatCode]}"/>

                                    <div class="seat ${isReserved ? 'booked' : 'available'}"
                                         data-seat="${seatCode}">
                                        ${col}
                                    </div>
                                </c:forEach>
                            </div>
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
                </div>
            </div>
        </div>

        <!-- Bên phải: panel tóm tắt đặt vé dùng booking-summary -->
        <div>
            <div class="booking-summary">
                <h3>
                    <i class="fa fa-ticket"></i>
                    Thông tin đặt vé (demo)
                </h3>

                <div class="info-box mb-3">
                    <p>
                        <i class="fa fa-info-circle"></i>
                        Đây là màn hình <strong>demo sơ đồ ghế</strong> cho khách hàng.
                        Bạn có thể click chọn/bỏ chọn ghế, nhưng hiện tại chưa lưu vé vào cơ sở dữ liệu.
                    </p>
                </div>

                <div class="empty-selection text-muted">
                    <i class="fa fa-chair"></i>
                    <p>Chọn một hoặc nhiều ghế ở bên trái để tiếp tục.</p>
                </div>

                <div class="action-buttons mt-3">
                    <button type="button" class="btn-proceed" disabled>
                        Tiếp tục thanh toán (demo)
                    </button>
                    <button type="button" class="btn-clear" id="clearSelectionBtn">
                        Xóa lựa chọn ghế
                    </button>
                    <a href="${pageContext.request.contextPath}/customer/booking-showtimes?movieId=999"
                       class="btn btn-link text-decoration-none mt-2">
                        &laquo; Quay lại chọn suất chiếu
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Đổi trạng thái ghế khi click (chỉ UI, không ảnh hưởng server)
    document.addEventListener('DOMContentLoaded', function () {
        const seatElements = document.querySelectorAll('.seat');
        seatElements.forEach(function (seat) {
            if (seat.classList.contains('booked')) {
                return; // ghế đã đặt, không cho chọn
            }
            seat.addEventListener('click', function () {
                seat.classList.toggle('selected');
            });
        });

        const clearBtn = document.getElementById('clearSelectionBtn');
        if (clearBtn) {
            clearBtn.addEventListener('click', function () {
                document.querySelectorAll('.seat.selected').forEach(function (s) {
                    s.classList.remove('selected');
                });
            });
        }
    });
</script>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>

