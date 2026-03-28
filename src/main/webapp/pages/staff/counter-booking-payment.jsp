<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Bán vé quầy</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        .payment-container {
            width: 100%;
            max-width: none;
        }

        .payment-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        }

        .payment-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .payment-header h1 {
            font-size: 32px;
            color: #d96c2c;
            margin-bottom: 10px;
        }

        .payment-header p {
            color: #ccc;
            font-size: 16px;
        }

        .booking-summary {
            /* Reset sticky positioning set by staff.css for the seat-selection panel */
            position: static;
            max-height: none;
            overflow-y: visible;
            background: rgba(217, 108, 44, 0.1);
            border: 1px solid #d96c2c;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
        }

        .booking-summary h3 {
            color: #d96c2c;
            margin-bottom: 15px;
            font-size: 18px;
        }

        #selectedSeatsDisplay {
            color: #ccc;
            font-size: 14px;
        }

        .seat-tag {
            display: inline-block;
            background: rgba(255, 255, 255, 0.1);
            padding: 5px 12px;
            border-radius: 15px;
            margin: 5px;
            font-size: 13px;
        }

        .seat-tag.adult {
            border: 1px solid #4caf50;
            color: #4caf50;
        }

        .seat-tag.child {
            border: 1px solid #2196f3;
            color: #2196f3;
        }

        .total-amount {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #262625;
            font-size: 28px;
            font-weight: 700;
        }

        .total-amount .label {
            color: white;
        }

        .total-amount .amount {
            color: #d96c2c;
        }

        /* Highlight voucher discount + final amount */
        #discountInfo {
            margin-top: 10px;
            font-size: 20px;
            font-weight: 700;
            color: #ffd27f;
        }

        #discountInfo span,
        #discountInfo strong {
            display: block;
        }

        #discountInfo .summary-row-label {
            font-size: 20px;
        }

        #discountInfo strong {
            font-size: 28px;
            color: #ffb347;
        }

        .form-section {
            margin-bottom: 30px;
        }

        .form-section h3 {
            color: white;
            margin-bottom: 20px;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-section h3 i {
            color: #d96c2c;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: #ccc;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
        }

        .form-group input {
            width: 100%;
            padding: 12px 16px;
            background: #0c121d;
            border: 2px solid #262625;
            border-radius: 8px;
            color: white;
            font-size: 14px;
            transition: all 0.3s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #d96c2c;
            box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
        }

        .form-group input::placeholder {
            color: #666;
        }

        .form-group input.input-error {
            border-color: #e74c3c;
            box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.2);
        }

        .form-group input.input-valid {
            border-color: #27ae60;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
        }

        .field-error-msg {
            color: #e74c3c;
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }

        .field-error-msg.visible {
            display: block;
        }

        .field-success-msg {
            color: #2ecc71;
            font-size: 12px;
            margin-top: 5px;
        }

        input:disabled {
            opacity: 0.45;
            cursor: not-allowed;
        }

        .payment-methods {
            display: grid;
            grid-template-columns: 1fr;
            gap: 15px;
        }

        .payment-method {
            background: #0c121d;
            border: 2px solid #262625;
            border-radius: 10px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }

        .payment-method:hover {
            border-color: #d96c2c;
            transform: translateY(-2px);
        }

        .payment-method.selected {
            border-color: #d96c2c;
            background: rgba(217, 108, 44, 0.1);
        }

        .payment-method input[type="radio"] {
            display: none;
        }

        .payment-method i {
            font-size: 32px;
            color: #d96c2c;
            margin-bottom: 10px;
        }

        .payment-method .method-name {
            font-size: 16px;
            font-weight: 600;
            color: white;
        }

        .payment-method .method-desc {
            font-size: 12px;
            color: #888;
            margin-top: 5px;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
        }

        .btn {
            flex: 1;
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary {
            background: #d96c2c;
            color: white;
        }

        .btn-primary:hover:not(:disabled) {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(217, 108, 44, 0.4);
        }

        .btn-primary:disabled {
            background: #555;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .btn-secondary {
            background: transparent;
            color: #ccc;
            border: 2px solid #262625;
        }

        .btn-secondary:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        /* Success Modal */
        .success-modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.75);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.25s ease, visibility 0.25s ease;
            backdrop-filter: blur(4px);
        }

        .success-modal-overlay.active {
            opacity: 1;
            visibility: visible;
        }

        .success-modal {
            background: #1a1a1a;
            border: 1px solid #2e5c30;
            border-radius: 16px;
            padding: 44px 40px 36px;
            max-width: 440px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6);
            transform: scale(0.9) translateY(-20px);
            transition: transform 0.25s ease;
            position: relative;
        }

        .success-modal-close {
            position: absolute;
            top: 14px;
            right: 14px;
            width: 30px;
            height: 30px;
            background: transparent;
            border: none;
            color: #666;
            font-size: 16px;
            cursor: pointer;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }

        .success-modal-close:hover {
            background: rgba(255, 255, 255, 0.08);
            color: #ccc;
        }

        .success-modal-overlay.active .success-modal {
            transform: scale(1) translateY(0);
        }

        .success-modal-icon {
            width: 72px;
            height: 72px;
            background: rgba(76, 175, 80, 0.15);
            border: 2px solid rgba(76, 175, 80, 0.45);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 22px;
            font-size: 32px;
            color: #4caf50;
        }

        .success-modal-title {
            font-size: 22px;
            font-weight: 700;
            color: #4caf50;
            margin-bottom: 10px;
        }

        .success-modal-subtitle {
            color: #aaa;
            font-size: 15px;
            margin-bottom: 28px;
        }

        .btn-export-receipt {
            width: 100%;
            padding: 14px 24px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-export-receipt:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(217, 108, 44, 0.4);
        }

        .btn-new-booking {
            width: 100%;
            margin-top: 12px;
            padding: 11px 24px;
            background: transparent;
            color: #888;
            border: 2px solid #262625;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.25s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-new-booking:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        .loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }

        .loading-overlay.show {
            display: flex;
        }

        .loading-spinner {
            text-align: center;
        }

        .spinner {
            border: 4px solid #262625;
            border-top: 4px solid #d96c2c;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .error-message {
            background: rgba(244, 67, 54, 0.1);
            border: 2px solid #f44336;
            border-radius: 10px;
            padding: 15px;
            color: #f44336;
            margin-bottom: 20px;
            display: none;
        }

        .error-message.show {
            display: block;
        }
        
        .summary-row {
            display: flex;
            align-items: baseline;
            gap: 6px;
            flex-wrap: nowrap;
        }
        
        .summary-row-label {
            font-weight: 600;
            white-space: nowrap;
        }

        /* Keep points usage on one line */
        #pointsUsageInfo {
            white-space: nowrap;
        }
        .points-discount-inline {
            white-space: nowrap;
        }
        #pointsUsageInfo span {
            display: inline;
        }
        
        .loyalty-info-text {
            color: #ffd27f;
            font-size: 13px;
            margin-top: 4px;
        }
        
        .loyalty-actions {
            display: flex;
            gap: 8px;
            margin-top: 6px;
        }
        
        .loyalty-actions button {
            flex: 1;
            padding: 6px 10px;
            font-size: 12px;
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
            <div class="logo-icon">
                <i class="fas fa-film"></i>
            </div>
            <h3>Nhân viên rạp</h3>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard">
                    <i class="fas fa-home"></i>
                    <span>Bảng điều khiển</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="active">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Bán vé tại quầy</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i>
                    <span>Lịch làm việc</span>
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
                        <c:otherwise>
                            <i class="fas fa-user"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="user-details">
                    <div class="user-name">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.fullName}">
                                ${sessionScope.user.fullName}
                            </c:when>
                                <c:otherwise>
                                Nhân viên
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Nhân viên rạp</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
    <div class="payment-container">
        <div class="payment-card" id="paymentCard">
            <div class="payment-header">
                <h1><i class="fas fa-credit-card"></i> Thanh toán</h1>
                <p>Hoàn tất giao dịch bán vé tại quầy</p>
            </div>

            <div id="errorMessage" class="error-message"></div>

            <!-- Booking Summary -->
            <div class="booking-summary">
                <h3><i class="fas fa-receipt"></i> Tóm tắt đặt chỗ</h3>
                <div id="selectedSeatsDisplay"></div>
                <div class="total-amount">
                    <span class="label">Tổng tiền:</span>
                    <span class="amount" id="totalAmountDisplay">0 VND</span>
                </div>
                <div id="discountInfo" style="display: none; margin-top: 8px;">
                    <div class="summary-row">
                        <span class="summary-row-label">Tổng giảm giá (voucher + điểm):</span>
                        <span id="discountAmountDisplay">0 VND</span>
                    </div>
                    <div id="pointsUsageInfo" class="summary-row" style="color:#ccc;display:none;margin-top:3px;">
                        <span class="summary-row-label">Điểm đã dùng:</span>
                        <span id="pointsUsedDisplay">0</span>
                        <span class="points-discount-inline">&nbsp;(≈ <span id="pointsDiscountDisplay">0 VND</span>)</span>
                    </div>
                    <div class="summary-row" style="margin-top:6px;">
                        <span class="summary-row-label">Thành tiền:</span>
                        <strong id="finalAmountDisplay">0 VND</strong>
                    </div>
                </div>
            </div>

            <!-- Customer Information (Optional) -->
            <div class="form-section">
                <h3><i class="fas fa-user"></i> Thông tin khách hàng (không bắt buộc)</h3>
                <div class="form-group">
                    <label for="customerName">Họ và tên</label>
                    <input type="text" id="customerName" placeholder="Nhập tên khách hàng">
                </div>
                <div class="form-group">
                    <label for="customerPhone">Số điện thoại</label>
                    <input type="tel" id="customerPhone" placeholder="0123456789">
                    <span class="field-error-msg" id="phoneError">Số điện thoại không hợp lệ (VD: 0912345678)</span>
                </div>
                <div class="form-group">
                    <label for="customerEmail">Email</label>
                    <input type="email" id="customerEmail" placeholder="customer@example.com">
                    <span class="field-error-msg" id="emailError">Email không hợp lệ (VD: example@email.com)</span>
                </div>
            </div>

            <!-- Voucher -->
            <div class="form-section">
                <h3><i class="fas fa-ticket-alt"></i> Voucher</h3>
                <div class="form-group">
                    <label for="voucherCode">Mã voucher (không bắt buộc)</label>
                    <input type="text" id="voucherCode" placeholder="Nhập mã voucher nếu có" oninput="onVoucherInput()" onblur="validateVoucher()">
                    <span class="field-error-msg" id="voucherError" style="display:none;"></span>
                    <span class="field-success-msg" id="voucherSuccess" style="display:none;"></span>
                </div>
                <div class="form-group">
                    <button type="button" class="btn btn-secondary" style="width:100%;justify-content:center;" onclick="suggestBestVoucher()">
                        <i class="fas fa-magic"></i> Gợi ý voucher tốt nhất (theo số điện thoại)
                    </button>
                </div>
                <div class="form-group" id="voucherSuggestionsContainer" style="display:none; margin-top:8px;">
                    <label style="color:#ccc;font-size:13px;">Các voucher hiện có của khách</label>
                    <div id="voucherSuggestionsList" style="max-height:160px; overflow-y:auto; border:1px solid #262625; border-radius:8px; padding:8px;"></div>
                </div>
            </div>

            <!-- Loyalty Points (Optional) -->
            <div class="form-section">
                <h3><i class="fas fa-star"></i> Điểm tích lũy (không bắt buộc)</h3>
                <div class="form-group">
                    <button type="button" class="btn btn-secondary" style="width:100%;justify-content:center;"
                            onclick="lookupLoyalty()">
                        <i class="fas fa-search"></i> Kiểm tra điểm (theo số điện thoại)
                    </button>
                    <div id="loyaltyInfoText" class="loyalty-info-text"></div>
                </div>
                <div class="form-group">
                    <label for="redeemPoints">Số điểm muốn dùng</label>
                    <input type="number" id="redeemPoints" min="0" step="1"
                           placeholder="Nhập số điện thoại và kiểm tra điểm trước"
                           disabled oninput="onRedeemPointsInput()">
                    <span class="field-error-msg" id="pointsError" style="display:none;"></span>
                </div>
                <p style="color:#777;font-size:12px;margin-top:-4px;">
                    1 điểm = giảm 1.000 VND. Cần tra cứu số điện thoại để sử dụng điểm.
                </p>
                <div class="loyalty-actions" id="loyaltyActions" style="display:none;">
                    <button type="button" class="btn btn-secondary" onclick="useAllPoints()">
                        Dùng toàn bộ điểm
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="clearPointUsage()">
                        Xóa điểm
                    </button>
                </div>
            </div>

            <!-- Payment Method -->
            <div class="form-section">
                <h3><i class="fas fa-wallet"></i> Phương thức thanh toán</h3>
                <div class="payment-methods">
                    <label class="payment-method selected" id="cashMethod">
                        <input type="radio" name="paymentMethod" value="CASH" checked>
                        <i class="fas fa-money-bill-wave"></i>
                        <div class="method-name">Tiền mặt</div>
                        <div class="method-desc">Thanh toán tiền mặt tại quầy</div>
                    </label>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="action-buttons">
                <button class="btn btn-secondary" onclick="goBack()">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </button>
                <button class="btn btn-primary" id="btnConfirmPayment" onclick="confirmPayment()">
                    <i class="fas fa-check"></i> Xác nhận thanh toán
                </button>
            </div>
        </div>

    </div>
    </div><!-- /.main-content -->

    <!-- Success Modal -->
    <div class="success-modal-overlay" id="successModalOverlay">
        <div class="success-modal">
            <button class="success-modal-close" onclick="document.getElementById('successModalOverlay').classList.remove('active')" title="Close">
                <i class="fas fa-times"></i>
            </button>
            <div class="success-modal-icon">
                <i class="fas fa-check"></i>
            </div>
            <div class="success-modal-title">Thanh toán thành công!</div>
            <div class="success-modal-subtitle">Đặt vé tại quầy đã hoàn tất</div>
            <button class="btn-export-receipt" onclick="exportReceipt()">
                <i class="fas fa-file-export"></i> Xuất hóa đơn
            </button>
            <button class="btn-new-booking" onclick="newBooking()">
                <i class="fas fa-plus"></i> Tạo giao dịch mới
            </button>
        </div>
    </div>

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
            <div class="loading-spinner">
            <div class="spinner"></div>
            <p style="color: white; font-size: 18px;">Đang xử lý thanh toán...</p>
        </div>
    </div>

    <%@ include file="confirm-modal.jsp" %>

    <script>
        // Toggle Sidebar
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
            const icon = document.querySelector('.sidebar-toggle i');
            if (sidebar.classList.contains('collapsed')) {
                icon.className = 'fas fa-chevron-right';
            } else {
                icon.className = 'fas fa-chevron-left';
            }
        }

        // Get booking data from sessionStorage
        const bookingData = JSON.parse(sessionStorage.getItem('bookingData') || '{}');
        const showtimeId = ${showtimeId};
        const ticketPrices = {
            ADULT: ${adultPrice},
            CHILD: ${childPrice}
        };
        const surchargeRates = {
            <c:forEach var="s" items="${surchargeList}" varStatus="vs">'${s.seatType}': ${s.surchargeRate}<c:if test="${!vs.last}">,</c:if></c:forEach>
        };
        let ticketIdsGenerated = [];
        let lastFinalAmount = null;
        let lastDiscountAmount = null;
        let lastTotalAmount = 0;
        let voucherSuggestions = [];
        let selectedVoucherCode = null;
        let lastVoucherResponse = null;
        let currentCustomerPoints = null;
        let lastRedeemPointsRequested = 0;
        let currentVoucherDiscountPreview = 0;

        // Display booking summary
        function displayBookingSummary() {
            if (!bookingData.seats || bookingData.seats.length === 0) {
                document.getElementById('errorMessage').textContent = 'Chưa chọn ghế nào. Vui lòng quay lại để chọn ghế.';
                document.getElementById('errorMessage').classList.add('show');
                document.getElementById('btnConfirmPayment').disabled = true;
                return;
            }

            const seatsDisplay = document.getElementById('selectedSeatsDisplay');
            seatsDisplay.innerHTML = '';

            bookingData.seats.forEach(seat => {
                const seatTag = document.createElement('span');
                seatTag.className = 'seat-tag ' + seat.ticketType.toLowerCase();
                seatTag.textContent = seat.seatCode + ' (' + seat.ticketType + ')';
                seatsDisplay.appendChild(seatTag);
            });

            // Display concessions if any
            if (bookingData.concessions && bookingData.concessions.length > 0) {
                const concDiv = document.createElement('div');
                concDiv.style.marginTop = '12px';
                concDiv.innerHTML = '<div style="color:#d96c2c; font-size:17px; font-weight:700; margin-bottom:6px;"><i class="fas fa-coffee"></i> Đồ ăn / Thức uống</div>';
                const formatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
                bookingData.concessions.forEach(c => {
                    const row = document.createElement('div');
                    row.style.cssText = 'display:flex; justify-content:space-between; font-size:16px; color:#ccc; padding:3px 0;';
                    row.innerHTML = '<span>' + c.concessionName + ' x' + c.quantity + '</span><span>' + formatter.format(c.priceBase * c.quantity) + '</span>';
                    concDiv.appendChild(row);
                });
                seatsDisplay.appendChild(concDiv);
            }

            displayTotalAmount();
        }

        function getConcessionTotal() {
            if (!bookingData.concessions) return 0;
            return bookingData.concessions.reduce((sum, c) => sum + c.priceBase * c.quantity, 0);
        }

        function displayTotalAmount() {
            let totalAmount = 0;

            bookingData.seats.forEach(seat => {
                let price = ticketPrices[seat.ticketType] || ticketPrices['ADULT'] || 0;

                const rate = surchargeRates[seat.seatType];
                if (rate != null && rate > 0) {
                    price *= (1 + rate / 100);
                }

                totalAmount += price;
            });

            totalAmount += getConcessionTotal();
            lastTotalAmount = totalAmount;
            document.getElementById('totalAmountDisplay').textContent =
                new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(totalAmount);
        }

        // ── Voucher validation ─────────────────────────────────────
        let voucherValidateTimer = null;

        function onVoucherInput() {
            const code = document.getElementById('voucherCode').value.trim();
            clearTimeout(voucherValidateTimer);
            // Reset trạng thái khi xóa input
            if (!code) {
                resetVoucherState();
                return;
            }
            // Debounce 600ms
            voucherValidateTimer = setTimeout(validateVoucher, 600);
        }

        function resetVoucherState() {
            const errEl = document.getElementById('voucherError');
            const okEl  = document.getElementById('voucherSuccess');
            errEl.style.display = 'none';
            okEl.style.display  = 'none';
            document.getElementById('voucherCode').classList.remove('input-error', 'input-valid');
            selectedVoucherCode = null;
            currentVoucherDiscountPreview = 0;
            updatePreviewTotals();
        }

        async function validateVoucher() {
            const code = document.getElementById('voucherCode').value.trim();
            const errEl = document.getElementById('voucherError');
            const okEl  = document.getElementById('voucherSuccess');
            const input = document.getElementById('voucherCode');

            if (!code) { resetVoucherState(); return; }

            errEl.style.display = 'none';
            okEl.style.display  = 'none';
            input.classList.remove('input-error', 'input-valid');

            try {
                const phone = document.getElementById('customerPhone').value.trim();
                const payload = {
                    voucherCode:   code,
                    customerPhone: phone || null,
                    totalAmount:   String(lastTotalAmount || 0)
                };
                const res  = await fetch('${pageContext.request.contextPath}/staff/counter-validate-voucher', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                const data = await res.json();

                if (data.success) {
                    input.classList.add('input-valid');
                    okEl.textContent = 'Voucher hợp lệ: ' + data.voucherName + ' – Giảm ' +
                        new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(Number(data.discount));
                    okEl.style.display = 'block';
                    selectedVoucherCode = code;
                    currentVoucherDiscountPreview = Number(data.discount) || 0;
                    updatePreviewTotals();
                } else {
                    input.classList.add('input-error');
                    errEl.textContent = data.message || 'Không tìm thấy voucher này, vui lòng chọn voucher khác hoặc bỏ nhập voucher';
                    errEl.style.display = 'block';
                    selectedVoucherCode = null;
                    currentVoucherDiscountPreview = 0;
                    updatePreviewTotals();
                }
            } catch (e) {
                errEl.textContent = 'Lỗi khi kiểm tra voucher.';
                errEl.style.display = 'block';
            }
        }

        // ── Points real-time validation ────────────────────────────
        function onRedeemPointsInput() {
            const input   = document.getElementById('redeemPoints');
            const errEl   = document.getElementById('pointsError');
            const val     = parseInt(input.value, 10);

            errEl.style.display = 'none';
            input.classList.remove('input-error');

            if (isNaN(val) || val <= 0) {
                lastRedeemPointsRequested = 0;
                updatePreviewTotals();
                return;
            }

            if (currentCustomerPoints !== null && val > currentCustomerPoints) {
                input.classList.add('input-error');
                errEl.textContent = 'Khách chỉ có ' + currentCustomerPoints + ' điểm, không thể nhập nhiều hơn';
                errEl.style.display = 'block';
                input.value = currentCustomerPoints;
                lastRedeemPointsRequested = currentCustomerPoints;
            } else {
                lastRedeemPointsRequested = val;
            }
            updatePreviewTotals();
        }

        function applyVoucherChoice(voucherCode, effectiveDiscountStr) {
            const codeInput = document.getElementById('voucherCode');
            const discountInfo = document.getElementById('discountInfo');
            const discountEl = document.getElementById('discountAmountDisplay');
            const finalEl = document.getElementById('finalAmountDisplay');

            if (!codeInput || !discountInfo || !discountEl || !finalEl) return;

            selectedVoucherCode = voucherCode;

            codeInput.value = voucherCode;

            const discount = Number(effectiveDiscountStr || 0);
            if (!isNaN(discount) && discount > 0) {
                currentVoucherDiscountPreview = discount;
            } else {
                currentVoucherDiscountPreview = 0;
            }

            updatePreviewTotals();
        }

        function renderVoucherSuggestions(data) {
            const container = document.getElementById('voucherSuggestionsContainer');
            const listEl = document.getElementById('voucherSuggestionsList');
            if (!container || !listEl) return;

            lastVoucherResponse = data;
            voucherSuggestions = Array.isArray(data.vouchers) ? data.vouchers : [];

            if (voucherSuggestions.length === 0) {
                container.style.display = 'none';
                listEl.innerHTML = '';
                return;
            }

            container.style.display = 'block';
            listEl.innerHTML = '';

            voucherSuggestions.forEach(v => {
                const item = document.createElement('div');
                item.style.display = 'flex';
                item.style.justifyContent = 'space-between';
                item.style.alignItems = 'center';
                item.style.padding = '6px 8px';
                item.style.borderRadius = '6px';
                item.style.marginBottom = '4px';
                const isSelected = selectedVoucherCode
                    ? selectedVoucherCode === v.voucherCode
                    : (data.bestVoucherCode && data.bestVoucherCode === v.voucherCode);
                item.style.background = isSelected ? 'rgba(217,108,44,0.18)' : 'transparent';

                const left = document.createElement('div');
                left.style.fontSize = '12px';
                left.style.color = '#ccc';
                left.innerHTML =
                    '<div><strong>' + (v.voucherName || v.voucherCode) + '</strong></div>' +
                    '<div>Code: <span class="font-monospace">' + v.voucherCode + '</span></div>' +
                    (v.expiresAt ? '<div>Expires: ' + v.expiresAt + '</div>' : '') +
                    '<div>Discount: ' + v.effectiveDiscount + ' VND</div>';

                const rightBtn = document.createElement('button');
                rightBtn.type = 'button';
                rightBtn.className = 'btn btn-secondary';
                rightBtn.style.flex = '0 0 auto';
                rightBtn.style.fontSize = '12px';
                rightBtn.style.padding = '6px 10px';
                rightBtn.textContent = 'Use';
                rightBtn.onclick = function() {
                    applyVoucherChoice(v.voucherCode, v.effectiveDiscount);
                    // Re-render list so that selected voucher is highlighted
                    if (lastVoucherResponse) {
                        renderVoucherSuggestions(lastVoucherResponse);
                    }
                };

                item.appendChild(left);
                item.appendChild(rightBtn);
                listEl.appendChild(item);
            });
        }

        // Gợi ý voucher tốt nhất dựa trên số điện thoại khách & tổng bill hiện tại
        async function suggestBestVoucher() {
            const phone = document.getElementById('customerPhone').value.trim();
            const errorEl = document.getElementById('errorMessage');
            const phoneError = document.getElementById('phoneError');

            errorEl.classList.remove('show');
            phoneError.classList.remove('visible');

            if (!phone) {
                phoneError.textContent = 'Vui lòng nhập số điện thoại khách hàng để tra cứu voucher.';
                phoneError.classList.add('visible');
                document.getElementById('customerPhone').classList.add('input-error');
                document.getElementById('customerPhone').focus();
                return;
            }

            if (!bookingData.seats || bookingData.seats.length === 0) {
                errorEl.textContent = 'Chưa chọn ghế nào. Vui lòng quay lại để chọn ghế.';
                errorEl.classList.add('show');
                return;
            }

            try {
                const payload = {
                    customerPhone: phone,
                    totalAmount: String(lastTotalAmount || 0)
                };

                const res = await fetch('${pageContext.request.contextPath}/staff/counter-best-voucher', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                const data = await res.json();

                if (!data.success) {
                    phoneError.textContent = data.message || 'Không thể gợi ý voucher.';
                    phoneError.classList.add('visible');
                    document.getElementById('customerPhone').classList.add('input-error');
                    return;
                }

                if (data.bestVoucherCode) {
                    document.getElementById('voucherCode').value = data.bestVoucherCode;

                    // Lưu giá trị voucher discount preview để kết hợp với điểm
                    try {
                        const discount = data.bestDiscount ? Number(data.bestDiscount) : 0;
                        if (!isNaN(discount) && discount > 0) {
                            currentVoucherDiscountPreview = discount;
                        } else {
                            currentVoucherDiscountPreview = 0;
                        }
                        updatePreviewTotals();
                    } catch (e) {
                        console.warn('Cannot render suggested voucher preview', e);
                    }
                } else {
                    errorEl.textContent = 'Khách có voucher nhưng không voucher nào giúp giảm thêm cho hóa đơn này.';
                    errorEl.classList.add('show');
                }

                // Luôn render danh sách để staff có thể switch giữa các voucher
                renderVoucherSuggestions(data);
            } catch (e) {
                console.error('Suggest voucher error:', e);
                errorEl.textContent = 'Lỗi khi gợi ý voucher.';
                errorEl.classList.add('show');
            }
        }

        // Lookup loyalty info (points) by phone
        async function lookupLoyalty() {
            const phone = document.getElementById('customerPhone').value.trim();
            const errorEl = document.getElementById('errorMessage');
            const infoEl = document.getElementById('loyaltyInfoText');
            const phoneError = document.getElementById('phoneError');
            const redeemInput = document.getElementById('redeemPoints');
            const loyaltyActions = document.getElementById('loyaltyActions');

            errorEl.classList.remove('show');
            phoneError.classList.remove('visible');
            infoEl.textContent = '';
            infoEl.style.color = '';
            currentCustomerPoints = null;

            // Reset & lock điểm
            redeemInput.disabled = true;
            redeemInput.value = '';
            redeemInput.placeholder = 'Nhập số điện thoại và kiểm tra điểm trước';
            loyaltyActions.style.display = 'none';
            lastRedeemPointsRequested = 0;
            updatePreviewTotals();

            if (!phone) {
                phoneError.textContent = 'Vui lòng nhập số điện thoại khách hàng để tra cứu điểm.';
                phoneError.classList.add('visible');
                document.getElementById('customerPhone').classList.add('input-error');
                document.getElementById('customerPhone').focus();
                return;
            }

            try {
                const payload = { customerPhone: phone };
                const res = await fetch('${pageContext.request.contextPath}/staff/counter-customer-loyalty', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                const data = await res.json();

                if (!data.success) {
                    phoneError.textContent = data.message || 'Không tìm thấy khách hàng với số điện thoại này.';
                    phoneError.classList.add('visible');
                    document.getElementById('customerPhone').classList.add('input-error');
                    return;
                }

                currentCustomerPoints = typeof data.points === 'number' ? data.points : 0;

                const namePart = data.fullName ? ' ' + data.fullName : '';
                const totalAccumulated =
                    (typeof data.totalAccumulatedPoints === 'number')
                        ? data.totalAccumulatedPoints : 0;
                infoEl.textContent =
                    'Khách hàng' + namePart + ' có ' + currentCustomerPoints + ' điểm.';

                // Mở khóa input điểm
                redeemInput.disabled = false;
                redeemInput.placeholder = 'Nhập số điểm muốn dùng (tối đa ' + currentCustomerPoints + ')';
                redeemInput.max = currentCustomerPoints;
                loyaltyActions.style.display = '';

                updatePreviewTotals();
            } catch (e) {
                console.error('Lookup loyalty error:', e);
                errorEl.textContent = 'Lỗi khi tải thông tin điểm thưởng.';
                errorEl.classList.add('show');
            }
        }

        function useAllPoints() {
            const redeemInput = document.getElementById('redeemPoints');
            const errorEl = document.getElementById('errorMessage');
            const infoEl = document.getElementById('loyaltyInfoText');

            if (currentCustomerPoints == null) return;

            errorEl.classList.remove('show');
            redeemInput.value = currentCustomerPoints;
            lastRedeemPointsRequested = currentCustomerPoints;
            document.getElementById('pointsError').style.display = 'none';
            redeemInput.classList.remove('input-error');
            updatePreviewTotals();
        }

        function clearPointUsage() {
            const redeemInput = document.getElementById('redeemPoints');
            redeemInput.value = '';
            lastRedeemPointsRequested = 0;
            document.getElementById('pointsError').style.display = 'none';
            redeemInput.classList.remove('input-error');
            updatePreviewTotals();
        }

        // Tính trước tổng giảm giá & số tiền phải trả dựa trên voucher (preview) + điểm nhập
        function updatePreviewTotals() {
            const discountInfo = document.getElementById('discountInfo');
            const discountEl = document.getElementById('discountAmountDisplay');
            const finalEl = document.getElementById('finalAmountDisplay');
            const pointsInfo = document.getElementById('pointsUsageInfo');
            const pointsUsedEl = document.getElementById('pointsUsedDisplay');
            const pointsDiscountEl = document.getElementById('pointsDiscountDisplay');

            if (!discountInfo || !discountEl || !finalEl) return;

            const formatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

            const redeemInput = document.getElementById('redeemPoints');
            let pointsRequested = lastRedeemPointsRequested || 0;
            if (redeemInput && redeemInput.value.trim() !== '') {
                const parsed = parseInt(redeemInput.value.trim(), 10);
                if (!isNaN(parsed) && parsed > 0) {
                    pointsRequested = parsed;
                }
            }

            // Giới hạn điểm theo số point hiện có (nếu đã load)
            if (currentCustomerPoints != null && pointsRequested > currentCustomerPoints) {
                pointsRequested = currentCustomerPoints;
            }

            // Số tiền có thể trừ tối đa từ điểm = (total - voucherPreview)
            let voucherDisc = currentVoucherDiscountPreview || 0;
            if (voucherDisc < 0) voucherDisc = 0;
            if (voucherDisc > lastTotalAmount) voucherDisc = lastTotalAmount;

            let maxPointDiscountFromAmount = (lastTotalAmount - voucherDisc);
            if (maxPointDiscountFromAmount < 0) maxPointDiscountFromAmount = 0;

            let pointDiscount = pointsRequested * 1000;
            if (pointDiscount > maxPointDiscountFromAmount) {
                pointDiscount = maxPointDiscountFromAmount;
            }

            const totalDiscount = voucherDisc + pointDiscount;
            let finalAmt = lastTotalAmount - totalDiscount;
            if (finalAmt < 0) finalAmt = 0;

            if (totalDiscount > 0) {
                discountEl.textContent = formatter.format(totalDiscount);
                finalEl.textContent = formatter.format(finalAmt);
                discountInfo.style.display = 'block';
            } else {
                discountInfo.style.display = 'none';
            }

            if (pointsInfo && pointsUsedEl && pointsDiscountEl) {
                if (pointDiscount > 0) {
                    pointsUsedEl.textContent = String(pointsRequested);
                    pointsDiscountEl.textContent = formatter.format(pointDiscount);
                    pointsInfo.style.display = 'block';
                } else {
                    pointsInfo.style.display = 'none';
                }
            }
        }

        // Payment method selection
        document.querySelectorAll('.payment-method').forEach(method => {
            method.addEventListener('click', function() {
                document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
                this.classList.add('selected');
                this.querySelector('input[type="radio"]').checked = true;
            });
        });

        // Confirm payment — ask first, then process
        async function confirmPayment() {
            console.log('confirmPayment called');
            
            // Check if showConfirmModal exists
            if (typeof showConfirmModal !== 'function') {
                console.error('showConfirmModal is not defined!');
                alert('Modal function not loaded. Please refresh the page.');
                return;
            }
            
            let confirmed = false;
            try {
                confirmed = await showConfirmModal({
                    title:       'Xác nhận thanh toán',
                    message:     'Bạn có chắc chắn muốn hoàn tất thanh toán này không?',
                    confirmText: 'Xác nhận thanh toán',
                    cancelText:  'Hủy',
                    icon:        'fas fa-credit-card'
                });
                
                console.log('Modal result:', confirmed);
            } catch (error) {
                console.error('Error showing modal:', error);
                // Fallback to native confirm
                confirmed = confirm('Bạn có chắc chắn muốn hoàn tất thanh toán này không?');
            }

            if (!confirmed) {
                console.log('Payment cancelled by user');
                return;
            }

            const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;
            const customerName  = document.getElementById('customerName').value.trim();
            const customerPhone = document.getElementById('customerPhone').value.trim();
            const customerEmail = document.getElementById('customerEmail').value.trim();
            const voucherCode   = document.getElementById('voucherCode').value.trim();
            const redeemPointsRaw = document.getElementById('redeemPoints') ? document.getElementById('redeemPoints').value.trim() : '';
            let redeemPoints = null;
            if (redeemPointsRaw !== '') {
                const parsed = parseInt(redeemPointsRaw, 10);
                if (!isNaN(parsed) && parsed > 0) {
                    redeemPoints = parsed;
                }
            }
            lastRedeemPointsRequested = redeemPoints || 0;

            // Validate phone and email format
            if (!validatePhone(customerPhone)) {
                document.getElementById('customerPhone').classList.add('input-error');
                document.getElementById('phoneError').classList.add('visible');
                document.getElementById('customerPhone').focus();
                return;
            }
            if (!validateEmail(customerEmail)) {
                document.getElementById('customerEmail').classList.add('input-error');
                document.getElementById('emailError').classList.add('visible');
                document.getElementById('customerEmail').focus();
                return;
            }

            document.getElementById('loadingOverlay').classList.add('show');
            document.getElementById('btnConfirmPayment').disabled = true;

            const paymentData = {
                showtimeId:    showtimeId,
                paymentMethod: paymentMethod,
                customerName:  customerName  || null,
                customerPhone: customerPhone || null,
                customerEmail: customerEmail || null,
                voucherCode:   voucherCode   || null,
                redeemPoints:  redeemPoints,
                seats:         bookingData.seats,
                concessions:   bookingData.concessions || []
            };

            try {
                const response = await fetch('${pageContext.request.contextPath}/staff/counter-booking-payment', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(paymentData)
                });

                const contentType = response.headers.get('content-type') || '';
                if (!contentType.includes('application/json')) {
                    const text = await response.text();
                    throw new Error(text || 'Server returned non-JSON response');
                }

                const result = await response.json();

                document.getElementById('loadingOverlay').classList.remove('show');

                if (result.success) {
                    ticketIdsGenerated = result.ticketIds || [];
                    // Lưu lại tổng tiền sau voucher (nếu có) để hiển thị
                    try {
                        const formatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
                        const total = result.totalAmount ? Number(result.totalAmount) : null;
                        const discount = result.discountAmount ? Number(result.discountAmount) : 0;
                        const finalAmt = result.finalAmount ? Number(result.finalAmount) : total;
                        lastDiscountAmount = discount;
                        lastFinalAmount = finalAmt;

                        if (!isNaN(discount) && discount > 0 && !isNaN(finalAmt)) {
                            const discountInfo = document.getElementById('discountInfo');
                            const discountEl = document.getElementById('discountAmountDisplay');
                            const finalEl = document.getElementById('finalAmountDisplay');
                            if (discountInfo && discountEl && finalEl) {
                                discountEl.textContent = formatter.format(discount);
                                finalEl.textContent = formatter.format(finalAmt);
                                discountInfo.style.display = 'block';

                                // Hiển thị số point đã dùng & tiền tương ứng (ước tính)
                                const pointsInfo = document.getElementById('pointsUsageInfo');
                                const pointsUsedEl = document.getElementById('pointsUsedDisplay');
                                const pointsDiscountEl = document.getElementById('pointsDiscountDisplay');
                                if (pointsInfo && pointsUsedEl && pointsDiscountEl) {
                                    const pointsUsed = lastRedeemPointsRequested || 0;
                                    if (pointsUsed > 0) {
                                        let estimatedPointDiscount = pointsUsed * 1000;
                                        if (!isNaN(discount) && estimatedPointDiscount > discount) {
                                            estimatedPointDiscount = discount;
                                        }
                                        pointsUsedEl.textContent = String(pointsUsed);
                                        pointsDiscountEl.textContent = formatter.format(estimatedPointDiscount);
                                        pointsInfo.style.display = 'block';
                                    } else {
                                        pointsInfo.style.display = 'none';
                                    }
                                }
                            }
                        }
                    } catch (e) {
                        console.warn('Cannot render voucher discount info', e);
                    }
                    sessionStorage.removeItem('bookingData');
                    document.getElementById('successModalOverlay').classList.add('active');
                } else {
                    throw new Error(result.message || 'Thanh toán thất bại');
                }
            } catch (error) {
                console.error('Payment error:', error);
                document.getElementById('loadingOverlay').classList.remove('show');
                document.getElementById('errorMessage').textContent = 'Thanh toán thất bại: ' + error.message;
                document.getElementById('errorMessage').classList.add('show');
                document.getElementById('btnConfirmPayment').disabled = false;
            }
        }

        // Go back
        function goBack() {
            window.history.back();
        }

        // Export receipt in a new tab
        function exportReceipt() {
            window.open('${pageContext.request.contextPath}/staff/counter-booking-receipt?ticketIds=' + ticketIdsGenerated.join(','), '_blank');
        }

        // Start a new booking
        function newBooking() {
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking';
        }

        // Initialize on page load
        const phoneRegex = /^(0[3|5|7|8|9])[0-9]{8}$/;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        function validatePhone(value) {
            if (!value) return true; // optional
            return phoneRegex.test(value);
        }

        function validateEmail(value) {
            if (!value) return true; // optional
            return emailRegex.test(value);
        }

        document.addEventListener('DOMContentLoaded', function() {
            displayBookingSummary();

            const redeemInput = document.getElementById('redeemPoints');
            if (redeemInput) {
                redeemInput.addEventListener('input', function() {
                    lastRedeemPointsRequested = 0; // sẽ đọc lại từ ô input
                    updatePreviewTotals();
                });
            }

            const phoneInput = document.getElementById('customerPhone');
            const phoneError = document.getElementById('phoneError');
            const phoneErrorDefaultText = phoneError.textContent;
            phoneInput.addEventListener('input', function() {
                const val = this.value.trim();
                phoneError.textContent = phoneErrorDefaultText;
                if (val === '') {
                    this.classList.remove('input-error', 'input-valid');
                    phoneError.classList.remove('visible');
                } else if (validatePhone(val)) {
                    this.classList.remove('input-error');
                    this.classList.add('input-valid');
                    phoneError.classList.remove('visible');
                } else {
                    this.classList.remove('input-valid');
                    this.classList.add('input-error');
                    phoneError.classList.add('visible');
                }
            });

            const emailInput = document.getElementById('customerEmail');
            const emailError = document.getElementById('emailError');
            emailInput.addEventListener('input', function() {
                const val = this.value.trim();
                if (val === '') {
                    this.classList.remove('input-error', 'input-valid');
                    emailError.classList.remove('visible');
                } else if (validateEmail(val)) {
                    this.classList.remove('input-error');
                    this.classList.add('input-valid');
                    emailError.classList.remove('visible');
                } else {
                    this.classList.remove('input-valid');
                    this.classList.add('input-error');
                    emailError.classList.add('visible');
                }
            });
        });
    </script>
</body>
</html>
