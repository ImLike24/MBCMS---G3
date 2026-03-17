<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo Vận hành</title>
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
                <h3 class="fw-bold text-dark mb-1">Báo cáo Vận hành</h3>
                <span class="text-secondary small">Tổng hợp suất chiếu, trạng thái và vé bán</span>
            </div>
            <a href="${pageContext.request.contextPath}/manager/report/performance" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-2"></i>Quay lại
            </a>
        </div>

        <div class="card card-custom mb-4">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/performance/operational-report" method="get" class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Từ ngày</label>
                        <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Đến ngày</label>
                        <input type="date" class="form-control" name="toDate" value="${toDate}">
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-orange px-4">
                            <i class="fa fa-filter me-2"></i>Lọc
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-primary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-calendar fa-2x text-primary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tổng suất chiếu</p>
                                <h3 class="fw-bold mb-0">${row.totalShowtimes}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                <i class="fa fa-check fa-2x text-success"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Đã hoàn thành</p>
                                <h3 class="fw-bold mb-0">${row.completedShowtimes}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-danger bg-opacity-10 p-3 me-3">
                                <i class="fa fa-times fa-2x text-danger"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Đã hủy</p>
                                <h3 class="fw-bold mb-0">${row.cancelledShowtimes}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-warning bg-opacity-10 p-3 me-3">
                                <i class="fa fa-ticket fa-2x text-warning"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tổng vé bán</p>
                                <h3 class="fw-bold mb-0">${row.totalTickets}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
