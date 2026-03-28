<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử giao dịch | MyCinema</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --bg-dark: #0a0b10;
            --card-bg: #161821;
            --card-border: rgba(255, 255, 255, 0.08);
            --accent-orange: #d96c2c;
            --accent-red: #fc6076;
            --text-main: #f8f9fb;
            --text-muted: #8e93a6;
            --primary-color: #d96c2c;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            font-family: 'Inter', sans-serif;
            padding-top: 80px;
            min-height: 100vh;
        }

        .container { max-width: 1000px; }

        .page-header {
            margin-bottom: 40px;
            border-left: 5px solid var(--accent-orange);
            padding-left: 20px;
        }

        .filter-section {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }

        .form-control {
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--card-border);
            color: #fff;
            border-radius: 10px;
            padding: 10px 15px;
        }

        input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(1);
            cursor: pointer;
        }

        .form-control:focus {
            background: rgba(255,255,255,0.08);
            border-color: var(--accent-orange);
            box-shadow: none;
            color: #fff;
        }

        .transaction-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            overflow: hidden;
        }

        .transaction-card:hover {
            transform: translateY(-3px);
            border-color: rgba(255,255,255,0.15);
            box-shadow: 0 12px 24px rgba(0,0,0,0.4);
        }

        .card-header-custom {
            padding: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .left-info {
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
        }

        .trans-code {
            font-weight: 700;
            font-size: 1.1rem;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .trans-code i { color: var(--accent-orange); }

        .meta-item {
            font-size: 0.95rem;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .meta-item i { color: var(--accent-orange); opacity: 0.8; }

        .payment-badge {
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-cash {
            border: 1px solid var(--accent-orange);
            color: var(--accent-orange);
            background: rgba(255, 154, 68, 0.05);
        }

        .badge-banking {
            border: 1px solid var(--accent-red);
            color: var(--accent-red);
            background: rgba(252, 96, 118, 0.05);
        }

        .total-amount {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--primary-color);
        }

        .expand-btn {
            width: 36px;
            height: 36px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: none;
        }

        .transaction-card.active .expand-btn {
            transform: rotate(180deg);
            background: var(--primary-color);
            color: #fff;
        }

        .details-pane {
            max-height: 0;
            overflow: hidden;
            transition: none;
            background: rgba(0,0,0,0.15);
        }

        .transaction-card.active .details-pane {
            max-height: 500px;
            padding: 24px;
            border-top: 1px solid var(--card-border);
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
            margin-bottom: 16px;
        }

        .detail-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .detail-value {
            font-size: 1.1rem;
            font-weight: 600;
            color: #fff;
        }

        .seat-tag {
            background: rgba(255,255,255,0.1);
            padding: 2px 8px;
            border-radius: 4px;
            margin-right: 5px;
            font-family: monospace;
        }

        .btn-search {
            background: var(--primary-color);
            border: none;
            color: white;
            font-weight: 600;
            padding: 10px 25px;
            border-radius: 10px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 0;
            color: var(--text-muted);
        }

        .pagination-container {
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 10px;
        }
        .page-link-custom {
            padding: 8px 16px;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            color: var(--text-main);
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .page-link-custom:hover {
            border-color: var(--accent-orange);
            color: var(--accent-orange);
            transform: translateY(-2px);
        }
        .page-link-custom.active {
            background: var(--primary-color);
            border-color: var(--primary-color);
            color: #fff;
            box-shadow: 0 4px 12px rgba(217, 108, 44, 0.3);
        }
        .page-link-custom.disabled {
            opacity: 0.4;
            cursor: not-allowed;
            pointer-events: none;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/Header.jsp" />

<div class="container">
    <div class="page-header">
        <h1 class="fw-bold">Lịch sử giao dịch</h1>
        <p class="text-muted">Theo dõi toàn bộ vé xem phim bạn đã mua online và tại quầy.</p>
    </div>

    <!-- Filters -->
    <section class="filter-section">
        <form action="${pageContext.request.contextPath}/customer/booking-history" method="get" class="row g-3 align-items-end">
            <div class="col-md-4">
                <label class="form-label small text-muted">Từ ngày</label>
                <input type="date" name="fromDate" value="${fromDate}" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label small text-muted">Đến ngày</label>
                <input type="date" name="toDate" value="${toDate}" class="form-control">
            </div>
            <div class="col-md-4">
                <button type="submit" class="btn btn-search w-100">Tìm kiếm</button>
            </div>
        </form>
    </section>

    <!-- History List -->
    <div class="history-list">
        <c:choose>
            <c:when test="${not empty historyList}">
                <c:forEach var="item" items="${historyList}">
                    <div class="transaction-card">
                        <div class="card-header-custom" onclick="toggleCard(this)">
                            <div class="left-info">
                                <div class="trans-code">
                                    <i class="fa-solid fa-ticket-simple"></i>
                                    ${item.transactionCode}
                                </div>
                                <div class="meta-item">
                                    <i class="fa-regular fa-calendar"></i>
                                    <fmt:formatDate value="${item.transactionDate}" pattern="dd/MM/yyyy • HH:mm" />
                                </div>
                                <div class="meta-item">
                                    <i class="fa-solid fa-location-dot"></i>
                                    ${item.branchName}
                                </div>
                            </div>
                            <div class="d-flex align-items-center gap-4">
                                <div class="total-amount">
                                    <fmt:formatNumber value="${item.totalAmount}" type="currency" currencySymbol="₫" />
                                </div>
                                <div class="expand-btn">
                                    <i class="fa-solid fa-chevron-down"></i>
                                </div>
                            </div>
                        </div>
                        <div class="details-pane">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="detail-item">
                                        <span class="detail-label">Phim</span>
                                        <span class="detail-value">${item.movieTitle}</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="detail-item">
                                        <span class="detail-label">Ghế ngồi</span>
                                        <span class="detail-value">
                                            <c:out value="${item.seatCodes}" />
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="detail-item">
                                        <span class="detail-label">Loại ghế</span>
                                        <span class="detail-value">
                                            <c:out value="${item.seatTypes}" />
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="detail-item">
                                        <span class="detail-label">Phương thức thanh toán</span>
                                        <span class="detail-value" style="color: var(--accent-orange)">${item.paymentMethod}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination-container mb-5">
                        <c:url var="prevUrl" value="/customer/booking-history">
                            <c:param name="page" value="${currentPage - 1}" />
                            <c:param name="fromDate" value="${fromDate}" />
                            <c:param name="toDate" value="${toDate}" />
                        </c:url>
                        <a href="${prevUrl}" class="page-link-custom ${currentPage <= 1 ? 'disabled' : ''}">
                            <i class="fa-solid fa-chevron-left"></i>
                        </a>

                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:url var="pageUrl" value="/customer/booking-history">
                                <c:param name="page" value="${p}" />
                                <c:param name="fromDate" value="${fromDate}" />
                                <c:param name="toDate" value="${toDate}" />
                            </c:url>
                            <a href="${pageUrl}" class="page-link-custom ${p == currentPage ? 'active' : ''}">${p}</a>
                        </c:forEach>

                        <c:url var="nextUrl" value="/customer/booking-history">
                            <c:param name="page" value="${currentPage + 1}" />
                            <c:param name="fromDate" value="${fromDate}" />
                            <c:param name="toDate" value="${toDate}" />
                        </c:url>
                        <a href="${nextUrl}" class="page-link-custom ${currentPage >= totalPages ? 'disabled' : ''}">
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fa-regular fa-folder-open fa-3x mb-3"></i>
                    <p>Không tìm thấy dữ liệu giao dịch nào.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/components/layout/Footer.jsp" />

<script>
    function toggleCard(header) {
        const card = header.parentElement;
        card.classList.toggle('active');
    }
</script>

<!-- Bootstrap Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>