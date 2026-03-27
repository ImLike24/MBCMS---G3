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

        /* Định dạng hiển thị cho ghế thường trên nền Dark Theme */
        .seat {
            background-color: #4a4a4a; /* Màu xám sáng để nổi bật trên nền đen */
            color: #ffffff;
            border: 1px solid #666;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
        }

        .seat:hover {
            opacity: 0.8;
        }

        /* Đảm bảo ghế đang chọn luôn có màu cam chủ đạo đè lên mọi class khác */
        .seat.selected {
            background-color: #d96c2c !important;
            color: #fff !important;
            border-color: #d96c2c !important;
            box-shadow: 0 0 8px rgba(217, 108, 44, 0.6);
        }
    </style>
</head>

<body>

    <jsp:include page="/components/layout/Header.jsp" />

    <div class="container mt-5 pt-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="payment-card p-0" style="background: transparent;">
                    <div class="payment-header text-center mb-4">
                        <h1 class="fw-bold text-uppercase" style="color: #d96c2c;">Thanh toán vé phim</h1>
                        <p class="text-light mb-0">${movieTitle} - ${branchName}</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger fw-semibold"><i class="fa fa-exclamation-triangle me-2"></i>${error}</div>
                    </c:if>

                    <c:if test="${not empty sessionScope.errorMsg}">
                        <div class="alert alert-danger fw-semibold">
                            <i class="fa fa-exclamation-triangle me-2"></i> ${sessionScope.errorMsg}
                        </div>
                        <c:remove var="errorMsg" scope="session" />
                    </c:if>

                    <div class="user-info-box p-4 rounded shadow-sm mb-4" style="background-color: #1a1a1a; border: 1px solid #333;">
                        <h5 class="mb-3 text-uppercase fw-bold" style="color: #d96c2c; font-size: 1.1rem;">
                            <i class="fa fa-user-circle-o me-2"></i>Thông tin người nhận vé
                        </h5>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label text-light small opacity-75">Họ tên</label>
                                <input type="text" class="form-control bg-dark text-white border-secondary" readonly value="${sessionScope.user.fullName}">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-light small opacity-75">Email nhận vé</label>
                                <input type="email" class="form-control bg-dark text-white border-secondary" readonly value="${sessionScope.user.email}">
                            </div>
                        </div>

                        <div class="mt-4 pt-3" style="border-top: 1px dashed #444;">
                            <h5 class="mb-2 text-uppercase fw-bold" style="color: #d96c2c; font-size: 1.1rem;">
                                <i class="fa fa-credit-card me-2"></i>Phương thức thanh toán
                            </h5>
                            <p class="text-light mb-0 bg-dark p-2 rounded border border-secondary d-inline-block">
                                Thanh toán Online an toàn qua cổng VNPAY
                            </p>
                        </div>
                    </div>

                    <div class="booking-summary-box p-4 rounded shadow-sm" style="background-color: #1a1a1a; color: #fff; border: 1px solid #333;">
                        <h5 class="border-bottom pb-3 mb-3 text-uppercase fw-bold" style="color: #d96c2c; border-color: #333 !important;">Xác nhận đơn hàng</h5>

                        <div class="mb-4 text-light">
                            <h6 class="fw-bold mb-2 fs-5 text-white">${movieTitle}</h6>
                            <p class="mb-1 opacity-75 small">
                                <i class="fa fa-map-marker me-2" style="color: #d96c2c;"></i>Phòng chiếu: <span class="fw-bold text-white">${showtimeDetails.branchName} - ${showtimeDetails.roomName}</span>
                            </p>
                            <p class="mb-0 opacity-75 small">
                                <i class="fa fa-clock-o me-2" style="color: #d96c2c;"></i>Giờ chiếu: <span class="fw-bold text-white">${showtimeDetails.showTimeFormatted} | Ngày: ${showtimeDetails.showDateFormatted}</span>
                            </p>
                        </div>

                        <div class="mb-3">
                            <h6 class="border-bottom pb-2 mb-2" style="border-color: #333 !important; color: #aaa;">Ghế đã chọn:</h6>
                            <c:choose>
                                <c:when test="${not empty sessionScope.customerBookingData.seats}">
                                    <c:forEach var="seat" items="${sessionScope.customerBookingData.seats}">
                                        <div class="d-flex justify-content-between align-items-center mb-2 pb-1">
                                            <div>
                                                <span class="fw-bold fs-6" style="color: #d96c2c;">${seat.seatCode}</span>
                                                <small class="text-muted ms-1">(${seat.ticketType == 'CHILD' ? 'Trẻ em/HSSV' : 'Người lớn'} - ${seat.seatType})</small>
                                            </div>
                                            <span class="fw-semibold text-light"><fmt:formatNumber value="${seat.price}" type="currency" currencySymbol="₫"/></span>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-muted small fst-italic">Chưa có ghế nào.</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <c:if test="${not empty sessionScope.customerBookingData.concessions}">
                            <div class="mb-3">
                                <h6 class="border-bottom pb-2 mb-2 mt-3" style="border-color: #333 !important; color: #aaa;">Bắp nước:</h6>
                                <c:forEach var="conc" items="${sessionScope.customerBookingData.concessions}">
                                    <div class="d-flex justify-content-between align-items-center mb-2 pb-1">
                                        <div>
                                            <span class="fw-bold text-light">${conc.quantity}x</span>
                                            <small class="text-muted ms-1">${conc.concessionName}</small>
                                        </div>
                                        <span class="fw-semibold text-light"><fmt:formatNumber value="${conc.lineTotal}" type="currency" currencySymbol="₫"/></span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <div class="mb-4 mt-4">
                            <h6 class="border-bottom pb-2 mb-3" style="border-color: #333 !important;">Mã giảm giá</h6>
                            <div class="input-group">
                                <c:set var="currentVoucher" value="${not empty param.voucherCode ? param.voucherCode : sessionScope.customerBookingData.voucherCode}" />
                                <input type="text" class="form-control bg-dark text-light border-secondary" id="voucherCodeInput" placeholder="Nhập mã giảm giá..." value="${currentVoucher}">
                                <button class="btn btn-outline-success fw-bold" type="button" onclick="applyVoucher()">Áp dụng</button>
                            </div>
                            <c:if test="${not empty voucherError}">
                                <small class="form-text text-danger mt-1 d-block"><i class="fa fa-exclamation-circle"></i> ${voucherError}</small>
                            </c:if>
                        </div>

                        <form action="${pageContext.request.contextPath}/booking-summary" method="POST">
                            <input type="hidden" name="showtimeId" value="${sessionScope.customerBookingData.showtimeId}">
                            <input type="hidden" name="voucherCode" id="hiddenVoucherCode" value="${currentVoucher}">

                            <div class="mt-4 pt-3" style="border-top: 1px dashed #555;">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="text-muted small">Tạm tính:</span>
                                    <span class="fw-semibold text-light"><fmt:formatNumber value="${sessionScope.customerBookingData.totalAmount}" type="currency" currencySymbol="₫"/></span>
                                </div>

                                <c:if test="${discountAmount != null && discountAmount > 0}">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="text-success small">Đã giảm (Voucher):</span>
                                        <span class="fw-semibold text-success">- <fmt:formatNumber value="${discountAmount}" type="currency" currencySymbol="₫"/></span>
                                    </div>
                                </c:if>

                                <div class="d-flex justify-content-between align-items-center mt-3 pt-2" style="border-top: 1px solid #333;">
                                    <span class="fw-bold text-light fs-6">TỔNG THANH TOÁN:</span>
                                    <span class="fw-bold fs-3 text-danger"><fmt:formatNumber value="${finalAmount}" type="currency" currencySymbol="₫"/></span>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between mt-4">
                                <a href="${pageContext.request.contextPath}/booking-tickets?showtimeId=${sessionScope.customerBookingData.showtimeId}"
                                   class="btn btn-outline-secondary px-4 fw-semibold border-secondary text-light">
                                    <i class="fa fa-arrow-left me-2"></i> Trở lại
                                </a>
                                <button type="submit" class="btn px-5 fw-bold text-uppercase shadow-sm"
                                        style="background-color: #d96c2c; border-color: #d96c2c; color: white; transition: 0.3s; border-radius: 8px;">
                                    Thanh toán <i class="fa fa-credit-card ms-2"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        function updateSummary() {
            const code = document.getElementById('voucherInput').value;
            const url = new URL(window.location.href);
            url.searchParams.set('voucherCode', code);
            // Maintain showtimeId
            window.location.href = url.toString();
        }

        function applyVoucher() {
            const code = document.getElementById('voucherCodeInput').value.trim();
            const url = new URL(window.location.href);
            if (code) {
                url.searchParams.set('voucherCode', code);
            } else {
                url.searchParams.delete('voucherCode');
            }
            // Tải lại trang (GET request) để Java Server tính toán lại tổng tiền
            window.location.href = url.toString();
        }

        // Đồng bộ giá trị voucher vào thẻ input ẩn của Form thanh toán
        document.getElementById('voucherCodeInput').addEventListener('input', function() {
            document.getElementById('hiddenVoucherCode').value = this.value.trim();
        });

        // Hỗ trợ ấn phím Enter để Apply Voucher
        document.getElementById('voucherCodeInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                applyVoucher();
            }
        });
    </script>
</body>

</html>