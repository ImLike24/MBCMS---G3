<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân công nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
    <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
        <jsp:param name="page" value="assign-staff" />
    </jsp:include>

    <main>
        <div class="container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold" style="color: #212529;">Phân công nhân viên</h3>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                            <li class="breadcrumb-item active" style="color: #d96c2c;">Phân công nhân viên</li>
                        </ol>
                    </nav>
                </div>
            </div>

            <%-- Alerts --%>
            <c:if test="${param.message == 'assigned'}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" style="border-left: 4px solid #198754 !important;">
                    <i class="fa fa-check-circle me-2"></i>Đã phân công nhân viên vào chi nhánh thành công.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.message == 'unassigned'}">
                <div class="alert alert-info alert-dismissible fade show border-0 shadow-sm">
                    <i class="fa fa-info-circle me-2"></i>Đã gỡ nhân viên khỏi chi nhánh.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.message == 'manager_assigned'}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" style="border-left: 4px solid #198754 !important;">
                    <i class="fa fa-check-circle me-2"></i>Đã phân công Manager vào chi nhánh thành công.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.message == 'manager_unassigned'}">
                <div class="alert alert-info alert-dismissible fade show border-0 shadow-sm">
                    <i class="fa fa-info-circle me-2"></i>Đã gỡ Manager khỏi chi nhánh.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.error == 'branch_has_manager'}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm">
                    <i class="fa fa-exclamation-triangle me-2"></i>Chi nhánh này đã có Manager. Vui lòng gỡ Manager hiện tại trước khi phân công người mới.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.error == 'invalid_params'}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm">
                    <i class="fa fa-exclamation-triangle me-2"></i>Tham số không hợp lệ.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <%-- Bộ lọc chi nhánh --%>
            <div class="card card-custom mb-4">
                <div class="card-body p-4">
                    <form method="get" action="${pageContext.request.contextPath}/admin/assign-staff" class="row g-3 align-items-end">
                        <div class="col-md-5">
                            <label for="branchSelect" class="form-label fw-semibold">Chọn chi nhánh để xem &amp; phân công</label>
                            <select id="branchSelect" class="form-select" name="branchId" onchange="this.form.submit()">
                                <option value="">-- Chọn chi nhánh --</option>
                                <c:forEach var="branch" items="${allBranches}">
                                    <option value="${branch.branchId}" ${branch.branchId == selectedBranchId ? 'selected' : ''}>
                                        ${branch.branchName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </form>
                </div>
            </div>

            <div class="row g-4">

                <%-- Cột trái: Nhân viên chưa phân công --%>
                <div class="col-lg-5">

                    <%-- Managers chưa có branch --%>
                    <div class="card card-custom mb-4">
                        <div class="card-header bg-white border-bottom py-3 px-4">
                            <h6 class="mb-0 fw-bold">
                                <i class="fa fa-user-tie me-2" style="color: #d96c2c;"></i>
                                Manager chưa được phân công
                                <span class="badge bg-warning text-dark ms-2">${unassignedManagers.size()}</span>
                            </h6>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty unassignedManagers}">
                                    <p class="text-muted text-center py-4 mb-0">Tất cả manager đã được phân công.</p>
                                </c:when>
                                <c:otherwise>
                                    <ul class="list-group list-group-flush">
                                        <c:forEach var="mgr" items="${unassignedManagers}">
                                            <li class="list-group-item d-flex justify-content-between align-items-center px-4 py-3">
                                                <div>
                                                    <div class="fw-semibold">${mgr.fullName}</div>
                                                    <small class="text-muted">${mgr.email}</small>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${selectedBranchId == null}">
                                                        <span class="text-muted small">Chọn chi nhánh để phân công</span>
                                                    </c:when>
                                                    <c:when test="${selectedBranch.managerId != null}">
                                                        <span class="text-muted small" title="Chi nhánh đã có Manager">
                                                            <i class="fa fa-lock me-1"></i>Đã có Manager
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/assign-staff">
                                                            <input type="hidden" name="action" value="assign-manager">
                                                            <input type="hidden" name="userId" value="${mgr.userId}">
                                                            <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                            <button class="btn btn-sm btn-orange" title="Phân công vào chi nhánh đang chọn">
                                                                <i class="fa fa-plus me-1"></i>Phân công
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Staff chưa có branch --%>
                    <div class="card card-custom">
                        <div class="card-header bg-white border-bottom py-3 px-4">
                            <h6 class="mb-0 fw-bold">
                                <i class="fa fa-users me-2" style="color: #0d6efd;"></i>
                                Nhân viên chưa được phân công
                                <span class="badge bg-secondary ms-2">${unassignedStaff.size()}</span>
                            </h6>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty unassignedStaff}">
                                    <p class="text-muted text-center py-4 mb-0">Tất cả nhân viên đã được phân công.</p>
                                </c:when>
                                <c:otherwise>
                                    <ul class="list-group list-group-flush">
                                        <c:forEach var="staff" items="${unassignedStaff}">
                                            <li class="list-group-item d-flex justify-content-between align-items-center px-4 py-3">
                                                <div>
                                                    <div class="fw-semibold">${staff.fullName}</div>
                                                    <small class="text-muted">${staff.email}</small>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${selectedBranchId != null}">
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/assign-staff">
                                                            <input type="hidden" name="action" value="assign">
                                                            <input type="hidden" name="userId" value="${staff.userId}">
                                                            <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                            <button class="btn btn-sm btn-outline-primary" title="Phân công vào chi nhánh đang chọn">
                                                                <i class="fa fa-plus me-1"></i>Phân công
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">Chọn chi nhánh để phân công</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>

                <%-- Cột phải: Chi nhánh đang chọn + danh sách nhân viên --%>
                <div class="col-lg-7">
                    <c:choose>
                        <c:when test="${selectedBranch != null}">
                            <div class="card card-custom">
                                <div class="card-header bg-white border-bottom py-3 px-4 d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-0 fw-bold">
                                            <i class="fa fa-building me-2" style="color: #d96c2c;"></i>
                                            ${selectedBranch.branchName}
                                        </h6>
                                        <small class="text-muted">${selectedBranch.address}</small>
                                    </div>
                                    <div class="text-end">
                                        <c:choose>
                                            <c:when test="${selectedBranch.managerId != null}">
                                                <span class="badge bg-success px-2 py-1">
                                                    <i class="fa fa-user-tie me-1"></i>Manager: ${selectedBranch.managerName}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark px-2 py-1">
                                                    <i class="fa fa-exclamation-circle me-1"></i>Chưa có Manager
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <%-- Manager của branch (nếu có, cho phép gỡ) --%>
                                <c:if test="${selectedBranch.managerId != null}">
                                    <div class="px-4 py-3 border-bottom bg-light">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <span class="fw-semibold text-dark">
                                                    <i class="fa fa-user-tie me-1 text-success"></i>${selectedBranch.managerName}
                                                </span>
                                                <span class="badge bg-success ms-2">Manager</span>
                                            </div>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/assign-staff"
                                                  onsubmit="return confirm('Gỡ manager khỏi chi nhánh này?');">
                                                <input type="hidden" name="action" value="unassign-manager">
                                                <input type="hidden" name="userId" value="${selectedBranch.managerId}">
                                                <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                <button class="btn btn-sm btn-outline-danger" title="Gỡ khỏi chi nhánh">
                                                    <i class="fa fa-times me-1"></i>Gỡ
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:if>

                                <div class="card-body p-0">
                                    <div class="px-4 pt-3 pb-2">
                                        <span class="fw-semibold text-secondary small text-uppercase">
                                            Nhân viên trong chi nhánh
                                            <span class="badge bg-light text-dark border ms-1">${assignedStaff.size()}</span>
                                        </span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${empty assignedStaff}">
                                            <p class="text-muted text-center py-4 mb-0">Chi nhánh chưa có nhân viên nào.</p>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="table-responsive">
                                                <table class="table table-hover align-middle mb-0">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th class="ps-4">Họ tên</th>
                                                            <th>Email</th>
                                                            <th>SĐT</th>
                                                            <th class="text-end pe-4">Hành động</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="staff" items="${assignedStaff}">
                                                            <tr>
                                                                <td class="ps-4 fw-semibold">${staff.fullName}</td>
                                                                <td class="text-muted small">${staff.email}</td>
                                                                <td class="text-muted small">${staff.phone != null ? staff.phone : '--'}</td>
                                                                <td class="text-end pe-4">
                                                                    <form method="post" action="${pageContext.request.contextPath}/admin/assign-staff"
                                                                          onsubmit="return confirm('Gỡ nhân viên khỏi chi nhánh này?');">
                                                                        <input type="hidden" name="action" value="unassign">
                                                                        <input type="hidden" name="userId" value="${staff.userId}">
                                                                        <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                                        <button class="btn btn-sm btn-outline-danger" title="Gỡ khỏi chi nhánh">
                                                                            <i class="fa fa-times"></i>
                                                                        </button>
                                                                    </form>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card card-custom">
                                <div class="card-body text-center py-5 text-muted">
                                    <i class="fa fa-building fa-3x mb-3 d-block" style="color: #dee2e6;"></i>
                                    Chọn một chi nhánh ở trên để xem và phân công nhân viên.
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
