<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Counter Booking</title>
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
            font-size: 24px;
            font-weight: 600;
        }

        .total-amount .label {
            color: white;
        }

        .total-amount .amount {
            color: #d96c2c;
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

        .payment-methods {
            display: grid;
            grid-template-columns: 1fr 1fr;
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
            <h3>Cinema Staff</h3>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="active">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Counter Booking</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i>
                    <span>View Working Schedule</span>
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
                                Staff User
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Cinema Staff</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
    <div class="payment-container">
        <div class="payment-card" id="paymentCard">
            <div class="payment-header">
                <h1><i class="fas fa-credit-card"></i> Payment</h1>
                <p>Complete your counter booking</p>
            </div>

            <div id="errorMessage" class="error-message"></div>

            <!-- Booking Summary -->
            <div class="booking-summary">
                <h3><i class="fas fa-receipt"></i> Booking Summary</h3>
                <div id="selectedSeatsDisplay"></div>
                <div class="total-amount">
                    <span class="label">Total Amount:</span>
                    <span class="amount" id="totalAmountDisplay">0 VND</span>
                </div>
            </div>

            <!-- Customer Information (Optional) -->
            <div class="form-section">
                <h3><i class="fas fa-user"></i> Customer Information (Optional)</h3>
                <div class="form-group">
                    <label for="customerName">Full Name</label>
                    <input type="text" id="customerName" placeholder="Enter customer name">
                </div>
                <div class="form-group">
                    <label for="customerPhone">Phone Number</label>
                    <input type="tel" id="customerPhone" placeholder="0123456789">
                </div>
                <div class="form-group">
                    <label for="customerEmail">Email</label>
                    <input type="email" id="customerEmail" placeholder="customer@example.com">
                </div>
            </div>

            <!-- Payment Method -->
            <div class="form-section">
                <h3><i class="fas fa-wallet"></i> Payment Method</h3>
                <div class="payment-methods">
                    <label class="payment-method selected" id="cashMethod">
                        <input type="radio" name="paymentMethod" value="CASH" checked>
                        <i class="fas fa-money-bill-wave"></i>
                        <div class="method-name">Cash</div>
                        <div class="method-desc">Pay with cash at counter</div>
                    </label>
                    <label class="payment-method" id="bankingMethod">
                        <input type="radio" name="paymentMethod" value="BANKING">
                        <i class="fas fa-university"></i>
                        <div class="method-name">Banking</div>
                        <div class="method-desc">Bank transfer / QR code</div>
                    </label>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="action-buttons">
                <button class="btn btn-secondary" onclick="goBack()">
                    <i class="fas fa-arrow-left"></i> Back
                </button>
                <button class="btn btn-primary" id="btnConfirmPayment" onclick="confirmPayment()">
                    <i class="fas fa-check"></i> Confirm Payment
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
            <div class="success-modal-title">Payment Successful!</div>
            <div class="success-modal-subtitle">Booking completed successfully</div>
            <button class="btn-export-receipt" onclick="exportReceipt()">
                <i class="fas fa-file-export"></i> Export Receipt
            </button>
            <button class="btn-new-booking" onclick="newBooking()">
                <i class="fas fa-plus"></i> New Booking
            </button>
        </div>
    </div>

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p style="color: white; font-size: 18px;">Processing payment...</p>
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
        let ticketCodeGenerated = '';

        // Display booking summary
        function displayBookingSummary() {
            if (!bookingData.seats || bookingData.seats.length === 0) {
                document.getElementById('errorMessage').textContent = 'No seats selected. Please go back and select seats.';
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

            displayTotalAmount();
        }

        function displayTotalAmount() {
            const basePrice = ${showtimeDetails.showtime.basePrice};
            let totalAmount = 0;

            bookingData.seats.forEach(seat => {
                let price = basePrice;
                if (seat.seatType === 'VIP')    price *= 1.5;
                else if (seat.seatType === 'COUPLE') price *= 2.0;
                if (seat.ticketType === 'CHILD') price *= 0.7;
                totalAmount += price;
            });

            document.getElementById('totalAmountDisplay').textContent =
                new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(totalAmount);
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
                    title:       'Confirm Payment',
                    message:     'Are you sure you want to complete this payment?',
                    confirmText: 'Confirm Payment',
                    cancelText:  'Cancel',
                    icon:        'fas fa-credit-card'
                });
                
                console.log('Modal result:', confirmed);
            } catch (error) {
                console.error('Error showing modal:', error);
                // Fallback to native confirm
                confirmed = confirm('Are you sure you want to complete this payment?');
            }

            if (!confirmed) {
                console.log('Payment cancelled by user');
                return;
            }

            const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;
            const customerName  = document.getElementById('customerName').value.trim();
            const customerPhone = document.getElementById('customerPhone').value.trim();
            const customerEmail = document.getElementById('customerEmail').value.trim();

            document.getElementById('loadingOverlay').classList.add('show');
            document.getElementById('btnConfirmPayment').disabled = true;

            const paymentData = {
                showtimeId:    showtimeId,
                paymentMethod: paymentMethod,
                customerName:  customerName  || null,
                customerPhone: customerPhone || null,
                customerEmail: customerEmail || null,
                seats:         bookingData.seats
            };

            try {
                const response = await fetch('${pageContext.request.contextPath}/staff/counter-booking-payment', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(paymentData)
                });

                const result = await response.json();

                document.getElementById('loadingOverlay').classList.remove('show');

                if (result.success) {
                    ticketCodeGenerated = result.ticketCode;
                    sessionStorage.removeItem('bookingData');
                    document.getElementById('successModalOverlay').classList.add('active');
                } else {
                    throw new Error(result.message || 'Payment failed');
                }
            } catch (error) {
                console.error('Payment error:', error);
                document.getElementById('loadingOverlay').classList.remove('show');
                document.getElementById('errorMessage').textContent = 'Payment failed: ' + error.message;
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
            window.open('${pageContext.request.contextPath}/staff/counter-booking-receipt?ticketCode=' + ticketCodeGenerated, '_blank');
        }

        // Start a new booking
        function newBooking() {
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking';
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            displayBookingSummary();
        });
    </script>
</body>
</html>
