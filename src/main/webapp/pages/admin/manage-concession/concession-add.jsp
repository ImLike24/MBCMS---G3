<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm Concession Mới</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
        }
        .genre-checkbox {
            min-width: 120px;
        }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp" />

<main class="container mt-4">
    <h3>Thêm Đồ ăn / Thức uống mới</h3>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/concessions/add" method="post">
        <div class="mb-3">
            <label class="form-label">Loại</label>
            <select name="concessionType" class="form-select" required>
                <option value="BEVERAGE">Thức uống</option>
                <option value="FOOD">Đồ ăn</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Số lượng tồn kho</label>
            <input type="number" name="quantity" class="form-control" min="0" value="0">
        </div>

        <div class="mb-3">
            <label class="form-label">Giá cơ bản (VND)</label>
            <input type="number" name="priceBase" class="form-control" step="0.1" min="0.1" required>
        </div>

        <button type="submit" class="btn btn-primary">Thêm</button>
        <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-secondary">Quay lại</a>
    </form>
</main>
</body>
</html>