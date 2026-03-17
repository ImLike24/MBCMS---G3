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
            <span class="text-secondary small">Tổng quan và các báo cáo chi tiết theo chi nhánh, ngày, phim, phương thức thanh toán</span>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                <i class="fa fa-money fa-2x text-success"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Tổng doanh thu (30 ngày)</p>
                                <h4 class="fw-bold text-success mb-0">
                                    <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0"/> đ
                                </h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-primary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-building fa-2x text-primary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo chi nhánh</p>
                                <p class="mb-0">Xem doanh thu từng chi nhánh</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/revenue/branch-report" class="stretched-link"></a>
                    </div>
                </div>
            </div>
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
                                <p class="mb-0">Doanh thu theo từng phim</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/revenue/movie-report" class="stretched-link"></a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card card-custom border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="rounded-circle bg-secondary bg-opacity-10 p-3 me-3">
                                <i class="fa fa-credit-card fa-2x text-secondary"></i>
                            </div>
                            <div>
                                <p class="text-muted mb-0 small">Theo phương thức thanh toán</p>
                                <p class="mb-0">Tiền mặt, chuyển khoản, ZaloPay...</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/report/revenue/payment-method" class="stretched-link"></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
