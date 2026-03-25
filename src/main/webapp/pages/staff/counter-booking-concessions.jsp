<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn đồ ăn - Bán vé quầy</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        .concession-page {
            max-width: 900px;
            margin: 0 auto;
            padding: 0 20px 40px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .page-header h1 {
            font-size: 28px;
            color: #d96c2c;
            margin-bottom: 8px;
        }

        .page-header p {
            color: #aaa;
            font-size: 15px;
        }

        /* Booking summary bar */
        .booking-bar {
            background: rgba(217,108,44,0.08);
            border: 1px solid #d96c2c;
            border-radius: 10px;
            padding: 14px 20px;
            margin-bottom: 28px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
        }

        .booking-bar-label {
            color: #d96c2c;
            font-size: 13px;
            font-weight: 600;
            margin-right: 4px;
        }

        .seat-tag {
            display: inline-block;
            background: rgba(255,255,255,0.07);
            border: 1px solid #444;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            color: #ccc;
        }

        /* Concession grid */
        .concession-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
            margin-bottom: 32px;
        }

        .concession-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 12px;
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            transition: border-color 0.2s;
        }

        .concession-card.has-qty {
            border-color: #d96c2c;
        }

        .concession-card-name {
            font-size: 15px;
            font-weight: 600;
            color: white;
        }

        .concession-card-meta {
            font-size: 12px;
            color: #888;
        }

        .concession-card-price {
            font-size: 16px;
            font-weight: 700;
            color: #d96c2c;
        }

        .concession-qty-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 4px;
        }

        .qty-btn {
            width: 32px;
            height: 32px;
            border: 1px solid #444;
            background: #0c121d;
            color: #ccc;
            border-radius: 6px;
            font-size: 18px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            flex-shrink: 0;
        }

        .qty-btn:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        .qty-value {
            min-width: 32px;
            text-align: center;
            font-size: 16px;
            font-weight: 600;
            color: white;
        }

        .qty-subtotal {
            margin-left: auto;
            font-size: 13px;
            color: #aaa;
        }

        /* Order summary */
        .order-summary {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 28px;
        }

        .order-summary h3 {
            color: #d96c2c;
            font-size: 16px;
            margin-bottom: 16px;
        }

        .summary-line {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #ccc;
            padding: 5px 0;
            border-bottom: 1px solid #1e1e1e;
        }

        .summary-line:last-child {
            border-bottom: none;
        }

        .summary-total {
            display: flex;
            justify-content: space-between;
            font-size: 18px;
            font-weight: 700;
            color: white;
            padding-top: 14px;
            margin-top: 8px;
            border-top: 1px solid #333;
        }

        .summary-total .amount {
            color: #d96c2c;
        }

        /* Empty concessions */
        .empty-concessions {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            font-size: 14px;
        }

        .empty-concessions i {
            font-size: 40px;
            display: block;
            margin-bottom: 12px;
            color: #333;
        }

        /* Actions */
        .action-row {
            display: flex;
            gap: 14px;
        }

        .btn-back-page {
            flex: 0 0 auto;
            padding: 14px 24px;
            background: transparent;
            color: #ccc;
            border: 2px solid #333;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-back-page:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        .btn-proceed-payment {
            flex: 1;
            padding: 14px 24px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-proceed-payment:hover {
            background: #fff;
            color: #000;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <button class="sidebar-toggle" onclick="toggleSidebar()">
            <i class="fas fa-chevron-left"></i>
        </button>
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-film"></i></div>
            <h3>Nhân viên rạp</h3>
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard">
                    <i class="fas fa-home"></i><span>Bảng điều khiển</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="active">
                    <i class="fas fa-ticket-alt"></i><span>Bán vé tại quầy</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i><span>Lịch làm việc</span>
                </a>
            </li>
        </ul>
        <div class="sidebar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName.substring(0, 1).toUpperCase()}
                        </c:when>
                        <c:otherwise><i class="fas fa-user"></i></c:otherwise>
                    </c:choose>
                </div>
                <div class="user-details">
                    <div class="user-name">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.fullName}">${sessionScope.user.fullName}</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Nhân viên rạp</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="top-bar">
            <h1><i class="fas fa-coffee"></i> Chọn đồ ăn / thức uống</h1>
            <div class="top-bar-actions">
                <a href="javascript:history.back()" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Quay lại chọn ghế
                </a>
            </div>
        </div>

        <div class="concession-page">

            <!-- Seats summary bar -->
            <div class="booking-bar" id="bookingBar">
                <span class="booking-bar-label"><i class="fas fa-couch"></i> Ghế đã chọn:</span>
                <span id="seatsBarContent" style="color:#aaa; font-size:13px;">Đang tải...</span>
            </div>

            <!-- Concessions grid -->
            <c:choose>
                <c:when test="${not empty concessionsList}">
                    <div class="concession-grid" id="concessionGrid">
                        <c:forEach var="c" items="${concessionsList}">
                        <div class="concession-card" id="card_${c.concessionId}"
                             data-id="${c.concessionId}"
                             data-name="${c.concessionName}"
                             data-type="${c.concessionType}"
                             data-price="${c.priceBase}"
                             data-stock="${c.quantity != null ? c.quantity : 9999}">
                            <div>
                                <div class="concession-card-name">${c.concessionName}</div>
                                <div class="concession-card-meta">${c.concessionType}
                                    <c:if test="${c.quantity != null}"> &nbsp;·&nbsp; Kho: ${c.quantity}</c:if>
                                </div>
                            </div>
                            <div class="concession-card-price">
                                <fmt:formatNumber value="${c.priceBase}" type="number" maxFractionDigits="0"/> ₫
                            </div>
                            <div class="concession-qty-row">
                                <button class="qty-btn" onclick="changeQty(${c.concessionId}, -1)">−</button>
                                <span class="qty-value" id="qty_${c.concessionId}">0</span>
                                <button class="qty-btn" onclick="changeQty(${c.concessionId}, 1)">+</button>
                                <span class="qty-subtotal" id="sub_${c.concessionId}"></span>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-concessions">
                        <i class="fas fa-mug-hot"></i>
                        Hiện chưa có đồ ăn / thức uống để bán.
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Order summary -->
            <div class="order-summary">
                <h3><i class="fas fa-receipt"></i> Tóm tắt đơn hàng</h3>
                <div id="ticketSummaryLines"></div>
                <div id="concessionSummaryLines"></div>
                <div class="summary-total">
                    <span>Tổng cộng:</span>
                    <span class="amount" id="grandTotal">0 ₫</span>
                </div>
            </div>

            <!-- Actions -->
            <div class="action-row">
                <button class="btn-back-page" onclick="goBack()">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </button>
                <button class="btn-proceed-payment" onclick="proceedToPayment()">
                    <i class="fas fa-credit-card"></i> Tiếp tục thanh toán
                </button>
            </div>
        </div>
    </div>

    <%@ include file="confirm-modal.jsp" %>

    <script>
        const showtimeId = ${showtimeId};
        const ticketPrices  = { ADULT: ${adultPrice}, CHILD: ${childPrice} };
        const surchargeRates = {
            <c:forEach var="s" items="${surchargeList}" varStatus="vs">
            '${s.seatType}': ${s.surchargeRate}<c:if test="${!vs.last}">,</c:if>
            </c:forEach>
        };

        const bookingData = JSON.parse(sessionStorage.getItem('bookingData') || '{}');
        const concessionQty = {};
        const fmt = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

        // ── Seats bar ──────────────────────────────────────────────
        function renderSeatsBar() {
            const bar = document.getElementById('seatsBarContent');
            if (!bookingData.seats || bookingData.seats.length === 0) {
                bar.textContent = 'Không có ghế. Vui lòng quay lại.';
                return;
            }
            bar.innerHTML = bookingData.seats.map(s =>
                '<span class="seat-tag">' + s.seatCode + ' (' + s.ticketType + ')</span>'
            ).join(' ');
        }

        // ── Ticket total ───────────────────────────────────────────
        function getTicketTotal() {
            if (!bookingData.seats) return 0;
            return bookingData.seats.reduce((sum, seat) => {
                let price = ticketPrices[seat.ticketType] || ticketPrices['ADULT'] || 0;
                const rate = surchargeRates[seat.seatType];
                if (rate != null && rate > 0) price *= (1 + rate / 100);
                return sum + price;
            }, 0);
        }

        // ── Concession qty ─────────────────────────────────────────
        function changeQty(id, delta) {
            const card = document.getElementById('card_' + id);
            const stock = parseInt(card.getAttribute('data-stock')) || 9999;
            const current = concessionQty[id] || 0;
            let next = current + delta;
            if (next < 0) next = 0;
            if (next > stock) next = stock;
            concessionQty[id] = next;

            document.getElementById('qty_' + id).textContent = next;

            const price = parseFloat(card.getAttribute('data-price')) || 0;
            const subEl = document.getElementById('sub_' + id);
            subEl.textContent = next > 0 ? fmt.format(price * next) : '';

            card.classList.toggle('has-qty', next > 0);
            refreshSummary();
        }

        // ── Summary ────────────────────────────────────────────────
        function refreshSummary() {
            const ticketTotal = getTicketTotal();

            // ticket lines
            const ticketLines = document.getElementById('ticketSummaryLines');
            if (bookingData.seats && bookingData.seats.length > 0) {
                ticketLines.innerHTML = bookingData.seats.map(s => {
                    let price = ticketPrices[s.ticketType] || ticketPrices['ADULT'] || 0;
                    const rate = surchargeRates[s.seatType];
                    if (rate != null && rate > 0) price *= (1 + rate / 100);
                    return '<div class="summary-line"><span>' + s.seatCode + ' (' + s.ticketType + ')</span><span>' + fmt.format(price) + '</span></div>';
                }).join('');
            }

            // concession lines
            let concessionTotal = 0;
            const concLines = [];
            document.querySelectorAll('#concessionGrid .concession-card').forEach(card => {
                const id = parseInt(card.getAttribute('data-id'));
                const qty = concessionQty[id] || 0;
                if (qty > 0) {
                    const price = parseFloat(card.getAttribute('data-price')) || 0;
                    const name  = card.getAttribute('data-name');
                    const line  = price * qty;
                    concessionTotal += line;
                    concLines.push('<div class="summary-line"><span>' + name + ' x' + qty + '</span><span>' + fmt.format(line) + '</span></div>');
                }
            });
            document.getElementById('concessionSummaryLines').innerHTML = concLines.join('');
            document.getElementById('grandTotal').textContent = fmt.format(ticketTotal + concessionTotal);
        }

        // ── Navigation ─────────────────────────────────────────────
        function goBack() {
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking-seats?showtimeId=' + showtimeId;
        }

        function proceedToPayment() {
            if (!bookingData.seats || bookingData.seats.length === 0) {
                alert('Không có ghế được chọn. Vui lòng quay lại.');
                return;
            }

            const selectedConcessions = [];
            document.querySelectorAll('#concessionGrid .concession-card').forEach(card => {
                const id = parseInt(card.getAttribute('data-id'));
                const qty = concessionQty[id] || 0;
                if (qty > 0) {
                    selectedConcessions.push({
                        concessionId:   id,
                        concessionName: card.getAttribute('data-name'),
                        concessionType: card.getAttribute('data-type'),
                        quantity:       qty,
                        priceBase:      parseFloat(card.getAttribute('data-price')) || 0
                    });
                }
            });

            bookingData.concessions = selectedConcessions;
            sessionStorage.setItem('bookingData', JSON.stringify(bookingData));
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking-payment?showtimeId=' + showtimeId;
        }

        // ── Sidebar ────────────────────────────────────────────────
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
            const icon = document.querySelector('.sidebar-toggle i');
            icon.className = sidebar.classList.contains('collapsed')
                ? 'fas fa-chevron-right'
                : 'fas fa-chevron-left';
        }

        // ── Init ───────────────────────────────────────────────────
        document.addEventListener('DOMContentLoaded', function () {
            if (!bookingData.seats || bookingData.seats.length === 0) {
                window.location.href = '${pageContext.request.contextPath}/staff/counter-booking-seats?showtimeId=' + showtimeId;
                return;
            }
            renderSeatsBar();
            refreshSummary();
        });
    </script>
</body>
</html>
