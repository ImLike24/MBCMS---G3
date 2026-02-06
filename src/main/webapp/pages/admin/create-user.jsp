<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Create User - Admin</title>
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

                .btn-back {
                    background: transparent;
                    border: 2px solid #262625;
                    color: #ccc;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                }

                .btn-back:hover {
                    background: #d96c2c;
                    border-color: #d96c2c;
                    color: white;
                    transform: translateY(-2px);
                }

                /* Alert Styling */
                .alert {
                    border-radius: 12px;
                    border: 1px solid #262625;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    animation: slideDown 0.3s ease-out;
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

                /* Form Container */
                .form-container {
                    background: #1a1a1a;
                    border: 1px solid #262625;
                    padding: 35px;
                    border-radius: 15px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    max-width: 900px;
                    margin: 0 auto;
                }

                .form-label {
                    font-weight: 600;
                    color: #ccc;
                    margin-bottom: 8px;
                    font-size: 14px;
                }

                .form-label i {
                    color: #d96c2c;
                    margin-right: 6px;
                }

                .required::after {
                    content: " *";
                    color: #f56565;
                    font-weight: 700;
                }

                .form-control,
                .form-select {
                    border-radius: 10px;
                    border: 2px solid #262625;
                    background: #0c121d;
                    color: white;
                    padding: 12px 16px;
                    transition: all 0.3s;
                    font-size: 14px;
                }

                .form-control:focus,
                .form-select:focus {
                    outline: none;
                    border-color: #d96c2c;
                    box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
                    background: #0c121d;
                    color: white;
                }

                .form-control::placeholder {
                    color: #666;
                }

                .form-select option {
                    background: #1a1a1a;
                    color: white;
                }

                .form-text {
                    color: #999;
                    font-size: 12px;
                    margin-top: 6px;
                }

                /* Date input calendar icon */
                .form-control[type="date"]::-webkit-calendar-picker-indicator {
                    filter: invert(1);
                    opacity: 0.9;
                    cursor: pointer;
                }

                /* Role Information Alert */
                .alert-info {
                    background: rgba(217, 108, 44, 0.2);
                    color: #d96c2c;
                    border: 1px solid #d96c2c;
                }

                .alert-info h6 {
                    color: #d96c2c;
                    font-weight: 700;
                    margin-bottom: 15px;
                }

                .alert-info ul {
                    margin-bottom: 0;
                }

                .alert-info li {
                    margin-bottom: 8px;
                    line-height: 1.6;
                    color: #ccc;
                }

                .alert-info strong {
                    color: #d96c2c;
                    font-weight: 700;
                }

                /* Button Group */
                .btn-group-custom {
                    display: flex;
                    gap: 15px;
                    justify-content: flex-end;
                    margin-top: 30px;
                    padding-top: 25px;
                    border-top: 2px solid #262625;
                }

                .btn-cancel {
                    background: transparent;
                    border: 2px solid #262625;
                    color: #ccc;
                    padding: 12px 30px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                }

                .btn-cancel:hover {
                    border-color: #d96c2c;
                    color: #d96c2c;
                    transform: translateY(-2px);
                }

                .btn-create {
                    background: #d96c2c;
                    border: none;
                    color: white;
                    padding: 12px 30px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                }

                .btn-create:hover {
                    background: #fff;
                    color: #000;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(217, 108, 44, 0.4);
                }

                /* Form Validation */
                .is-invalid {
                    border-color: #f56565 !important;
                }

                .is-valid {
                    border-color: #48bb78 !important;
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

                    .form-container {
                        padding: 25px 20px;
                    }

                    .btn-group-custom {
                        flex-direction: column;
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
                        <h2><i class="fa fa-user-plus"></i>Create New User</h2>
                        <a href="${pageContext.request.contextPath}/admin/manage-users" class="btn btn-back">
                            <i class="fa fa-arrow-left me-2"></i>Back to Users
                        </a>
                    </div>

                    <!-- Error Messages -->
                    <c:if test="${error != null}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa fa-exclamation-circle me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Create User Form -->
                    <div class="form-container">
                        <form method="post" action="${pageContext.request.contextPath}/admin/create-user"
                            id="createUserForm">
                            <div class="row">
                                <!-- Username -->
                                <div class="col-md-6 mb-3">
                                    <label for="username" class="form-label required">
                                        <i class="fa fa-user"></i>Username
                                    </label>
                                    <input type="text" class="form-control" id="username" name="username" required
                                        minlength="3" maxlength="50" pattern="^[a-zA-Z0-9_]+$"
                                        title="Username can only contain letters, numbers, and underscores"
                                        value="${param.username}">
                                    <div class="form-text">3-50 characters, letters, numbers, and underscores only</div>
                                </div>

                                <!-- Email -->
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label required">
                                        <i class="fa fa-envelope"></i>Email
                                    </label>
                                    <input type="email" class="form-control" id="email" name="email" required
                                        maxlength="100" value="${param.email}">
                                </div>

                                <!-- Password -->
                                <div class="col-md-6 mb-3">
                                    <label for="password" class="form-label required">
                                        <i class="fa fa-lock"></i>Password
                                    </label>
                                    <input type="password" class="form-control" id="password" name="password" required
                                        minlength="6" maxlength="255">
                                    <div class="form-text">Minimum 6 characters</div>
                                </div>

                                <!-- Confirm Password -->
                                <div class="col-md-6 mb-3">
                                    <label for="confirmPassword" class="form-label required">
                                        <i class="fa fa-lock"></i>Confirm Password
                                    </label>
                                    <input type="password" class="form-control" id="confirmPassword"
                                        name="confirmPassword" required minlength="6" maxlength="255">
                                </div>

                                <!-- Full Name -->
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label required">
                                        <i class="fa fa-id-card"></i>Full Name
                                    </label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" required
                                        maxlength="255" value="${param.fullName}">
                                </div>

                                <!-- Phone -->
                                <div class="col-md-6 mb-3">
                                    <label for="phone" class="form-label">
                                        <i class="fa fa-phone"></i>Phone
                                    </label>
                                    <input type="tel" class="form-control" id="phone" name="phone" maxlength="20"
                                        pattern="^[0-9+\-\s()]+$" title="Please enter a valid phone number"
                                        value="${param.phone}">
                                </div>

                                <!-- Birthday -->
                                <div class="col-md-6 mb-3">
                                    <label for="birthday" class="form-label">
                                        <i class="fa fa-calendar"></i>Birthday
                                    </label>
                                    <input type="date" class="form-control" id="birthday" name="birthday"
                                        value="${param.birthday}">
                                </div>

                                <!-- Role -->
                                <div class="col-md-6 mb-3">
                                    <label for="roleId" class="form-label required">
                                        <i class="fa fa-user-tag"></i>Role
                                    </label>
                                    <select class="form-select" id="roleId" name="roleId" required>
                                        <option value="">Select Role</option>
                                        <c:forEach var="role" items="${creatableRoles}">
                                            <option value="${role.roleId}" ${param.roleId==role.roleId.toString()
                                                ? 'selected' : '' }>
                                                ${role.roleName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <div class="form-text">Select ADMIN, CINEMA_STAFF, STAFF, or BRANCH_MANAGER role
                                    </div>
                                </div>
                            </div>

                            <!-- Role Information -->
                            <div class="alert alert-info mt-3">
                                <h6><i class="fa fa-info-circle me-2"></i>Role Information</h6>
                                <ul class="mb-0">
                                    <li><strong>ADMIN:</strong> Full system access, can manage all users and settings
                                    </li>
                                    <li><strong>CINEMA_STAFF:</strong> Cinema staff with specific permissions</li>
                                    <li><strong>BRANCH_MANAGER:</strong> Can manage branch operations, staff, and
                                        reports</li>
                                </ul>
                            </div>

                            <!-- Buttons -->
                            <div class="btn-group-custom">
                                <a href="${pageContext.request.contextPath}/admin/manage-users"
                                    class="btn btn-secondary btn-cancel">
                                    <i class="fa fa-times me-2"></i>Cancel
                                </a>
                                <button type="submit" class="btn btn-primary btn-create">
                                    <i class="fa fa-save me-2"></i>Create User
                                </button>
                            </div>
                        </form>
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

                    // Password confirmation validation
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

                    // Real-time password match indicator
                    confirmPassword.addEventListener('input', function () {
                        if (this.value && password.value !== this.value) {
                            this.setCustomValidity('Passwords do not match');
                            this.classList.add('is-invalid');
                            this.classList.remove('is-valid');
                        } else {
                            this.setCustomValidity('');
                            this.classList.remove('is-invalid');
                            if (this.value) {
                                this.classList.add('is-valid');
                            }
                        }
                    });
                });
            </script>

        </body>

        </html>