<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo Hiệu suất</title>
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
        <div class="mb-4">
            <h3 class="fw-bold text-dark mb-1">Báo cáo Hiệu suất</h3>
            <span class="text-secondary small">Báo cáo hiệu suất chung và chỉ số hiệu suất theo khoảng thời gian</span>
        </div>

        <%-- Báo cáo hiệu suất chung --%>
        <div class="card card-custom border-0 shadow-sm mb-4">
            <div class="card-header bg-transparent border-0 py-3">
                <h5 class="fw-bold text-dark mb-0">Báo cáo hiệu suất chung</h5>
            </div>
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/performance" method="get" id="periodForm">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label">Khoảng thời gian</label>
                            <select name="periodType" id="periodType" class="form-select">
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
                            <select name="year" class="form-select">
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
                            <th>Khoảng thời gian</th>
                            <th class="text-end pe-4">Tổng số suất chiếu</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${branchRows}">
                            <tr>
                                <td class="ps-4">
                                    <i class="fa fa-building text-muted me-2"></i>
                                    <strong>${r.branchName}</strong>
                                </td>
                                <td class="text-muted">${periodLabel}</td>
                                <td class="text-end pe-4 fw-semibold">${r.totalShowtimes}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty branchRows}">
                            <tr><td colspan="3" class="text-center py-4 text-muted">Chọn khoảng thời gian và nhấn Áp dụng để xem dữ liệu.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- Chỉ số hiệu suất (Performance Metrics) --%>
        <div class="card card-custom border-0 shadow-sm mb-4">
            <div class="card-header bg-transparent border-0 py-3">
                <h5 class="fw-bold text-dark mb-0">Chỉ số hiệu suất (Performance Metrics)</h5>
            </div>
            <div class="card-body p-4">
                <p class="text-muted small mb-4">Khoảng thời gian đang xem: <strong>${periodLabel}</strong></p>

                <p class="text-uppercase small fw-semibold text-secondary mb-2">Nhóm trường – Tỷ lệ sử dụng chỗ ngồi</p>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label mb-1">Tỷ lệ lấp đầy chỗ ngồi</label>
                        <p class="mb-0 text-muted small">Phần trăm số chỗ ngồi đã được sử dụng trong tất cả các suất chiếu. Loại: Phần trăm.</p>
                        <div class="form-control bg-light mt-2" readonly>
                            <fmt:formatNumber value="${seatMetrics != null ? seatMetrics.occupancyRatePct : 0}" type="number" maxFractionDigits="1"/>%
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label mb-1">Số chỗ ngồi bán trung bình</label>
                        <p class="mb-0 text-muted small">Số chỗ ngồi bán trung bình cho mỗi suất chiếu. Loại: Số nguyên.</p>
                        <div class="form-control bg-light mt-2" readonly>
                            ${seatMetrics != null ? seatMetrics.averageSeatsSold : 0} chỗ / suất chiếu
                        </div>
                    </div>
                </div>

                <p class="text-uppercase small fw-semibold text-secondary mb-2">Nhóm trường – Phân tích giờ cao điểm</p>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label mb-1">Giờ cao điểm</label>
                        <p class="mb-0 text-muted small">Khoảng thời gian có lượng khán giả tham dự cao nhất. Loại: Khoảng thời gian.</p>
                        <div class="form-control bg-light mt-2" readonly>
                            ${peakLow != null ? peakLow.peakHours : '—'}
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label mb-1">Giờ thấp điểm</label>
                        <p class="mb-0 text-muted small">Khoảng thời gian có lượng khán giả tham dự thấp nhất. Loại: Khoảng thời gian.</p>
                        <div class="form-control bg-light mt-2" readonly>
                            ${peakLow != null ? peakLow.lowDemandHours : '—'}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                <i class="fa fa-pie-chart fa-2x text-success"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tỷ lệ lấp đầy ghế</p>
                                <p class="mb-0">Occupancy % theo phòng</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/performance/seat-occupancy" class="stretched-link"></a>
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
