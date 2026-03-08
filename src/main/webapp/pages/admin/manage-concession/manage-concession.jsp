<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Concession - Admin</title>
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
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="concession"/>
</jsp:include>

<main class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Quản lý Đồ ăn / Thức uống</h3>
        <a href="${pageContext.request.contextPath}/admin/concessions/add" 
           class="btn btn-success">
            <i class="fas fa-plus"></i> Thêm mới
        </a>
    </div>

    <!-- Thông báo -->
    <c:if test="${param.success == 'add'}">
        <div class="alert alert-success">Thêm concession thành công!</div>
    </c:if>
    <c:if test="${param.success == 'update'}">
        <div class="alert alert-success">Cập nhật thành công!</div>
    </c:if>
    <c:if test="${param.success == 'delete'}">
        <div class="alert alert-success">Xóa thành công!</div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger">${param.error}</div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Loại</th>
                        <th>Số lượng tồn</th>
                        <th>Giá cơ bản</th>
                        <th>Thêm bởi</th>
                        <th>Ngày tạo</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${concessions}">
                        <tr>
                            <td>${item.concessionId}</td>
                            <td>${item.concessionType}</td>
                            <td>${item.quantity}</td>
                            <td><fmt:formatNumber value="${item.priceBase}" pattern="#,##0.0"/> ₫</td>
                            <td>${item.addedBy}</td>
                            <td>
                                <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/concessions/edit?id=${item.concessionId}"
                                   class="btn btn-sm btn-warning">Sửa</a>
                                <a href="#" onclick="if(confirm('Xóa concession này?')) window.location='${pageContext.request.contextPath}/admin/concessions/delete?id=${item.concessionId}'"
                                   class="btn btn-sm btn-danger">Xóa</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty concessions}">
                        <tr>
                            <td colspan="7" class="text-center py-4">Chưa có concession nào</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>