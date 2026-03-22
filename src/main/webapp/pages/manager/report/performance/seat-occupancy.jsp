<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tỷ lệ Lấp đầy ghế</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="performance"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">Tỷ lệ Lấp đầy ghế</h3>
                <span class="text-secondary small">Tỷ lệ lấp đầy trung bình theo phòng (tổng vé đã bán / tổng sức chứa)</span>
            </div>
            <a href="${pageContext.request.contextPath}/manager/report/performance" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-2"></i>Quay lại
            </a>
        </div>

        <div class="card card-custom mb-4">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/performance/seat-occupancy" method="get" class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label">Chi nhánh</label>
                        <select name="branchId" class="form-select">
                            <option value="all">Tất cả chi nhánh</option>
                            <c:forEach var="b" items="${managedBranches}">
                                <option value="${b.branchId}" ${selectedBranchId != null && selectedBranchId == b.branchId ? 'selected' : ''}>${b.branchName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Từ ngày</label>
                        <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Đến ngày</label>
                        <input type="date" class="form-control" name="toDate" value="${toDate}">
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-orange w-100">
                            <i class="fa fa-filter me-2"></i>Lọc dữ liệu
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card card-custom">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">Phòng chiếu</th>
                            <th>Sức chứa</th>
                            <th>Suất chiếu</th>
                            <th>Ghế đã bán</th>
                            <th class="text-end pe-4">Tỷ lệ lấp đầy</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${rows}">
                            <tr>
                                <td class="ps-4">
                                    <i class="fa fa-desktop text-muted me-2"></i>
                                    <strong>${r.roomName}</strong>
                                </td>
                                <td>${r.totalSeats}</td>
                                <td>${r.showtimesCount}</td>
                                <td>${r.soldSeats}</td>
                                <td class="text-end pe-4">
                                    <span class="badge ${r.occupancyPct != null && r.occupancyPct.doubleValue() >= 50 ? 'bg-success' : 'bg-warning'} rounded-pill px-3">
                                        <fmt:formatNumber value="${r.occupancyPct}" type="number" maxFractionDigits="1"/>%
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty rows}">
                            <tr><td colspan="5" class="text-center py-4 text-muted">Không có dữ liệu trong khoảng thời gian này.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
