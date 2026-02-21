<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Cấu hình Sơ đồ Ghế - Branch Manager</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
            <style>
                :root {
                    --bg-dark: #0c121d;
                    --bg-card: #141b27;
                    --bg-card2: #1a2436;
                    --border: #2a3547;
                    --orange: #e8742a;
                    --orange-dim: rgba(232, 116, 42, 0.15);
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

                /* ── Page header ─────────────────────────────────────── */
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
                    color: var(--text);
                }

                .page-header p {
                    font-size: 13px;
                    color: var(--text-muted);
                    margin-top: 2px;
                }

                /* ── Alert ───────────────────────────────────────────── */
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

                /* ── Card ────────────────────────────────────────────── */
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
                    color: var(--text);
                    margin-bottom: 20px;
                }

                .card-title i {
                    color: var(--orange);
                }

                /* ── Form controls ───────────────────────────────────── */
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
                    width: 100%;
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

                .form-control.small-input {
                    width: 100px;
                    text-align: center;
                    font-size: 20px;
                    font-weight: 700;
                }

                small.hint {
                    font-size: 12px;
                    color: var(--text-muted);
                    margin-top: 4px;
                    display: block;
                }

                /* ── Room info strip ─────────────────────────────────── */
                .room-info-strip {
                    background: var(--orange-dim);
                    border: 1px solid rgba(232, 116, 42, .3);
                    border-radius: 10px;
                    padding: 14px 18px;
                    display: flex;
                    align-items: center;
                    gap: 14px;
                    margin-bottom: 22px;
                }

                .room-info-strip i {
                    color: var(--orange);
                    font-size: 18px;
                }

                .room-info-strip strong {
                    color: var(--orange);
                }

                .room-info-strip span {
                    color: var(--text-muted);
                    font-size: 13px;
                }

                /* ── Dimension controls ──────────────────────────────── */
                .dim-row {
                    display: flex;
                    align-items: flex-end;
                    gap: 20px;
                    flex-wrap: wrap;
                    margin-bottom: 20px;
                }

                .dim-group {
                    display: flex;
                    flex-direction: column;
                }

                .dim-stepper {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .step-btn {
                    width: 36px;
                    height: 36px;
                    border-radius: 8px;
                    border: 1.5px solid var(--border);
                    background: var(--bg-dark);
                    color: var(--text);
                    font-size: 18px;
                    font-weight: 700;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    transition: all .2s;
                }

                .step-btn:hover {
                    border-color: var(--orange);
                    color: var(--orange);
                }

                /* ── Buttons ─────────────────────────────────────────── */
                .btn-orange {
                    background: var(--orange);
                    color: white;
                    border: none;
                    border-radius: 10px;
                    padding: 11px 24px;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .25s;
                    white-space: nowrap;
                }

                .btn-orange:hover {
                    background: #ff9550;
                    transform: translateY(-2px);
                    box-shadow: 0 6px 18px rgba(232, 116, 42, .4);
                }

                .btn-danger {
                    background: var(--red);
                    color: white;
                    border: none;
                    border-radius: 10px;
                    padding: 11px 24px;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .25s;
                }

                .btn-danger:hover {
                    background: #e53e3e;
                    transform: translateY(-2px);
                }

                .btn-ghost {
                    background: transparent;
                    color: var(--text-muted);
                    border: 1.5px solid var(--border);
                    border-radius: 10px;
                    padding: 11px 24px;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all .2s;
                }

                .btn-ghost:hover {
                    border-color: var(--orange);
                    color: var(--orange);
                }

                /* ── Live preview area ───────────────────────────────── */
                .preview-section {
                    background: var(--bg-card2);
                    border: 1px solid var(--border);
                    border-radius: 16px;
                    padding: 28px;
                    overflow-x: auto;
                }

                .preview-title {
                    font-size: 13px;
                    font-weight: 700;
                    color: var(--text-muted);
                    letter-spacing: .8px;
                    text-transform: uppercase;
                    margin-bottom: 20px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .preview-title .dot {
                    width: 8px;
                    height: 8px;
                    border-radius: 50%;
                    background: var(--orange);
                    box-shadow: 0 0 6px var(--orange);
                    animation: pulse 1.5s infinite;
                }

                @keyframes pulse {

                    0%,
                    100% {
                        opacity: 1;
                    }

                    50% {
                        opacity: .4;
                    }
                }

                /* Screen */
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
                    margin-bottom: 28px;
                }

                /* Grid */
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
                    width: 34px;
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

                .seat-cell {
                    width: 34px;
                    height: 34px;
                    margin: 2px;
                    border-radius: 7px;
                    background: var(--green);
                    box-shadow: 0 2px 6px rgba(0, 0, 0, .4);
                    opacity: .85;
                    transition: transform .15s, opacity .15s;
                }

                .seat-cell:hover {
                    transform: scale(1.15);
                    opacity: 1;
                }

                /* Stats */
                .stats-row {
                    display: flex;
                    gap: 16px;
                    flex-wrap: wrap;
                    justify-content: center;
                    margin-top: 22px;
                }

                .stat-chip {
                    background: var(--bg-dark);
                    border: 1px solid var(--border);
                    border-radius: 20px;
                    padding: 6px 16px;
                    font-size: 13px;
                    font-weight: 600;
                    color: var(--text-muted);
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .stat-chip span {
                    color: var(--orange);
                    font-size: 16px;
                }

                /* ── Existing seat display ───────────────────────────── */
                .seat-existing {
                    width: 34px;
                    height: 34px;
                    margin: 2px;
                    border-radius: 7px;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 10px;
                    font-weight: 700;
                    color: white;
                    box-shadow: 0 2px 6px rgba(0, 0, 0, .4);
                    transition: transform .15s;
                }

                .seat-existing:hover {
                    transform: scale(1.1);
                }

                .seat-existing.NORMAL {
                    background: var(--green);
                }

                .seat-existing.VIP {
                    background: var(--amber);
                }

                .seat-existing.COUPLE {
                    background: var(--red);
                }

                .legend {
                    display: flex;
                    gap: 18px;
                    flex-wrap: wrap;
                    justify-content: center;
                    margin-top: 20px;
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

                /* ── Responsive ──────────────────────────────────────── */
                @media (max-width: 768px) {
                    main {
                        margin-left: 0;
                        padding: 15px;
                    }

                    .dim-row {
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
                        <div class="icon-wrap"><i class="fa fa-th"></i></div>
                        <div>
                            <h2>Cấu hình Sơ đồ Ghế</h2>
                            <p>Thiết kế ma trận ghế (hàng × cột) cho từng phòng chiếu</p>
                        </div>
                    </div>

                    <!-- Alerts -->
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success">
                            <i class="fa fa-check-circle me-2"></i>${param.success}
                        </div>
                    </c:if>
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger">
                            <i class="fa fa-exclamation-circle me-2"></i>${param.error}
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <i class="fa fa-exclamation-circle me-2"></i>${error}
                        </div>
                    </c:if>

                    <!-- Room Selection -->
                    <div class="card">
                        <div class="card-title"><i class="fa fa-building"></i> Chọn phòng chiếu</div>
                        <form method="get"
                            action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout">
                            <div class="mb-1">
                                <label class="form-label">Phòng chiếu</label>
                                <select class="form-select" name="roomId" onchange="this.form.submit()">
                                    <option value="">-- Chọn một phòng --</option>
                                    <c:forEach var="room" items="${rooms}">
                                        <option value="${room.roomId}" ${selectedRoom !=null &&
                                            selectedRoom.roomId==room.roomId ? 'selected' : '' }>
                                            ${room.roomName}
                                            (${room.totalSeats} ghế)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </form>
                    </div>

                    <!-- Layout configurator (only when room selected) -->
                    <c:if test="${selectedRoom != null}">

                        <!-- Room info strip -->
                        <div class="room-info-strip">
                            <i class="fa fa-film"></i>
                            <div>
                                <strong>${selectedRoom.roomName}</strong>
                                <span> — Chi nhánh: ${branch.branchName} &nbsp;|&nbsp; Hiện có: ${existingSeats != null
                                    ? existingSeats.size() : 0} ghế</span>
                            </div>
                        </div>

                        <!-- Configuration + live preview -->
                        <div class="card">
                            <div class="card-title"><i class="fa fa-cogs"></i> Cấu hình kích thước</div>

                            <form method="post"
                                action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout"
                                id="generateForm" onsubmit="return confirmGenerate()">
                                <input type="hidden" name="action" value="generate">
                                <input type="hidden" name="roomId" value="${selectedRoom.roomId}">

                                <div class="dim-row">
                                    <!-- Rows -->
                                    <div class="dim-group">
                                        <label class="form-label"><i class="fa fa-arrows-v me-1"
                                                style="color:var(--orange)"></i>Số hàng (A–Z)</label>
                                        <div class="dim-stepper">
                                            <button type="button" class="step-btn"
                                                onclick="adjust('rows',-1)">−</button>
                                            <input type="number" class="form-control small-input" id="rows" name="rows"
                                                min="1" max="26" value="5" required oninput="updatePreview()">
                                            <button type="button" class="step-btn" onclick="adjust('rows',1)">+</button>
                                        </div>
                                        <small class="hint">Tối đa 26 hàng (A→Z)</small>
                                    </div>

                                    <!-- Columns -->
                                    <div class="dim-group">
                                        <label class="form-label"><i class="fa fa-arrows-h me-1"
                                                style="color:var(--orange)"></i>Số cột</label>
                                        <div class="dim-stepper">
                                            <button type="button" class="step-btn"
                                                onclick="adjust('cols',-1)">−</button>
                                            <input type="number" class="form-control small-input" id="columns"
                                                name="columns" min="1" max="30" value="10" required
                                                oninput="updatePreview()">
                                            <button type="button" class="step-btn" onclick="adjust('cols',1)">+</button>
                                        </div>
                                        <small class="hint">Tối đa 30 cột</small>
                                    </div>

                                    <!-- Actions -->
                                    <div class="dim-group" style="flex:1; align-items:flex-end;">
                                        <div style="display:flex; gap:10px; flex-wrap:wrap;">
                                            <button type="submit" class="btn-orange">
                                                <i class="fa fa-magic me-2"></i>Tạo sơ đồ ghế
                                            </button>
                                            <c:if test="${existingSeats != null && !existingSeats.isEmpty()}">
                                                <button type="button" class="btn-danger"
                                                    data-roomid="${selectedRoom.roomId}"
                                                    onclick="clearLayout(parseInt(this.getAttribute('data-roomid')))">
                                                    <i class="fa fa-trash me-2"></i>Xóa sơ đồ
                                                </button>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </form>

                            <!-- Live Preview -->
                            <div class="preview-section" id="previewSection">
                                <div class="preview-title">
                                    <div class="dot"></div> Xem trước sơ đồ ghế
                                </div>
                                <div class="screen-bar"></div>
                                <div class="screen-label">MÀN HÌNH</div>
                                <div class="seat-grid-wrapper" id="livePreviewGrid"></div>
                                <div class="stats-row" id="previewStats"></div>
                            </div>
                        </div>

                        <!-- Existing seats display -->
                        <c:if test="${existingSeats != null && !existingSeats.isEmpty()}">
                            <div class="card">
                                <div class="card-title"><i class="fa fa-check-circle"></i> Sơ đồ ghế hiện tại</div>
                                <div class="preview-section" style="background:var(--bg-dark);">
                                    <div class="screen-bar"></div>
                                    <div class="screen-label">MÀN HÌNH</div>

                                    <div class="seat-grid-wrapper">
                                        <jsp:useBean id="seatMap" class="java.util.HashMap" scope="page" />
                                        <jsp:useBean id="rowSet" class="java.util.TreeSet" scope="page" />
                                        <jsp:useBean id="colSet" class="java.util.TreeSet" scope="page" />
                                        <c:forEach var="seat" items="${existingSeats}">
                                            <c:set target="${seatMap}" property="${seat.rowNumber}-${seat.seatNumber}"
                                                value="${seat}" />
                                            <c:set var="a1" value="${rowSet.add(seat.rowNumber)}" />
                                            <c:set var="a2" value="${colSet.add(seat.seatNumber)}" />
                                        </c:forEach>

                                        <!-- Col header -->
                                        <div class="col-header-row">
                                            <div class="col-spacer"></div>
                                            <c:forEach var="col" items="${colSet}">
                                                <div class="col-lbl">${col}</div>
                                            </c:forEach>
                                        </div>

                                        <!-- Rows -->
                                        <c:forEach var="row" items="${rowSet}">
                                            <div class="seat-row">
                                                <div class="row-lbl">${row}</div>
                                                <c:forEach var="col" items="${colSet}">
                                                    <c:set var="s" value="${seatMap[row.concat('-').concat(col)]}" />
                                                    <c:if test="${s != null}">
                                                        <div class="seat-existing ${s.seatType}"
                                                            title="${s.seatCode} — ${s.seatType}"></div>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <div class="legend">
                                        <div class="legend-item">
                                            <div class="legend-dot" style="background:var(--green)"></div> Standard
                                        </div>
                                        <div class="legend-item">
                                            <div class="legend-dot" style="background:var(--amber)"></div> VIP
                                        </div>
                                        <div class="legend-item">
                                            <div class="legend-dot" style="background:var(--red)"></div> Couple
                                        </div>
                                    </div>

                                    <div class="stats-row">
                                        <div class="stat-chip"><i class="fa fa-ticket" style="color:var(--orange)"></i>
                                            Tổng ghế: <span>${existingSeats.size()}</span></div>
                                        <div class="stat-chip"><i class="fa fa-th" style="color:var(--orange)"></i> Kích
                                            thước: <span>${rowSet.size()} × ${colSet.size()}</span></div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                    </c:if>

                    <!-- No rooms -->
                    <c:if test="${selectedRoom == null && (rooms == null || rooms.isEmpty())}">
                        <div class="card" style="text-align:center; padding:60px 20px; color:var(--text-muted)">
                            <i class="fa fa-building"
                                style="font-size:56px; color:var(--orange); opacity:.5; margin-bottom:16px; display:block;"></i>
                            <p style="font-size:16px; color:var(--text)">Chưa có phòng chiếu nào.</p>
                            <p style="font-size:13px;">Hãy tạo phòng chiếu trong mục <strong>Quản lý phòng
                                    chiếu</strong> trước.</p>
                        </div>
                    </c:if>

                </div>
            </main>

            <!-- Hidden clear form -->
            <form id="clearForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/configure-seat-layout" style="display:none;">
                <input type="hidden" name="action" value="clear">
                <input type="hidden" name="roomId" id="clearRoomId">
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                // ── Sidebar toggle ──────────────────────────────────────────────────────
                document.addEventListener('DOMContentLoaded', () => {
                    const toggleBtn = document.getElementById('sidebarToggle');
                    if (toggleBtn) toggleBtn.addEventListener('click', () => document.body.classList.toggle('sidebar-collapsed'));

                    // Auto-dismiss alerts
                    setTimeout(() => {
                        document.querySelectorAll('.alert').forEach(el => {
                            try { new bootstrap.Alert(el).close(); } catch (e) { }
                        });
                    }, 5000);

                    updatePreview();
                });

                // ── Stepper ─────────────────────────────────────────────────────────────
                function adjust(field, delta) {
                    const id = field === 'rows' ? 'rows' : 'columns';
                    const max = field === 'rows' ? 26 : 30;
                    const el = document.getElementById(id);
                    let val = parseInt(el.value) || 5;
                    val = Math.max(1, Math.min(max, val + delta));
                    el.value = val;
                    updatePreview();
                }

                // ── Live preview ─────────────────────────────────────────────────────────
                const LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

                function updatePreview() {
                    const rows = Math.max(1, Math.min(26, parseInt(document.getElementById('rows').value) || 5));
                    const cols = Math.max(1, Math.min(30, parseInt(document.getElementById('columns').value) || 10));

                    const grid = document.getElementById('livePreviewGrid');
                    const stats = document.getElementById('previewStats');
                    if (!grid) return;

                    let html = '';

                    // Column header
                    html += '<div class="col-header-row"><div class="col-spacer"></div>';
                    for (let c = 1; c <= cols; c++) html += `<div class="col-lbl">${c}</div>`;
                    html += '</div>';

                    // Rows
                    for (let r = 0; r < rows; r++) {
                        html += `<div class="seat-row"><div class="row-lbl">${LETTERS[r]}</div>`;
                        for (let c = 1; c <= cols; c++) {
                            html += `<div class="seat-cell" title="${LETTERS[r]}${c}"></div>`;
                        }
                        html += '</div>';
                    }

                    grid.innerHTML = html;

                    // Stats
                    stats.innerHTML = `
            <div class="stat-chip"><i class="fa fa-ticket" style="color:var(--orange)"></i> Tổng ghế: <span>${rows * cols}</span></div>
            <div class="stat-chip"><i class="fa fa-arrows-v" style="color:var(--orange)"></i> Hàng: <span>${rows} (A \u2192 ${LETTERS[rows - 1]})</span></div>
            <div class="stat-chip"><i class="fa fa-arrows-h" style="color:var(--orange)"></i> Cột: <span>${cols}</span></div>
        `;
                }

                // ── Confirm generate ─────────────────────────────────────────────────────
                function confirmGenerate() {
                    const rows = document.getElementById('rows').value;
                    const cols = document.getElementById('columns').value;
                    const total = rows * cols;
                    return confirm(`Tạo sơ đồ ghế ${rows} hàng × ${cols} cột = ${total} ghế?\nNếu đã có ghế, sơ đồ cũ sẽ bị xóa và tạo lại.`);
                }

                // ── Clear layout ─────────────────────────────────────────────────────────
                function clearLayout(roomId) {
                    if (!confirm('Bạn chắc chắn muốn xóa toàn bộ ghế trong phòng này? Thao tác không thể hoàn tác!')) return;
                    document.getElementById('clearRoomId').value = roomId;
                    document.getElementById('clearForm').submit();
                }
            </script>
        </body>

        </html>