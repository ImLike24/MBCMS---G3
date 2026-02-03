<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Configure Seat Layout - Branch Manager</title>
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

                .btn-generate {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border: none;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                }

                .btn-generate:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
                }

                .btn-clear {
                    background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
                    border: none;
                    padding: 12px 28px;
                    border-radius: 10px;
                    font-weight: 600;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(245, 101, 101, 0.4);
                }

                .btn-clear:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(245, 101, 101, 0.6);
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
                    cursor: default;
                    transition: all 0.2s;
                    background: #48bb78;
                    color: white;
                    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                }

                .seat:hover {
                    transform: scale(1.1);
                }

                .seat-normal {
                    background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                }

                .seat-vip {
                    background: linear-gradient(135deg, #f6ad55 0%, #ed8936 100%);
                }

                .seat-couple {
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
                        <h2><i class="fa fa-th"></i>Configure Seat Layout</h2>
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

                    <!-- Configuration Card -->
                    <div class="config-card">
                        <h5><i class="fa fa-cog"></i>Layout Configuration</h5>

                        <div class="info-box">
                            <i class="fa fa-info-circle"></i>
                            <strong>Instructions:</strong> Select a screening room, then specify the number of rows
                            (A-Z) and columns (1-50) to generate the seat layout.
                        </div>

                        <form method="get"
                            action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout">
                            <div class="row g-3 mb-3">
                                <div class="col-md-12">
                                    <label for="roomId" class="form-label">
                                        <i class="fa fa-building me-1"></i>Select Screening Room
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

                        <c:if test="${selectedRoom != null}">
                            <form method="post"
                                action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout"
                                onsubmit="return confirm('This will replace the existing seat layout. Continue?');">
                                <input type="hidden" name="action" value="generate">
                                <input type="hidden" name="roomId" value="${selectedRoom.roomId}">

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="rows" class="form-label">
                                            <i class="fa fa-arrows-v me-1"></i>Number of Rows (1-26)
                                        </label>
                                        <input type="number" class="form-control" id="rows" name="rows" min="1" max="26"
                                            value="5" required>
                                        <small class="text-muted">Rows will be labeled A, B, C, etc.</small>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="columns" class="form-label">
                                            <i class="fa fa-arrows-h me-1"></i>Number of Columns (1-50)
                                        </label>
                                        <input type="number" class="form-control" id="columns" name="columns" min="1"
                                            max="50" value="10" required>
                                        <small class="text-muted">Columns will be numbered 1, 2, 3, etc.</small>
                                    </div>
                                </div>

                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary btn-generate">
                                        <i class="fa fa-magic me-2"></i>Generate Layout
                                    </button>

                                    <c:if test="${existingSeats != null && !existingSeats.isEmpty()}">
                                        <button type="button" class="btn btn-danger btn-clear"
                                            onclick="clearLayout(${selectedRoom.roomId})">
                                            <i class="fa fa-trash me-2"></i>Clear Layout
                                        </button>
                                    </c:if>
                                </div>
                            </form>
                        </c:if>
                    </div>

                    <!-- Seat Grid Display -->
                    <c:if test="${selectedRoom != null}">
                        <div class="seat-grid-container">
                            <c:choose>
                                <c:when test="${existingSeats != null && !existingSeats.isEmpty()}">
                                    <div class="screen-indicator">
                                        <i class="fa fa-desktop me-2"></i>SCREEN
                                    </div>

                                    <div class="seat-grid-wrapper">
                                        <jsp:useBean id="seatMap" class="java.util.HashMap" scope="page" />
                                        <jsp:useBean id="rowSet" class="java.util.TreeSet" scope="page" />
                                        <jsp:useBean id="colSet" class="java.util.TreeSet" scope="page" />

                                        <c:forEach var="seat" items="${existingSeats}">
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
                                                        <c:set var="seat"
                                                            value="${seatMap[row.concat('-').concat(col)]}" />
                                                        <c:if test="${seat != null}">
                                                            <div class="seat seat-${seat.seatType.toLowerCase()}"
                                                                title="${seat.seatCode} - ${seat.seatType}">
                                                                ${seat.seatCode}
                                                            </div>
                                                        </c:if>
                                                    </c:forEach>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <!-- Stats -->
                                        <div class="mt-4 text-center">
                                            <span class="badge bg-success me-2">
                                                <i class="fa fa-chair me-1"></i>Total Seats: ${existingSeats.size()}
                                            </span>
                                            <span class="badge bg-info">
                                                <i class="fa fa-th me-1"></i>Layout: ${rowSet.size()} rows ×
                                                ${colSet.size()} columns
                                            </span>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fa fa-th"></i>
                                        <p class="mb-0">No seat layout configured for this room yet.</p>
                                        <p class="text-muted">Use the form above to generate a seat layout.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
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

            <!-- Hidden form for clear action -->
            <form id="clearForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout" style="display: none;">
                <input type="hidden" name="action" value="clear">
                <input type="hidden" name="roomId" id="clearRoomId">
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

                // Clear layout function
                function clearLayout(roomId) {
                    if (confirm('Are you sure you want to clear all seats in this room? This action cannot be undone!')) {
                        document.getElementById('clearRoomId').value = roomId;
                        document.getElementById('clearForm').submit();
                    }
                }
            </script>

        </body>

        </html>