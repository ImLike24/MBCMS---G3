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
            background: rgba(255,255,255,0.08);
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

<jsp:include page="/components/layout/Header.jsp"/>

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
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <span class="text-muted">Tổng tiền</span>
                        <span class="total-amount" id="totalAmountText">0 ₫</span>
                    </div>
                </div>

                <div class="mb-4">
                    <h5 class="mb-3">Thông tin người nhận vé</h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label text-light">Họ tên</label>
                            <input type="text" class="form-control" id="customerName" placeholder="Nguyễn Văn A">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-light">Email (nhận e-ticket)</label>
                            <input type="email" class="form-control" id="customerEmail" placeholder="email@example.com">
                        </div>
                    </div>
                </div>

                <div class="mb-4">
                    <h5 class="mb-3">Phương thức thanh toán</h5>
                    <p class="text-muted small mb-2">Khách hàng chỉ được thanh toán online.</p>
                    <div class="d-flex gap-3">
                        <button type="button" class="btn btn-primary flex-fill" id="btnOnline" disabled>
                            <i class="fa fa-credit-card"></i> Thanh toán online
                        </button>
                    </div>
                </div>

                <div class="d-flex gap-3">
                    <button type="button" class="btn btn-primary flex-fill" id="btnConfirmPay" disabled>
                        Xác nhận thanh toán
                    </button>
                    <button type="button" class="btn btn-secondary flex-fill" id="btnPrint" disabled>
                        In vé
                    </button>
                </div>

                <div id="paymentMessage" class="mt-3 text-success fw-semibold" style="display:none;"></div>

                <div id="receiptArea" class="receipt-box mt-4" style="display:none;">
                    <h5 class="mb-2">E-ticket</h5>
                    <p class="mb-1"><strong>Mã vé:</strong> <span id="receiptCode"></span></p>
                    <p class="mb-1"><strong>Phim:</strong> ${movieTitle}</p>
                    <p class="mb-1"><strong>Rạp:</strong> ${showtimeDetails.branchName}</p>
                    <p class="mb-1"><strong>Ngày chiếu:</strong> ${showDateFormatted} — <strong>Giờ:</strong> ${showTimeFormatted}</p>
                    <p class="mb-1"><strong>Ghế:</strong> <span id="receiptSeats"></span></p>
                    <p class="mb-0"><strong>Tổng tiền:</strong> <span id="receiptTotal"></span></p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const ctx = '${pageContext.request.contextPath}';
    const showtimeId = ${showtimeId};

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
            if (!parsed || parsed.showtimeId !== showtimeId) return;
            bookingData = parsed;
        } catch (e) {
            console.warn('Cannot read booking data from sessionStorage', e);
        }
    }

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

        totalEl.textContent = formatCurrency(bookingData.totalAmount);
        document.getElementById('btnConfirmPay').disabled = false;
    }

    async function submitPayment() {
        if (!bookingData) return;
        const name = document.getElementById('customerName').value.trim();
        const email = document.getElementById('customerEmail').value.trim();
        const msgEl = document.getElementById('paymentMessage');

        msgEl.style.display = 'none';
        msgEl.classList.remove('text-danger');

        try {
            const payload = {
                showtimeId: bookingData.showtimeId,
                seats: bookingData.seats,
                totalAmount: bookingData.totalAmount,
                customerName: name,
                customerEmail: email,
                paymentMethod: 'BANKING'
            };

            const res = await fetch(ctx + '/customer/booking-payment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body: JSON.stringify(payload)
            });

            const data = await res.json();
            if (!data.success) {
                msgEl.textContent = data.message || 'Thanh toán thất bại.';
                msgEl.classList.add('text-danger');
                msgEl.style.display = 'block';
                return;
            }

            bookingData.eTicketCode = data.eTicketCode;
            try {
                sessionStorage.setItem('customerBookingData', JSON.stringify(bookingData));
            } catch (e) {}

            msgEl.textContent = 'Thanh toán thành công. Mã vé: ' + data.eTicketCode;
            msgEl.classList.remove('text-danger');
            msgEl.style.display = 'block';

            const receipt = document.getElementById('receiptArea');
            const ticketLabel = (t) => (t === 'CHILD' ? 'Trẻ em' : 'Người lớn');
            document.getElementById('receiptCode').textContent = data.eTicketCode;
            document.getElementById('receiptSeats').textContent = bookingData.seats
                .map(s => s.seatCode + ' (' + ticketLabel(s.ticketType || 'ADULT') + ')').join(', ');
            document.getElementById('receiptTotal').textContent = formatCurrency(bookingData.totalAmount);
            receipt.style.display = 'block';
            document.getElementById('btnPrint').disabled = false;

        } catch (e) {
            msgEl.textContent = 'Lỗi hệ thống, vui lòng thử lại.';
            msgEl.classList.add('text-danger');
            msgEl.style.display = 'block';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        loadBookingFromStorage();
        // Customer chỉ thanh toán online
        selectedPaymentMethod = 'BANKING';
        renderBookingSummary();

        document.getElementById('btnConfirmPay').addEventListener('click', submitPayment);
        document.getElementById('btnPrint').addEventListener('click', function () {
            window.print();
        });
    });
</script>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
