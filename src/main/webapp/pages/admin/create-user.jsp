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
                body {
                    padding-top: 56px;
                    overflow-x: hidden;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
                    background: white;
                    padding: 25px 30px;
                    border-radius: 15px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                    margin-bottom: 30px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }

                .page-header h2 {
                    margin: 0;
                    color: #2d3748;
                    font-weight: 700;
                    font-size: 28px;
                }

                .page-header h2 i {
                    color: #667eea;
                    margin-right: 12px;
                }

                .btn-back {
                    background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                    border: none;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(160, 174, 192, 0.4);
                    color: white;
                }

                .btn-back:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(160, 174, 192, 0.6);
                    color: white;
                }

                /* Alert Styling */
                .alert {
                    border-radius: 12px;
                    border: none;
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                    animation: slideDown 0.3s ease-out;
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
                    background: white;
                    padding: 35px;
                    border-radius: 15px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                    max-width: 900px;
                    margin: 0 auto;
                }

                .form-label {
                    font-weight: 600;
                    color: #4a5568;
                    margin-bottom: 8px;
                    font-size: 14px;
                }

                .form-label i {
                    color: #667eea;
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
                    border: 2px solid #e2e8f0;
                    padding: 12px 16px;
                    transition: all 0.3s;
                    font-size: 14px;
                }

                .form-control:focus,
                .form-select:focus {
                    border-color: #667eea;
                    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                }

                .form-text {
                    color: #a0aec0;
                    font-size: 12px;
                    margin-top: 6px;
                }

                /* Role Information Alert */
                .alert-info {
                    background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
                    color: white;
                    border: none;
                }

                .alert-info h6 {
                    color: white;
                    font-weight: 700;
                    margin-bottom: 15px;
                }

                .alert-info ul {
                    margin-bottom: 0;
                }

                .alert-info li {
                    margin-bottom: 8px;
                    line-height: 1.6;
                }

                .alert-info strong {
                    color: #fff;
                    font-weight: 700;
                }

                /* Button Group */
                .btn-group-custom {
                    display: flex;
                    gap: 15px;
                    justify-content: flex-end;
                    margin-top: 30px;
                    padding-top: 25px;
                    border-top: 2px solid #f7fafc;
                }

                .btn-cancel {
                    background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                    border: none;
                    padding: 12px 30px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(160, 174, 192, 0.3);
                }

                .btn-cancel:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(160, 174, 192, 0.5);
                }

                .btn-create {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border: none;
                    padding: 12px 30px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                }

                .btn-create:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
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