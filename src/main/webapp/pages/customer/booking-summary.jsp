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

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <c:if test="${pendingPaymentMessage}">
                        <div class="alert alert-info fw-semibold mb-4">
                            Hiện tại chưa làm bước Xử lý thanh toán
                        </div>
                    </c:if>

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
                            <c:forEach var="seat" items="${selectedSeats}">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <span class="seat-tag">${seat.seatCode}</span>
                                        <span class="badge bg-secondary me-1">${seat.seatType}</span>
                                        <span class="badge bg-info">${seat.ticketType == 'CHILD' ? 'Trẻ em' : 'Người lớn'}</span>
                                    </div>
                                    <div class="text-end text-light">
                                        <fmt:formatNumber value="${seat.price}" type="currency" currencySymbol="₫" />
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <c:if test="${not empty selectedConcessions}">
                            <hr>
                            <h5 class="mb-2">Đồ ăn / Thức uống</h5>
                            <c:forEach var="con" items="${selectedConcessions}">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span>${con.concessionName} <span class="text-muted">x${con.quantity}</span></span>
                                    <span class="text-light">
                                        <fmt:formatNumber value="${con.lineTotal}" type="number" maxFractionDigits="0" /> ₫
                                    </span>
                                </div>
                            </c:forEach>
                            <div class="d-flex justify-content-between align-items-center mt-2">
                                <span class="text-muted">Tổng vé</span>
                                <span>
                                    <fmt:formatNumber value="${ticketTotal}" type="number" maxFractionDigits="0" /> ₫
                                </span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted small">Tổng đồ ăn / thức uống</span>
                                <span class="small">
                                    <fmt:formatNumber value="${concessionTotal}" type="number" maxFractionDigits="0" /> ₫
                                </span>
                            </div>
                        </c:if>

                        <c:if test="${!paymentSuccess}">
                            <div class="voucher-section mt-4 mb-3 border-top border-secondary pt-3">
                                <label class="form-label text-muted small mb-2">Mã giảm giá & Điểm thưởng</label>
                                <div class="input-group input-group-sm">
                                    <input type="text" id="voucherInput" class="form-control bg-dark text-light border-secondary" placeholder="Nhập mã voucher" value="${appliedVoucherCode}">
                                    <button class="btn btn-outline-primary" type="button" onclick="updateSummary()">Áp dụng mã</button>
                                </div>
                                <c:if test="${not empty voucherMessage}">
                                    <div class="small ${isVoucherValid ? 'text-success' : 'text-danger'} mt-1">
                                        ${voucherMessage}
                                    </div>
                                </c:if>
                            </div>
                        </c:if>

                        <div class="border-top border-secondary mt-3 pt-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-muted">Tổng cộng</span>
                                <span class="text-light">
                                    <fmt:formatNumber value="${totalAmount != null ? totalAmount : 0}" type="currency" currencySymbol="₫" />
                                </span>
                            </div>
                            <c:if test="${discountAmount != null && discountAmount > 0}">
                                <div class="d-flex justify-content-between align-items-center mb-2 text-success">
                                    <span>Lượng giá giảm:</span>
                                    <span>Giảm giá: <fmt:formatNumber value="${discountAmount}" type="number" maxFractionDigits="0" /> đ</span>
                                </div>
                            </c:if>
                            <div class="d-flex justify-content-between align-items-center border-top border-secondary pt-2">
                                <span class="fw-bold">Thành tiền</span>
                                <span class="total-amount fs-4">
                                    <fmt:formatNumber value="${totalAmount - discountAmount}" type="currency" currencySymbol="₫" />
                                </span>
                            </div>
                        </div>
                    </div>

                    <c:if test="${!paymentSuccess}">
                        <form method="post" action="${pageContext.request.contextPath}/customer/booking-summary">
                            <input type="hidden" name="showtimeId" value="${showtimeId}">
                            <input type="hidden" name="appliedVoucherCode" value="${appliedVoucherCode}">

                            <div class="mb-4">
                                <h5 class="mb-3">Phương thức thanh toán</h5>
                                <p class="text-light"><i class="fa fa-credit-card"></i> Thanh toán online (BANKING)</p>
                            </div>

                            <div class="d-flex gap-3">
                                <button type="submit" class="btn btn-primary flex-fill">Xử lý thanh toán</button>
                            </div>
                        </form>
                    </c:if>

                    <c:if test="${paymentSuccess}">
                        <div class="receipt-box mt-4">
                            <h5 class="mb-2">Hóa đơn thanh toán</h5>
                            <p class="mb-1"><strong>Mã hóa đơn:</strong> ${receiptBookingCode}</p>
                            <p class="mb-1"><strong>Phim:</strong> ${movieTitle}</p>
                            <p class="mb-1"><strong>Rạp:</strong> ${showtimeDetails.branchName}</p>
                            <p class="mb-1"><strong>Ngày chiếu:</strong> ${showDateFormatted} — <strong>Giờ:</strong> ${showTimeFormatted}</p>
                            <p class="mb-1"><strong>Ghế:</strong> ${receiptSeats}</p>
                            <p class="mb-0"><strong>Tổng tiền:</strong>
                                <fmt:formatNumber value="${receiptTotal}" type="currency" currencySymbol="₫" />
                            </p>
                        </div>
                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/movies" class="btn btn-primary">Quay lại danh sách phim</a>
                        </div>
                    </c:if>
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
    </script>
</body>

</html>