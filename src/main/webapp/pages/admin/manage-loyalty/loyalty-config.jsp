<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình Tích Điểm - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="loyalty-config"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <!-- Page Title + Breadcrumb -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold" style="color: #212529;">Cấu hình Tích Điểm (Loyalty)</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Cấu hình Tích Điểm</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="success" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="error" scope="session" />
        </c:if>

        <div class="row g-4">
            <!-- Form Card -->
            <div class="col-lg-8">
                <div class="card card-custom shadow-sm border-0">
                    <div class="card-header-custom">
                        <h5 class="mb-0"><i class="fas fa-sliders-h me-2"></i>Thông số tích lũy điểm</h5>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/admin/loyalty-config" method="POST">

                            <div class="mb-4">
                                <label for="earnRatio" class="form-label fw-semibold">
                                    <i class="fas fa-money-bill-wave text-success me-1"></i> Giá trị quy đổi (VNĐ)
                                </label>
                                <input type="number" class="form-control" id="earnRatio" name="earnRatio"
                                       value="${config.earnRateAmount}" step="1000" min="1000" max="100000" required>
                                <div class="form-text text-muted">Số tiền khách hàng cần chi để đổi lấy số điểm tương ứng.</div>
                            </div>

                            <div class="mb-4">
                                <label for="earnPoints" class="form-label fw-semibold">
                                    <i class="fas fa-star text-warning me-1"></i> Số điểm nhận được
                                </label>
                                <input type="number" class="form-control" id="earnPoints" name="earnPoints"
                                       value="${config.earnPoints}" min="1" max="100" required>
                                <div class="form-text text-muted">Số điểm cộng vào tài khoản sau khi chi tiêu theo mức trên.</div>
                            </div>

                            <div class="mb-4">
                                <label for="minRedeem" class="form-label fw-semibold">
                                    <i class="fas fa-gift text-danger me-1"></i> Điểm tối thiểu để đổi quà
                                </label>
                                <input type="number" class="form-control" id="minRedeem" name="minRedeem"
                                       value="${config.minRedeemPoints}" min="0" max="1000" required>
                                <div class="form-text text-muted">Số điểm tối thiểu để khách hàng có thể truy cập danh sách đổi thưởng.</div>
                            </div>

                            <div class="d-flex justify-content-end pt-3 border-top">
                                <button type="submit" class="btn btn-orange shadow-sm px-4">
                                    <i class="fas fa-save me-2"></i>Lưu Cấu Hình
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Info Card -->
            <div class="col-lg-4">
                <div class="card card-custom shadow-sm border-0 h-100">
                    <div class="card-header-custom">
                        <h5 class="mb-0"><i class="fas fa-info-circle me-2"></i>Cấu hình hiện tại</h5>
                    </div>
                    <div class="card-body p-4">
                        <ul class="list-unstyled">
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="fas fa-arrow-right text-primary mt-1"></i>
                                <span>Cứ mỗi <strong><fmt:formatNumber value="${config.earnRateAmount}" pattern="#,###" /> VNĐ</strong> chi tiêu,</span>
                            </li>
                            <li class="mb-3 d-flex align-items-start gap-2">
                                <i class="fas fa-star text-warning mt-1"></i>
                                <span>Khách nhận được <strong>${config.earnPoints} điểm</strong>.</span>
                            </li>
                            <li class="d-flex align-items-start gap-2">
                                <i class="fas fa-gift text-danger mt-1"></i>
                                <span>Cần tối thiểu <strong>${config.minRedeemPoints} điểm</strong> để đổi thưởng.</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
