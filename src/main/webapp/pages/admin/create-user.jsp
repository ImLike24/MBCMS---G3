<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List" %>
        <%@ page import="models.Role" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Create User - Admin Dashboard</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
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

                    .form-card {
                        background: white;
                        border-radius: 0.5rem;
                        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
                        padding: 2rem;
                    }

                    .required-field::after {
                        content: " *";
                        color: #dc3545;
                    }

                    .alert {
                        border-radius: 0.5rem;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/components/layout/admin/admin_header.jsp" />
                <jsp:include page="/components/layout/admin/admin_sidebar.jsp" />

                <main>
                    <div class="container-fluid">
                        <div class="row mb-4">
                            <div class="col">
                                <h2 class="mb-0">Create New User</h2>
                                <p class="text-muted">Create accounts for Staff and Branch Managers</p>
                            </div>
                        </div>

                        <% String successMessage=(String) session.getAttribute("successMessage"); %>
                            <% if (successMessage !=null) { %>
                                <div class="alert alert-success alert-dismissible fade show" role="alert">
                                    <i class="fa fa-check-circle me-2"></i>
                                    <%= successMessage %>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                </div>
                                <% session.removeAttribute("successMessage"); } %>

                                    <% String errorMessage=(String) session.getAttribute("errorMessage"); %>
                                        <% if (errorMessage !=null) { %>
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fa fa-exclamation-circle me-2"></i>
                                                <%= errorMessage %>
                                                    <button type="button" class="btn-close"
                                                        data-bs-dismiss="alert"></button>
                                            </div>
                                            <% session.removeAttribute("errorMessage"); } %>

                                                <div class="row">
                                                    <div class="col-lg-8">
                                                        <div class="form-card">
                                                            <form method="post"
                                                                action="${pageContext.request.contextPath}/admin/create-user"
                                                                id="createUserForm">
                                                                <div class="row mb-3">
                                                                    <div class="col-md-6">
                                                                        <label for="username"
                                                                            class="form-label required-field">Username</label>
                                                                        <input type="text" class="form-control"
                                                                            id="username" name="username" required
                                                                            minlength="3" maxlength="50"
                                                                            pattern="^[a-zA-Z0-9_]+$"
                                                                            title="Username must contain only letters, numbers, and underscores">
                                                                        <div class="form-text">3-50 characters, letters,
                                                                            numbers, and underscores only</div>
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <label for="email"
                                                                            class="form-label required-field">Email</label>
                                                                        <input type="email" class="form-control"
                                                                            id="email" name="email" required>
                                                                        <div class="form-text">Valid email address</div>
                                                                    </div>
                                                                </div>

                                                                <div class="row mb-3">
                                                                    <div class="col-md-6">
                                                                        <label for="password"
                                                                            class="form-label required-field">Password</label>
                                                                        <input type="password" class="form-control"
                                                                            id="password" name="password" required
                                                                            minlength="6">
                                                                        <div class="form-text">Minimum 6 characters
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <label for="confirmPassword"
                                                                            class="form-label required-field">Confirm
                                                                            Password</label>
                                                                        <input type="password" class="form-control"
                                                                            id="confirmPassword" name="confirmPassword"
                                                                            required minlength="6">
                                                                        <div class="form-text">Must match password</div>
                                                                    </div>
                                                                </div>

                                                                <div class="row mb-3">
                                                                    <div class="col-md-6">
                                                                        <label for="fullName" class="form-label">Full
                                                                            Name</label>
                                                                        <input type="text" class="form-control"
                                                                            id="fullName" name="fullName"
                                                                            maxlength="255">
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <label for="phone"
                                                                            class="form-label">Phone</label>
                                                                        <input type="tel" class="form-control"
                                                                            id="phone" name="phone"
                                                                            pattern="^[0-9]{10,20}$"
                                                                            title="Phone number must be 10-20 digits">
                                                                        <div class="form-text">10-20 digits</div>
                                                                    </div>
                                                                </div>

                                                                <div class="row mb-3">
                                                                    <div class="col-md-6">
                                                                        <label for="birthday"
                                                                            class="form-label">Birthday</label>
                                                                        <input type="date" class="form-control"
                                                                            id="birthday" name="birthday">
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <label for="roleId"
                                                                            class="form-label required-field">Role</label>
                                                                        <select class="form-select" id="roleId"
                                                                            name="roleId" required>
                                                                            <option value="">Select Role</option>
                                                                            <% List<Role> rolesList = (List<Role>)
                                                                                    request.getAttribute("roles");
                                                                                    if (rolesList != null) {
                                                                                    for (Role role : rolesList) {
                                                                                    String roleName =
                                                                                    role.getRoleName();
                                                                                    if (!"CUSTOMER".equals(roleName) &&
                                                                                    !"GUEST".equals(roleName)) {
                                                                                    %>
                                                                                    <option
                                                                                        value="<%= role.getRoleId() %>">
                                                                                        <%= roleName %>
                                                                                    </option>
                                                                                    <% } } } %>
                                                                        </select>
                                                                        <div class="form-text">Assign user role and
                                                                            permissions</div>
                                                                    </div>
                                                                </div>

                                                                <hr class="my-4">

                                                                <div class="d-flex justify-content-between">
                                                                    <a href="${pageContext.request.contextPath}/admin/manage-users"
                                                                        class="btn btn-secondary">
                                                                        <i class="fa fa-arrow-left me-1"></i> Back to
                                                                        Users
                                                                    </a>
                                                                    <button type="submit" class="btn btn-primary">
                                                                        <i class="fa fa-user-plus me-1"></i> Create User
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>

                                                    <div class="col-lg-4">
                                                        <div class="form-card">
                                                            <h5 class="mb-3"><i class="fa fa-info-circle me-2"></i>Role
                                                                Permissions</h5>
                                                            <div class="mb-3">
                                                                <h6 class="text-primary"><i
                                                                        class="fa fa-shield me-1"></i> ADMIN</h6>
                                                                <ul class="small text-muted">
                                                                    <li>Full system access</li>
                                                                    <li>Manage all users</li>
                                                                    <li>System configuration</li>
                                                                </ul>
                                                            </div>
                                                            <div class="mb-3">
                                                                <h6 class="text-info"><i
                                                                        class="fa fa-building me-1"></i> BRANCH_MANAGER
                                                                </h6>
                                                                <ul class="small text-muted">
                                                                    <li>Manage branch operations</li>
                                                                    <li>View branch reports</li>
                                                                    <li>Manage staff in branch</li>
                                                                </ul>
                                                            </div>
                                                            <div class="mb-3">
                                                                <h6 class="text-success"><i class="fa fa-user me-1"></i>
                                                                    STAFF</h6>
                                                                <ul class="small text-muted">
                                                                    <li>Sell tickets at counter</li>
                                                                    <li>Check-in customers</li>
                                                                    <li>Basic operations</li>
                                                                </ul>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const toggleBtn = document.getElementById('sidebarToggle');
                        if (toggleBtn) {
                            toggleBtn.addEventListener('click', function () {
                                document.body.classList.toggle('sidebar-collapsed');
                            });
                        }

                        const form = document.getElementById('createUserForm');
                        const password = document.getElementById('password');
                        const confirmPassword = document.getElementById('confirmPassword');

                        form.addEventListener('submit', function (e) {
                            if (password.value !== confirmPassword.value) {
                                e.preventDefault();
                                alert('Passwords do not match!');
                                confirmPassword.focus();
                                return false;
                            }
                        });

                        confirmPassword.addEventListener('input', function () {
                            if (password.value !== confirmPassword.value) {
                                confirmPassword.setCustomValidity('Passwords do not match');
                            } else {
                                confirmPassword.setCustomValidity('');
                            }
                        });
                    });
                </script>
            </body>

            </html>