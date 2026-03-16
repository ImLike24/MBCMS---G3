<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Thanh toán vé phim</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
                <style>
                    .payment-card {
                        background: #1a1a1a;
                        border-radius: 15px;
                        padding: 30px;
                        color: #fff;
                    }

                    .payment-header h1 {
                        font-size: 26px;
                        color: #d96c2c;
                    }

                    .seat-tag {
                        display: inline-block;
                        background: rgba(255, 255, 255, 0.08);
                        border-radius: 999px;
                        padding: 4px 10px;
                        margin: 3px;
                        font-size: 13px;
                    }

                    .total-amount {
                        font-size: 22px;
                        font-weight: 600;
                        color: #d96c2c;
                    }

                    .receipt-box {
                        background: #0c121d;
                        border-radius: 10px;
                        padding: 15px;
                        margin-top: 20px;
                    }
                </style>
            </head>

            <body>

                <jsp:include page="/components/layout/Header.jsp" />

                <div class="container mt-5 pt-4 mb-5">
                    <div class="row justify-content-center">
                        <div class="col-lg-8">
                            <div class="payment-card">
                                <div class="payment-header text-center mb-4">
                                    <h1>Thanh toán vé phim</h1>
                                    <p class="text-muted mb-0">${movieTitle} - ${branchName}</p>
                                </div>

                                <div class="booking-summary mb-4">
                                    <h5 class="mb-2">Thông tin suất chiếu</h5>
                                    <p class="mb-1">
                                        <strong>Rạp:</strong> ${showtimeDetails.branchName}
                                    </p>
                                    <p class="mb-1">
                                        <strong>Phòng:</strong> ${showtimeDetails.roomName}
                                    </p>
                                    <p class="mb-1">
                                        <strong>Ngày chiếu:</strong> ${showDateFormatted}
                                        <strong class="ms-2">Giờ chiếu:</strong> ${showTimeFormatted}
                                    </p>
                                    <hr>
                                    <h5 class="mb-2">Ghế đã chọn</h5>
                                    <div id="selectedSeatsDisplay">
                                        <span class="text-muted">Đang tải dữ liệu ghế...</span>
                                    </div>
                                    <div class="voucher-section mt-4 pt-3 border-top border-secondary">
                                        <label class="form-label text-muted small mb-2">Mã Voucher</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control bg-dark border-secondary text-white"
                                                id="voucherCodeInput" placeholder="Nhập mã voucher..."
                                                value="${appliedVoucherCode}" ${isVoucherValid ? 'readonly' : '' }>
                                            <button class="btn btn-outline-warning" type="button" id="btnApplyVoucher"
                                                ${isVoucherValid ? 'disabled' : '' }>Áp dụng</button>
                                        </div>
                                        <div id="voucherMessage"
                                            class="small mt-2 ${isVoucherValid ? 'text-success' : 'text-danger'}">
                                            ${voucherMessage}
                                        </div>
                                    </div>

                                    <div class="summary-details mt-4">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="text-muted">Tổng tiền vé</span>
                                            <span class="text-light" id="baseAmountText">0 ₫</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-1 text-warning"
                                            id="discountArea"
                                            style="${discountAmount > 0 ? 'display:flex;' : 'display:none;'}">
                                            <span class="small">Giảm giá voucher</span>
                                            <span class="small" id="discountAmountText">-${fmtAmount}</span>
                                            <c:if test="${discountAmount > 0}">
                                                <fmt:setLocale value="vi_VN" />
                                                <fmt:formatNumber value="${discountAmount}" type="currency"
                                                    var="fmtDiscount" />
                                                <script>document.getElementById('discountAmountText').textContent = '-${fmtDiscount}';</script>
                                            </c:if>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-3">
                                            <span class="text-muted">Tổng thanh toán</span>
                                            <span class="total-amount" id="totalAmountText">0 ₫</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex gap-3">
                                    <button type="button" class="btn btn-primary flex-fill" id="btnConfirmPay">
                                        Xác nhận & Thanh toán VNPay
                                    </button>
                                </div>

                                <div id="paymentMessage" class="mt-3 text-success fw-semibold" style="display:none;">
                                </div>

                                <div id="receiptArea" class="receipt-box mt-4" style="display:none;">
                                    <h5 class="mb-2">E-ticket</h5>
                                    <p class="mb-1"><strong>Mã vé:</strong> <span id="receiptCode"></span></p>
                                    <p class="mb-1"><strong>Phim:</strong> ${movieTitle}</p>
                                    <p class="mb-1"><strong>Rạp:</strong> ${showtimeDetails.branchName}</p>
                                    <p class="mb-1"><strong>Ngày chiếu:</strong> ${showDateFormatted} —
                                        <strong>Giờ:</strong> ${showTimeFormatted}</p>
                                    <p class="mb-1"><strong>Ghế:</strong> <span id="receiptSeats"></span></p>
                                    <p class="mb-0"><strong>Tổng tiền:</strong> <span id="receiptTotal"></span></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    const ctx = '${pageContext.request.contextPath}';
                    const currentShowtimeId = parseInt('${showtimeId}' || '0');

                    let bookingData = null;
                    let selectedPaymentMethod = null;

                    function formatCurrency(amount) {
                        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount || 0);
                    }

                    function loadBookingFromStorage() {
                        try {
                            const raw = sessionStorage.getItem('customerBookingData');
                            if (!raw) return;
                            const parsed = JSON.parse(raw);
                            if (!parsed || parsed.showtimeId !== currentShowtimeId) return;
                            bookingData = parsed;
                        } catch (e) {
                            console.warn('Cannot read booking data from sessionStorage', e);
                        }
                    }

                    let appliedVoucherCode = '${appliedVoucherCode}';
                    let discountAmount = <c:out value="${discountAmount}" default="0" />;

                    function renderBookingSummary() {
                        const container = document.getElementById('selectedSeatsDisplay');
                        const totalEl = document.getElementById('totalAmountText');
                        if (!bookingData || !bookingData.seats || bookingData.seats.length === 0) {
                            container.innerHTML = '<span class="text-muted">Không tìm thấy dữ liệu ghế. Vui lòng quay lại chọn ghế.</span>';
                            totalEl.textContent = formatCurrency(0);
                            document.getElementById('btnConfirmPay').disabled = true;
                            return;
                        }

                        container.innerHTML = '';
                        const frag = document.createDocumentFragment();
                        const ticketTypeLabel = (t) => (t === 'CHILD' ? 'Trẻ em' : 'Người lớn');
                        const seatTypeLabel = (s) => ({ 'VIP': 'VIP', 'COUPLE': 'Đôi', 'NORMAL': 'Thường' }[s] || s);

                        bookingData.seats.forEach(seat => {
                            const div = document.createElement('div');
                            div.className = 'd-flex justify-content-between align-items-center mb-2';

                            const left = document.createElement('div');
                            left.innerHTML =
                                '<span class="seat-tag">' + seat.seatCode + '</span>' +
                                ' <span class="badge bg-secondary me-1">' + seatTypeLabel(seat.seatType || 'NORMAL') + '</span>' +
                                ' <span class="badge bg-info">' + ticketTypeLabel(seat.ticketType || 'ADULT') + '</span>';

                            const right = document.createElement('div');
                            right.className = 'text-end text-light';
                            right.textContent = formatCurrency(seat.price || 0);

                            div.appendChild(left);
                            div.appendChild(right);
                            frag.appendChild(div);
                        });
                        container.appendChild(frag);

                        totalEl.textContent = formatCurrency(bookingData.totalAmount - discountAmount);
                        document.getElementById('baseAmountText').textContent = formatCurrency(bookingData.totalAmount);

                        if (discountAmount > 0) {
                            document.getElementById('discountArea').style.display = 'flex';
                            document.getElementById('discountAmountText').textContent = '-' + formatCurrency(discountAmount);
                        }

                        document.getElementById('btnConfirmPay').disabled = false;
                    }


                    function applyVoucher() {
                        const codeInput = document.getElementById('voucherCodeInput');
                        const code = codeInput.value.trim();

                        if (!code) {
                            alert('Vui lòng nhập mã voucher.');
                            return;
                        }

                        window.location.href = ctx + '/customer/booking-payment?showtimeId=' + currentShowtimeId + '&voucherCode=' + encodeURIComponent(code);
                    }

                    async function redirectToVnpayPayment() {
                        if (!bookingData) {
                            alert("Không tìm thấy thông tin đặt chỗ. Vui lòng chọn ghế lại.");
                            return;
                        }

                        const msgEl = document.getElementById('paymentMessage');

                        try {
                            // 1️⃣ Gọi VNPay ajax để tạo paymentUrl
                            const vnpRes = await fetch(ctx + '/payment/vnpayajax', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded'
                                },
                                body:
                                    "amount=" + (bookingData.totalAmount - discountAmount)
                            });

                            const vnpData = await vnpRes.json();

                            if (vnpData.code !== "00") {
                                alert("Không tạo được thanh toán VNPay");
                                return;
                            }

                            const paymentUrl = vnpData.data;

                            // 2️⃣ Lấy TxnRef từ URL
                            const txnRef = new URL(paymentUrl).searchParams.get("vnp_TxnRef");

                            // 3️⃣ Gửi BookingPayment để insert PENDING
                            const payload = {
                                showtimeId: bookingData.showtimeId,
                                seats: bookingData.seats,
                                totalAmount: bookingData.totalAmount,
                                finalAmount: bookingData.totalAmount - discountAmount,
                                discountAmount: discountAmount,
                                voucherCode: appliedVoucherCode,
                                txnRef: txnRef
                            };

                            const res = await fetch(ctx + '/customer/booking-payment', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                body: JSON.stringify(payload)
                            });

                            const data = await res.json();

                            if (!data.success) {
                                alert("Không thể tạo booking.");
                                return;
                            }

                            // 4️⃣ Lưu bookingCode
                            sessionStorage.setItem('lastBookingCode', txnRef);

                            // 5️⃣ Redirect VNPay
                            window.location.href = paymentUrl;

                        } catch (err) {

                            console.error(err);
                            msgEl.textContent = 'Lỗi kết nối, vui lòng thử lại.';
                            msgEl.classList.add('text-danger');
                            msgEl.style.display = 'block';
                        }
                    }

                    document.addEventListener('DOMContentLoaded', function () {
                        loadBookingFromStorage();
                        selectedPaymentMethod = 'BANKING';
                        renderBookingSummary();

                        document.getElementById('btnConfirmPay').addEventListener('click', redirectToVnpayPayment);
                        document.getElementById('btnApplyVoucher').addEventListener('click', applyVoucher);
                    });
                </script>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>