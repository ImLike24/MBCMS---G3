<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Concession Mới - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
        }
        .form-label {
            font-weight: 500;
        }
        .required::after {
            content: " *";
            color: red;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="concession"/>
</jsp:include>

<main class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Thêm Đồ ăn / Thức uống mới</h3>
        <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-1"></i> Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/concessions/add" method="post">
                <div class="mb-3">
                    <label class="form-label required">Tên sản phẩm</label>
                    <input type="text" name="concessionName" class="form-control" 
                           value="${concession.concessionName}" required 
                           placeholder="Ví dụ: Popcorn caramel, Coca Cola 500ml, Hotdog...">
                </div>

                <div class="mb-3">
                    <label class="form-label required">Loại</label>
                    <select name="concessionType" class="form-select" required>
                        <option value="" disabled ${concession.concessionType == null ? 'selected' : ''}>Chọn loại</option>
                        <option value="BEVERAGE" ${concession.concessionType == 'BEVERAGE' ? 'selected' : ''}>Thức uống</option>
                        <option value="FOOD" ${concession.concessionType == 'FOOD' ? 'selected' : ''}>Đồ ăn</option>
                    </select>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Số lượng tồn kho</label>
                        <input type="number" name="quantity" class="form-control" 
                               min="0" max="1000" 
                               value="${concession.quantity != null ? concession.quantity : '0'}"
                               oninput="this.value = Math.max(0, Math.min(1000, this.value));">
                        <div class="form-text text-muted small">Tối đa 1,000 đơn vị.</div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label required">Giá cơ bản (VND)</label>
                        <div class="input-group">
                            <input type="number" name="priceBase" class="form-control" 
                                   step="100" min="1000" max="200000" required
                                   value="${concession.priceBase > 0 ? concession.priceBase : ''}"
                                   oninput="this.value = Math.max(0, Math.min(200000, this.value));"
                                   placeholder="Ví dụ: 45000">
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-4">
                    <button type="submit" class="btn btn-primary px-4">
                        <i class="fas fa-save me-1"></i> Thêm mới
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-outline-secondary px-4">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>