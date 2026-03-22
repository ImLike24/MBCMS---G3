<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo Doanh thu</title>
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
        <div class="mb-4">
            <h3 class="fw-bold text-dark mb-1">Báo cáo Doanh thu</h3>
            <span class="text-secondary small">Báo cáo doanh thu chung và báo cáo cụ thể theo chi nhánh, kỳ báo cáo</span>
        </div>

        <%-- Báo cáo doanh thu chung --%>
        <div class="card card-custom border-0 shadow-sm mb-4">
            <div class="card-header bg-transparent border-0 py-3">
                <h5 class="fw-bold text-dark mb-0">Báo cáo doanh thu chung</h5>
            </div>
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/revenue" method="get" id="periodForm">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label">Báo cáo định kỳ <span class="text-danger">*</span></label>
                            <select name="periodType" id="periodType" class="form-select" required>
                                <option value="day" ${periodType == 'day' ? 'selected' : ''}>Theo ngày</option>
                                <option value="month" ${periodType == 'month' ? 'selected' : ''}>Theo tháng</option>
                                <option value="year" ${periodType == 'year' ? 'selected' : ''}>Theo năm</option>
                            </select>
                        </div>
                        <div class="col-md-3" id="wrapDay">
                            <label class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                        </div>
                        <div class="col-md-3" id="wrapToDay">
                            <label class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" name="toDate" value="${toDate}">
                        </div>
                        <div class="col-md-2 d-none" id="wrapMonth">
                            <label class="form-label">Tháng</label>
                            <select name="month" class="form-select">
                                <c:forEach begin="1" end="12" var="m">
                                    <option value="${m}" ${selectedMonth != null && selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2 d-none" id="wrapYear">
                            <label class="form-label">Năm</label>
                            <select name="year" class="form-select" id="yearSelect">
                                <c:forEach begin="2023" end="2030" var="y">
                                    <option value="${y}" ${selectedYear != null && selectedYear == y ? 'selected' : ''}>${y}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-orange w-100">
                                <i class="fa fa-filter me-2"></i>Áp dụng
                            </button>
                        </div>
                    </div>
                </form>

                <div class="table-responsive mt-4">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">Tên chi nhánh</th>
                            <th>Báo cáo định kỳ</th>
                            <th class="text-end pe-4">Tổng doanh thu của chi nhánh</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${rows}">
                            <tr>
                                <td class="ps-4">
                                    <i class="fa fa-building text-muted me-2"></i>
                                    <strong>${r.branchName}</strong>
                                </td>
                                <td class="text-muted">${periodLabel}</td>
                                <td class="text-end pe-4 fw-bold text-success">
                                    <fmt:formatNumber value="${r.totalRevenue}" type="number" maxFractionDigits="0"/> đ
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty rows}">
                            <tr><td colspan="3" class="text-center py-4 text-muted">Chọn kỳ báo cáo và nhấn Áp dụng để xem dữ liệu.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- Báo cáo cụ thể --%>
        <div class="card card-custom border-0 shadow-sm">
            <div class="card-header bg-transparent border-0 py-3">
                <h5 class="fw-bold text-dark mb-0">Báo cáo cụ thể</h5>
            </div>
            <div class="card-body p-4">
                <p class="text-muted small mb-4">Xem chi tiết doanh thu theo vé và combo trong kỳ đã chọn.</p>
                <a href="${pageContext.request.contextPath}/manager/report/revenue/detail" class="btn btn-orange">
                    <i class="fa fa-file-lines me-2"></i>Xem báo cáo cụ thể
                </a>
            </div>
        </div>

        <div class="row g-4 mt-2">
            <div class="col-md-4">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-warning bg-opacity-10 p-3 me-3">
                                <i class="fa fa-calendar fa-2x text-warning"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo ngày</p>
                                <p class="mb-0">Doanh thu theo từng ngày</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/revenue/date-report" class="stretched-link"></a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-info bg-opacity-10 p-3 me-3">
                                <i class="fa fa-film fa-2x text-info"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo phim</p>
                                <p class="mb-0">Doanh thu theo từng phim</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/revenue/movie-report" class="stretched-link"></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
    var periodType = document.getElementById('periodType');
    var wrapDay = document.getElementById('wrapDay');
    var wrapToDay = document.getElementById('wrapToDay');
    var wrapMonth = document.getElementById('wrapMonth');
    var wrapYear = document.getElementById('wrapYear');

    function togglePeriodFields() {
        var v = periodType.value;
        wrapDay.classList.toggle('d-none', v !== 'day');
        wrapToDay.classList.toggle('d-none', v !== 'day');
        wrapMonth.classList.toggle('d-none', v !== 'month');
        wrapYear.classList.toggle('d-none', v !== 'month' && v !== 'year');
    }
    periodType.addEventListener('change', togglePeriodFields);
    togglePeriodFields();
})();
</script>
</body>
</html>
