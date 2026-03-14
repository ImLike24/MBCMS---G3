<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
            <span class="text-secondary small">Tổng quan hoạt động: suất chiếu, vé bán, phòng chiếu, tỷ lệ lấp đầy ghế</span>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-primary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-calendar fa-2x text-primary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tổng suất chiếu</p>
                                <h4 class="fw-bold mb-0">${operational.totalShowtimes}</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                <i class="fa fa-check fa-2x text-success"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Đã hoàn thành</p>
                                <h4 class="fw-bold mb-0">${operational.completedShowtimes}</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-danger bg-opacity-10 p-3 me-3">
                                <i class="fa fa-times fa-2x text-danger"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Đã hủy</p>
                                <h4 class="fw-bold mb-0">${operational.cancelledShowtimes}</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-warning bg-opacity-10 p-3 me-3">
                                <i class="fa fa-ticket fa-2x text-warning"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tổng vé bán</p>
                                <h4 class="fw-bold mb-0">${operational.totalTickets}</h4>
                            </div>
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
                            <div class="rounded-circle bg-info bg-opacity-10 p-3 me-3">
                                <i class="fa fa-film fa-2x text-info"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo phim</p>
                                <p class="mb-0">Doanh thu, vé bán theo từng phim</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/performance/movie" class="stretched-link"></a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-secondary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-desktop fa-2x text-secondary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo phòng chiếu</p>
                                <p class="mb-0">Hiệu suất từng phòng chiếu</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/performance/screening-room" class="stretched-link"></a>
                    </div>
                </div>
            </div>
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
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-secondary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-bar-chart fa-2x text-secondary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Báo cáo vận hành</p>
                                <p class="mb-0">Chi tiết suất chiếu, vé bán</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/performance/operational-report" class="stretched-link"></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
