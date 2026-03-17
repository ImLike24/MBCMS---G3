<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo Doanh thu cụ thể</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="revenue"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">Báo cáo cụ thể</h3>
                <span class="text-secondary small">Chi tiết doanh thu theo vé và combo theo kỳ</span>
            </div>
            <a href="${pageContext.request.contextPath}/manager/report/revenue" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-2"></i>Quay lại
            </a>
        </div>

        <div class="card card-custom border-0 shadow-sm">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/revenue/detail" method="get" id="detailForm">
                    <input type="hidden" name="generate" value="1">

                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <label class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" name="toDate" value="${toDate}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Chi nhánh</label>
                            <select name="branchId" class="form-select">
                                <option value="all">Tất cả chi nhánh</option>
                                <c:forEach var="b" items="${managedBranches}">
                                    <option value="${b.branchId}" ${selectedBranchId != null && selectedBranchId == b.branchId ? 'selected' : ''}>
                                        ${b.branchName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold">Revenue (Chỉ số hiệu suất)</label>
                        <select name="revenueMetric" class="form-select" style="max-width: 280px;">
                            <option value="total" ${revenueMetric == 'total' ? 'selected' : ''}>Tổng doanh thu</option>
                            <option value="ticket" ${revenueMetric == 'ticket' ? 'selected' : ''}>Doanh thu vé</option>
                            <option value="combo" ${revenueMetric == 'combo' ? 'selected' : ''}>Doanh thu combo</option>
                        </select>
                    </div>

                    <hr class="my-4">

                    <p class="text-muted small text-uppercase fw-semibold mb-3">Revenue Breakdown</p>
                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <label class="form-label">Ticket Revenue (Doanh thu vé)</label>
                            <div class="form-control bg-light" readonly>
                                <fmt:formatNumber value="${generated ? ticketRevenue : 0}" type="number" maxFractionDigits="0"/> đ
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Combo Revenue (Doanh thu combo)</label>
                            <div class="form-control bg-light" readonly>
                                <fmt:formatNumber value="${generated ? comboRevenue : 0}" type="number" maxFractionDigits="0"/> đ
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">

                    <p class="text-muted small text-uppercase fw-semibold mb-3">Report Actions</p>
                    <button type="submit" class="btn btn-orange">
                        <i class="fa fa-filter me-2"></i>Lọc dữ liệu
                    </button>
                </form>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
