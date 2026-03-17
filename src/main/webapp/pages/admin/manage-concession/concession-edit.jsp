<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Concession - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        :root {
            --primary: #0d6efd;
            --danger: #dc3545;
            --warning: #ffc107;
            --success: #198754;
            --light: #f8f9fa;
            --gray: #6c757d;
        }
        body { margin-left: 50px; background-color: #f5f7ff; font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
        .main-content { margin-left: 280px; margin-right: 20px; padding: 1.5rem 0; }
        .page-header { background: white; border-radius: 12px; padding: 1.25rem 1.5rem; box-shadow: 0 4px 12px rgba(0,0,0,0.06); margin-bottom: 1.5rem; }
        .card-modern { border: none; border-radius: 12px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); }
        .form-label { font-weight: 600; color: #495057; }
        .form-control-plaintext { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 6px; padding: 0.375rem 0.75rem; }
        .readonly-field { background-color: #e9ecef !important; cursor: not-allowed; }
        @media (max-width: 992px) { .main-content { margin-left: 0; margin-right: 0; } }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="concession"/>
</jsp:include>

<div class="main-content">
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h4 class="mb-0 fw-bold">Chỉnh sửa sản phẩm: ${concession.concessionName}</h4>
            <small class="text-muted">ID: ${concession.concessionId}</small>
        </div>
        <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty errorMsg or not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i>
            ${errorMsg != null ? errorMsg : 'Cập nhật thất bại - vui lòng kiểm tra lại thông tin'}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card-modern">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/admin/concessions/edit" method="post">
                <input type="hidden" name="concessionId" value="${concession.concessionId}">

                <div class="row g-4">
                    <!-- Tên sản phẩm - chỉ hiển thị, không submit -->
                    <div class="col-md-6">
                        <label class="form-label">Tên sản phẩm</label>
                        <div class="form-control-plaintext readonly-field">
                            <c:out value="${concession.concessionName}"/>
                        </div>
                    </div>

                    <!-- Loại -->
                    <div class="col-md-6">
                        <label for="concessionType" class="form-label">Loại sản phẩm <span class="text-danger">*</span></label>
                        <select class="form-select" id="concessionType" name="concessionType" required>
                            <option value="FOOD" ${concession.concessionType == 'FOOD' ? 'selected' : ''}>Đồ ăn</option>
                            <option value="BEVERAGE" ${concession.concessionType == 'BEVERAGE' ? 'selected' : ''}>Thức uống</option>
                            <!-- Thêm các loại khác nếu hệ thống có -->
                        </select>
                    </div>

                    <!-- Số lượng tồn kho -->
                    <div class="col-md-6">
                        <label for="quantity" class="form-label">Số lượng tồn kho <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="quantity" name="quantity"
                               value="${concession.quantity != null ? concession.quantity : 0}"
                               min="0" required>
                    </div>

                    <!-- Giá cơ bản -->
                    <div class="col-md-6">
                        <label for="priceBase" class="form-label">Giá cơ bản (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="priceBase" name="priceBase"
                               value="${concession.priceBase}" min="0"required>
                        <small class="text-muted">Nhập giá theo đơn vị nghìn đồng (ví dụ: 45000 = 45.000 ₫)</small>
                    </div>
                </div>

                <div class="mt-5 d-flex gap-3">
                    <button type="submit" class="btn btn-primary px-5">
                        <i class="fas fa-save me-2"></i>Lưu thay đổi
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-outline-secondary px-4">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>