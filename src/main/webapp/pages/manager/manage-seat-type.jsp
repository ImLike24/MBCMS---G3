<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Manage Seat Type - Branch Manager</title>
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

                .config-card {
                    background: white;
                    border-radius: 15px;
                    padding: 25px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                    margin-bottom: 25px;
                }

                .config-card h5 {
                    color: #2d3748;
                    font-weight: 700;
                    margin-bottom: 20px;
                }

                .config-card h5 i {
                    color: #667eea;
                    margin-right: 10px;
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

                /* Seat Grid */
                .seat-grid-container {
                    background: white;
                    border-radius: 15px;
                    padding: 30px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                    overflow-x: auto;
                }

                .screen-indicator {
                    background: linear-gradient(135deg, #4a5568 0%, #2d3748 100%);
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
                    color: #667eea;
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
                    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                    border: 2px solid transparent;
                }

                .seat:hover {
                    transform: scale(1.15);
                    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
                }

                .seat.selected {
                    border: 2px solid #2d3748;
                    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
                }

                .seat-NORMAL {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                }

                .seat-VIP {
                    background: linear-gradient(135deg, #f6ad55 0%, #ed8936 100%);
                }

                .seat-COUPLE {
                    background: linear-gradient(135deg, #fc8181 0%, #f56565 100%);
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
                    color: #667eea;
                    font-size: 12px;
                }

                .legend {
                    display: flex;
                    justify-content: center;
                    gap: 20px;
                    margin-top: 30px;
                    padding: 20px;
                    background: #f7fafc;
                    border-radius: 10px;
                }

                .legend-item {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .legend-box {
                    width: 30px;
                    height: 30px;
                    border-radius: 6px;
                }

                .legend-box.normal {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                }

                .legend-box.vip {
                    background: linear-gradient(135deg, #f6ad55 0%, #ed8936 100%);
                }

                .legend-box.couple {
                    background: linear-gradient(135deg, #fc8181 0%, #f56565 100%);
                }

                .toolbar {
                    background: #f7fafc;
                    padding: 20px;
                    border-radius: 10px;
                    margin-bottom: 20px;
                    display: flex;
                    gap: 10px;
                    flex-wrap: wrap;
                    align-items: center;
                }

                .btn-type {
                    padding: 10px 20px;
                    border-radius: 8px;
                    font-weight: 600;
                    border: 2px solid transparent;
                    transition: all 0.3s;
                }

                .btn-type:hover {
                    transform: translateY(-2px);
                }

                .btn-type.active {
                    border-color: #2d3748;
                    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.2);
                }

                .btn-normal {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                    color: white;
                }

                .btn-vip {
                    background: linear-gradient(135deg, #f6ad55 0%, #ed8936 100%);
                    color: white;
                }

                .btn-couple {
                    background: linear-gradient(135deg, #fc8181 0%, #f56565 100%);
                    color: white;
                }

                .btn-save {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 10px 30px;
                    border-radius: 8px;
                    font-weight: 600;
                    border: none;
                    transition: all 0.3s;
                }

                .btn-save:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
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

                .info-box {
                    background: #edf2f7;
                    border-left: 4px solid #667eea;
                    padding: 15px;
                    border-radius: 8px;
                    margin-bottom: 20px;
                }

                .info-box i {
                    color: #667eea;
                    margin-right: 10px;
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
                        <h2><i class="fa fa-wheelchair"></i>Manage Seat Type</h2>
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
                            <strong>Instructions:</strong> Select a room, then click on seats to change their type. You
                            can select multiple seats and apply a type to all at once.
                        </div>

                        <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-seat-type">
                            <div class="row g-3">
                                <div class="col-md-12">
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
                            </div>
                        </form>
                    </div>

                    <!-- Seat Type Management -->
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
                                <button type="button" class="btn btn-type btn-normal" onclick="setClickMode('NORMAL')">
                                    <i class="fa fa-chair me-1"></i>Normal
                                </button>
                                <button type="button" class="btn btn-type btn-vip" onclick="setClickMode('VIP')">
                                    <i class="fa fa-star me-1"></i>VIP
                                </button>
                                <button type="button" class="btn btn-type btn-couple" onclick="setClickMode('COUPLE')">
                                    <i class="fa fa-heart me-1"></i>Couple
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
                                                    <div class="seat seat-${seat.seatType}"
                                                        data-seat-id="${seat.seatId}" data-seat-type="${seat.seatType}"
                                                        onclick="toggleSeat(this)"
                                                        title="${seat.seatCode} - ${seat.seatType}">
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
                                        <div class="legend-box normal"></div>
                                        <span><strong>Normal</strong> - Standard seating</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box vip"></div>
                                        <span><strong>VIP</strong> - Premium seating</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box couple"></div>
                                        <span><strong>Couple</strong> - Double seating</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${selectedRoom != null && (seats == null || seats.isEmpty())}">
                        <div class="config-card">
                            <div class="empty-state">
                                <i class="fa fa-th"></i>
                                <p class="mb-0">No seats configured for this room.</p>
                                <p class="text-muted">Please configure the seat layout first in "Configure Seat Layout".
                                </p>
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
                action="${pageContext.request.contextPath}/branch-manager/manage-seat-type" style="display: none;">
                <input type="hidden" name="action" value="updateBulk">
                <input type="hidden" name="roomId" value="${selectedRoom != null ? selectedRoom.roomId : ''}">
                <input type="hidden" name="seatType" id="bulkSeatType">
                <div id="seatIdsContainer"></div>
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                let selectedSeats = new Set();
                let clickMode = 'NORMAL';

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
                    setClickMode('NORMAL');
                });

                function setClickMode(mode) {
                    clickMode = mode;

                    // Update button states
                    document.querySelectorAll('.btn-type').forEach(btn => {
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

                        // Update seat type visually
                        seatElement.classList.remove('seat-NORMAL', 'seat-VIP', 'seat-COUPLE');
                        seatElement.classList.add('seat-' + clickMode);
                        seatElement.setAttribute('data-seat-type', clickMode);
                    }
                }

                function clearSelection() {
                    selectedSeats.clear();
                    document.querySelectorAll('.seat.selected').forEach(seat => {
                        seat.classList.remove('selected');
                        // Restore original type
                        const originalType = seat.getAttribute('data-seat-type');
                        seat.classList.remove('seat-NORMAL', 'seat-VIP', 'seat-COUPLE');
                        seat.classList.add('seat-' + originalType);
                    });
                }

                function saveChanges() {
                    if (selectedSeats.size === 0) {
                        alert('Please select at least one seat to update.');
                        return;
                    }

                    if (!confirm('Update ' + selectedSeats.size + ' seat(s) to ' + clickMode + ' type?')) {
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

                    document.getElementById('bulkSeatType').value = clickMode;
                    document.getElementById('bulkUpdateForm').submit();
                }
            </script>

        </body>

        </html>