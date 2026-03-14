<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa Concession</title>
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
    <h3>Chỉnh sửa Concession #${concession.concessionId}</h3>

    <form action="${pageContext.request.contextPath}/admin/concessions/edit" method="post">
        <input type="hidden" name="concessionId" value="${concession.concessionId}">

        <div class="mb-3">
            <label class="form-label">Loại</label>
            <select name="concessionType" class="form-select" required>
                <option value="BEVERAGE" ${concession.concessionType == 'BEVERAGE' ? 'selected' : ''}>Thức uống</option>
                <option value="FOOD" ${concession.concessionType == 'FOOD' ? 'selected' : ''}>Đồ ăn</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Số lượng tồn kho</label>
            <input type="number" name="quantity" class="form-control" value="${concession.quantity}" min="0">
        </div>

        <div class="mb-3">
            <label class="form-label">Giá cơ bản (VND)</label>
            <input type="number" name="priceBase" class="form-control" step="0.1" value="${concession.priceBase}" min="0.1" required>
        </div>

        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
        <a href="${pageContext.request.contextPath}/admin/concessions" class="btn btn-secondary">Quay lại</a>
    </form>
</main>
</body>
</html>