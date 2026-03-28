<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Phòng chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="rooms"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <c:choose>
            <c:when test="${noBranchAssigned}">
                <div class="d-flex justify-content-between align-items-end mb-4">
                    <div>
                        <h3 class="fw-bold text-dark mb-1">Phòng chiếu phim</h3>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-0">
                                <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Manager</a></li>
                                <li class="breadcrumb-item active" style="color: #d96c2c;">Phòng chiếu</li>
                            </ol>
                        </nav>
                    </div>
                </div>

                <div class="empty-state mt-4">
                    <i class="fa fa-building-o"></i>
                    <h3>Chưa có chi nhánh quản lý</h3>
                    <p>Tài khoản của bạn hiện tại chưa được cấp quyền quản lý bất kỳ chi nhánh nào.<br>Vui lòng liên hệ với Quản trị viên (Admin) để được phân công trước khi thực hiện thao tác.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="d-flex justify-content-between align-items-end mb-4">
                    <div>
                        <h3 class="fw-bold text-dark mb-1">Phòng chiếu phim</h3>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-0">
                                <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Manager</a></li>
                                <li class="breadcrumb-item active" style="color: #d96c2c;">Phòng chiếu</li>
                            </ol>
                        </nav>
                    </div>

                    <div class="d-flex gap-3 align-items-center">
                        <form action="rooms" method="get" id="branchSelectForm" class="mb-0">
                            <div class="input-group shadow-sm">
                                <span class="input-group-text bg-dark text-white border-dark"><i class="fa fa-building"></i></span>
                                <select class="form-select border-dark" name="branchId" onchange="document.getElementById('branchSelectForm').submit()" style="min-width: 200px; font-weight: 500;">
                                    <c:forEach var="b" items="${managedBranches}">
                                        <option value="${b.branchId}" ${b.branchId == selectedBranchId ? 'selected' : ''}>
                                                ${b.branchName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </form>

                        <a href="rooms?action=create" class="btn btn-orange shadow-sm px-4 h-100 d-flex align-items-center">
                            <i class="fa fa-plus me-2"></i>Thêm Phòng
                        </a>
                    </div>
                </div>

            </c:otherwise>
        </c:choose>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success border-0 shadow-sm" role="alert" style="border-left: 4px solid #d96c2c !important;">
                Thao tác thành công!
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger border-0 shadow-sm" role="alert" style="border-left: 4px solid #dc3545 !important;">
                <i class="fa fa-exclamation-triangle me-2"></i> ${param.error}
            </div>
        </c:if>

        <div class="card card-custom mb-4">
            <div class="card-body p-4">
                <form action="rooms" method="get">
                    <input type="hidden" name="branchId" value="${selectedBranchId}">

                    <div class="row g-3">
                        <div class="col-md-5">
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa fa-search text-muted"></i></span>
                                <input type="text" class="form-control border-start-0 bg-light" name="search"
                                       value="${searchQuery}" placeholder="Tìm theo tên phòng (VD: Cinema 1)...">
                            </div>
                        </div>

                        <div class="col-md-4">
                            <select class="form-select" name="status">
                                <option value="">-- Tất cả Trạng thái --</option>
                                <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                                <option value="MAINTENANCE" ${statusFilter == 'MAINTENANCE' ? 'selected' : ''}>Bảo trì</option>
                                <option value="CLOSED" ${statusFilter == 'CLOSED' ? 'selected' : ''}>Đóng cửa</option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <div class="d-flex gap-2 h-100">
                                <button type="submit" class="btn btn-dark flex-grow-1" title="Lọc dữ liệu">
                                    <i class="fa fa-filter me-1"></i> Lọc
                                </button>
                                <a href="rooms?branchId=${selectedBranchId}" class="btn btn-light border flex-grow-1" title="Xóa bộ lọc">
                                    <i class="fa fa-undo me-1"></i> Reset
                                </a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="card card-custom">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Tên Phòng</th>
                            <th>Sức chứa</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th class="text-end pe-4">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${rooms}">
                            <tr>
                                <td class="ps-4 fw-bold" style="color: #d96c2c;">#${r.roomId}</td>
                                <td class="fw-bold">${r.roomName}</td>
                                <td>
                                    <span class="badge bg-light text-dark border">
                                        <i class="fa fa-users me-1"></i> ${r.totalSeats} ghế
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status == 'ACTIVE'}">
                                            <span class="badge bg-success rounded-pill px-3">Hoạt động</span>
                                        </c:when>
                                        <c:when test="${r.status == 'MAINTENANCE'}">
                                            <span class="badge bg-warning text-dark rounded-pill px-3">Bảo trì</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger rounded-pill px-3">Đóng cửa</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-secondary small">${r.createdAt.toLocalDate()}</td>
                                <td class="text-end pe-4">
                                    <a href="rooms?action=edit&id=${r.roomId}" class="btn btn-outline-dark btn-sm me-1">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                    <a href="rooms?action=delete&id=${r.roomId}" class="btn btn-outline-danger btn-sm"
                                       onclick="return confirm('Xóa phòng này?')">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty rooms}">
                            <tr><td colspan="6" class="text-center py-5 text-muted">Chưa có dữ liệu phòng chiếu.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="card card-custom">
            <c:if test="${totalPages > 1}">
                <div class="card-footer bg-white border-0 py-3">
                    <nav class="d-flex justify-content-end mb-0">
                        <ul class="pagination mb-0">
                            <c:set var="q" value="&branchId=${selectedBranchId}&search=${param.search}&status=${param.status}" />

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="rooms?page=${i}${q}">${i}</a>
                                </li>
                            </c:forEach>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>