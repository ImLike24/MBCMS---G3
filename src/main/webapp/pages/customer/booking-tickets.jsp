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
    <!-- Tái sử dụng CSS sơ đồ ghế từ khu vực staff/counter -->
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

                <div class="seat-map" id="seatMap"></div>

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
                    <p class="mb-2"><strong><i class = "fa fa-money"></i>Giá vé cơ bản:</strong><fmt:formatNumber value="${basePrice}" type="number" maxFractionDigits="0"/> ₫</p>
                    <p>
                        <i class="fa fa-info-circle"></i>
                        Chọn ghế ở bên trái để tiếp tục. (Thanh toán sẽ nối sau)
                    </p>
                </div>

                <div id="selectedSeatsList" class="selected-seats-list">
                    <div class="empty-selection text-muted">
                        <i class="fa fa-hand-pointer-o"></i>
                        <p>Chưa chọn ghế nào.<br/>Click vào ghế trống để bắt đầu.</p>
                    </div>
                </div>

                <div id="priceSummary" class="price-summary" style="display:none;">
                    <div class="price-row total">
                        <span>Tạm tính:</span>
                        <span class="price-amount" id="totalAmount">0 VND</span>
                    </div>
                </div>

                <div class="action-buttons mt-3">
                    <button type="button" class="btn-proceed" id="btnProceed" disabled>
                        Tiếp tục
                    </button>
                    <button type="button" class="btn-clear" id="clearSelectionBtn">
                        Xóa lựa chọn ghế
                    </button>
                    <a href="javascript:history.back()" class="btn btn-link text-decoration-none mt-2">
                        &laquo; Quay lại chọn suất chiếu
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const seatsData = [
        <c:forEach items="${seatsWithStatus}" var="seatInfo" varStatus="status">
        {
            seatId: ${seatInfo.seat.seatId},
            seatCode: '${seatInfo.seat.seatCode}',
            seatType: '${seatInfo.seat.seatType}',
            rowNumber: '${seatInfo.seat.rowNumber}',
            seatNumber: ${seatInfo.seat.seatNumber},
            bookingStatus: '${seatInfo.bookingStatus}'
        }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const basePrice = ${basePrice};
    const surchargeRates = {
        <c:forEach var="s" items="${surchargeList}" varStatus="vs">'${s.seatType}': ${s.surchargeRate}<c:if test="${!vs.last}">,</c:if></c:forEach>
    };
    let selectedSeats = [];
    const seatElementsById = {};

    function renderSeatMap() {
        const seatMap = document.getElementById('seatMap');
        if (!seatMap) return;
        seatMap.innerHTML = '';
        Object.keys(seatElementsById).forEach(k => delete seatElementsById[k]);

        const seatsByRow = {};
        seatsData.forEach(seat => {
            const row = seat.rowNumber || '';
            if (!seatsByRow[row]) seatsByRow[row] = [];
            seatsByRow[row].push(seat);
        });

        Object.keys(seatsByRow).sort().forEach(rowNumber => {
            const rowEl = document.createElement('div');
            rowEl.className = 'seat-row';

            const labelLeft = document.createElement('div');
            labelLeft.className = 'row-label';
            labelLeft.textContent = rowNumber;
            rowEl.appendChild(labelLeft);

            const seatsContainer = document.createElement('div');
            seatsContainer.className = 'seats-container';

            seatsByRow[rowNumber].sort((a, b) => a.seatNumber - b.seatNumber).forEach(seat => {
                const seatEl = document.createElement('div');
                seatEl.className = 'seat';
                seatEl.setAttribute('data-seat-id', seat.seatId);
                seatEl.textContent = seat.seatCode;

                seatElementsById[seat.seatId] = seatEl;

                if (seat.seatType === 'VIP') seatEl.classList.add('vip');
                if (seat.seatType === 'COUPLE') seatEl.classList.add('couple');

                if (seat.bookingStatus === 'AVAILABLE') {
                    seatEl.classList.add('available');
                    seatEl.onclick = function () { toggleSeatById(seat.seatId); };
                } else {
                    seatEl.classList.add('booked');
                    seatEl.title = 'Ghế đã được đặt';
                }

                seatsContainer.appendChild(seatEl);
            });

            rowEl.appendChild(seatsContainer);

            const labelRight = document.createElement('div');
            labelRight.className = 'row-label';
            labelRight.textContent = rowNumber;
            rowEl.appendChild(labelRight);

            seatMap.appendChild(rowEl);
        });
    }

    function toggleSeatById(seatId) {
        const seat = seatsData.find(s => s.seatId === seatId);
        if (!seat) return;
        const seatEl = seatElementsById[seatId];
        if (!seatEl) return;

        const idx = selectedSeats.findIndex(s => s.seatId === seatId);
        if (idx > -1) {
            selectedSeats.splice(idx, 1);
            seatEl.classList.remove('selected');
        } else {
            selectedSeats.push(seat);
            seatEl.classList.add('selected');
        }
        updateBookingSummary();
    }

    function updateBookingSummary() {
        const listContainer = document.getElementById('selectedSeatsList');
        const priceSummary = document.getElementById('priceSummary');
        const btnProceed = document.getElementById('btnProceed');

        if (!listContainer || !priceSummary || !btnProceed) return;

        if (selectedSeats.length === 0) {
            listContainer.innerHTML = `
                <div class="empty-selection text-muted">
                    <i class="fa fa-hand-pointer-o"></i>
                    <p>Chưa chọn ghế nào.<br/>Click vào ghế trống để bắt đầu.</p>
                </div>
            `;
            priceSummary.style.display = 'none';
            btnProceed.disabled = true;
            return;
        }

        listContainer.innerHTML = '';
        selectedSeats
            .slice()
            .sort((a, b) => (a.seatCode || '').localeCompare(b.seatCode || ''))
            .forEach(seat => {
                const item = document.createElement('div');
                item.className = 'selected-seat-item';
                item.innerHTML = `
                    <div class="seat-item-header">
                        <span class="seat-code">${seat.seatCode}</span>
                        <button class="btn-remove-seat" type="button" title="Bỏ ghế" onclick="removeSeat(${seat.seatId})">
                            <i class="fa fa-times"></i>
                        </button>
                    </div>
                `;
                listContainer.appendChild(item);
            });

        let total = 0;
        selectedSeats.forEach(seat => {
            let price = basePrice || 0;
            const rate = surchargeRates[seat.seatType];
            if (rate != null && rate > 0) price *= (1 + rate/100);
            total += price;
        });

        document.getElementById('totalAmount').textContent = formatCurrency(total);
        priceSummary.style.display = 'block';
        btnProceed.disabled = false;
    }

    function removeSeat(seatId) {
        toggleSeatById(seatId);
    }

    function formatCurrency(amount) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount || 0);
    }

    document.addEventListener('DOMContentLoaded', function () {
        renderSeatMap();
        updateBookingSummary();

        const clearBtn = document.getElementById('clearSelectionBtn');
        if (clearBtn) {
            clearBtn.addEventListener('click', function () {
                if (selectedSeats.length === 0) return;
                if (!window.confirm('Xóa toàn bộ ghế đã chọn?')) return;
                selectedSeats.forEach(seat => {
                    const el = seatElementsById[seat.seatId];
                    if (el) el.classList.remove('selected');
                });
                selectedSeats = [];
                updateBookingSummary();
            });
        }

        const btnProceed = document.getElementById('btnProceed');
        if (btnProceed) {
            btnProceed.addEventListener('click', function () {
                if (selectedSeats.length === 0) return;
                alert('Bước thanh toán chưa được triển khai. Hiện tại bạn đã chọn được ghế.');
            });
        }
    });
</script>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>

