<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Trạng thái Ghế - Branch Manager</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
            <style>
                :root {
                    --bg-dark: #0c121d;
                    --bg-card: #141b27;
                    --bg-card2: #1a2436;
                    --border: #2a3547;
                    --orange: #e8742a;
                    --orange-dim: rgba(232, 116, 42, .15);
                    --text: #e2e8f0;
                    --text-muted: #8899b0;
                    --green: #48bb78;
                    --red: #f56565;
                    --amber: #ed8936;
                }

                *,
                *::before,
                *::after {
                    box-sizing: border-box;
                    margin: 0;
                    padding: 0;
                }

                body {
                    font-family: 'Segoe UI', sans-serif;
                    background: var(--bg-dark);
                    color: var(--text);
                    padding-top: 56px;
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
                    transition: margin-left .3s;
                }

                .sidebar-collapsed #sidebarMenu {
                    margin-left: -280px;
                }

                .sidebar-collapsed main {
                    margin-left: 0;
                }

                /* ── Page Header ─────────────────────────────────────────*/
                .page-header {
                    display: flex;
                    align-items: center;
                    gap: 14px;
                    padding: 22px 28px;
                    background: var(--bg-card);
                    border: 1px solid var(--border);
                    border-radius: 16px;
                    margin-bottom: 28px;
                }

                .page-header .icon-wrap {
                    width: 52px;
                    height: 52px;
                    background: var(--orange-dim);
                    border-radius: 14px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 22px;
                    color: var(--orange);
                }

                .page-header h2 {
                    font-size: 22px;
                    font-weight: 700;
                }

                .page-header p {
                    font-size: 13px;
                    color: var(--text-muted);
                    margin-top: 2px;
                }

                /* ── Alerts ──────────────────────────────────────────────*/
                .alert {
                    border-radius: 12px;
                    border: none;
                    padding: 14px 18px;
                    font-size: 14px;
                    margin-bottom: 20px;
                    animation: slideDown .3s ease;
                }

                .alert-success {
                    background: rgba(72, 187, 120, .15);
                    color: var(--green);
                    border-left: 4px solid var(--green);
                }

                .alert-danger {
                    background: rgba(245, 101, 101, .15);
                    color: var(--red);
                    border-left: 4px solid var(--red);
                }

                @keyframes slideDown {
                    from {
                        opacity: 0;
                        transform: translateY(-10px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                /* ── Card ────────────────────────────────────────────────*/
                .card {
                    background: var(--bg-card);
                    border: 1px solid var(--border);
                    border-radius: 16px;
                    padding: 26px;
                    margin-bottom: 24px;
                }

                .card-title {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    font-size: 16px;
                    font-weight: 700;
                    margin-bottom: 20px;
                }

                .card-title i {
                    color: var(--orange);
                }

                /* ── Info box ────────────────────────────────────────────*/
                .info-box {
                    display: flex;
                    align-items: flex-start;
                    gap: 12px;
                    background: var(--orange-dim);
                    border-left: 4px solid var(--orange);
                    border-radius: 10px;
                    padding: 14px 18px;
                    font-size: 13px;
                    color: var(--text-muted);
                    margin-bottom: 22px;
                }

                .info-box i {
                    color: var(--orange);
                    margin-top: 2px;
                }

                /* ── Form controls ───────────────────────────────────────*/
                .form-label {
                    font-size: 13px;
                    font-weight: 600;
                    color: var(--text-muted);
                    margin-bottom: 6px;
                }

                .form-control,
                .form-select {
                    background: var(--bg-dark);
                    color: var(--text);
                    border: 1.5px solid var(--border);
                    border-radius: 10px;
                    padding: 10px 14px;
                    font-size: 14px;
                    transition: border-color .2s, box-shadow .2s;
                }

                .form-control:focus,
                .form-select:focus {
                    outline: none;
                    border-color: var(--orange);
                    box-shadow: 0 0 0 3px rgba(232, 116, 42, .2);
                    background: var(--bg-dark);
                    color: var(--text);
                }

                .form-select option {
                    background: var(--bg-card);
                }

                /* ── Stats row ───────────────────────────────────────────*/
                .stats-row {
                    display: flex;
                    gap: 12px;
                    flex-wrap: wrap;
                    margin-bottom: 20px;
                }

                .stat-badge {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 8px 16px;
                    border-radius: 10px;
                    font-size: 13px;
                    font-weight: 700;
                }

                .stat-badge.available {
                    background: rgba(72, 187, 120, .15);
                    color: var(--green);
                }

                .stat-badge.broken {
                    background: rgba(245, 101, 101, .15);
                    color: var(--red);
                }

                .stat-badge.maintenance {
                    background: rgba(237, 137, 54, .15);
                    color: var(--amber);
                }

                .stat-dot {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                }

                /* ── Toolbar ─────────────────────────────────────────────*/
                .toolbar {
                    background: var(--bg-card2);
                    border: 1px solid var(--border);
                    border-radius: 12px;
                    padding: 16px 20px;
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    flex-wrap: wrap;
                    margin-bottom: 20px;
                }

                .toolbar-label {
                    font-size: 13px;
                    font-weight: 700;
                    color: var(--text-muted);
                }

                .mode-btn {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 10px 18px;
                    border-radius: 10px;
                    border: 2px solid transparent;
                    font-weight: 700;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .2s;
                }

                .mode-btn:hover {
                    transform: translateY(-1px);
                }

                .mode-btn.active {
                    border-color: var(--orange);
                    box-shadow: 0 0 0 3px rgba(232, 116, 42, .2);
                }

                .mode-btn.available {
                    background: rgba(72, 187, 120, .15);
                    color: var(--green);
                }

                .mode-btn.broken {
                    background: rgba(245, 101, 101, .15);
                    color: var(--red);
                }

                .mode-btn.maintenance {
                    background: rgba(237, 137, 54, .15);
                    color: var(--amber);
                }

                .mode-btn .dot {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                }

                .mode-btn.available .dot {
                    background: var(--green);
                }

                .mode-btn.broken .dot {
                    background: var(--red);
                }

                .mode-btn.maintenance .dot {
                    background: var(--amber);
                }

                .btn-orange {
                    background: var(--orange);
                    color: white;
                    border: none;
                    border-radius: 10px;
                    padding: 11px 26px;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .25s;
                }

                .btn-orange:hover {
                    background: #ff9550;
                    transform: translateY(-2px);
                    box-shadow: 0 6px 18px rgba(232, 116, 42, .4);
                }

                .btn-ghost {
                    background: transparent;
                    color: var(--text-muted);
                    border: 1.5px solid var(--border);
                    border-radius: 10px;
                    padding: 10px 20px;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .2s;
                }

                .btn-ghost:hover {
                    border-color: var(--orange);
                    color: var(--orange);
                }

                /* ── Seat grid ───────────────────────────────────────────*/
                .seat-grid-outer {
                    background: var(--bg-card2);
                    border: 1px solid var(--border);
                    border-radius: 14px;
                    padding: 24px;
                    overflow-x: auto;
                }

                .screen-bar {
                    background: linear-gradient(90deg, transparent, #4a5568 20%, #4a5568 80%, transparent);
                    height: 6px;
                    border-radius: 3px;
                    margin: 0 60px 6px;
                }

                .screen-label {
                    text-align: center;
                    font-size: 11px;
                    color: var(--text-muted);
                    letter-spacing: 3px;
                    margin-bottom: 26px;
                }

                .seat-grid-wrapper {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                }

                .col-header-row {
                    display: flex;
                    margin-bottom: 6px;
                }

                .col-spacer {
                    width: 38px;
                }

                .col-lbl {
                    width: 41px;
                    text-align: center;
                    font-size: 11px;
                    font-weight: 700;
                    color: var(--orange);
                }

                .seat-row {
                    display: flex;
                    align-items: center;
                    margin-bottom: 5px;
                }

                .row-lbl {
                    width: 38px;
                    text-align: center;
                    font-size: 14px;
                    font-weight: 700;
                    color: var(--orange);
                }

                .seat {
                    width: 35px;
                    height: 35px;
                    margin: 3px;
                    border-radius: 8px;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 10px;
                    font-weight: 700;
                    color: white;
                    cursor: pointer;
                    transition: all .2s;
                    border: 2px solid transparent;
                    box-shadow: 0 2px 6px rgba(0, 0, 0, .4);
                }

                .seat:hover {
                    transform: scale(1.12);
                }

                .seat.selected {
                    border-color: white;
                    box-shadow: 0 0 0 3px rgba(232, 116, 42, .5);
                }

                .seat-AVAILABLE {
                    background: var(--green);
                }

                .seat-BROKEN {
                    background: var(--red);
                }

                .seat-MAINTENANCE {
                    background: var(--amber);
                }

                /* ── Legend ──────────────────────────────────────────────*/
                .legend {
                    display: flex;
                    gap: 20px;
                    flex-wrap: wrap;
                    justify-content: center;
                    margin-top: 22px;
                    padding: 16px;
                    background: var(--orange-dim);
                    border-radius: 10px;
                }

                .legend-item {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 13px;
                    color: var(--text-muted);
                }

                .legend-dot {
                    width: 14px;
                    height: 14px;
                    border-radius: 4px;
                }

                /* ── Empty state ─────────────────────────────────────────*/
                .empty-state {
                    text-align: center;
                    padding: 60px 20px;
                    color: var(--text-muted);
                }

                .empty-state i {
                    font-size: 52px;
                    color: var(--orange);
                    opacity: .4;
                    display: block;
                    margin-bottom: 16px;
                }

                .empty-state p.title {
                    font-size: 16px;
                    color: var(--text);
                }

                /* ── Responsive ──────────────────────────────────────────*/
                @media (max-width: 768px) {
                    main {
                        margin-left: 0;
                        padding: 15px;
                    }

                    .toolbar {
                        flex-direction: column;
                        align-items: stretch;
                    }

                    .stats-row {
                        flex-direction: column;
                    }
                }
            </style>
        </head>

        <body>

            <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
            <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp" />

            <main>
                <div class="container-fluid">

                    <!-- Page Header -->
                    <div class="page-header">
                        <div class="icon-wrap"><i class="fa fa-wrench"></i></div>
                        <div>
                            <h2>Trạng thái Ghế</h2>
                            <p>Đánh dấu ghế bị hỏng hoặc đang bảo trì để ngăn đặt vé</p>
                        </div>
                    </div>

                    <!-- Alerts -->
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success"><i class="fa fa-check-circle me-2"></i>${param.success}</div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger"><i class="fa fa-exclamation-circle me-2"></i>${param.error}
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger"><i class="fa fa-exclamation-circle me-2"></i>${error}</div>
                    </c:if>

                    <!-- Room selector + filter -->
                    <div class="card">
                        <div class="card-title"><i class="fa fa-building"></i> Chọn phòng chiếu</div>

                        <div class="info-box">
                            <i class="fa fa-info-circle"></i>
                            <span>Chọn chế độ (Available / Broken / Maintenance), sau đó <strong
                                    style="color:var(--orange)">click vào ghế</strong> để thay đổi trạng thái. Nhấn
                                <strong style="color:var(--orange)">Lưu thay đổi</strong> để áp dụng.</span>
                        </div>

                        <form method="get"
                            action="${pageContext.request.contextPath}/branch-manager/manage-seat-status">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Phòng chiếu</label>
                                    <select class="form-select" name="roomId" onchange="this.form.submit()">
                                        <option value="">-- Chọn phòng --</option>
                                        <c:forEach var="room" items="${rooms}">
                                            <option value="${room.roomId}" ${selectedRoom !=null &&
                                                selectedRoom.roomId==room.roomId ? 'selected' : '' }>
                                                ${room.roomName} (${room.totalSeats} ghế)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Lọc theo trạng thái</label>
                                    <select class="form-select" name="statusFilter" onchange="this.form.submit()">
                                        <option value="">Tất cả</option>
                                        <option value="AVAILABLE" ${statusFilter=='AVAILABLE' ? 'selected' : '' }>
                                            Available</option>
                                        <option value="BROKEN" ${statusFilter=='BROKEN' ? 'selected' : '' }>Broken
                                        </option>
                                        <option value="MAINTENANCE" ${statusFilter=='MAINTENANCE' ? 'selected' : '' }>
                                            Maintenance</option>
                                    </select>
                                </div>
                                <c:if test="${selectedRoom != null}">
                                    <input type="hidden" name="roomId" value="${selectedRoom.roomId}">
                                </c:if>
                            </div>
                        </form>
                    </div>

                    <!-- Seat editor (room selected + seats exist) -->
                    <c:if test="${selectedRoom != null && seats != null && !seats.isEmpty()}">

                        <!-- Stats -->
                        <div class="stats-row">
                            <c:set var="cntA" value="0" />
                            <c:set var="cntB" value="0" />
                            <c:set var="cntM" value="0" />
                            <c:forEach var="s" items="${seats}">
                                <c:if test="${s.status == 'AVAILABLE'}">
                                    <c:set var="cntA" value="${cntA + 1}" />
                                </c:if>
                                <c:if test="${s.status == 'BROKEN'}">
                                    <c:set var="cntB" value="${cntB + 1}" />
                                </c:if>
                                <c:if test="${s.status == 'MAINTENANCE'}">
                                    <c:set var="cntM" value="${cntM + 1}" />
                                </c:if>
                            </c:forEach>
                            <div class="stat-badge available">
                                <div class="stat-dot" style="background:var(--green)"></div>
                                Available: ${cntA}
                            </div>
                            <div class="stat-badge broken">
                                <div class="stat-dot" style="background:var(--red)"></div>
                                Broken: ${cntB}
                            </div>
                            <div class="stat-badge maintenance">
                                <div class="stat-dot" style="background:var(--amber)"></div>
                                Maintenance: ${cntM}
                            </div>
                        </div>

                        <div class="card">
                            <!-- Toolbar -->
                            <div class="toolbar">
                                <span class="toolbar-label"><i class="fa fa-hand-o-up me-1"></i>Chế độ click:</span>
                                <button type="button" class="mode-btn available" onclick="setMode('AVAILABLE')">
                                    <div class="dot"></div> Available
                                </button>
                                <button type="button" class="mode-btn broken" onclick="setMode('BROKEN')">
                                    <div class="dot"></div> Broken
                                </button>
                                <button type="button" class="mode-btn maintenance" onclick="setMode('MAINTENANCE')">
                                    <div class="dot"></div> Maintenance
                                </button>
                                <div class="ms-auto" style="display:flex; gap:10px; flex-wrap:wrap;">
                                    <button type="button" class="btn-ghost" onclick="clearSelection()">
                                        <i class="fa fa-times me-1"></i>Bỏ chọn
                                    </button>
                                    <button type="button" class="btn-orange" onclick="saveChanges()">
                                        <i class="fa fa-save me-1"></i>Lưu thay đổi
                                    </button>
                                </div>
                            </div>

                            <!-- Counter -->
                            <div style="margin-bottom:14px; font-size:13px; color:var(--text-muted);">
                                <i class="fa fa-info-circle me-1" style="color:var(--orange)"></i>
                                Đã chọn: <strong id="selCount" style="color:var(--orange)">0</strong> ghế —
                                Chế độ: <strong id="modeLabel" style="color:var(--orange)">AVAILABLE</strong>
                            </div>

                            <!-- Grid -->
                            <div class="seat-grid-outer">
                                <div class="screen-bar"></div>
                                <div class="screen-label">MÀN HÌNH</div>
                                <div class="seat-grid-wrapper">
                                    <jsp:useBean id="seatMap" class="java.util.HashMap" scope="page" />
                                    <jsp:useBean id="rowSet" class="java.util.TreeSet" scope="page" />
                                    <jsp:useBean id="colSet" class="java.util.TreeSet" scope="page" />
                                    <c:forEach var="seat" items="${seats}">
                                        <c:set target="${seatMap}" property="${seat.rowNumber}-${seat.seatNumber}"
                                            value="${seat}" />
                                        <c:set var="ra" value="${rowSet.add(seat.rowNumber)}" />
                                        <c:set var="ca" value="${colSet.add(seat.seatNumber)}" />
                                    </c:forEach>

                                    <!-- Col labels -->
                                    <div class="col-header-row">
                                        <div class="col-spacer"></div>
                                        <c:forEach var="col" items="${colSet}">
                                            <div class="col-lbl">${col}</div>
                                        </c:forEach>
                                    </div>

                                    <!-- Seats -->
                                    <c:forEach var="row" items="${rowSet}">
                                        <div class="seat-row">
                                            <div class="row-lbl">${row}</div>
                                            <c:forEach var="col" items="${colSet}">
                                                <c:set var="s" value="${seatMap[row.concat('-').concat(col)]}" />
                                                <c:if test="${s != null}">
                                                    <div class="seat seat-${s.status}" data-seat-id="${s.seatId}"
                                                        data-seat-status="${s.status}" onclick="toggleSeat(this)"
                                                        title="${s.seatCode} — ${s.status} (${s.seatType})">
                                                        ${s.seatCode}
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Legend -->
                                <div class="legend">
                                    <div class="legend-item">
                                        <div class="legend-dot" style="background:var(--green)"></div>
                                        Available — Sẵn sàng đặt vé
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-dot" style="background:var(--red)"></div>
                                        Broken — Ghế hỏng
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-dot" style="background:var(--amber)"></div>
                                        Maintenance — Đang bảo trì
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Empty: filter returned nothing -->
                    <c:if test="${selectedRoom != null && (seats == null || seats.isEmpty())}">
                        <div class="card">
                            <div class="empty-state">
                                <i class="fa fa-filter"></i>
                                <c:choose>
                                    <c:when test="${not empty statusFilter}">
                                        <p class="title">Không tìm thấy ghế với trạng thái "${statusFilter}".</p>
                                        <p style="font-size:13px;">Thay đổi bộ lọc hoặc chọn phòng khác.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="title">Phòng này chưa có ghế.</p>
                                        <p style="font-size:13px;">Hãy cấu hình sơ đồ ghế trong mục <strong>Cấu hình Sơ
                                                đồ Ghế</strong> trước.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>

                    <!-- No rooms -->
                    <c:if test="${selectedRoom == null && (rooms == null || rooms.isEmpty())}">
                        <div class="card">
                            <div class="empty-state">
                                <i class="fa fa-building"></i>
                                <p class="title">Chưa có phòng chiếu nào.</p>
                            </div>
                        </div>
                    </c:if>

                </div>
            </main>

            <!-- Hidden bulk-update form -->
            <form id="bulkForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/manage-seat-status" style="display:none;">
                <input type="hidden" name="action" value="updateBulk">
                <input type="hidden" name="roomId" value="${selectedRoom != null ? selectedRoom.roomId : ''}">
                <input type="hidden" name="status" id="bulkStatus">
                <div id="seatIdsContainer"></div>
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                let selectedSeats = new Set();
                let clickMode = 'AVAILABLE';

                document.addEventListener('DOMContentLoaded', () => {
                    const toggle = document.getElementById('sidebarToggle');
                    if (toggle) toggle.addEventListener('click', () => document.body.classList.toggle('sidebar-collapsed'));
                    setTimeout(() => {
                        document.querySelectorAll('.alert').forEach(el => {
                            try { new bootstrap.Alert(el).close(); } catch (e) { }
                        });
                    }, 5000);
                    setMode('AVAILABLE');
                });

                function setMode(mode) {
                    clickMode = mode;
                    document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
                    const map = { AVAILABLE: 'available', BROKEN: 'broken', MAINTENANCE: 'maintenance' };
                    document.querySelector('.mode-btn.' + map[mode])?.classList.add('active');
                    document.getElementById('modeLabel').textContent = mode;
                }

                function toggleSeat(el) {
                    const id = el.getAttribute('data-seat-id');
                    if (selectedSeats.has(id)) {
                        selectedSeats.delete(id);
                        el.classList.remove('selected');
                        const original = el.getAttribute('data-seat-status');
                        el.classList.remove('seat-AVAILABLE', 'seat-BROKEN', 'seat-MAINTENANCE');
                        el.classList.add('seat-' + original);
                    } else {
                        selectedSeats.add(id);
                        el.classList.add('selected');
                        el.classList.remove('seat-AVAILABLE', 'seat-BROKEN', 'seat-MAINTENANCE');
                        el.classList.add('seat-' + clickMode);
                    }
                    document.getElementById('selCount').textContent = selectedSeats.size;
                }

                function clearSelection() {
                    document.querySelectorAll('.seat.selected').forEach(el => {
                        el.classList.remove('selected');
                        const orig = el.getAttribute('data-seat-status');
                        el.classList.remove('seat-AVAILABLE', 'seat-BROKEN', 'seat-MAINTENANCE');
                        el.classList.add('seat-' + orig);
                    });
                    selectedSeats.clear();
                    document.getElementById('selCount').textContent = 0;
                }

                function saveChanges() {
                    if (!selectedSeats.size) { alert('Hãy chọn ít nhất một ghế.'); return; }
                    const modeViMap = { AVAILABLE: 'Khả dụng', BROKEN: 'Hỏng', MAINTENANCE: 'Bảo trì' };
                    if (!confirm(`Cập nhật ${selectedSeats.size} ghế → ${modeViMap[clickMode] || clickMode}?`)) return;

                    const container = document.getElementById('seatIdsContainer');
                    container.innerHTML = '';
                    selectedSeats.forEach(id => {
                        const inp = document.createElement('input');
                        inp.type = 'hidden'; inp.name = 'seatIds[]'; inp.value = id;
                        container.appendChild(inp);
                    });
                    document.getElementById('bulkStatus').value = clickMode;
                    document.getElementById('bulkForm').submit();
                }
            </script>
        </body>

        </html>