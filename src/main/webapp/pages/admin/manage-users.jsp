<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List" %>
        <%@ page import="java.util.Map" %>
            <%@ page import="models.User" %>
                <%@ page import="models.Role" %>
                    <%@ page import="java.time.format.DateTimeFormatter" %>
                        <% List<User> users = (List<User>) request.getAttribute("users");
                                List<Role> roles = (List<Role>) request.getAttribute("roles");
                                        Map<Integer, String> roleMap = (Map<Integer, String>)
                                                request.getAttribute("roleMap");
                                                String currentStatus = (String) request.getAttribute("statusFilter");
                                                if (currentStatus == null) currentStatus = "";
                                                Integer currentRoleId = (Integer) request.getAttribute("roleIdFilter");
                                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyyHH:mm");
                                                %>
                                                <!DOCTYPE html>
                                                <html lang="en">

                                                <head>
                                                    <meta charset="UTF-8">
                                                    <title>Manage Users | MBCMS Admin</title>
                                                    <link rel="stylesheet"
                                                        href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                                                    <link rel="stylesheet"
                                                        href="${pageContext.request.contextPath}/css/font-awesome.min.css">
                                                    <link rel="stylesheet"
                                                        href="${pageContext.request.contextPath}/css/global.css">
                                                    <style>
                                                        body {
                                                            padding-top: 56px;
                                                            overflow-x: hidden;
                                                            background-color: #f8f9fa;
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
                                                            padding: 20px;
                                                            transition: margin-left 0.3s;
                                                        }

                                                        .sidebar-collapsed #sidebarMenu {
                                                            margin-left: -280px;
                                                        }

                                                        .sidebar-collapsed main {
                                                            margin-left: 0;
                                                        }

                                                        .card {
                                                            border: none;
                                                            border-radius: 12px;
                                                            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                                                        }

                                                        .table thead th {
                                                            background-color: #f8f9fa;
                                                            border-bottom: 2px solid #e9ecef;
                                                            font-weight: 600;
                                                            text-transform: uppercase;
                                                            font-size: 0.8rem;
                                                            letter-spacing: 0.5px;
                                                        }

                                                        .avatar-circle {
                                                            width: 40px;
                                                            height: 40px;
                                                            background-color: #e9ecef;
                                                            border-radius: 50%;
                                                            display: flex;
                                                            align-items: center;
                                                            justify-content: center;
                                                            font-weight: bold;
                                                            color: #495057;
                                                        }

                                                        .badge-role {
                                                            font-size: 0.75rem;
                                                            padding: 0.35em 0.65em;
                                                        }

                                                        .badge-role.ADMIN {
                                                            background-color: #6610f2;
                                                            color: #fff;
                                                        }

                                                        .badge-role.STAFF {
                                                            background-color: #0d6efd;
                                                            color: #fff;
                                                        }

                                                        .badge-role.BRANCH_MANAGER {
                                                            background-color: #fd7e14;
                                                            color: #fff;
                                                        }

                                                        .badge-role.CUSTOMER {
                                                            background-color: #6c757d;
                                                            color: #fff;
                                                        }

                                                        .badge-role.GUEST {
                                                            background-color: #adb5bd;
                                                            color: #fff;
                                                        }

                                                        .status-dot {
                                                            height: 10px;
                                                            width: 10px;
                                                            border-radius: 50%;
                                                            display: inline-block;
                                                            margin-right: 5px;
                                                        }

                                                        .status.ACTIVE {
                                                            color: #198754;
                                                        }

                                                        .status.ACTIVE .status-dot {
                                                            background-color: #198754;
                                                        }

                                                        .status.LOCKED {
                                                            color: #dc3545;
                                                        }

                                                        .status.LOCKED .status-dot {
                                                            background-color: #dc3545;
                                                        }

                                                        .status.INACTIVE {
                                                            color: #ffc107;
                                                        }

                                                        .status.INACTIVE .status-dot {
                                                            background-color: #ffc107;
                                                        }

                                                        @media (max-width: 992px) {
                                                            main {
                                                                margin-left: 0;
                                                            }
                                                        }
                                                    </style>
                                                </head>

                                                <body>
                                                    <jsp:include page="/components/layout/admin/admin_header.jsp" />
                                                    <jsp:include page="/components/layout/admin/admin_sidebar.jsp" />

                                                    <main>
                                                        <div class="container-fluid">
                                                            <div
                                                                class="d-flex justify-content-between align-items-center mb-4">
                                                                <div>
                                                                    <h2 class="h4 mb-1 fw-bold text-dark">User
                                                                        Management</h2>
                                                                    <p class="text-muted small mb-0">Monitor and manage
                                                                        system access.</p>
                                                                </div>
                                                                <a href="${pageContext.request.contextPath}/admin/create-user"
                                                                    class="btn btn-primary">
                                                                    <i class="fa fa-plus me-2"></i>Create New User
                                                                </a>
                                                            </div>

                                                            <% String successMsg=(String)
                                                                session.getAttribute("successMessage"); %>
                                                                <% if (successMsg !=null) { %>
                                                                    <div class="alert alert-success alert-dismissible fade show"
                                                                        role="alert">
                                                                        <i class="fa fa-check-circle me-2"></i>
                                                                        <%= successMsg %>
                                                                            <button type="button" class="btn-close"
                                                                                data-bs-dismiss="alert"></button>
                                                                    </div>
                                                                    <% session.removeAttribute("successMessage"); } %>

                                                                        <% String errorMsg=(String)
                                                                            session.getAttribute("errorMessage"); %>
                                                                            <% if (errorMsg !=null) { %>
                                                                                <div class="alert alert-danger alert-dismissible fade show"
                                                                                    role="alert">
                                                                                    <i
                                                                                        class="fa fa-exclamation-triangle me-2"></i>
                                                                                    <%= errorMsg %>
                                                                                        <button type="button"
                                                                                            class="btn-close"
                                                                                            data-bs-dismiss="alert"></button>
                                                                                </div>
                                                                                <% session.removeAttribute("errorMessage");
                                                                                    } %>

                                                                                    <div class="card mb-4">
                                                                                        <div class="card-body py-3">
                                                                                            <form method="GET"
                                                                                                action="${pageContext.request.contextPath}/admin/manage-users"
                                                                                                class="row g-3 align-items-center">
                                                                                                <div class="col-md-4">
                                                                                                    <label
                                                                                                        class="small text-muted fw-bold mb-1">Filter
                                                                                                        by
                                                                                                        Status</label>
                                                                                                    <select
                                                                                                        name="status"
                                                                                                        class="form-select form-select-sm">
                                                                                                        <option
                                                                                                            value="">All
                                                                                                            Statuses
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="ACTIVE"
                                                                                                            <%="ACTIVE"
                                                                                                            .equals(currentStatus)
                                                                                                            ? "selected"
                                                                                                            : "" %>
                                                                                                            >Active
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="LOCKED"
                                                                                                            <%="LOCKED"
                                                                                                            .equals(currentStatus)
                                                                                                            ? "selected"
                                                                                                            : "" %>
                                                                                                            >Locked
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="INACTIVE"
                                                                                                            <%="INACTIVE"
                                                                                                            .equals(currentStatus)
                                                                                                            ? "selected"
                                                                                                            : "" %>
                                                                                                            >Inactive
                                                                                                        </option>
                                                                                                    </select>
                                                                                                </div>
                                                                                                <div class="col-md-4">
                                                                                                    <label
                                                                                                        class="small text-muted fw-bold mb-1">Filter
                                                                                                        by Role</label>
                                                                                                    <select
                                                                                                        name="roleId"
                                                                                                        class="form-select form-select-sm">
                                                                                                        <option
                                                                                                            value="">All
                                                                                                            Roles
                                                                                                        </option>
                                                                                                        <% if (roles
                                                                                                            !=null) {
                                                                                                            for (Role r
                                                                                                            : roles) {
                                                                                                            %>
                                                                                                            <option
                                                                                                                value="<%= r.getRoleId() %>"
                                                                                                                <%=(currentRoleId
                                                                                                                !=null
                                                                                                                &&
                                                                                                                currentRoleId.equals(r.getRoleId()))
                                                                                                                ? "selected"
                                                                                                                : "" %>>
                                                                                                                <%= r.getRoleName()
                                                                                                                    %>
                                                                                                            </option>
                                                                                                            <% } } %>
                                                                                                    </select>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="col-md-4 text-end mt-4">
                                                                                                    <button
                                                                                                        type="submit"
                                                                                                        class="btn btn-dark btn-sm px-4"><i
                                                                                                            class="fa fa-filter me-2"></i>Apply</button>
                                                                                                    <a href="${pageContext.request.contextPath}/admin/manage-users"
                                                                                                        class="btn btn-light btn-sm ms-2">Reset</a>
                                                                                                </div>
                                                                                            </form>
                                                                                        </div>
                                                                                    </div>

                                                                                    <div class="card">
                                                                                        <div class="table-responsive">
                                                                                            <table
                                                                                                class="table table-hover align-middle mb-0">
                                                                                                <thead>
                                                                                                    <tr>
                                                                                                        <th
                                                                                                            class="ps-4">
                                                                                                            User</th>
                                                                                                        <th>Role</th>
                                                                                                        <th>Status</th>
                                                                                                        <th>Contact</th>
                                                                                                        <th>Last Login
                                                                                                        </th>
                                                                                                        <th
                                                                                                            class="text-end pe-4">
                                                                                                            Actions</th>
                                                                                                    </tr>
                                                                                                </thead>
                                                                                                <tbody>
                                                                                                    <% if (users !=null
                                                                                                        &&
                                                                                                        !users.isEmpty())
                                                                                                        { for (User u :
                                                                                                        users) { String
                                                                                                        uRole=(roleMap
                                                                                                        !=null) ?
                                                                                                        roleMap.get(u.getRoleId())
                                                                                                        : "Unknown" ;
                                                                                                        String
                                                                                                        navName=u.getFullName()
                                                                                                        !=null ?
                                                                                                        u.getFullName()
                                                                                                        :
                                                                                                        u.getUsername();
                                                                                                        String
                                                                                                        initial=navName.substring(0,
                                                                                                        1).toUpperCase();
                                                                                                        String
                                                                                                        lastLogin=(u.getLastLogin()
                                                                                                        !=null) ?
                                                                                                        u.getLastLogin().format(formatter)
                                                                                                        : "Never" ; %>
                                                                                                        <tr>
                                                                                                            <td
                                                                                                                class="ps-4">
                                                                                                                <div
                                                                                                                    class="d-flex align-items-center">
                                                                                                                    <div
                                                                                                                        class="avatar-circle me-3">
                                                                                                                        <%= initial
                                                                                                                            %>
                                                                                                                    </div>
                                                                                                                    <div>
                                                                                                                        <div
                                                                                                                            class="fw-bold text-dark">
                                                                                                                            <%= navName
                                                                                                                                %>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            class="small text-muted">
                                                                                                                            @
                                                                                                                            <%= u.getUsername()
                                                                                                                                %>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </td>
                                                                                                            <td><span
                                                                                                                    class="badge rounded-pill badge-role <%= uRole %>">
                                                                                                                    <%= uRole
                                                                                                                        %>
                                                                                                                </span>
                                                                                                            </td>
                                                                                                            <td>
                                                                                                                <div
                                                                                                                    class="status <%= u.getStatus() %>">
                                                                                                                    <span
                                                                                                                        class="status-dot"></span>
                                                                                                                    <span
                                                                                                                        class="small fw-bold">
                                                                                                                        <%= u.getStatus()
                                                                                                                            %>
                                                                                                                    </span>
                                                                                                                </div>
                                                                                                            </td>
                                                                                                            <td><span
                                                                                                                    class="text-muted small">
                                                                                                                    <%= u.getEmail()
                                                                                                                        %>
                                                                                                                </span>
                                                                                                            </td>
                                                                                                            <td><span
                                                                                                                    class="text-muted small">
                                                                                                                    <%= lastLogin
                                                                                                                        %>
                                                                                                                </span>
                                                                                                            </td>
                                                                                                            <td
                                                                                                                class="text-end pe-4">
                                                                                                                <div
                                                                                                                    class="btn-group">
                                                                                                                    <% if
                                                                                                                        ("ACTIVE".equals(u.getStatus()))
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <form
                                                                                                                            method="POST"
                                                                                                                            action="${pageContext.request.contextPath}/admin/manage-users"
                                                                                                                            style="display:inline;">
                                                                                                                            <input
                                                                                                                                type="hidden"
                                                                                                                                name="action"
                                                                                                                                value="updateStatus">
                                                                                                                            <input
                                                                                                                                type="hidden"
                                                                                                                                name="userId"
                                                                                                                                value="<%= u.getUserId() %>">
                                                                                                                            <input
                                                                                                                                type="hidden"
                                                                                                                                name="status"
                                                                                                                                value="LOCKED">
                                                                                                                            <input
                                                                                                                                type="hidden"
                                                                                                                                name="currentStatusFilter"
                                                                                                                                value="<%= currentStatus %>">
                                                                                                                            <input
                                                                                                                                type="hidden"
                                                                                                                                name="currentRoleIdFilter"
                                                                                                                                value="<%= currentRoleId != null ? currentRoleId : "" %>">
                                                                                                                            <button
                                                                                                                                type="submit"
                                                                                                                                class="btn btn-outline-danger btn-sm"
                                                                                                                                onclick="return confirm('Lock this user account?')">
                                                                                                                                <i
                                                                                                                                    class="fa fa-lock"></i>
                                                                                                                            </button>
                                                                                                                        </form>
                                                                                                                        <% } else
                                                                                                                            if
                                                                                                                            ("LOCKED".equals(u.getStatus())
                                                                                                                            || "INACTIVE"
                                                                                                                            .equals(u.getStatus()))
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <form
                                                                                                                                method="POST"
                                                                                                                                action="${pageContext.request.contextPath}/admin/manage-users"
                                                                                                                                style="display:inline;">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="action"
                                                                                                                                    value="updateStatus">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="userId"
                                                                                                                                    value="<%= u.getUserId() %>">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="status"
                                                                                                                                    value="ACTIVE">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="currentStatusFilter"
                                                                                                                                    value="<%= currentStatus %>">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="currentRoleIdFilter"
                                                                                                                                    value="<%= currentRoleId != null ? currentRoleId : "" %>">
                                                                                                                                <button
                                                                                                                                    type="submit"
                                                                                                                                    class="btn btn-outline-success btn-sm">
                                                                                                                                    <i
                                                                                                                                        class="fa fa-check"></i>
                                                                                                                                </button>
                                                                                                                            </form>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                                </div>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                        <% } } else { %>
                                                                                                            <tr>
                                                                                                                <td colspan="6"
                                                                                                                    class="text-center py-5 text-muted">
                                                                                                                    <i
                                                                                                                        class="fa fa-users fa-3x mb-3 opacity-50"></i>
                                                                                                                    <p>No
                                                                                                                        users
                                                                                                                        found
                                                                                                                        matching
                                                                                                                        your
                                                                                                                        criteria.
                                                                                                                    </p>
                                                                                                                </td>
                                                                                                            </tr>
                                                                                                            <% } %>
                                                                                                </tbody>
                                                                                            </table>
                                                                                        </div>
                                                                                    </div>
                                                        </div>
                                                    </main>

                                                    <script
                                                        src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                                                    <script>
                                                        document.addEventListener('DOMContentLoaded', function () {
                                                            const toggleBtn = document.getElementById('sidebarToggle');
                                                            if (toggleBtn) {
                                                                toggleBtn.addEventListener('click', function () {
                                                                    document.body.classList.toggle('sidebar-collapsed');
                                                                });
                                                            }
                                                        });
                                                    </script>
                                                </body>

                                                </html>