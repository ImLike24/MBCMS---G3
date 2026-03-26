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
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/booking-tickets.css">
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
                        <form method="get" action="${pageContext.request.contextPath}/booking-tickets"
                            id="formSeatMap">
                            <input type="hidden" name="showtimeId" value="${param.showtimeId}">
                            <div>
                                <div class="movie-info-header">
                                    <c:set var="defaultPoster"
                                        value="${pageContext.request.contextPath}/images/default_poster.jpg" />
                                    <c:set var="posterSrc"
                                        value="${not empty movie.posterUrl ? movie.posterUrl : defaultPoster}" />
                                    <img src="${posterSrc}" alt="${movie.title}" class="movie-poster-small"
                                        onerror="this.onerror=null; this.src='${defaultPoster}';">
                                    <div class="movie-info-text">
                                        <h2 class="mb-1">${movie.title}</h2>
                                        <div class="movie-info-meta">
                                            <span><i class="fa fa-door-open-o"></i> ${room.roomName}</span>
                                            <span><i class="fa fa-clock-o"></i> ${showtime.startTime}</span>
                                            <span><i class="fa fa-calendar"></i> ${showtime.showDate}</span>
                                            <span class="text-muted">
                                                <i class="fa fa-info-circle"></i>
                                                Còn trống: ${room.totalSeats - occupiedSeats.size()} /
                                                ${room.totalSeats}
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
                                                                <c:set var="seatChecked" value="false" />
                                                                <c:forEach var="sid" items="${selectedSeatIds}">
                                                                    <c:if test="${sid == seat.seatId}">
                                                                        <c:set var="seatChecked" value="true" />
                                                                    </c:if>
                                                                </c:forEach>
                                                                <label
                                                                    class="seat available ${seat.seatType == 'VIP' ? 'vip' : ''} ${seat.seatType == 'COUPLE' ? 'couple' : ''}">
                                                                    <input type="checkbox" name="seatIds"
                                                                        value="${seat.seatId}" class="seat-checkbox"
                                                                        <c:if test="${seatChecked}">checked="checked"
                                                                    </c:if>>
                                                                    <span>${seat.seatCode}</span>
                                                                </label>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="seat booked ${seat.seatType == 'VIP' ? 'vip' : ''} ${seat.seatType == 'COUPLE' ? 'couple' : ''}"
                                                                    title="Ghế đã được đặt">
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
                                    <div class="concession-counter mt-4">
                                        <h4 class="mb-2"><i class="fa fa-coffee"></i> Quầy đồ ăn / Thức uống</h4>
                                        <c:choose>
                                            <c:when test="${not empty concessionsList}">
                                                <p class="small text-muted mb-2">Xem danh sách món bên dưới, nhấn
                                                    <strong>Chọn món</strong> để chỉnh số lượng ở phần <strong>Thông tin
                                                        mua hàng</strong> bên phải.</p>
                                                <div class="concession-list">
                                                    <c:forEach var="c" items="${concessionsList}">
                                                        <div class="concession-row">
                                                            <div class="flex-grow-1">
                                                                <span class="concession-name">${c.concessionName}</span>
                                                                <span
                                                                    class="concession-type small text-muted">(${c.concessionType})</span>
                                                                <div class="small text-muted mt-1">
                                                                    Giá:
                                                                    <fmt:formatNumber value="${c.priceBase}"
                                                                        type="number" maxFractionDigits="0" /> ₫
                                                                    · Kho: ${c.quantity != null ? c.quantity : 0} món
                                                                </div>
                                                            </div>
                                                            <button type="button"
                                                                class="btn btn-sm btn-outline-warning ms-2 btn-jump-concession"
                                                                data-concession-id="${c.concessionId}">
                                                                Chọn món
                                                            </button>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="concession-empty text-muted mb-0"><i
                                                        class="fa fa-info-circle"></i> Hiện đồ ăn / thức uống chưa được
                                                    bán!</p>
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
                                        <fmt:formatNumber value="${basePrice}" type="number" maxFractionDigits="0" /> ₫
                                    </p>
                                    <c:choose>
                                        <c:when test="${not empty selectedSeatsInfo}">
                                            <form method="post"
                                                action="${pageContext.request.contextPath}/booking-tickets"
                                                id="bookingSummaryForm">
                                                <input type="hidden" name="showtimeId" value="${param.showtimeId}">
                                                <div id="bookingPricesConfig"
                                                    data-adult="${adultPrice != null ? adultPrice : 0}"
                                                    data-child="${childPrice != null ? childPrice : 0}"
                                                    data-surcharges='${surchargeRatesJson != null ? surchargeRatesJson : "{}"}'
                                                    style="display:none;"></div>
                                                <div class="selected-seats-list mb-2">
                                                    <c:forEach var="seatInfo" items="${selectedSeatsInfo}">
                                                        <c:set var="st"
                                                            value="${seatInfo.seatType != null ? seatInfo.seatType : 'NORMAL'}" />
                                                        <div class="selected-seat-item" data-seat-type="${st}">
                                                            <input type="hidden" name="seatIds"
                                                                value="${seatInfo.seatId}">
                                                            <div class="seat-item-header">
                                                                <span class="seat-code">${seatInfo.seatCode}</span>
                                                                <span class="seat-price" data-price="${seatInfo.price}">
                                                                    <fmt:formatNumber value="${seatInfo.price}"
                                                                        type="number" maxFractionDigits="0" /> ₫
                                                                </span>
                                                                <c:url var="removeSeatUrl"
                                                                    value="/booking-tickets">
                                                                    <c:param name="showtimeId" value="${showtimeId}" />
                                                                    <c:forEach var="other" items="${selectedSeatsInfo}">
                                                                        <c:if test="${other.seatId != seatInfo.seatId}">
                                                                            <c:param name="seatIds"
                                                                                value="${other.seatId}" />
                                                                            <c:param name="ticketType_${other.seatId}"
                                                                                value="${other.ticketType}" />
                                                                        </c:if>
                                                                    </c:forEach>
                                                                    <c:forEach var="c" items="${concessionsList}">
                                                                        <c:param name="concession_${c.concessionId}"
                                                                            value="${concessionQty[c.concessionId] != null ? concessionQty[c.concessionId] : 0}" />
                                                                    </c:forEach>
                                                                </c:url>
                                                                <a href="${removeSeatUrl}" class="btn-remove-seat"
                                                                    title="Bỏ ghế này"
                                                                    data-seat-id="${seatInfo.seatId}">&times;</a>
                                                            </div>
                                                            <div class="ticket-type-selector">
                                                                <label class="ticket-type-btn">
                                                                    <input type="radio"
                                                                        name="ticketType_${seatInfo.seatId}"
                                                                        value="ADULT" ${seatInfo.ticketType=='ADULT'
                                                                        ? 'checked' : '' }>
                                                                    <i class="fa fa-user"></i> Người lớn
                                                                </label>
                                                                <label class="ticket-type-btn">
                                                                    <input type="radio"
                                                                        name="ticketType_${seatInfo.seatId}"
                                                                        value="CHILD" ${seatInfo.ticketType=='CHILD'
                                                                        ? 'checked' : '' }>
                                                                    <i class="fa fa-child"></i> Trẻ em
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                                <div class="voucher-section mt-3 mb-2">
                                                    <label class="form-label small mb-1"><i class="fa fa-tag"></i> Nhập
                                                        mã thẻ giảm giá (nếu có)</label>
                                                    <input type="text" name="voucherCode"
                                                        class="form-control form-control-sm" placeholder="VD: TET2026"
                                                        value="<c:out value='${param.voucherCode}'/>" maxlength="50">
                                                </div>
                                                <c:if test="${not empty concessionsList}">
                                                    <div class="concession-section mt-3 mb-3">
                                                        <h4 class="mb-2"><i class="fa fa-coffee"></i> Đồ ăn / Thức uống
                                                        </h4>
                                                        <div class="concession-list" id="summaryConcessionList">
                                                            <c:forEach var="c" items="${concessionsList}">
                                                                <div class="concession-row summary-concession-row ${concessionQty[c.concessionId] != null && concessionQty[c.concessionId] > 0 ? '' : 'd-none'}"
                                                                    data-concession-id="${c.concessionId}">
                                                                    <span
                                                                        class="concession-name">${c.concessionName}</span>
                                                                    <span
                                                                        class="concession-type small text-muted">(${c.concessionType})</span>
                                                                    <span class="concession-price">
                                                                        <fmt:formatNumber value="${c.priceBase}"
                                                                            type="number" maxFractionDigits="0" /> ₫
                                                                    </span>
                                                                    <input type="number"
                                                                        name="concession_${c.concessionId}"
                                                                        value="${concessionQty[c.concessionId] != null ? concessionQty[c.concessionId] : 0}"
                                                                        min="0"
                                                                        class="form-control form-control-sm concession-qty summary-concession-qty"
                                                                        data-price="${c.priceBase}">
                                                                    <button type="button" class="btn-remove-concession"
                                                                        title="Bỏ món"
                                                                        data-remove-concession="${c.concessionId}">&times;</button>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </div>
                                                </c:if>
                                                <div class="price-summary">
                                                    <div class="price-row">
                                                        <span>Tổng vé:</span>
                                                        <span class="price-amount" id="ticketTotalEl">
                                                            <fmt:formatNumber value="${ticketTotal}" type="number"
                                                                maxFractionDigits="0" /> ₫
                                                        </span>
                                                    </div>
                                                    <c:if test="${not empty concessionsList}">
                                                        <div class="price-row">
                                                            <span>Tổng đồ ăn / thức uống:</span>
                                                            <span class="price-amount" id="concessionTotalEl">
                                                                <fmt:formatNumber value="${concessionTotal}"
                                                                    type="number" maxFractionDigits="0" /> ₫
                                                            </span>
                                                        </div>
                                                    </c:if>
                                                    <div class="price-row total">
                                                        <span>Tổng cộng:</span>
                                                        <span class="price-amount" id="grandTotalEl">
                                                            <fmt:formatNumber value="${totalAmount}" type="number"
                                                                maxFractionDigits="0" /> ₫
                                                        </span>
                                                    </div>
                                                </div>
                                                <p class="small text-muted mb-2">Đổi loại vé (Người lớn/Trẻ em) hoặc số
                                                    lượng đồ ăn — tổng tiền cập nhật ngay, không cần reload.</p>
                                                <div class="action-buttons mt-3">
                                                    <button type="submit"
                                                        class="btn btn-sm btn-warning btn-proceed px-4">
                                                        Tiếp tục
                                                    </button>
                                                </div>
                                            </form>
                                            <p class="mb-2 mt-2">
                                                <a href="${pageContext.request.contextPath}/booking-tickets?showtimeId=${showtimeId}"
                                                    class="btn btn-sm btn-outline-danger btn-clear-all">
                                                    Xóa toàn bộ ghế đã chọn
                                                </a>
                                            </p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="text-muted small mb-2">Chọn ghế bên trái để hiển thị danh sách ghế
                                                đã chọn và chọn loại vé (Người lớn / Trẻ em).</p>
                                        </c:otherwise>
                                    </c:choose>
                                    <p class="mb-0 small text-muted mt-2">
                                        <a href="${pageContext.request.contextPath}/booking-showtimes?movieId=${showtime.movieId}&date=${showtime.showDate}"
                                            class="text-decoration-none">&laquo; Quay lại chọn suất chiếu</a>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    // Tự động submit khi chọn/bỏ chọn ghế để cập nhật danh sách bên phải
                    (function () {
                        var form = document.getElementById('formSeatMap');
                        if (!form) return;
                        var timer = null;
                        form.querySelectorAll('.seat-checkbox').forEach(function (cb) {
                            cb.addEventListener('change', function () {
                                if (timer) clearTimeout(timer);
                                timer = setTimeout(function () { form.submit(); }, 200);
                            });
                        });
                        // Nút "Chọn món": hiện món ở Thông tin mua hàng + set qty mặc định
                        document.querySelectorAll('.btn-jump-concession').forEach(function (btn) {
                            btn.addEventListener('click', function () {
                                var id = this.getAttribute('data-concession-id');
                                var targetList = document.getElementById('summaryConcessionList');
                                if (!id || !targetList) return;
                                var row = targetList.querySelector('.summary-concession-row[data-concession-id=\"' + id + '\"]');
                                if (!row) return;
                                row.classList.remove('d-none');
                                var qtyInput = row.querySelector('.summary-concession-qty');
                                if (qtyInput) {
                                    var v = parseInt(qtyInput.value, 10) || 0;
                                    if (v <= 0) qtyInput.value = 1;
                                    qtyInput.dispatchEvent(new Event('input', { bubbles: true }));
                                    qtyInput.focus();
                                    qtyInput.select && qtyInput.select();
                                }
                                row.scrollIntoView && row.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                            });
                        });

                        // Nút bỏ món trong Thông tin mua hàng
                        document.querySelectorAll('[data-remove-concession]').forEach(function (btn) {
                            btn.addEventListener('click', function () {
                                var id = this.getAttribute('data-remove-concession');
                                var row = this.closest('.summary-concession-row');
                                if (!row) return;
                                var qtyInput = row.querySelector('.summary-concession-qty');
                                if (qtyInput) {
                                    qtyInput.value = 0;
                                    qtyInput.dispatchEvent(new Event('input', { bubbles: true }));
                                }
                                row.classList.add('d-none');
                            });
                        });
                    })();

                    (function () {
                        var config = document.getElementById('bookingPricesConfig');
                        if (!config) return;
                        var adultPrice = parseFloat(config.getAttribute('data-adult')) || 0;
                        var childPrice = parseFloat(config.getAttribute('data-child')) || 0;
                        var surcharges = {};
                        try {
                            surcharges = JSON.parse(config.getAttribute('data-surcharges') || '{}');
                        } catch (e) { }

                        function getSeatPrice(seatType, ticketType) {
                            var base = (ticketType === 'CHILD') ? childPrice : adultPrice;
                            var rate = surcharges[seatType] || 0;
                            return Math.round(base * (1 + rate / 100));
                        }

                        function formatVnd(n) {
                            return (n || 0).toLocaleString('vi-VN') + ' ₫';
                        }

                        function refreshTicketTotal() {
                            var total = 0;
                            document.querySelectorAll('.selected-seat-item').forEach(function (item) {
                                var seatType = item.getAttribute('data-seat-type') || 'NORMAL';
                                var radio = item.querySelector('input[type="radio"]:checked');
                                var ticketType = radio ? radio.value : 'ADULT';
                                var price = getSeatPrice(seatType, ticketType);
                                total += price;
                                var priceEl = item.querySelector('.seat-price');
                                if (priceEl) {
                                    priceEl.setAttribute('data-price', price);
                                    priceEl.textContent = formatVnd(price);
                                }
                            });
                            var el = document.getElementById('ticketTotalEl');
                            if (el) el.textContent = formatVnd(total);
                            return total;
                        }

                        function refreshConcessionTotal() {
                            var total = 0;
                            document.querySelectorAll('.summary-concession-qty').forEach(function (input) {
                                var qty = parseInt(input.value, 10) || 0;
                                var price = parseFloat(input.getAttribute('data-price')) || 0;
                                total += qty * price;
                            });
                            var el = document.getElementById('concessionTotalEl');
                            if (el) el.textContent = formatVnd(total);
                            return total;
                        }

                        function refreshGrandTotal() {
                            var ticket = 0;
                            document.querySelectorAll('.selected-seat-item .seat-price').forEach(function (el) {
                                ticket += parseInt(el.getAttribute('data-price'), 10) || 0;
                            });
                            var concession = 0;
                            document.querySelectorAll('.summary-concession-qty').forEach(function (input) {
                                var qty = parseInt(input.value, 10) || 0;
                                concession += qty * (parseFloat(input.getAttribute('data-price')) || 0);
                            });
                            var el = document.getElementById('grandTotalEl');
                            if (el) el.textContent = formatVnd(ticket + concession);
                        }

                        document.querySelectorAll('.selected-seat-item').forEach(function (item) {
                            item.querySelectorAll('input[type="radio"]').forEach(function (radio) {
                                radio.addEventListener('change', function () {
                                    refreshTicketTotal();
                                    refreshGrandTotal();
                                });
                            });
                        });

                        document.querySelectorAll('.summary-concession-qty').forEach(function (input) {
                            input.addEventListener('input', function () { refreshConcessionTotal(); refreshGrandTotal(); });
                            input.addEventListener('change', function () { refreshConcessionTotal(); refreshGrandTotal(); });
                        });
                    })();
                </script>
            </body>

            </html>