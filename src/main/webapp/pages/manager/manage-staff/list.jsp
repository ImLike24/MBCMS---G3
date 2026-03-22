<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-layout.css">
    <style>
        body { padding-top: 56px; background-color: #f8f9fa; }
        main { margin-left: 280px; padding: 24px; transition: margin-left .3s; }
        .sidebar-collapsed #sidebarMenu { margin-left: -280px; }
        .sidebar-collapsed main { margin-left: 0; }
        .staff-card { border-left: 4px solid #0d6efd; }
        .badge-shift { font-size: 12px; }
    </style>
</head>
<body>
    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
    <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
        <jsp:param name="page" value="manage-staff"/>
    </jsp:include>

    <main>
        <div class="container-fluid">

            <!-- Page header -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0"><i class="fa fa-users me-2"></i>Quản lý nhân viên</h4>
                <a href="${pageContext.request.contextPath}/branch-manager/manage-staff?action=schedule&branchId=${selectedBranchId}"
                   class="btn btn-primary btn-sm">
                    <i class="fa fa-calendar me-1"></i>Xem lịch làm việc
                </a>
            </div>

            <!-- Branch selector -->
            <c:if test="${managedBranches.size() > 1}">
                <div class="mb-3">
                    <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-staff" class="d-flex gap-2 align-items-center">
                        <label class="form-label mb-0 fw-semibold">Chi nhánh:</label>
                        <select name="branchId" class="form-select form-select-sm w-auto" onchange="this.form.submit()">
                            <c:forEach items="${managedBranches}" var="b">
                                <option value="${b.branchId}" ${b.branchId == selectedBranchId ? 'selected' : ''}>${b.branchName}</option>
                            </c:forEach>
                        </select>
                    </form>
                </div>
            </c:if>

            <!-- Alerts -->
            <c:if test="${param.message == 'assigned'}">
                <div class="alert alert-success alert-dismissible fade show">Đã thêm nhân viên vào chi nhánh thành công. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.message == 'unassigned'}">
                <div class="alert alert-info alert-dismissible fade show">Đã gỡ nhân viên khỏi chi nhánh. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.error == 'assign_failed'}">
                <div class="alert alert-danger alert-dismissible fade show">Thao tác thất bại. Vui lòng thử lại. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>

            <div class="row">
                <!-- Staff in branch -->
                <div class="col-lg-7 mb-4">
                    <div class="card shadow-sm">
                        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                            <span><i class="fa fa-user-check me-1"></i>Nhân viên thuộc chi nhánh</span>
                            <span class="badge bg-light text-dark">${staffInBranch.size()} người</span>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty staffInBranch}">
                                    <p class="text-muted p-3 mb-0"><i class="fa fa-info-circle me-1"></i>Chi nhánh chưa có nhân viên nào.</p>
                                </c:when>
                                <c:otherwise>
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th>SĐT</th>
                                                <th>Trạng thái</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${staffInBranch}" var="s" varStatus="loop">
                                                <tr>
                                                    <td>${loop.index + 1}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty s.avatarUrl}">
                                                                <img src="${s.avatarUrl}" class="rounded-circle me-2" width="28" height="28" style="object-fit:cover;">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="me-2"><i class="fa fa-user-circle"></i></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        ${s.fullName}
                                                    </td>
                                                    <td>${s.email}</td>
                                                    <td>${s.phone}</td>
                                                    <td>
                                                        <span class="badge ${s.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${s.status}</span>
                                                    </td>
                                                    <td>
                                                        <form method="post" action="${pageContext.request.contextPath}/branch-manager/manage-staff"
                                                              onsubmit="return confirm('Gỡ nhân viên ${s.fullName} khỏi chi nhánh này?')">
                                                            <input type="hidden" name="action" value="unassign">
                                                            <input type="hidden" name="staffId" value="${s.userId}">
                                                            <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                                                <i class="fa fa-times"></i> Gỡ
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Unassigned staff -->
                <div class="col-lg-5 mb-4">
                    <div class="card shadow-sm">
                        <div class="card-header bg-secondary text-white d-flex justify-content-between align-items-center">
                            <span><i class="fa fa-user-plus me-1"></i>Nhân viên chưa có chi nhánh</span>
                            <span class="badge bg-light text-dark">${unassignedStaff.size()} người</span>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty unassignedStaff}">
                                    <p class="text-muted p-3 mb-0"><i class="fa fa-check-circle me-1"></i>Không có nhân viên nào chờ phân công.</p>
                                </c:when>
                                <c:otherwise>
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${unassignedStaff}" var="s">
                                                <tr>
                                                    <td>${s.fullName}</td>
                                                    <td>${s.email}</td>
                                                    <td>
                                                        <form method="post" action="${pageContext.request.contextPath}/branch-manager/manage-staff">
                                                            <input type="hidden" name="action" value="assign">
                                                            <input type="hidden" name="staffId" value="${s.userId}">
                                                            <input type="hidden" name="branchId" value="${selectedBranchId}">
                                                            <button type="submit" class="btn btn-primary btn-sm">
                                                                <i class="fa fa-plus"></i> Thêm
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('sidebarToggle')?.addEventListener('click', () =>
            document.body.classList.toggle('sidebar-collapsed'));
    </script>
</body>
</html>
