<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo Doanh thu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        .filter-card { background: #f8f9fa; border-radius: 10px; }
        .table-custom th { background: #070707; color: #fff; font-weight: 600; font-size: 0.85rem; }
        .btn-orange { background: #d96c2c; border-color: #d96c2c; color: #fff; }
        .btn-orange:hover { background: #b85a22; border-color: #b85a22; color: #fff; }
        .sum-box { font-size: 1.75rem; font-weight: 700; color: #d96c2c; }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp"/>
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="revenue"/>
</jsp:include>
<main>
<div class="container-fluid py-4">
    <h3 class="fw-bold mb-1"><i class="fa-solid fa-coins me-2" style="color:#d96c2c;"></i>Báo cáo Doanh thu</h3>
    <p class="text-muted small mb-2">Theo vé (online + quầy).</p>

    <c:if test="${not empty reportFilterError}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <c:out value="${reportFilterError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>

    <form method="get" action="${pageContext.request.contextPath}/manager/report/revenue" class="filter-card p-4 mb-4 shadow-sm">
        <div class="row g-3 align-items-end">
            <div class="col-md-4">
                <label class="form-label fw-semibold">Chi nhánh</label>
                <select name="branchId" class="form-select border-dark">
                    <option value="all" ${empty selectedBranchId ? 'selected' : ''}>Tất cả</option>
                    <c:forEach var="b" items="${managedBranches}">
                        <option value="${b.branchId}" ${selectedBranchId != null && selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.branchName}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-3"><label class="form-label fw-semibold">Từ ngày</label>
                <input type="date" name="from" class="form-control border-dark" value="${fromDate}"></div>
            <div class="col-md-3"><label class="form-label fw-semibold">Đến ngày</label>
                <input type="date" name="to" class="form-control border-dark" value="${toDate}" max="${todayMaxDate}"></div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-orange w-100"><i class="fa-solid fa-filter me-1"></i> Xem</button>
            </div>
        </div>
    </form>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <span class="text-muted text-uppercase small fw-semibold">Tổng doanh thu (vé)</span>
            <p class="sum-box mb-0">
                <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0" groupingUsed="true"/> đ
            </p>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-dark text-white py-2 small"><i class="fa-solid fa-table me-1"></i> Chi tiết</div>
        <div class="table-responsive">
            <table class="table table-hover mb-0 table-custom">
                <thead>
                <tr>
                    <th>Chi nhánh</th>
                    <th>Ngày chiếu</th>
                    <th class="text-end">Vé bán</th>
                    <th class="text-end">Doanh thu</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty ticketRevenueRows}">
                        <tr><td colspan="4" class="text-center text-muted py-3">Không có dữ liệu</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="r" items="${ticketRevenueRows}">
                            <tr>
                                <td><c:out value="${r.branchName}"/></td>
                                <td>${r.showDate}</td>
                                <td class="text-end">${r.totalTicketsSold}</td>
                                <td class="text-end"><fmt:formatNumber value="${r.totalRevenue}" type="number" maxFractionDigits="0" groupingUsed="true"/> đ</td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
