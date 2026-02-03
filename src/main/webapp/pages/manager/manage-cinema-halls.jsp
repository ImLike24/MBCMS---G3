<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Manage Cinema Halls - Branch Manager</title>
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

                .btn-add-hall {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border: none;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                }

                .btn-add-hall:hover {
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

                .halls-table-container {
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

                .status-maintenance {
                    background: linear-gradient(135deg, #ed8936 0%, #dd6b20 100%);
                    color: white;
                    box-shadow: 0 2px 10px rgba(237, 137, 54, 0.3);
                }

                .status-closed {
                    background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
                    color: white;
                    box-shadow: 0 2px 10px rgba(245, 101, 101, 0.3);
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

                .btn-warning {
                    background: linear-gradient(135deg, #ed8936 0%, #dd6b20 100%);
                    border: none;
                }

                .btn-success {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                    border: none;
                }

                .btn-danger {
                    background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
                    border: none;
                }

                .btn-info {
                    background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
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
            <jsp:include page="/components/layout/dashboard/branch_manager_sidebar.jsp" />

            <!-- Main Content -->
            <main>
                <div class="container-fluid">
                    <!-- Page Header -->
                    <div class="page-header">
                        <h2><i class="fa fa-building"></i>Manage Cinema Halls</h2>
                        <button class="btn btn-primary btn-add-hall" data-bs-toggle="modal"
                            data-bs-target="#addHallModal">
                            <i class="fa fa-plus me-2"></i>Add New Hall
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

                    <c:if test="${error != null}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fa fa-exclamation-circle me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Branch Info -->
                    <c:if test="${branch != null}">
                        <div class="alert alert-info">
                            <i class="fa fa-info-circle me-2"></i>
                            Managing halls for: <strong>${branch.branchName}</strong>
                        </div>
                    </c:if>

                    <!-- Halls Table -->
                    <div class="halls-table-container">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Hall Name</th>
                                        <th>Total Seats</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty rooms}">
                                            <tr>
                                                <td colspan="5" class="empty-state">
                                                    <i class="fa fa-building"></i>
                                                    <p class="mb-0">No screening rooms found. Click "Add New Hall" to
                                                        create one.</p>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="room" items="${rooms}">
                                                <tr>
                                                    <td><strong>#${room.roomId}</strong></td>
                                                    <td><strong>${room.roomName}</strong></td>
                                                    <td>${room.totalSeats} seats</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${room.status == 'ACTIVE'}">
                                                                <span class="status-badge status-active">
                                                                    <i class="fa fa-check-circle me-1"></i>Active
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${room.status == 'MAINTENANCE'}">
                                                                <span class="status-badge status-maintenance">
                                                                    <i class="fa fa-wrench me-1"></i>Maintenance
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-closed">
                                                                    <i class="fa fa-ban me-1"></i>Closed
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <!-- Edit Button -->
                                                        <button class="btn btn-info btn-sm action-btn"
                                                            onclick="editHall(${room.roomId}, '${room.roomName}')">
                                                            <i class="fa fa-edit"></i> Edit
                                                        </button>

                                                        <!-- Status Change Dropdown -->
                                                        <div class="btn-group" role="group">
                                                            <button type="button"
                                                                class="btn btn-warning btn-sm action-btn dropdown-toggle"
                                                                data-bs-toggle="dropdown">
                                                                <i class="fa fa-exchange"></i> Status
                                                            </button>
                                                            <ul class="dropdown-menu">
                                                                <li>
                                                                    <a class="dropdown-item" href="#"
                                                                        onclick="changeStatus(${room.roomId}, 'ACTIVE')">
                                                                        <i class="fa fa-check-circle text-success"></i>
                                                                        Active
                                                                    </a>
                                                                </li>
                                                                <li>
                                                                    <a class="dropdown-item" href="#"
                                                                        onclick="changeStatus(${room.roomId}, 'MAINTENANCE')">
                                                                        <i class="fa fa-wrench text-warning"></i>
                                                                        Maintenance
                                                                    </a>
                                                                </li>
                                                                <li>
                                                                    <a class="dropdown-item" href="#"
                                                                        onclick="changeStatus(${room.roomId}, 'CLOSED')">
                                                                        <i class="fa fa-ban text-danger"></i> Closed
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>

                                                        <!-- Delete Button -->
                                                        <button class="btn btn-danger btn-sm action-btn"
                                                            onclick="deleteHall(${room.roomId}, '${room.roomName}')">
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

            <!-- Add Hall Modal -->
            <div class="modal fade" id="addHallModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa fa-plus me-2"></i>Add New Screening Hall</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <form method="post"
                            action="${pageContext.request.contextPath}/branch-manager/manage-cinema-halls">
                            <div class="modal-body">
                                <input type="hidden" name="action" value="create">
                                <div class="mb-3">
                                    <label for="roomName" class="form-label">
                                        <i class="fa fa-building me-1"></i>Hall Name
                                    </label>
                                    <input type="text" class="form-control" id="roomName" name="roomName"
                                        placeholder="e.g., Hall A, Cinema 1" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save me-2"></i>Create Hall
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Edit Hall Modal -->
            <div class="modal fade" id="editHallModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa fa-edit me-2"></i>Edit Screening Hall</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <form method="post"
                            action="${pageContext.request.contextPath}/branch-manager/manage-cinema-halls">
                            <div class="modal-body">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="roomId" id="editRoomId">
                                <div class="mb-3">
                                    <label for="editRoomName" class="form-label">
                                        <i class="fa fa-building me-1"></i>Hall Name
                                    </label>
                                    <input type="text" class="form-control" id="editRoomName" name="roomName" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save me-2"></i>Update Hall
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Hidden forms for actions -->
            <form id="deleteForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/manage-cinema-halls" style="display: none;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="roomId" id="deleteRoomId">
            </form>

            <form id="statusForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/manage-cinema-halls" style="display: none;">
                <input type="hidden" name="action" value="changeStatus">
                <input type="hidden" name="roomId" id="statusRoomId">
                <input type="hidden" name="status" id="statusValue">
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

                // Edit hall function
                function editHall(roomId, roomName) {
                    document.getElementById('editRoomId').value = roomId;
                    document.getElementById('editRoomName').value = roomName;
                    const editModal = new bootstrap.Modal(document.getElementById('editHallModal'));
                    editModal.show();
                }

                // Delete hall function
                function deleteHall(roomId, roomName) {
                    if (confirm('Are you sure you want to delete "' + roomName + '"? This will also delete all seats in this hall. This action cannot be undone!')) {
                        document.getElementById('deleteRoomId').value = roomId;
                        document.getElementById('deleteForm').submit();
                    }
                }

                // Change status function
                function changeStatus(roomId, status) {
                    if (confirm('Are you sure you want to change the status to ' + status + '?')) {
                        document.getElementById('statusRoomId').value = roomId;
                        document.getElementById('statusValue').value = status;
                        document.getElementById('statusForm').submit();
                    }
                    return false;
                }
            </script>

        </body>

        </html>