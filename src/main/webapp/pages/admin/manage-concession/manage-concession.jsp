<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Concession - Admin</title>
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
        .card-modern { border: none; border-radius: 12px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); overflow: hidden; }
        .table { margin-bottom: 0; background: white; }
        .table thead th { background: #f1f3f9; font-weight: 600; text-transform: uppercase; font-size: 0.82rem; color: #495057; border-bottom: 2px solid #dee2e6; }
        .table td { vertical-align: middle; font-size: 0.95rem; }
        .product-name { font-weight: 600; color: #212529; }
        .stock-low { background-color: #fff3cd; color: #856404; font-weight: 500; }
        .stock-out { background-color: #f8d7da; color: #721c24; font-weight: 600; }
        .btn-action { min-width: 38px; padding: 0.375rem 0.65rem; font-size: 0.875rem; border-radius: 6px; transition: all 0.2s; }
        .btn-action:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,0.12); }
        .empty-state { padding: 5rem 1rem; text-align: center; color: var(--gray); }
        .empty-state i { font-size: 3.5rem; opacity: 0.4; margin-bottom: 1rem; }
        .pagination .page-item.active .page-link { background-color: var(--primary); border-color: var(--primary); }
        .pagination .page-link { color: var(--primary); }
        .pagination .page-link:hover { background-color: #e9ecef; }
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
            <h4 class="mb-0 fw-bold">Quản lý Đồ ăn / Thức uống</h4>
            <small class="text-muted">Tổng cộng: ${totalItems} sản phẩm</small>
        </div>
        <a href="${pageContext.request.contextPath}/admin/concessions/add"
           class="btn btn-primary d-flex align-items-center gap-2 shadow-sm">
            <i class="fas fa-plus"></i> Thêm sản phẩm mới
        </a>
    </div>

    <!-- Thông báo thành công / lỗi -->
    <c:if test="${param.success == 'add'}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="fas fa-check-circle me-2"></i> Thêm concession thành công!
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'update'}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="fas fa-check-circle me-2"></i> Cập nhật concession thành công!
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'delete'}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="fas fa-check-circle me-2"></i> Xóa concession thành công!
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i>
            Lỗi:
            <c:choose>
                <c:when test="${param.error == 'notfound'}">Không tìm thấy sản phẩm</c:when>
                <c:when test="${param.error == 'invalid'}">Dữ liệu không hợp lệ</c:when>
                <c:when test="${param.error == 'delete'}">Không thể xóa sản phẩm</c:when>
                <c:otherwise>${param.error}</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card-modern">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                    <tr>
                        <th>Tên sản phẩm</th>
                        <th>Loại</th>
                        <th class="text-center">Tồn kho</th>
                        <th class="text-end">Giá cơ bản</th>
                        <th class="text-center">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="item" items="${concessions}">
                        <tr>
                            <td>
                                <div class="product-name">
                                    <c:out value="${item.concessionName}"/>
                                </div>
                            </td>
                            <td>
                                <span class="badge bg-info-subtle text-info">${item.concessionType}</span>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${item.quantity == null || item.quantity == 0}">
                                        <span class="badge stock-out px-3 py-2">Hết hàng</span>
                                    </c:when>
                                    <c:when test="${item.quantity <= 10}">
                                        <span class="badge stock-low px-3 py-2">${item.quantity}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-success-subtle text-success px-3 py-2">${item.quantity}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end fw-medium">
                                <fmt:formatNumber value="${item.priceBase}" pattern="#,##0"/>₫
                            </td>
                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-2">
                                    <a href="${pageContext.request.contextPath}/admin/concessions/edit?id=${item.concessionId}"
                                       class="btn btn-warning btn-action" title="Chỉnh sửa">
                                        <i class="fas fa-edit"></i>
                                    </a>

                                    <a href="#"
                                       onclick="if(confirm('Xóa sản phẩm?')) 
                                            window.location='${pageContext.request.contextPath}/admin/concessions/delete?id=${item.concessionId}'"
                                       class="btn btn-danger btn-action" title="Xóa">
                                        <i class="fas fa-trash-alt"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty concessions}">
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-box-open"></i>
                                    <h5 class="mt-3">Chưa có sản phẩm concession nào</h5>
                                    <p class="text-muted">Nhấn nút "Thêm sản phẩm mới" để bắt đầu</p>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Concession pagination" class="d-flex justify-content-center my-4">
                    <ul class="pagination mb-0">
                        <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&size=${pageSize}" aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                        <c:forEach begin="0" end="${totalPages - 1}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&size=${pageSize}">${i + 1}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&size=${pageSize}" aria-label="Next">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>

            <div class="text-center text-muted small mb-3">
                Hiển thị ${concessions.size()} / ${totalItems} sản phẩm
                (Trang ${currentPage + 1} / ${totalPages})
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>