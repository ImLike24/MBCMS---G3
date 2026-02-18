<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Thể loại - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        .table-custom {
            table-layout: fixed; /* giữ kích thước cột cố định */
        }
        .table-custom th, .table-custom td {
            vertical-align: middle;
            padding: 12px 10px;
        }
        /* Căn giữa mặc định cho hầu hết cột */
        .table-custom th, .table-custom td {
            text-align: center;
        }
        /* Chỉ cột Tên thể loại giữ lệch trái để dễ đọc tên */
        .table-custom th:first-child,
        .table-custom td:first-child {
            text-align: left;
        }
        .genre-name {
            font-weight: 600;
            color: #212529;
        }
        .description-col {
            max-width: 400px;              
            line-height: 1.5;
            text-align: left !important; 
        }
        .status-col {
            width: 140px;
        }
        .action-col {
            width: 180px;
        }
        .action-btn {
            width: 38px;
            height: 38px;
            padding: 0;
            font-size: 1.1rem;
            border-radius: 50%;
            transition: all 0.25s ease;
            box-shadow: 0 2px 6px rgba(0,0,0,0.12);
            color: white !important;
            border: none !important;
        }
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(0,0,0,0.2);
            filter: brightness(1.1);
        }
        .btn-view { background-color: #0d6efd; }
        .btn-view:hover { background-color: #0b5ed7; }
        .btn-edit { background-color: #ffc107; color: #212529 !important; }
        .btn-edit:hover { background-color: #e0a800; }
        .btn-delete { background-color: #dc3545; }
        .btn-delete:hover { background-color: #bb2d3b; }
        .btn-group-sm .action-btn + .action-btn {
            margin-left: 8px;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="genre"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold" style="color: #212529;">Quản lý Thể loại</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Thể loại</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/admin/genres/add" 
               class="btn btn-orange shadow-sm px-4">
                <i class="fa fa-plus me-2"></i>Thêm Thể loại mới
            </a>
        </div>

        <div class="card card-custom shadow-sm border-0">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-custom align-middle mb-0">
                        <thead class="table-light">
                        <tr style="color: black;">
                            <th class="ps-4">Tên Thể loại</th>
                            <th>Mô tả</th>
                            <th class="status-col">Trạng thái</th>
                            <th class="action-col">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty genres}">
                                <c:forEach var="genre" items="${genres}">
                                    <tr>
                                        <td class="ps-4 genre-name">
                                            ${genre.genreName}
                                        </td>
                                        <td class="description-col">
                                            <c:out value="${genre.description}" default="Chưa có mô tả" />
                                        </td>
                                        <td class="status-col">
                                            <c:choose>
                                                <c:when test="${genre.active}">
                                                    <span class="badge bg-success rounded-pill px-3 py-2">HOẠT ĐỘNG</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary rounded-pill px-3 py-2">TẮT</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <div class="btn-group btn-group-sm" role="group">
                                                <button type="button"
                                                        class="btn action-btn btn-view"
                                                        data-bs-toggle="tooltip"
                                                        data-bs-placement="top"
                                                        title="Xem chi tiết"
                                                        onclick="window.location='${pageContext.request.contextPath}/admin/genres/detail?id=${genre.genreId}'">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button"
                                                        class="btn action-btn btn-edit"
                                                        data-bs-toggle="tooltip"
                                                        data-bs-placement="top"
                                                        title="Chỉnh sửa"
                                                        onclick="window.location='${pageContext.request.contextPath}/admin/genres/edit?id=${genre.genreId}'">
                                                    <i class="fas fa-pencil-alt"></i>
                                                </button>
                                                <button type="button"
                                                        class="btn action-btn btn-delete"
                                                        data-bs-toggle="tooltip"
                                                        data-bs-placement="top"
                                                        title="Xóa thể loại"
                                                        onclick="if(confirm('Bạn có chắc chắn muốn xóa thể loại \'${genre.genreName.replace("'", "\\'")}\' không?\\nLưu ý: Các phim liên quan sẽ mất liên kết thể loại này.')) { window.location='${pageContext.request.contextPath}/admin/genres/delete?id=${genre.genreId}'; }">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="text-center py-5 text-muted">
                                        <i class="fas fa-tags fa-4x mb-3 opacity-50"></i>
                                        <h5>Chưa có thể loại nào trong hệ thống</h5>
                                        <p>Hãy thêm thể loại mới để phân loại phim.</p>
                                        <a href="${pageContext.request.contextPath}/admin/genres/add" 
                                           class="btn btn-orange mt-3">
                                            <i class="fa fa-plus me-2"></i>Thêm Thể loại ngay
                                        </a>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Kích hoạt tooltip -->
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
</script>
</body>
</html>