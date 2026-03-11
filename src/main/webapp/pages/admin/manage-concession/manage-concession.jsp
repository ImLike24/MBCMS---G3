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
        .table th, .table td {
            vertical-align: middle;
        }
        .empty-text {
            color: #6c757d;
            font-style: italic;
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
        <h3>Quản lý Đồ ăn / Thức uống (Concession)</h3>
        <a href="${pageContext.request.contextPath}/admin/concessions/add"
           class="btn btn-success">
            <i class="fas fa-plus me-1"></i> Thêm mới
        </a>
    </div>

    <!-- Thông báo -->
    <c:if test="${param.success == 'add'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            Thêm concession thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'update'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            Cập nhật thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'delete'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            Xóa thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Tên sản phẩm</th>
                        <th>Loại</th>
                        <th class="text-center" style="width: 130px;">Số lượng tồn</th>
                        <th class="text-end" style="width: 140px;">Giá cơ bản</th>
                        <th class="text-center" style="width: 140px;">Hành động</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="item" items="${concessions}">
                        <tr>
                            <td class="text-center fw-bold">${item.concessionId}</td>
                            <td>${item.concessionName}</td>
                            <td>${item.concessionType}</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${item.quantity != null && item.quantity > 0}">
                                        ${item.quantity}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="empty-text">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <fmt:formatNumber value="${item.priceBase}" pattern="#,##0"/> ₫
                            </td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/admin/concessions/edit?id=${item.concessionId}"
                                   class="btn btn-sm btn-warning me-1" title="Sửa">
                                    <i class="fas fa-edit"></i> Sửa
                                </a>
                                <a href="#" 
                                   onclick="if(confirm('Xóa \"${item.concessionName}\" ?')) 
                                           window.location='${pageContext.request.contextPath}/admin/concessions/delete?id=${item.concessionId}'"
                                   class="btn btn-sm btn-danger" title="Xóa">
                                    <i class="fas fa-trash-alt"></i> Xóa
                                </a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty concessions}">
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
                                <i class="fas fa-box-open fa-2x mb-3 d-block"></i>
                                Chưa có sản phẩm concession nào
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>