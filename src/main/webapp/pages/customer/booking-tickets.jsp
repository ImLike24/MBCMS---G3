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

<jsp:include page="/components/layout/Sidebar.jsp"/>
<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-5 pt-4 mb-5">
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="content-layout mt-5">
        <div class="left-col">
            <div id="seatForm">
                <div class="screen-container">
                    <div class="screen-curve">MÀN HÌNH</div>
                </div>

                <div class="seat-map-container text-center overflow-auto mb-4">
                    <c:forEach var="entry" items="${seatsByRow}">
                        <div class="seat-row d-flex justify-content-center mb-2">
                            <div class="seat-row-label fw-bold me-3 align-self-center"
                                 style="width: 20px;">${entry.key}</div>
                            <div class="d-flex gap-2">
                                <c:forEach var="seatInfo" items="${entry.value}">
                                    <c:set var="seat" value="${seatInfo.seat}"/>
                                    <c:set var="isBooked" value="${seatInfo.bookingStatus == 'BOOKED'}"/>

                                    <c:set var="seatClass" value="normal" />
                                    <c:if test="${isBooked}"><c:set var="seatClass" value="booked" /></c:if>
                                    <c:if test="${seat.seatType == 'VIP' and not isBooked}"><c:set var="seatClass" value="vip" /></c:if>
                                    <c:if test="${seat.seatType == 'COUPLE' and not isBooked}"><c:set var="seatClass" value="couple" /></c:if>

                                    <div class="seat ${seatClass}"
                                         id="ui-seat-${seat.seatId}"
                                         title="${seat.seatCode} - ${seat.seatType}"
                                         onclick="toggleSeat('${seat.seatId}', '${seat.seatCode}', '${seat.seatType}')">
                                            ${seat.seatCode}
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="seat-legend mt-4">
                    <div class="d-flex align-items-center">
                        <div class="seat me-2"></div>
                        Thường
                    </div>
                    <div class="d-flex align-items-center">
                        <div class="seat vip me-2"></div>
                        VIP
                    </div>
                    <div class="d-flex align-items-center">
                        <div class="seat couple me-2"></div>
                        Couple
                    </div>
                    <div class="d-flex align-items-center">
                        <div class="seat booked me-2"></div>
                        Đã bán
                    </div>
                    <div class="d-flex align-items-center">
                        <div class="seat selected me-2"></div>
                        Đang chọn
                    </div>
                </div>

                <hr class="my-5">

                <div class="concessions-section mt-5">
                    <h5 class="mb-4 text-uppercase fw-bold" style="color: #d96c2c;">
                        <i class="fa fa-coffee me-2"></i>Đồ ăn/Thức uống
                    </h5>
                    <div class="row">
                        <c:forEach var="c" items="${concessionsList}">
                            <div class="col-md-6 mb-3">
                                <div class="d-flex align-items-center p-3 border rounded shadow-sm" style="background-color: #262626; border-color: #444 !important;">
                                    <div class="me-3 fs-3 text-warning">🍿🥤</div>

                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-white fw-bold">${c.concessionName}</h6>
                                        <div class="text-danger fw-bold">
                                            <fmt:formatNumber value="${c.priceBase}" type="currency" currencySymbol="₫"/>
                                        </div>
                                    </div>

                                    <div class="d-flex align-items-center gap-2">
                                        <button type="button" class="btn btn-outline-secondary btn-sm rounded-circle d-flex justify-content-center align-items-center" style="width: 32px; height: 32px;" onclick="changeQty('${c.concessionId}', -1)">
                                            <i class="fa fa-minus"></i>
                                        </button>

                                        <input type="text" id="qty-display-${c.concessionId}" class="form-control text-center bg-transparent text-white border-0 p-0 fw-bold fs-5" style="width: 30px;" value="0" readonly>

                                        <button type="button" class="btn btn-outline-warning btn-sm rounded-circle d-flex justify-content-center align-items-center" style="width: 32px; height: 32px;" onclick="changeQty('${c.concessionId}', 1)">
                                            <i class="fa fa-plus"></i>
                                        </button>

                                        <input type="hidden" id="conc-price-${c.concessionId}" value="${c.priceBase}">
                                        <input type="hidden" name="concession_${c.concessionId}" id="conc-input-${c.concessionId}" value="0">
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

            </div>
        </div>

        <div class="right-col">
            <div class="booking-summary-box sticky-top p-4 rounded shadow-sm"
                 style="top: 80px; background-color: #1a1a1a; color: #fff; border: 1px solid #333; border-radius: 10px;">
                <h5 class="border-bottom pb-3 mb-3 text-uppercase fw-bold"
                    style="color: #d96c2c; border-color: #333 !important;">Thông tin đặt vé</h5>
                <div class="mb-4 text-light">
                    <h6 class="fw-bold mb-2 fs-5 text-white">${movie.title}</h6>
                    <p class="mb-1 opacity-75 small">
                        <i class="fa fa-map-marker me-2" style="color: #d96c2c;"></i>Phòng chiếu: <span
                            class="fw-bold text-white">${room.roomName}</span>
                    </p>
                    <p class="mb-0 opacity-75 small">
                        <i class="fa fa-clock-o me-2" style="color: #d96c2c;"></i>Giờ chiếu: <span
                            class="fw-bold text-white">${showtime.startTime} | ${showtime.showDate}</span>
                    </p>
                </div>

                <div class="mb-4">
                    <h6 class="border-bottom pb-2 mb-3" style="border-color: #333 !important;">Ghế đã chọn:</h6>
                    <div id="selected-seats-list"></div>
                </div>

                <div class="mb-4">
                    <h6 class="border-bottom pb-2 mb-3" style="border-color: #333 !important;">Mã giảm giá</h6>
                    <div class="input-group">
                        <input type="text" class="form-control bg-dark text-light border-secondary"
                               id="voucherCodeInput" placeholder="Nhập mã..." value="">
                        <button class="btn btn-outline-success fw-bold" type="button" onclick="applyVoucherUI()">Áp
                            dụng
                        </button>
                    </div>
                    <small id="voucherMessage" class="form-text mt-1 d-block"></small>
                </div>

                <div class="border-top pt-3 mb-4 d-flex justify-content-between align-items-center"
                     style="border-color: #333 !important;">
                    <span class="fw-bold text-light">TỔNG TIỀN:</span>
                    <span class="fw-bold fs-4 text-danger" id="grandTotalEl">0 ₫</span>
                </div>

                <button type="button" onclick="submitToSummary()"
                        class="btn w-100 py-3 fw-bold text-uppercase shadow-sm"
                        style="background-color: #d96c2c; border-color: #d96c2c; color: white; transition: 0.3s; border-radius: 8px;">
                    Tiếp tục <i class="fa fa-arrow-right ms-2"></i>
                </button>
            </div>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    // 1. KHỞI TẠO STATE (Giỏ hàng trên bộ nhớ tạm của trình duyệt)
    const state = {
        showtimeId: '${showtimeId}',
        seats: new Map(),       // Lưu ghế đã chọn
        concessions: new Map(), // Lưu bắp nước
        voucherCode: ''
    };

    const pricingConfig = {
        adult: ${adultPrice != null ? adultPrice : 0},
        child: ${childPrice != null ? childPrice : 0},
        surcharges: ${surchargeRatesJson != null ? surchargeRatesJson : '{}'}
    };

    // 2. PHỤC HỒI DỮ LIỆU TỪ SESSION (Xử lý hoàn hảo nút Back)
    document.addEventListener("DOMContentLoaded", function() {

        <c:if test="${not empty sessionScope.customerBookingData and sessionScope.customerBookingData.showtimeId == showtimeId}">

        // A. Phục hồi Voucher
        <c:if test="${not empty sessionScope.customerBookingData.voucherCode}">
        state.voucherCode = '${sessionScope.customerBookingData.voucherCode}';
        let vInput = document.getElementById('voucherCodeInput');
        if (vInput) {
            vInput.value = state.voucherCode;
            // Kích hoạt luôn dòng chữ thông báo màu xanh trên UI
            let msgEl = document.getElementById('voucherMessage');
            if (msgEl) msgEl.innerHTML = '<span class="text-success"><i class="fa fa-check-circle"></i> Đã khôi phục mã: <b>' + state.voucherCode + '</b></span>';
        }
        </c:if>

        // B. Phục hồi Ghế
        <c:forEach var="seatMap" items="${sessionScope.customerBookingData.seats}">
        {
            let seatId = '${seatMap.seatId}';
            let tType = '${seatMap.ticketType}'; // ADULT hoặc CHILD
            let uiSeat = document.getElementById('ui-seat-' + seatId);

            // Chỉ phục hồi nếu ghế đó tồn tại trên màn hình và chưa bị ai khác mua mất
            if (uiSeat && !uiSeat.classList.contains('booked')) {

                // Trích xuất Tên ghế (seatCode) và Loại ghế (VIP/COUPLE) từ thuộc tính title của thẻ div
                let titleParts = uiSeat.getAttribute('title').split(' - ');
                let sName = titleParts[0];
                let sType = titleParts[1];

                // Dùng hàm JS để tính lại giá chính xác theo loại vé (Người lớn/Trẻ em)
                let sPrice = calculateSeatPrice(tType, sType);

                // Nạp vào Giỏ hàng State
                state.seats.set(seatId, {
                    id: seatId,
                    name: sName,
                    type: sType,
                    ticketType: tType,
                    price: sPrice
                });

                // Bật màu cam cho ghế
                uiSeat.classList.add('selected');
            }
        }
        </c:forEach>

        // C. Phục hồi Bắp nước
        <c:forEach var="conc" items="${sessionScope.customerBookingData.concessions}">
        {
            let cId = '${conc.concessionId}';
            let cQty = parseInt('${conc.quantity}') || 0;

            if (cQty > 0) {
                state.concessions.set(cId, cQty);
                // Điền lại số lượng vào ô input trên màn hình
                let concInput = document.querySelector('input[name="concession_' + cId + '"]');
                if (concInput) concInput.value = cQty;
            }
        }
        </c:forEach>

        </c:if>

        // Gọi hàm Render để vẽ toàn bộ giỏ hàng ra cột bên phải
        renderCart();
    });

    function calculateSeatPrice(ticketType, seatType) {
        let basePrice = (ticketType === 'CHILD') ? pricingConfig.child : pricingConfig.adult;
        let surchargePercent = pricingConfig.surcharges[seatType] || 0;

        // Tính theo %: Giá cơ bản * (1 + % Phụ phí)
        let finalPrice = basePrice * (1 + surchargePercent / 100.0);

        return Math.round(finalPrice); // Làm tròn số tiền
    }

    // 3. HÀM CHỌN / BỎ CHỌN GHẾ MƯỢT MÀ
    function toggleSeat(id, name, type) {
        let uiSeat = document.getElementById('ui-seat-' + id);
        if (uiSeat.classList.contains('booked')) return;

        if (state.seats.has(id)) {
            state.seats.delete(id);
            uiSeat.classList.remove('selected');
        } else {
            // Tự động tính giá ban đầu là vé ADULT
            let initialPrice = calculateSeatPrice('ADULT', type);
            state.seats.set(id, {
                id: id,
                name: name,
                type: type,
                ticketType: 'ADULT',
                price: initialPrice
            });
            uiSeat.classList.add('selected');
        }
        renderCart();
    }

    // 4. HÀM CẬP NHẬT LOẠI VÉ VÀ BẮP NƯỚC
    function updateTicketType(seatId, newType) {
        if (state.seats.has(seatId)) {
            let seat = state.seats.get(seatId);
            seat.ticketType = newType;
            // Tự động nhảy lại giá tiền khi khách chọn vé Trẻ em/HSSV
            seat.price = calculateSeatPrice(newType, seat.type);
            renderCart();
        }
    }

    // Hàm xử lý tăng giảm số lượng bắp nước mượt mà
    function changeQty(id, delta) {
        let displayInput = document.getElementById('qty-display-' + id);
        let realInput = document.getElementById('conc-input-' + id);
        let currentVal = parseInt(displayInput.value) || 0;
        let newVal = currentVal + delta;

        // Giới hạn cho phép mua từ 0 đến 10 combo
        if (newVal >= 0 && newVal <= 10) {
            displayInput.value = newVal;
            realInput.value = newVal;
            updateConcession(id, newVal); // Gọi lại hàm tổng của bạn để tính tiền
        }
    }

    function updateConcession(concessionId, quantity) {
        let qty = parseInt(quantity);
        if (isNaN(qty) || qty < 0) qty = 0;
        state.concessions.set(concessionId, qty);
        renderCart();
    }

    // 5. HÀM RENDER UI GIỎ HÀNG BÊN PHẢI (Không cần load lại trang)
    function renderCart() {
        const container = document.getElementById('selected-seats-list'); // ID của thẻ div chứa danh sách ghế bên cột phải
        if (!container) return;

        let html = '';
        let totalPrice = 0;

        // Vẽ danh sách ghế
        state.seats.forEach((seat, id) => {
            totalPrice += seat.price; // Nếu bạn có logic giảm giá cho CHILD, tính luôn ở đây

            html += `
                <div class="selected-seat-item mb-3 p-3 border border-secondary rounded shadow-sm" style="background-color: #2b2b2b; color: #fff;">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="fw-bold" style="color: #d96c2c;">Ghế: \${seat.name} (\${seat.type})</span>
                        <span class="fw-semibold text-danger">\${seat.price.toLocaleString()} ₫</span>
                    </div>
                    <div class="d-flex align-items-center">
                        <label class="me-2 small text-light">Loại vé:</label>
                        <select class="form-select form-select-sm bg-dark text-white border-secondary" onchange="updateTicketType('\${id}', this.value)">
                            <option value="ADULT" \${seat.ticketType === 'ADULT' ? 'selected' : ''}>Người lớn</option>
                            <option value="CHILD" \${seat.ticketType === 'CHILD' ? 'selected' : ''}>Trẻ em / HSSV</option>
                        </select>
                        <button type="button" class="btn btn-sm btn-outline-danger ms-2" onclick="toggleSeat('\${id}', '\${seat.name}', '\${seat.type}')">
                            <i class="fa fa-trash"></i>
                        </button>
                    </div>
                </div>
            `;
        });

        if (state.seats.size === 0) {
            html = '<div class="alert alert-secondary text-center">Bạn chưa chọn ghế nào.</div>';
        }

        container.innerHTML = html;

        // Tính cộng dồn tiền bắp nước
        state.concessions.forEach((qty, id) => {
            let priceBase = parseFloat(document.getElementById('conc-price-' + id)?.value || 0);
            totalPrice += (qty * priceBase);
        });

        // Hiển thị tổng tiền
        let totalEl = document.getElementById('grandTotalEl');
        if (totalEl) totalEl.innerText = totalPrice.toLocaleString() + ' ₫';
    }

    // 6. SUBMIT DỮ LIỆU ĐỂ ĐI TỚI THANH TOÁN
    function submitToSummary() {
        if (state.seats.size === 0) {
            alert('Vui lòng chọn ít nhất 1 ghế để tiếp tục!');
            return;
        }

        // Tạo một form ảo để POST toàn bộ state lên BE
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/booking-tickets';

        // Nhét showtimeId
        form.appendChild(createHiddenInput('showtimeId', state.showtimeId));

        // Nhét mã Voucher
        let vCode = document.getElementById('voucherCodeInput')?.value || '';
        if (vCode) form.appendChild(createHiddenInput('voucherCode', vCode));

        // Nhét thông tin từng ghế
        state.seats.forEach((seat, id) => {
            form.appendChild(createHiddenInput('seatIds', id));
            form.appendChild(createHiddenInput('ticketType_' + id, seat.ticketType));
        });

        // Nhét thông tin bắp nước
        state.concessions.forEach((qty, id) => {
            if (qty > 0) form.appendChild(createHiddenInput('concession_' + id, qty));
        });

        document.body.appendChild(form);
        form.submit();
    }

    function createHiddenInput(name, value) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        return input;
    }

    // Xử lý giao diện khi bấm nút Áp dụng Voucher
    function applyVoucherUI() {
        let vCode = document.getElementById('voucherCodeInput').value.trim();
        let msgEl = document.getElementById('voucherMessage');

        if (vCode === '') {
            msgEl.innerHTML = '<span class="text-warning"><i class="fa fa-exclamation-circle"></i> Vui lòng nhập mã giảm giá!</span>';
            state.voucherCode = '';
        } else {
            state.voucherCode = vCode;
            // Báo thành công tạm thời trên UI, việc kiểm tra hợp lệ thật sự sẽ do BE làm ở bước sau
            msgEl.innerHTML = '<span class="text-success"><i class="fa fa-check-circle"></i> Đã ghi nhận mã: <b>' + vCode + '</b></span>';
        }
    }
</script>
</body>

</html>