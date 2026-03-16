<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đặt vé | MyCinema</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <style>
        :root { --dark: #212529; --orange: #d96c2c; }
        body { background: #111; color: #fff; padding-top: 56px; min-height: 100vh; }
        .history-hero {
            background: linear-gradient(135deg, #000 0%, #212529 50%, #1a1a1a 100%);
            padding: 40px 30px;
            border-radius: 12px;
            margin-bottom: 32px;
            border-left: 6px solid var(--orange);
        }
        .invoice-card {
            background: var(--dark);
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.08);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .invoice-card:hover { border-color: rgba(217,108,44,0.4); }
        .invoice-header {
            padding: 20px 24px;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            cursor: pointer;
            user-select: none;
        }
        .invoice-header:focus { outline: none; }
        .invoice-card:not(.expanded) .invoice-header { border-bottom: 1px solid rgba(255,255,255,0.06); }
        .invoice-header .invoice-toggle { transition: transform 0.2s; color: #888; }
        .invoice-card.expanded .invoice-header .invoice-toggle { transform: rotate(180deg); color: var(--orange); }
        .invoice-header-left { display: flex; flex-wrap: wrap; align-items: center; gap: 16px; }
        .invoice-code { font-weight: 700; font-size: 1.1rem; color: var(--orange); }
        .invoice-meta { font-size: 0.9rem; color: #aaa; }
        .invoice-total { font-size: 1.25rem; font-weight: 600; color: var(--orange); }
        .invoice-detail { display: none; padding: 0 24px 24px; }
        .invoice-card.expanded .invoice-detail { display: block; }
        .detail-section { margin-top: 20px; }
        .detail-section h6 { color: var(--orange); margin-bottom: 12px; font-weight: 600; }
        .ticket-table { width: 100%; margin: 0; }
        .ticket-table th, .ticket-table td { padding: 12px 16px; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .ticket-table th { color: #888; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; }
        .ticket-table tr:last-child td { border-bottom: none; }
        .ticket-table tbody tr:hover { background: rgba(255,255,255,0.03); }
        .seat-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; margin-right: 6px; margin-bottom: 4px; font-size: 0.85rem; }
        .pagination-wrap { margin-top: 32px; margin-bottom: 48px; }
        .pagination .page-link { background: var(--dark); border-color: #444; color: #fff; }
        .pagination .page-link:hover { background: var(--orange); border-color: var(--orange); color: #fff; }
        .pagination .page-item.active .page-link { background: var(--orange); border-color: var(--orange); }
        .empty-state { text-align: center; padding: 60px 20px; color: #888; }
        .badge-method { font-size: 0.75rem; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/Header.jsp"/>

<div class="container mt-4 mb-5">
    <div class="history-hero">
        <h1><i class="fa fa-history me-2" style="color: var(--orange);"></i> Lịch sử đặt vé</h1>
        <p class="text-white-50 mb-0 mt-2">Các hóa đơn đặt vé online của bạn. Mỗi hóa đơn kèm chi tiết vé.</p>
    </div>

    <c:choose>
        <c:when test="${not empty invoices}">
            <c:forEach var="inv" items="${invoices}" varStatus="st">
                <div class="invoice-card" data-invoice-index="${st.index}">
                    <div class="invoice-header" role="button" tabindex="0" aria-expanded="false" aria-controls="invoice-detail-${st.index}" id="invoice-header-${st.index}">
                        <div class="invoice-header-left">
                            <span class="invoice-code">#${inv.invoiceCode}</span>
                            <span class="invoice-meta">
                                <i class="fa fa-calendar me-1"></i>
                                <fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                            <span class="invoice-meta">
                                <i class="fa fa-building me-1"></i><c:out value="${inv.branchName}"/>
                            </span>
                            <c:if test="${not empty inv.bookingCode}">
                                <span class="invoice-meta"><i class="fa fa-ticket me-1"></i>${inv.bookingCode}</span>
                            </c:if>
                            <span class="badge bg-secondary badge-method">${inv.paymentMethod}</span>
                            <span class="invoice-meta ms-2 text-white-50">(Ấn để xem chi tiết vé & ghế)</span>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <span class="invoice-total">
                                <fmt:formatNumber value="${inv.finalAmount}" type="currency" currencyCode="VND" currencySymbol="₫"/>
                            </span>
                            <i class="fa fa-chevron-down invoice-toggle"></i>
                        </div>
                    </div>
                    <div class="invoice-detail" id="invoice-detail-${st.index}" aria-hidden="true">
                        <div class="detail-section">
                            <h6><i class="fa fa-film me-2"></i>Chi tiết vé</h6>
                            <div class="table-responsive">
                                <table class="ticket-table">
                                    <thead>
                                        <tr>
                                            <th>Tên phim</th>
                                            <th>Giờ suất chiếu</th>
                                            <th>Phòng</th>
                                            <th class="text-end">Đơn giá</th>
                                            <th class="text-end">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${inv.items}">
                                            <tr>
                                                <td><c:out value="${item.movieTitle}"/></td>
                                                <td>
                                                    <fmt:formatDate value="${item.showtimeDate}" pattern="dd/MM/yyyy"/>
                                                    <c:if test="${not empty item.showtimeTime}"> — <fmt:formatDate value="${item.showtimeTime}" type="time" timeStyle="short"/></c:if>
                                                </td>
                                                <td><c:out value="${item.roomName}"/></td>
                                                <td class="text-end"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencyCode="VND" currencySymbol="₫"/></td>
                                                <td class="text-end"><fmt:formatNumber value="${item.amount}" type="currency" currencyCode="VND" currencySymbol="₫"/></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="detail-section">
                            <h6><i class="fa fa-chair me-2"></i>Ghế đã đặt</h6>
                            <div class="table-responsive">
                                <table class="ticket-table">
                                    <thead>
                                        <tr>
                                            <th>Mã ghế</th>
                                            <th>Vị trí ghế</th>
                                            <th>Loại ghế</th>
                                            <th>Loại vé</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${inv.items}">
                                            <tr>
                                                <td><span class="badge bg-dark">${item.seatCode}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.seatRow || item.seatCol != null}">
                                                            Hàng <c:out value="${item.seatRow}"/><c:if test="${item.seatCol != null}">, Số ${item.seatCol}</c:if>
                                                        </c:when>
                                                        <c:otherwise>${item.seatCode}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${item.seatType}</td>
                                                <td>${item.ticketType == 'ADULT' ? 'Người lớn' : 'Trẻ em'}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <div class="pagination-wrap d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="text-muted">
                    Hiển thị ${(page - 1) * pageSize + 1}–${(page - 1) * pageSize + invoices.size()} / ${totalCount} hóa đơn
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <c:if test="${page > 1}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/customer/booking-history?page=${page - 1}">Trước</a>
                            </li>
                        </c:if>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <li class="page-item ${p == page ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/customer/booking-history?page=${p}">${p}</a>
                            </li>
                        </c:forEach>
                        <c:if test="${page < totalPages}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/customer/booking-history?page=${page + 1}">Sau</a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="fa fa-receipt fa-4x text-muted mb-3"></i>
                <h5>Chưa có hóa đơn nào</h5>
                <p class="mb-0">Bạn chưa đặt vé online. Đặt vé tại <a href="${pageContext.request.contextPath}/movies" class="text-warning">Phim đang chiếu</a> hoặc <a href="${pageContext.request.contextPath}/showtimes" class="text-warning">Lịch chiếu</a>.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/components/layout/Footer.jsp"/>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
    document.querySelectorAll('.invoice-header').forEach(function(header) {
        header.addEventListener('click', function() {
            var card = this.closest('.invoice-card');
            var detail = card.querySelector('.invoice-detail');
            var expanded = card.classList.toggle('expanded');
            header.setAttribute('aria-expanded', expanded);
            if (detail) detail.setAttribute('aria-hidden', !expanded);
        });
        header.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
            }
        });
    });
})();
</script>
</body>
</html>
