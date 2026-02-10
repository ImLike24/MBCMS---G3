<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Manage Seat Status - Branch Manager</title>
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

                .page-header {
                    background: #1a1a1a;
                    border: 1px solid #262625;
                    padding: 25px 30px;
                    border-radius: 15px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    margin-bottom: 30px;
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

                .config-card {
                    background: #1a1a1a;
                    border: 1px solid #262625;
                    border-radius: 15px;
                    padding: 25px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    margin-bottom: 25px;
                }

                .config-card h5 {
                    color: white;
                    font-weight: 600;
                    margin-bottom: 20px;
                }

                .config-card h5 i {
                    color: #d96c2c;
                    margin-right: 10px;
                }

                .form-label {
                    font-weight: 600;
                    color: #ccc;
                    margin-bottom: 8px;
                }

                .form-label i {
                    color: #d96c2c;
                }

                .form-control,
                .form-select {
                    border-radius: 10px;
                    border: 2px solid #262625;
                    background: #0c121d;
                    color: white;
                    padding: 10px 15px;
                    transition: all 0.3s;
                }

                .form-control:focus,
                .form-select:focus {
                    outline: none;
                    border-color: #d96c2c;
                    box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
                    background: #0c121d;
                    color: white;
                }

                .form-select option {
                    background: #1a1a1a;
                    color: white;
                }

                /* Seat Grid */
                .seat-grid-container {
                    background: #1a1a1a;
                    border: 1px solid #262625;
                    border-radius: 15px;
                    padding: 30px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                    overflow-x: auto;
                }

                .screen-indicator {
                    background: #2d3748;
                    color: white;
                    text-align: center;
                    padding: 15px;
                    border-radius: 10px 10px 0 0;
                    margin-bottom: 30px;
                    font-weight: 700;
                    letter-spacing: 2px;
                }

                .seat-grid-wrapper {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                }

                .seat-grid {
                    display: inline-block;
                }

                .seat-row {
                    display: flex;
                    align-items: center;
                    margin-bottom: 8px;
                }

                .row-label {
                    font-weight: 700;
                    color: #d96c2c;
                    width: 40px;
                    text-align: center;
                    font-size: 16px;
                }

                .seat {
                    width: 35px;
                    height: 35px;
                    margin: 3px;
                    border-radius: 8px;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 11px;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s;
                    color: white;
                    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
                    border: 2px solid transparent;
                }

                .seat:hover {
                    transform: scale(1.15);
                    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4);
                }

                .seat.selected {
                    border: 2px solid #d96c2c;
                    box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.3);
                }

                .seat-AVAILABLE {
                    background: #48bb78;
                }

                .seat-BROKEN {
                    background: #f56565;
                }

                .seat-MAINTENANCE {
                    background: #ed8936;
                }

                .column-labels {
                    display: flex;
                    margin-left: 40px;
                    margin-bottom: 10px;
                }

                .column-label {
                    width: 41px;
                    text-align: center;
                    font-weight: 700;
                    color: #d96c2c;
                    font-size: 12px;
                }

                .legend {
                    display: flex;
                    justify-content: center;
                    gap: 20px;
                    margin-top: 30px;
                    padding: 20px;
                    background: rgba(217, 108, 44, 0.1);
                    border-radius: 10px;
                }

                .legend-item {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    color: #ccc;
                }

                .legend-box {
                    width: 30px;
                    height: 30px;
                    border-radius: 6px;
                }

                .legend-box.available {
                    background: #48bb78;
                }

                .legend-box.broken {
                    background: #f56565;
                }

                .legend-box.maintenance {
                    background: #ed8936;
                }

                .toolbar {
                    background: rgba(217, 108, 44, 0.1);
                    border: 1px solid #262625;
                    padding: 20px;
                    border-radius: 10px;
                    margin-bottom: 20px;
                    display: flex;
                    gap: 10px;
                    flex-wrap: wrap;
                    align-items: center;
                }

                .toolbar strong {
                    color: #ccc;
                }

                .btn-status {
                    padding: 10px 20px;
                    border-radius: 8px;
                    font-weight: 600;
                    border: 2px solid transparent;
                    transition: all 0.3s;
                }

                .btn-status:hover {
                    transform: translateY(-2px);
                }

                .btn-status.active {
                    border-color: #d96c2c;
                    box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
                }

                .btn-available {
                    background: #48bb78;
                    color: white;
                }

                .btn-broken {
                    background: #f56565;
                    color: white;
                }

                .btn-maintenance {
                    background: #ed8936;
                    color: white;
                }

                .btn-save {
                    background: #d96c2c;
                    color: white;
                    padding: 10px 30px;
                    border-radius: 8px;
                    font-weight: 600;
                    border: none;
                    transition: all 0.3s;
                }

                .btn-save:hover {
                    background: #fff;
                    color: #000;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 15px rgba(217, 108, 44, 0.4);
                }

                .btn-secondary {
                    background: #4a5568;
                    color: white;
                    border: none;
                }

                .btn-secondary:hover {
                    background: #2d3748;
                }

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

                .empty-state p {
                    color: #ccc;
                }

                .info-box {
                    background: rgba(217, 108, 44, 0.1);
                    border-left: 4px solid #d96c2c;
                    padding: 15px;
                    border-radius: 8px;
                    margin-bottom: 20px;
                    color: #ccc;
                }

                .info-box i {
                    color: #d96c2c;
                    margin-right: 10px;
                }

                .info-box strong {
                    color: #d96c2c;
                }

                .filter-section {
                    display: flex;
                    gap: 10px;
                    align-items: center;
                    margin-top: 15px;
                }

                @media (max-width: 768px) {
                    main {
                        margin-left: 0;
                        padding: 15px;
                    }

                    .page-header h2 {
                        font-size: 22px;
                    }

                    .seat {
                        width: 30px;
                        height: 30px;
                        font-size: 10px;
                    }

                    .column-label {
                        width: 36px;
                    }

                    .toolbar {
                        flex-direction: column;
                        align-items: stretch;
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
                        <h2><i class="fa fa-wrench"></i>Manage Seat Status</h2>
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

                    <!-- Room Selection -->
                    <div class="config-card">
                        <h5><i class="fa fa-building"></i>Select Screening Room</h5>

                        <div class="info-box">
                            <i class="fa fa-info-circle"></i>
                            <strong>Instructions:</strong> Select a room, then click on seats to change their status.
                            Mark seats as broken or under maintenance to prevent bookings.
                        </div>

                        <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-seat-status"
                            id="roomForm">
                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label for="roomId" class="form-label">
                                        <i class="fa fa-building me-1"></i>Screening Room
                                    </label>
                                    <select class="form-select" id="roomId" name="roomId" onchange="this.form.submit()"
                                        required>
                                        <option value="">-- Select a room --</option>
                                        <c:forEach var="room" items="${rooms}">
                                            <option value="${room.roomId}" ${selectedRoom !=null &&
                                                selectedRoom.roomId==room.roomId ? 'selected' : '' }>
                                                ${room.roomName} (${room.totalSeats} seats)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label for="statusFilter" class="form-label">
                                        <i class="fa fa-filter me-1"></i>Filter by Status
                                    </label>
                                    <select class="form-select" id="statusFilter" name="statusFilter"
                                        onchange="this.form.submit()">
                                        <option value="">All Statuses</option>
                                        <option value="AVAILABLE" ${statusFilter=='AVAILABLE' ? 'selected' : '' }>
                                            Available</option>
                                        <option value="BROKEN" ${statusFilter=='BROKEN' ? 'selected' : '' }>Broken
                                        </option>
                                        <option value="MAINTENANCE" ${statusFilter=='MAINTENANCE' ? 'selected' : '' }>
                                            Maintenance</option>
                                    </select>
                                </div>
                            </div>
                        </form>
                    </div>

                    <!-- Seat Status Management -->
                    <c:if test="${selectedRoom != null && seats != null && !seats.isEmpty()}">
                        <div class="seat-grid-container">
                            <div class="screen-indicator">
                                <i class="fa fa-desktop me-2"></i>SCREEN
                            </div>

                            <!-- Toolbar -->
                            <div class="toolbar">
                                <div>
                                    <strong><i class="fa fa-hand-pointer-o me-2"></i>Click Mode:</strong>
                                </div>
                                <button type="button" class="btn btn-status btn-available"
                                    onclick="setClickMode('AVAILABLE')">
                                    <i class="fa fa-check me-1"></i>Available
                                </button>
                                <button type="button" class="btn btn-status btn-broken"
                                    onclick="setClickMode('BROKEN')">
                                    <i class="fa fa-times me-1"></i>Broken
                                </button>
                                <button type="button" class="btn btn-status btn-maintenance"
                                    onclick="setClickMode('MAINTENANCE')">
                                    <i class="fa fa-wrench me-1"></i>Maintenance
                                </button>
                                <div class="ms-auto">
                                    <button type="button" class="btn btn-secondary me-2" onclick="clearSelection()">
                                        <i class="fa fa-times me-1"></i>Clear Selection
                                    </button>
                                    <button type="button" class="btn btn-save" onclick="saveChanges()">
                                        <i class="fa fa-save me-1"></i>Save Changes
                                    </button>
                                </div>
                            </div>

                            <div class="seat-grid-wrapper">
                                <jsp:useBean id="seatMap" class="java.util.HashMap" scope="page" />
                                <jsp:useBean id="rowSet" class="java.util.TreeSet" scope="page" />
                                <jsp:useBean id="colSet" class="java.util.TreeSet" scope="page" />

                                <c:forEach var="seat" items="${seats}">
                                    <c:set target="${seatMap}" property="${seat.rowNumber}-${seat.seatNumber}"
                                        value="${seat}" />
                                    <c:set var="addRow" value="${rowSet.add(seat.rowNumber)}" />
                                    <c:set var="addCol" value="${colSet.add(seat.seatNumber)}" />
                                </c:forEach>

                                <!-- Column Labels -->
                                <div class="column-labels">
                                    <c:forEach var="col" items="${colSet}">
                                        <div class="column-label">${col}</div>
                                    </c:forEach>
                                </div>

                                <!-- Seat Grid -->
                                <div class="seat-grid">
                                    <c:forEach var="row" items="${rowSet}">
                                        <div class="seat-row">
                                            <div class="row-label">${row}</div>
                                            <c:forEach var="col" items="${colSet}">
                                                <c:set var="seat" value="${seatMap[row.concat('-').concat(col)]}" />
                                                <c:if test="${seat != null}">
                                                    <div class="seat seat-${seat.status}" data-seat-id="${seat.seatId}"
                                                        data-seat-status="${seat.status}" onclick="toggleSeat(this)"
                                                        title="${seat.seatCode} - ${seat.status} (${seat.seatType})">
                                                        ${seat.seatCode}
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Legend -->
                                <div class="legend">
                                    <div class="legend-item">
                                        <div class="legend-box available"></div>
                                        <span><strong>Available</strong> - Ready for booking</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box broken"></div>
                                        <span><strong>Broken</strong> - Out of service</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box maintenance"></div>
                                        <span><strong>Maintenance</strong> - Under repair</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${selectedRoom != null && (seats == null || seats.isEmpty())}">
                        <div class="config-card">
                            <div class="empty-state">
                                <i class="fa fa-th"></i>
                                <c:choose>
                                    <c:when test="${statusFilter != null && !statusFilter.isEmpty()}">
                                        <p class="mb-0">No seats with status "${statusFilter}" found in this room.</p>
                                        <p class="text-muted">Try changing the filter or select a different room.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="mb-0">No seats configured for this room.</p>
                                        <p class="text-muted">Please configure the seat layout first in "Configure Seat
                                            Layout".</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${selectedRoom == null && (rooms == null || rooms.isEmpty())}">
                        <div class="config-card">
                            <div class="empty-state">
                                <i class="fa fa-building"></i>
                                <p class="mb-0">No screening rooms available.</p>
                                <p class="text-muted">Please create a screening room first in "Manage Cinema Halls".</p>
                            </div>
                        </div>
                    </c:if>
                </div>
            </main>

            <!-- Hidden form for bulk update -->
            <form id="bulkUpdateForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/manage-seat-status" style="display: none;">
                <input type="hidden" name="action" value="updateBulk">
                <input type="hidden" name="roomId" value="${selectedRoom != null ? selectedRoom.roomId : ''}">
                <input type="hidden" name="status" id="bulkStatus">
                <div id="seatIdsContainer"></div>
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                let selectedSeats = new Set();
                let clickMode = 'AVAILABLE';

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

                    // Set initial click mode
                    setClickMode('AVAILABLE');
                });

                function setClickMode(mode) {
                    clickMode = mode;

                    // Update button states
                    document.querySelectorAll('.btn-status').forEach(btn => {
                        btn.classList.remove('active');
                    });

                    const activeBtn = document.querySelector('.btn-' + mode.toLowerCase());
                    if (activeBtn) {
                        activeBtn.classList.add('active');
                    }
                }

                function toggleSeat(seatElement) {
                    const seatId = seatElement.getAttribute('data-seat-id');

                    if (selectedSeats.has(seatId)) {
                        selectedSeats.delete(seatId);
                        seatElement.classList.remove('selected');
                    } else {
                        selectedSeats.add(seatId);
                        seatElement.classList.add('selected');

                        // Update seat status visually
                        seatElement.classList.remove('seat-AVAILABLE', 'seat-BROKEN', 'seat-MAINTENANCE');
                        seatElement.classList.add('seat-' + clickMode);
                        seatElement.setAttribute('data-seat-status', clickMode);
                    }
                }

                function clearSelection() {
                    selectedSeats.clear();
                    document.querySelectorAll('.seat.selected').forEach(seat => {
                        seat.classList.remove('selected');
                        // Restore original status
                        const originalStatus = seat.getAttribute('data-seat-status');
                        seat.classList.remove('seat-AVAILABLE', 'seat-BROKEN', 'seat-MAINTENANCE');
                        seat.classList.add('seat-' + originalStatus);
                    });
                }

                function saveChanges() {
                    if (selectedSeats.size === 0) {
                        alert('Please select at least one seat to update.');
                        return;
                    }

                    if (!confirm('Update ' + selectedSeats.size + ' seat(s) to ' + clickMode + ' status?')) {
                        return;
                    }

                    // Prepare form
                    const container = document.getElementById('seatIdsContainer');
                    container.innerHTML = '';

                    selectedSeats.forEach(seatId => {
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = 'seatIds[]';
                        input.value = seatId;
                        container.appendChild(input);
                    });

                    document.getElementById('bulkStatus').value = clickMode;
                    document.getElementById('bulkUpdateForm').submit();
                }
            </script>

        </body>

        </html>