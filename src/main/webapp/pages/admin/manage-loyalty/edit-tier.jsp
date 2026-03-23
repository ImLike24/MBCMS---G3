<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Hạng Thành Viên - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="manage-tiers"/>
</jsp:include>

<main>
<div class="container-fluid py-4">

    <!-- Page Title -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-1" style="color: #212529;">Chỉnh sửa Hạng: ${tier.tierName}</h3>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/admin/manage-tiers" class="text-decoration-none text-secondary">Hạng Thành Viên</a>
                    </li>
                    <li class="breadcrumb-item active" style="color: #d96c2c;">Chỉnh sửa</li>
                </ol>
            </nav>
        </div>
    </div>

    <!-- Error Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Form -->
    <form action="${pageContext.request.contextPath}/admin/edit-tier" method="POST"
          class="row g-3 needs-validation" novalidate>
        <input type="hidden" name="tierId" value="${tier.tierId}">

        <div class="col-md-6">
            <label class="form-label">Tên Hạng <span class="text-danger">*</span></label>
            <input type="text" class="form-control" name="tierName"
                   value="${tier.tierName}" required>
            <div class="invalid-feedback">Vui lòng nhập tên hạng</div>
        </div>

        <div class="col-md-3">
            <label class="form-label">Điểm yêu cầu tối thiểu <span class="text-danger">*</span></label>
            <input type="number" class="form-control" name="minPoints"
                   min="0" value="${tier.minPointsRequired}" required>
            <div class="form-text">Số điểm tích lũy để đạt hạng này.</div>
        </div>

        <div class="col-md-3">
            <label class="form-label">Hệ số nhân (Multiplier) <span class="text-danger">*</span></label>
            <input type="number" class="form-control" name="multiplier"
                   step="0.1" min="1.0" max="2.0" value="${tier.pointMultiplier}" required>
            <div class="form-text">VD: 1.0, 1.2, 1.5, 2.0</div>
            <div class="invalid-feedback">Vui lòng nhập hệ số hợp lệ (≥ 1.0)</div>
        </div>

        <!-- Buttons -->
        <div class="col-12 mt-4 pt-3 border-top">
            <button type="submit" class="btn btn-orange px-5 me-2">
                <i class="fas fa-save me-2"></i>Cập nhật
            </button>
            <a href="${pageContext.request.contextPath}/admin/manage-tiers" class="btn btn-secondary px-4">
                <i class="fas fa-arrow-left me-2"></i>Hủy
            </a>
        </div>

    </form>
</div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        'use strict';
        var forms = document.querySelectorAll('.needs-validation');
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    })();
</script>
</body>
</html>
