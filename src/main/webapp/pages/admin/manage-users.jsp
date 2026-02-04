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
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
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