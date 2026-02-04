<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Manage Cinema Branches - Admin</title>
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

                .btn-add-branch {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border: none;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                }

                .btn-add-branch:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
                }

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

                .filter-section {
                    background: white;
                    padding: 20px;
                    border-radius: 12px;
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                    margin-bottom: 25px;
                }

                .branches-table-container {
                    background: white;
                    border-radius: 15px;
                    overflow: hidden;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                }

                .table {
                    margin-bottom: 0;
                }

                .table thead th {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
                    border-bottom: 1px solid #f7fafc;
                }

                .table tbody tr:hover {
                    background-color: #f7fafc;
                    transform: scale(1.01);
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                }

                .table tbody td {
                    padding: 18px 15px;
                    vertical-align: middle;
                    color: #4a5568;
                    font-size: 14px;
                }

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
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                    color: white;
                    box-shadow: 0 2px 10px rgba(72, 187, 120, 0.3);
                }

                .status-inactive {
                    background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                    color: white;
                    box-shadow: 0 2px 10px rgba(160, 174, 192, 0.3);
                }

                .manager-badge {
                    padding: 4px 12px;
                    border-radius: 15px;
                    font-size: 12px;
                    font-weight: 600;
                    background: #edf2f7;
                    color: #4a5568;
                }

                .manager-badge.unassigned {
                    background: #fed7d7;
                    color: #c53030;
                }

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
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
                }

                .btn-info {
                    background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
                    border: none;
                }

                .btn-success {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                    border: none;
                }

                .btn-secondary {
                    background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                    border: none;
                }

                .btn-danger {
                    background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
                    border: none;
                }

                .empty-state {
                    padding: 60px 20px;
                    text-align: center;
                    color: #a0aec0;
                }

                .empty-state i {
                    font-size: 64px;
                    margin-bottom: 20px;
                    opacity: 0.5;
                }

                .modal-content {
                    border-radius: 15px;
                    border: none;
                }

                .modal-header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    border-radius: 15px 15px 0 0;
                }

                .form-label {
                    font-weight: 600;
                    color: #4a5568;
                    margin-bottom: 8px;
                }

                .form-control,
                .form-select {
                    border-radius: 10px;
                    border: 2px solid #e2e8f0;
                    padding: 10px 15px;
                    transition: all 0.3s;
                }

                .form-control:focus,
                .form-select:focus {
                    border-color: #667eea;
                    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                }

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
                        <h2><i class="fa fa-building"></i>Manage Cinema Branches</h2>
                        <button class="btn btn-primary btn-add-branch" data-bs-toggle="modal"
                            data-bs-target="#addBranchModal">
                            <i class="fa fa-plus me-2"></i>Add New Branch
                        </button>
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

                    <!-- Filter Section -->
                    <div class="filter-section">
                        <form method="get" action="${pageContext.request.contextPath}/admin/manage-cinema-branches"
                            class="row g-3">
                            <div class="col-md-4">
                                <label for="statusFilter" class="form-label">
                                    <i class="fa fa-filter me-1"></i>Filter by Status
                                </label>
                                <select class="form-select" id="statusFilter" name="statusFilter"
                                    onchange="this.form.submit()">
                                    <option value="">All Branches</option>
                                    <option value="active" ${statusFilter=='active' ? 'selected' : '' }>Active Only
                                    </option>
                                    <option value="inactive" ${statusFilter=='inactive' ? 'selected' : '' }>Inactive
                                        Only</option>
                                </select>
                            </div>
                        </form>
                    </div>

                    <!-- Branches Table -->
                    <div class="branches-table-container">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Branch Name</th>
                                        <th>Address</th>
                                        <th>Contact</th>
                                        <th>Manager</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty branches}">
                                            <tr>
                                                <td colspan="7" class="empty-state">
                                                    <i class="fa fa-building"></i>
                                                    <p class="mb-0">No cinema branches found. Click "Add New Branch" to
                                                        create one.</p>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="branch" items="${branches}">
                                                <tr>
                                                    <td><strong>#${branch.branchId}</strong></td>
                                                    <td><strong>${branch.branchName}</strong></td>
                                                    <td>${branch.address != null ? branch.address : 'N/A'}</td>
                                                    <td>
                                                        <c:if test="${branch.phone != null}">
                                                            <i class="fa fa-phone me-1"></i>${branch.phone}<br>
                                                        </c:if>
                                                        <c:if test="${branch.email != null}">
                                                            <i class="fa fa-envelope me-1"></i>${branch.email}
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${branch.managerId != null}">
                                                                <span class="manager-badge">
                                                                    <i
                                                                        class="fa fa-user me-1"></i>${managerMap[branch.managerId]}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="manager-badge unassigned">
                                                                    <i class="fa fa-user-times me-1"></i>Unassigned
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${branch.active}">
                                                                <span class="status-badge status-active">
                                                                    <i class="fa fa-check-circle me-1"></i>Active
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
                                                        <!-- Edit Button -->
                                                        <button class="btn btn-info btn-sm action-btn"
                                                            onclick="editBranch(${branch.branchId}, '${branch.branchName}', '${branch.address}', '${branch.phone}', '${branch.email}', ${branch.managerId}, ${branch.active})">
                                                            <i class="fa fa-edit"></i> Edit
                                                        </button>

                                                        <!-- Toggle Status -->
                                                        <c:choose>
                                                            <c:when test="${branch.active}">
                                                                <button class="btn btn-secondary btn-sm action-btn"
                                                                    onclick="toggleStatus(${branch.branchId}, false)">
                                                                    <i class="fa fa-ban"></i> Deactivate
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button class="btn btn-success btn-sm action-btn"
                                                                    onclick="toggleStatus(${branch.branchId}, true)">
                                                                    <i class="fa fa-check"></i> Activate
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Delete Button -->
                                                        <button class="btn btn-danger btn-sm action-btn"
                                                            onclick="deleteBranch(${branch.branchId}, '${branch.branchName}')">
                                                            <i class="fa fa-trash"></i> Delete
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>

            <!-- Add Branch Modal -->
            <div class="modal fade" id="addBranchModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa fa-plus me-2"></i>Add New Cinema Branch</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/manage-cinema-branches">
                            <div class="modal-body">
                                <input type="hidden" name="action" value="create">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="branchName" class="form-label">
                                            <i class="fa fa-building me-1"></i>Branch Name <span
                                                class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control" id="branchName" name="branchName"
                                            required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="managerId" class="form-label">
                                            <i class="fa fa-user me-1"></i>Assign Manager
                                        </label>
                                        <select class="form-select" id="managerId" name="managerId">
                                            <option value="">-- No Manager --</option>
                                            <c:forEach var="manager" items="${availableManagers}">
                                                <option value="${manager.userId}">${manager.fullName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-12">
                                        <label for="address" class="form-label">
                                            <i class="fa fa-map-marker me-1"></i>Address
                                        </label>
                                        <input type="text" class="form-control" id="address" name="address">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="phone" class="form-label">
                                            <i class="fa fa-phone me-1"></i>Phone
                                        </label>
                                        <input type="tel" class="form-control" id="phone" name="phone">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="email" class="form-label">
                                            <i class="fa fa-envelope me-1"></i>Email
                                        </label>
                                        <input type="email" class="form-control" id="email" name="email">
                                    </div>
                                    <div class="col-md-12">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="isActive"
                                                name="isActive" checked>
                                            <label class="form-check-label" for="isActive">
                                                Active Branch
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save me-2"></i>Create Branch
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Edit Branch Modal -->
            <div class="modal fade" id="editBranchModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa fa-edit me-2"></i>Edit Cinema Branch</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/manage-cinema-branches">
                            <div class="modal-body">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="branchId" id="editBranchId">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="editBranchName" class="form-label">
                                            <i class="fa fa-building me-1"></i>Branch Name <span
                                                class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control" id="editBranchName" name="branchName"
                                            required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="editManagerId" class="form-label">
                                            <i class="fa fa-user me-1"></i>Assign Manager
                                        </label>
                                        <select class="form-select" id="editManagerId" name="managerId">
                                            <option value="">-- No Manager --</option>
                                            <c:forEach var="manager" items="${availableManagers}">
                                                <option value="${manager.userId}">${manager.fullName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-12">
                                        <label for="editAddress" class="form-label">
                                            <i class="fa fa-map-marker me-1"></i>Address
                                        </label>
                                        <input type="text" class="form-control" id="editAddress" name="address">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="editPhone" class="form-label">
                                            <i class="fa fa-phone me-1"></i>Phone
                                        </label>
                                        <input type="tel" class="form-control" id="editPhone" name="phone">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="editEmail" class="form-label">
                                            <i class="fa fa-envelope me-1"></i>Email
                                        </label>
                                        <input type="email" class="form-control" id="editEmail" name="email">
                                    </div>
                                    <div class="col-md-12">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="editIsActive"
                                                name="isActive">
                                            <label class="form-check-label" for="editIsActive">
                                                Active Branch
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save me-2"></i>Update Branch
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Hidden forms for actions -->
            <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/manage-cinema-branches"
                style="display: none;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="branchId" id="deleteBranchId">
            </form>

            <form id="toggleStatusForm" method="post"
                action="${pageContext.request.contextPath}/admin/manage-cinema-branches" style="display: none;">
                <input type="hidden" name="action" value="toggleStatus">
                <input type="hidden" name="branchId" id="toggleBranchId">
                <input type="hidden" name="isActive" id="toggleIsActive">
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                // Sidebar toggle
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

                // Edit branch function
                function editBranch(branchId, branchName, address, phone, email, managerId, isActive) {
                    document.getElementById('editBranchId').value = branchId;
                    document.getElementById('editBranchName').value = branchName;
                    document.getElementById('editAddress').value = address || '';
                    document.getElementById('editPhone').value = phone || '';
                    document.getElementById('editEmail').value = email || '';
                    document.getElementById('editManagerId').value = managerId || '';
                    document.getElementById('editIsActive').checked = isActive;

                    const editModal = new bootstrap.Modal(document.getElementById('editBranchModal'));
                    editModal.show();
                }

                // Delete branch function
                function deleteBranch(branchId, branchName) {
                    if (confirm('Are you sure you want to delete "' + branchName + '"? This action cannot be undone!')) {
                        document.getElementById('deleteBranchId').value = branchId;
                        document.getElementById('deleteForm').submit();
                    }
                }

                // Toggle status function
                function toggleStatus(branchId, isActive) {
                    const action = isActive ? 'activate' : 'deactivate';
                    if (confirm('Are you sure you want to ' + action + ' this branch?')) {
                        document.getElementById('toggleBranchId').value = branchId;
                        document.getElementById('toggleIsActive').value = isActive;
                        document.getElementById('toggleStatusForm').submit();
                    }
                }
            </script>

        </body>

        </html>