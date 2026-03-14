<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Hạng Thành Viên - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        .action-btn {
            width: 38px;
            height: 38px;
            padding: 0;
            font-size: 1.0rem;
            border-radius: 50% !important;
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
        .btn-edit  { background-color: #ffc107; color: #212529 !important; }
        .btn-edit:hover  { background-color: #e0a800; }
        .btn-delete { background-color: #dc3545; }
        .btn-delete:hover { background-color: #bb2d3b; }
        .btn-group-sm .action-btn + .action-btn { margin-left: 8px; }
        .table-custom th, .table-custom td { vertical-align: middle; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="manage-tiers"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <!-- Page Title + Breadcrumb -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold" style="color: #212529;">Quản lý Hạng Thành Viên</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Hạng Thành Viên</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/admin/create-tier" class="btn btn-orange shadow-sm px-4">
                <i class="fas fa-plus me-2"></i>Thêm Hạng
            </a>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="success" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="error" scope="session" />
        </c:if>

        <!-- Table Card -->
        <div class="card card-custom shadow-sm border-0">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-custom align-middle mb-0">
                        <thead class="table-light">
                        <tr style="color: black;">
                            <th class="ps-4">Id</th>
                            <th>Tên Hạng</th>
                            <th>Điểm yêu cầu</th>
                            <th>Hệ số nhân (Multiplier)</th>
                            <th class="text-center" width="120">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="tier" items="${tiers}">
                        <tr>
                            <td class="ps-4 text-muted">${tier.tierId}</td>
                            <td class="fw-semibold text-dark">${tier.tierName}</td>
                            <td>${tier.minPointsRequired} điểm</td>
                            <td>
                                <span class="badge bg-success rounded-pill px-3 fs-6">x${tier.pointMultiplier}</span>
                            </td>
                            <td class="text-center">
                                <div class="btn-group btn-group-sm" role="group">
                                    <a href="${pageContext.request.contextPath}/admin/edit-tier?id=${tier.tierId}"
                                       class="btn action-btn btn-edit"
                                       data-bs-toggle="tooltip" data-bs-placement="top" title="Chỉnh sửa">
                                        <i class="fas fa-pencil-alt"></i>
                                    </a>
                                    <button type="button" class="btn action-btn btn-delete"
                                            data-bs-toggle="tooltip" data-bs-placement="top" title="Xóa"
                                            onclick="confirmDelete(${tier.tierId}, '${tier.tierName}')">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty tiers}">
                        <tr>
                            <td colspan="5" class="text-center py-5 text-muted">
                                <i class="fas fa-trophy fa-4x mb-3 opacity-50"></i>
                                <h5>Chưa có hạng thành viên nào</h5>
                                <p>Hãy thêm hạng đầu tiên ngay bây giờ.</p>
                                <a href="${pageContext.request.contextPath}/admin/create-tier" class="btn btn-orange mt-2">
                                    <i class="fas fa-plus me-2"></i>Thêm Hạng ngay
                                </a>
                            </td>
                        </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Delete Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" style="background-color: #212529; color: white;">
                <h5 class="modal-title">Xác nhận xóa</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                Bạn có chắc muốn xóa hạng <strong id="deleteTierName"></strong>?
                <br><small class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Thao tác này có thể gây lỗi nếu có người dùng đang ở hạng này!</small>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <form id="deleteForm" action="${pageContext.request.contextPath}/admin/manage-tiers" method="POST" style="display:inline">
                    <input type="hidden" name="tierId" id="deleteTierId">
                    <button type="submit" class="btn btn-danger">Xóa</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(el => new bootstrap.Tooltip(el))

    function confirmDelete(id, name) {
        document.getElementById('deleteTierId').value = id;
        document.getElementById('deleteTierName').innerText = name;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    }
</script>
</body>
</html>
