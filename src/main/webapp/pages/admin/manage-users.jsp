<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Manage Users - Admin</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        background: #0c121d;
                        padding-top: 56px;
                        overflow-x: hidden;
                        min-height: 100vh;
                    }

                    #sidebarMenu {
                        height: calc(100vh - 56px);
                        position: fixed;
                        top: 56px;
                        left: 0;
                        bottom: 0;
                        z-index: 100;
                        overflow-y: auto;
                    }

                    main {
                        margin-left: 280px;
                        padding: 30px;
                        transition: margin-left 0.3s;
                    }

                    .sidebar-collapsed #sidebarMenu {
                        margin-left: -280px;
                    }

                    .sidebar-collapsed main {
                        margin-left: 0;
                    }

                    /* Page Header */
                    .page-header {
                        background: #1a1a1a;
                        border: 1px solid #262625;
                        padding: 25px 30px;
                        border-radius: 15px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                        margin-bottom: 30px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                    }

                    .page-header h2 {
                        margin: 0;
                        color: white;
                        font-weight: 600;
                        font-size: 28px;
                    }

                    .page-header h2 i {
                        color: #d96c2c;
                        margin-right: 12px;
                    }

                    .btn-create-user {
                        background: #d96c2c;
                        border: none;
                        color: white;
                        padding: 12px 28px;
                        border-radius: 10px;
                        font-weight: 600;
                        transition: all 0.3s;
                    }

                    .btn-create-user:hover {
                        background: #fff;
                        color: #000;
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(217, 108, 44, 0.4);
                    }

                    /* Alert Styling */
                    .alert {
                        border-radius: 12px;
                        border: 1px solid #262625;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                        animation: slideDown 0.3s ease-out;
                    }

                    .alert-success {
                        background: rgba(72, 187, 120, 0.2);
                        color: #48bb78;
                        border-color: #48bb78;
                    }

                    .alert-danger {
                        background: rgba(245, 101, 101, 0.2);
                        color: #f56565;
                        border-color: #f56565;
                    }

                    @keyframes slideDown {
                        from {
                            opacity: 0;
                            transform: translateY(-20px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    /* Filter Section */
                    .filter-section {
                        background: #1a1a1a;
                        border: 1px solid #262625;
                        padding: 25px;
                        border-radius: 15px;
                        margin-bottom: 25px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    }

                    .filter-section .form-label {
                        font-weight: 600;
                        color: #ccc;
                        margin-bottom: 8px;
                        font-size: 14px;
                    }

                    .filter-section .form-label i {
                        color: #d96c2c;
                    }

                    .filter-section .form-select,
                    .filter-section .form-control {
                        border-radius: 10px;
                        border: 2px solid #262625;
                        background: #0c121d;
                        color: white;
                        padding: 10px 15px;
                        transition: all 0.3s;
                    }

                    .filter-section .form-select:focus,
                    .filter-section .form-control:focus {
                        outline: none;
                        border-color: #d96c2c;
                        box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
                        background: #0c121d;
                        color: white;
                    }

                    .filter-section .form-control::placeholder {
                        color: #666;
                    }

                    .filter-section .form-select option {
                        background: #1a1a1a;
                        color: white;
                    }

                    .btn-filter {
                        background: #d96c2c;
                        border: none;
                        color: white;
                        padding: 10px 0;
                        border-radius: 10px;
                        font-weight: 600;
                        transition: all 0.3s;
                    }

                    .btn-filter:hover {
                        background: #fff;
                        color: #000;
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(217, 108, 44, 0.4);
                    }

                    /* Users Table */
                    .users-table-container {
                        background: #1a1a1a;
                        border: 1px solid #262625;
                        border-radius: 15px;
                        overflow: hidden;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    }

                    .table {
                        margin-bottom: 0;
                    }

                    .table thead th {
                        background: #d96c2c;
                        color: white;
                        border: none;
                        font-weight: 600;
                        text-transform: uppercase;
                        font-size: 13px;
                        letter-spacing: 0.5px;
                        padding: 18px 15px;
                    }

                    .table tbody tr {
                        transition: all 0.3s;
                        border-bottom: 1px solid #262625;
                        background: #1a1a1a;
                    }

                    .table tbody tr:hover {
                        background-color: #262625;
                        transform: scale(1.005);
                        box-shadow: 0 2px 8px rgba(217, 108, 44, 0.2);
                    }

                    .table tbody td {
                        padding: 18px 15px;
                        vertical-align: middle;
                        color: #ccc;
                        font-size: 14px;
                        border-color: #262625;
                    }

                    .table tbody td strong {
                        color: white;
                    }

                    /* Status Badges */
                    .status-badge {
                        padding: 6px 16px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        display: inline-block;
                    }

                    .status-active {
                        background: rgba(72, 187, 120, 0.2);
                        color: #48bb78;
                        border: 1px solid #48bb78;
                    }

                    .status-locked {
                        background: rgba(245, 101, 101, 0.2);
                        color: #f56565;
                        border: 1px solid #f56565;
                    }

                    .status-inactive {
                        background: rgba(160, 174, 192, 0.2);
                        color: #a0aec0;
                        border: 1px solid #a0aec0;
                    }

                    /* Role Badge */
                    .role-badge {
                        background: rgba(217, 108, 44, 0.2);
                        color: #d96c2c;
                        border: 1px solid #d96c2c;
                        padding: 6px 14px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    /* Action Buttons */
                    .action-btn {
                        padding: 6px 14px;
                        font-size: 12px;
                        margin: 2px;
                        border-radius: 8px;
                        font-weight: 600;
                        transition: all 0.3s;
                        border: none;
                    }

                    .action-btn:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                    }

                    .btn-warning {
                        background: #ed8936;
                        border: none;
                        color: white;
                    }

                    .btn-warning:hover {
                        background: #dd6b20;
                    }

                    .btn-success {
                        background: #48bb78;
                        border: none;
                        color: white;
                    }

                    .btn-success:hover {
                        background: #38a169;
                    }

                    .btn-danger {
                        background: #f56565;
                        border: none;
                        color: white;
                    }

                    .btn-danger:hover {
                        background: #e53e3e;
                    }

                    .btn-dark {
                        background: #2d3748;
                        border: none;
                        color: white;
                    }

                    .btn-dark:hover {
                        background: #1a202c;
                    }

                    /* User Count */
                    .user-count {
                        background: #1a1a1a;
                        border: 1px solid #262625;
                        padding: 15px 25px;
                        border-radius: 12px;
                        margin-top: 20px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                        color: #ccc;
                        font-size: 14px;
                    }

                    .user-count i {
                        color: #d96c2c;
                        margin-right: 8px;
                    }

                    .user-count strong {
                        color: white;
                        font-size: 18px;
                        font-weight: 700;
                    }

                    /* Empty State */
                    .empty-state {
                        padding: 60px 20px;
                        text-align: center;
                        color: #666;
                    }

                    .empty-state i {
                        font-size: 64px;
                        margin-bottom: 20px;
                        opacity: 0.5;
                        color: #d96c2c;
                    }

                    /* Responsive */
                    @media (max-width: 768px) {
                        main {
                            margin-left: 0;
                            padding: 15px;
                        }

                        .page-header {
                            flex-direction: column;
                            gap: 15px;
                        }

                        .page-header h2 {
                            font-size: 22px;
                        }
                    }
                </style>
            </head>

            <body>

                <!-- Header -->
                <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

                <!-- Sidebar -->
                <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp" />

                <!-- Main Content -->
                <main>
                    <div class="container-fluid">
                        <!-- Page Header -->
                        <div class="page-header">
                            <h2><i class="fa fa-users"></i>User Management</h2>
                            <a href="${pageContext.request.contextPath}/admin/create-user"
                                class="btn btn-primary btn-create-user">
                                <i class="fa fa-plus me-2"></i>Create New User
                            </a>
                        </div>

                        <!-- Success/Error Messages -->
                        <c:if test="${param.success != null}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <i class="fa fa-check-circle me-2"></i>${param.success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${param.error != null}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="fa fa-exclamation-circle me-2"></i>${param.error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${error != null}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="fa fa-exclamation-circle me-2"></i>${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Filter Section -->
                        <div class="filter-section">
                            <form method="get" action="${pageContext.request.contextPath}/admin/manage-users"
                                class="row g-3">
                                <div class="col-md-3">
                                    <label for="roleFilter" class="form-label">
                                        <i class="fa fa-user-tag me-1"></i>Filter by Role
                                    </label>
                                    <select class="form-select" id="roleFilter" name="roleFilter">
                                        <option value="">All Roles</option>
                                        <c:forEach var="role" items="${allRoles}">
                                            <option value="${role.roleId}" ${roleFilter==role.roleId.toString()
                                                ? 'selected' : '' }>
                                                ${role.roleName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-md-3">
                                    <label for="statusFilter" class="form-label">
                                        <i class="fa fa-toggle-on me-1"></i>Filter by Status
                                    </label>
                                    <select class="form-select" id="statusFilter" name="statusFilter">
                                        <option value="">All Status</option>
                                        <option value="ACTIVE" ${statusFilter=='ACTIVE' ? 'selected' : '' }>Active
                                        </option>
                                        <option value="LOCKED" ${statusFilter=='LOCKED' ? 'selected' : '' }>Locked
                                        </option>
                                        <option value="INACTIVE" ${statusFilter=='INACTIVE' ? 'selected' : '' }>Inactive
                                        </option>
                                    </select>
                                </div>

                                <div class="col-md-4">
                                    <label for="search" class="form-label">
                                        <i class="fa fa-search me-1"></i>Search Users
                                    </label>
                                    <input type="text" class="form-control" id="search" name="search"
                                        placeholder="Username, email, or name..." value="${searchKeyword}">
                                </div>

                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary btn-filter w-100">
                                        <i class="fa fa-filter me-2"></i>Apply Filters
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Users Table -->
                        <div class="users-table-container">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Username</th>
                                            <th>Email</th>
                                            <th>Full Name</th>
                                            <th>Role</th>
                                            <th>Status</th>
                                            <th>Last Login</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty users}">
                                                <tr>
                                                    <td colspan="8" class="empty-state">
                                                        <i class="fa fa-users"></i>
                                                        <p class="mb-0">No users found</p>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="user" items="${users}">
                                                    <tr>
                                                        <td><strong>#${user.userId}</strong></td>
                                                        <td><strong>${user.username}</strong></td>
                                                        <td>${user.email}</td>
                                                        <td>${user.fullName != null ? user.fullName : '-'}</td>
                                                        <td>
                                                            <span class="role-badge">
                                                                ${roleMap[user.roleId]}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${user.status == 'ACTIVE'}">
                                                                    <span class="status-badge status-active">
                                                                        <i class="fa fa-check-circle me-1"></i>Active
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${user.status == 'LOCKED'}">
                                                                    <span class="status-badge status-locked">
                                                                        <i class="fa fa-lock me-1"></i>Locked
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="status-badge status-inactive">
                                                                        <i class="fa fa-ban me-1"></i>Inactive
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${user.lastLogin != null}">
                                                                    ${user.lastLoginFormatted}

                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">Never</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:if test="${user.status == 'ACTIVE'}">
                                                                <form method="post" style="display: inline;"
                                                                    onsubmit="return confirm('Are you sure you want to lock this user?');">
                                                                    <input type="hidden" name="action" value="lock">
                                                                    <input type="hidden" name="userId"
                                                                        value="${user.userId}">
                                                                    <button type="submit"
                                                                        class="btn btn-warning btn-sm action-btn">
                                                                        <i class="fa fa-lock"></i> Lock
                                                                    </button>
                                                                </form>
                                                            </c:if>

                                                            <c:if test="${user.status == 'LOCKED'}">
                                                                <form method="post" style="display: inline;"
                                                                    onsubmit="return confirm('Are you sure you want to unlock this user?');">
                                                                    <input type="hidden" name="action" value="unlock">
                                                                    <input type="hidden" name="userId"
                                                                        value="${user.userId}">
                                                                    <button type="submit"
                                                                        class="btn btn-success btn-sm action-btn">
                                                                        <i class="fa fa-unlock"></i> Unlock
                                                                    </button>
                                                                </form>
                                                            </c:if>

                                                            <c:if test="${user.status != 'INACTIVE'}">
                                                                <form method="post" style="display: inline;"
                                                                    onsubmit="return confirm('Are you sure you want to deactivate this user?');">
                                                                    <input type="hidden" name="action"
                                                                        value="deactivate">
                                                                    <input type="hidden" name="userId"
                                                                        value="${user.userId}">
                                                                    <button type="submit"
                                                                        class="btn btn-danger btn-sm action-btn">
                                                                        <i class="fa fa-ban"></i> Deactivate
                                                                    </button>
                                                                </form>
                                                            </c:if>

                                                            <!-- Delete Button -->
                                                            <form method="post" style="display: inline;"
                                                                onsubmit="return confirm('Are you sure you want to DELETE this user? This action cannot be undone!');">
                                                                <input type="hidden" name="action" value="delete">
                                                                <input type="hidden" name="userId"
                                                                    value="${user.userId}">
                                                                <button type="submit"
                                                                    class="btn btn-dark btn-sm action-btn">
                                                                    <i class="fa fa-trash"></i> Delete
                                                                </button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- User Count -->
                        <div class="user-count">
                            <i class="fa fa-info-circle"></i>
                            Total users: <strong>${users != null ? users.size() : 0}</strong>
                        </div>
                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const toggleBtn = document.getElementById('sidebarToggle');
                        const body = document.body;

                        if (toggleBtn) {
                            toggleBtn.addEventListener('click', function () {
                                body.classList.toggle('sidebar-collapsed');
                            });
                        }

                        // Auto-dismiss alerts after 5 seconds
                        setTimeout(function () {
                            const alerts = document.querySelectorAll('.alert');
                            alerts.forEach(function (alert) {
                                const bsAlert = new bootstrap.Alert(alert);
                                bsAlert.close();
                            });
                        }, 5000);
                    });
                </script>

            </body>

            </html>