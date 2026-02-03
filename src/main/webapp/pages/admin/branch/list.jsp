<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Chi nhánh</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f3f4f6; padding-top: 56px; overflow-x: hidden; }
        #sidebarMenu { position: fixed; top: 56px; left: 0; bottom: 0; z-index: 100; overflow-y: auto; }
        main { margin-left: 280px; padding: 30px; transition: margin-left 0.3s; }
        .sidebar-collapsed #sidebarMenu { margin-left: -280px; }
        .sidebar-collapsed main { margin-left: 0; }

        .table-action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 6px; }
        .status-badge { font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; font-weight: 500; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="branch"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-dark">Danh sách Chi nhánh</h2>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Chi nhánh</li>
                    </ol>
                </nav>
            </div>
            <a href="branches?action=create" class="btn btn-primary shadow-sm">
                <i class="fa fa-plus me-2"></i>Thêm Chi nhánh mới
            </a>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                <i class="fa fa-check-circle me-2"></i> Thao tác thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <form action="branches" method="get" id="filterForm">
                    <div class="row mb-4 g-3">
                        <div class="col-md-4">
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa fa-search text-muted"></i></span>
                                <input type="text" class="form-control border-start-0 bg-light"
                                       name="search" value="${currentSearch}"
                                       placeholder="Tìm kiếm tên chi nhánh...">
                            </div>
                        </div>
                        <div class="col-md-2 ms-auto">
                            <select class="form-select" name="status" onchange="document.getElementById('filterForm').submit()">
                                <option value="">Trạng thái: Tất cả</option>
                                <option value="true" ${param.status == 'true' ? 'selected' : ''}>Hoạt động</option>
                                <option value="false" ${param.status == 'false' ? 'selected' : ''}>Ngừng hoạt động</option>
                            </select>
                        </div>
                        <div class="col-md-1">
                            <button type="submit" class="btn btn-secondary w-100">Tìm</button>
                        </div>
                    </div>
                </form>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light text-secondary">
                        <tr>
                            <th scope="col" width="5%">ID</th>
                            <th scope="col" width="20%">Tên Chi nhánh</th>
                            <th scope="col" width="30%">Thông tin liên hệ</th>
                            <th scope="col" width="15%">Quản lý</th>
                            <th scope="col" width="15%">Trạng thái</th>
                            <th scope="col" width="15%" class="text-end">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="b" items="${branches}">
                            <tr>
                                <td class="fw-bold text-muted">#${b.branchId}</td>
                                <td>
                                    <div class="fw-bold text-dark">${b.branchName}</div>
                                    <small class="text-muted">Ngày tạo: ${b.createdAt.toLocalDate()}</small>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center mb-1">
                                        <i class="fa fa-map-marker text-danger me-2" style="width:15px"></i>
                                        <span class="text-truncate" style="max-width: 200px;">${b.address}</span>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="fa fa-phone text-success me-2" style="width:15px"></i> ${b.phone}
                                    </div>
                                </td>
                                <td>
                                    <c:if test="${not empty b.managerName}">
                                        <div class="d-flex align-items-center">
                                            <div class="bg-light rounded-circle d-flex justify-content-center align-items-center me-2" style="width: 30px; height: 30px;">
                                                <i class="fa fa-user-tie text-primary"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark">${b.managerName}</div>
                                                <small class="text-muted" style="font-size: 0.75rem;">ID: ${b.managerId}</small>
                                            </div>
                                        </div>
                                    </c:if>
                                    <c:if test="${empty b.managerName}">
                                            <span class="badge bg-secondary-subtle text-secondary rounded-pill fw-normal">
                                                <i class="fa fa-exclamation-circle me-1"></i> Chưa phân công
                                            </span>
                                    </c:if>
                                </td>
                                <td>
                                        <span class="status-badge ${b.active ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}">
                                            <i class="fa ${b.active ? 'fa-check-circle' : 'fa-times-circle'} me-1"></i>
                                                ${b.active ? 'Hoạt động' : 'Tạm dừng'}
                                        </span>
                                </td>
                                <td class="text-end">
                                    <a href="branches?action=edit&id=${b.branchId}" class="btn btn-light table-action-btn text-primary me-2" title="Sửa">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                    <button type="button" class="btn btn-light table-action-btn text-danger"
                                            onclick="confirmDelete(${b.branchId})" title="Xóa">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
                <c:if test="${totalPages > 1}">
                    <nav class="d-flex justify-content-end mt-4">
                        <ul class="pagination">
                            <c:set var="queryParams" value="&search=${currentSearch}&status=${currentStatus}" />

                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="branches?page=${currentPage - 1}${queryParams}" aria-label="Trang trước">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="branches?page=${i}${queryParams}">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="branches?page=${currentPage + 1}${queryParams}" aria-label="Trang sau">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>

                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    // Toggle Sidebar Script
    document.getElementById('sidebarToggle').addEventListener('click', function () {
        document.body.classList.toggle('sidebar-collapsed');
    });

    // Delete Confirmation
    function confirmDelete(id) {
        if(confirm('Bạn có chắc chắn muốn xóa chi nhánh #' + id + ' không? Hành động này không thể hoàn tác.')) {
            window.location.href = 'branches?action=delete&id=' + id;
        }
    }
</script>
</body>
</html>