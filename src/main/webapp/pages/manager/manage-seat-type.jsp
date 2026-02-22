<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Quản lý Loại Ghế - Branch Manager</title>
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

                /* ── Header ──────────────────────────────────────────── */
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
                    margin-bottom: 20px;
                }

                .card-title i {
                    color: var(--orange);
                }

                /* ── Form ────────────────────────────────────────────── */
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

                /* ── Surcharge cards ─────────────────────────────────── */
                .surcharge-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 16px;
                    margin-bottom: 22px;
                }

                .surcharge-card {
                    border-radius: 14px;
                    padding: 20px;
                    border: 2px solid transparent;
                    transition: border-color .2s, transform .2s;
                }

                .surcharge-card:hover {
                    transform: translateY(-2px);
                }

                .surcharge-card.normal {
                    background: rgba(72, 187, 120, .1);
                    border-color: rgba(72, 187, 120, .3);
                }

                .surcharge-card.vip {
                    background: rgba(237, 137, 54, .1);
                    border-color: rgba(237, 137, 54, .3);
                }

                .surcharge-card.couple {
                    background: rgba(245, 101, 101, .1);
                    border-color: rgba(245, 101, 101, .3);
                }

                .surcharge-card-header {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    margin-bottom: 14px;
                }

                .surcharge-type-dot {
                    width: 12px;
                    height: 12px;
                    border-radius: 50%;
                }

                .surcharge-card-header h6 {
                    font-size: 15px;
                    font-weight: 700;
                    margin: 0;
                }

                .surcharge-card-header small {
                    font-size: 12px;
                    color: var(--text-muted);
                }

                .surcharge-input-wrap {
                    position: relative;
                }

                .surcharge-input-wrap input {
                    padding-right: 44px;
                    font-size: 18px;
                    font-weight: 700;
                    text-align: center;
                }

                .surcharge-input-wrap .unit {
                    position: absolute;
                    right: 14px;
                    top: 50%;
                    transform: translateY(-50%);
                    font-size: 16px;
                    font-weight: 700;
                    color: var(--text-muted);
                    pointer-events: none;
                }

                /* ── Save surcharge btn ────────────────────────────────*/
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

                /* ── Seat toolbar ────────────────────────────────────── */
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

                .type-btn {
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

                .type-btn.normal {
                    background: rgba(72, 187, 120, .15);
                    color: var(--green);
                }

                .type-btn.vip {
                    background: rgba(237, 137, 54, .15);
                    color: var(--amber);
                }

                .type-btn.couple {
                    background: rgba(245, 101, 101, .15);
                    color: var(--red);
                }

                .type-btn.active {
                    border-color: var(--orange);
                    box-shadow: 0 0 0 3px rgba(232, 116, 42, .2);
                }

                .type-btn:hover {
                    transform: translateY(-1px);
                }

                .type-btn .dot {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                }

                .type-btn.normal .dot {
                    background: var(--green);
                }

                .type-btn.vip .dot {
                    background: var(--amber);
                }

                .type-btn.couple .dot {
                    background: var(--red);
                }

                /* ── Seat grid ───────────────────────────────────────── */
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

                .seat-NORMAL {
                    background: var(--green);
                }

                .seat-VIP {
                    background: var(--amber);
                }

                .seat-COUPLE {
                    background: var(--red);
                }

                /* ── Legend ──────────────────────────────────────────── */
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

                /* ── Responsive ──────────────────────────────────────── */
                @media (max-width: 768px) {
                    main {
                        margin-left: 0;
                        padding: 15px;
                    }

                    .toolbar {
                        flex-direction: column;
                        align-items: stretch;
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
                        <div class="icon-wrap"><i class="fa fa-cogs"></i></div>
                        <div>
                            <h2>Quản lý Loại Ghế</h2>
                            <p>Cấu hình phụ phí theo loại ghế và phân loại từng ghế trong phòng</p>
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

                    <!-- ────────────────────────────────────────────────────────────────────── -->
                    <!-- SECTION 1 — Surcharge Rate Configuration                              -->
                    <!-- ────────────────────────────────────────────────────────────────────── -->
                    <div class="card">
                        <div class="card-title"><i class="fa fa-percent"></i> Cấu hình phụ phí theo loại ghế</div>
                        <p style="font-size:13px; color:var(--text-muted); margin-bottom:20px;">
                            Phụ phí (%) được cộng thêm vào giá cơ bản của suất chiếu.
                            Ví dụ: ghế VIP +50% → giá cơ sở 100.000đ thành 150.000đ.
                        </p>

                        <form method="post" action="${pageContext.request.contextPath}/branch-manager/manage-seat-type">
                            <input type="hidden" name="action" value="updateSurcharge">

                            <div class="surcharge-grid">
                                <!-- NORMAL -->
                                <div class="surcharge-card normal">
                                    <div class="surcharge-card-header">
                                        <div class="surcharge-type-dot" style="background:var(--green)"></div>
                                        <div>
                                            <h6>Standard (Normal)</h6>
                                            <small>Ghế thường</small>
                                        </div>
                                    </div>
                                    <div class="surcharge-input-wrap">
                                        <input type="number" class="form-control" name="rateNORMAL" id="rateNORMAL"
                                            min="0" max="500" step="0.5"
                                            value="${surchargeMap != null && surchargeMap.containsKey('NORMAL') ? surchargeMap['NORMAL'] : 0}"
                                            placeholder="0">
                                        <span class="unit">%</span>
                                    </div>
                                </div>

                                <!-- VIP -->
                                <div class="surcharge-card vip">
                                    <div class="surcharge-card-header">
                                        <div class="surcharge-type-dot" style="background:var(--amber)"></div>
                                        <div>
                                            <h6>VIP</h6>
                                            <small>Ghế cao cấp</small>
                                        </div>
                                    </div>
                                    <div class="surcharge-input-wrap">
                                        <input type="number" class="form-control" name="rateVIP" id="rateVIP" min="0"
                                            max="500" step="0.5"
                                            value="${surchargeMap != null && surchargeMap.containsKey('VIP') ? surchargeMap['VIP'] : 0}"
                                            placeholder="0">
                                        <span class="unit">%</span>
                                    </div>
                                </div>

                                <!-- COUPLE -->
                                <div class="surcharge-card couple">
                                    <div class="surcharge-card-header">
                                        <div class="surcharge-type-dot" style="background:var(--red)"></div>
                                        <div>
                                            <h6>Couple</h6>
                                            <small>Ghế đôi</small>
                                        </div>
                                    </div>
                                    <div class="surcharge-input-wrap">
                                        <input type="number" class="form-control" name="rateCOUPLE" id="rateCOUPLE"
                                            min="0" max="500" step="0.5"
                                            value="${surchargeMap != null && surchargeMap.containsKey('COUPLE') ? surchargeMap['COUPLE'] : 0}"
                                            placeholder="0">
                                        <span class="unit">%</span>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn-orange">
                                <i class="fa fa-save me-2"></i>Lưu phụ phí
                            </button>
                        </form>
                    </div>

                    <!-- ────────────────────────────────────────────────────────────────────── -->
                    <!-- SECTION 2 — Seat Type Editor                                          -->
                    <!-- ────────────────────────────────────────────────────────────────────── -->
                    <div class="card">
                        <div class="card-title"><i class="fa fa-th"></i> Phân loại ghế theo phòng</div>

                        <!-- Room selector -->
                        <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-seat-type">
                            <div class="row g-3 mb-0">
                                <div class="col-md-6">
                                    <label class="form-label">Chọn phòng chiếu</label>
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
                            </div>
                        </form>
                    </div>

                    <!-- Seat editor (shown only when room selected and has seats) -->
                    <c:if test="${selectedRoom != null && seats != null && !seats.isEmpty()}">
                        <div class="card">

                            <!-- Toolbar -->
                            <div class="toolbar">
                                <span class="toolbar-label"><i class="fa fa-hand-o-up me-1"></i>Chế độ click:</span>
                                <button type="button" class="type-btn normal" onclick="setMode('NORMAL')">
                                    <div class="dot"></div> Standard
                                </button>
                                <button type="button" class="type-btn vip" onclick="setMode('VIP')">
                                    <div class="dot"></div> VIP
                                </button>
                                <button type="button" class="type-btn couple" onclick="setMode('COUPLE')">
                                    <div class="dot"></div> Couple
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

                            <!-- Grid -->
                            <div class="seat-grid-outer">
                                <div class="screen-bar"></div>
                                <div class="screen-label">MÀN HÌNH</div>
                                <div class="seat-grid-wrapper">
                                    <jsp:useBean id="seatMap2" class="java.util.HashMap" scope="page" />
                                    <jsp:useBean id="rowSet2" class="java.util.TreeSet" scope="page" />
                                    <jsp:useBean id="colSet2" class="java.util.TreeSet" scope="page" />
                                    <c:forEach var="seat" items="${seats}">
                                        <c:set target="${seatMap2}" property="${seat.rowNumber}-${seat.seatNumber}"
                                            value="${seat}" />
                                        <c:set var="ra" value="${rowSet2.add(seat.rowNumber)}" />
                                        <c:set var="ca" value="${colSet2.add(seat.seatNumber)}" />
                                    </c:forEach>

                                    <!-- Col labels -->
                                    <div class="col-header-row">
                                        <div class="col-spacer"></div>
                                        <c:forEach var="col" items="${colSet2}">
                                            <div class="col-lbl">${col}</div>
                                        </c:forEach>
                                    </div>

                                    <!-- Seats -->
                                    <c:forEach var="row" items="${rowSet2}">
                                        <div class="seat-row">
                                            <div class="row-lbl">${row}</div>
                                            <c:forEach var="col" items="${colSet2}">
                                                <c:set var="s" value="${seatMap2[row.concat('-').concat(col)]}" />
                                                <c:if test="${s != null}">
                                                    <div class="seat seat-${s.seatType}" data-seat-id="${s.seatId}"
                                                        data-seat-type="${s.seatType}" onclick="toggleSeat(this)"
                                                        title="${s.seatCode} — ${s.seatType}">
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
                                        <div class="legend-dot" style="background:var(--green)"></div> Standard (Normal)
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-dot" style="background:var(--amber)"></div> VIP
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-dot" style="background:var(--red)"></div> Couple
                                    </div>
                                </div>
                            </div>

                            <!-- Selection counter -->
                            <div style="margin-top:14px; font-size:13px; color:var(--text-muted);">
                                <i class="fa fa-info-circle me-1" style="color:var(--orange)"></i>
                                Đã chọn: <strong id="selCount" style="color:var(--orange)">0</strong> ghế — Chế độ:
                                <strong id="modeLabel" style="color:var(--orange)">STANDARD</strong>
                            </div>
                        </div>
                    </c:if>

                    <!-- No seats -->
                    <c:if test="${selectedRoom != null && (seats == null || seats.isEmpty())}">
                        <div class="card" style="text-align:center; padding:50px 20px; color:var(--text-muted)">
                            <i class="fa fa-th"
                                style="font-size:52px; color:var(--orange); opacity:.4; margin-bottom:14px; display:block;"></i>
                            <p style="font-size:16px; color:var(--text)">Phòng này chưa có ghế.</p>
                            <p style="font-size:13px;">Hãy cấu hình sơ đồ ghế trong mục <strong>Cấu hình Sơ đồ
                                    Ghế</strong> trước.</p>
                        </div>
                    </c:if>

                    <!-- No rooms -->
                    <c:if test="${selectedRoom == null && (rooms == null || rooms.isEmpty())}">
                        <div class="card" style="text-align:center; padding:50px 20px; color:var(--text-muted)">
                            <i class="fa fa-door-closed"
                                style="font-size:52px; color:var(--orange); opacity:.4; margin-bottom:14px; display:block;"></i>
                            <p style="font-size:16px; color:var(--text)">Chưa có phòng chiếu nào.</p>
                        </div>
                    </c:if>

                </div>
            </main><!-- ─── Hidden bulk-update form ─── -->
            <form id="bulkForm" method="post"
                action="${pageContext.request.contextPath}/branch-manager/manage-seat-type" style="display:none;">
                <input type="hidden" name="action" value="updateBulk">
                <input type="hidden" name="roomId" value="${selectedRoom != null ? selectedRoom.roomId : ''}">
                <input type="hidden" name="seatType" id="bulkSeatType">
                <div id="seatIdsContainer"></div>
            </form>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                let selectedSeats = new Set();
                let clickMode = 'NORMAL';

                document.addEventListener('DOMContentLoaded', () => {
                    const toggle = document.getElementById('sidebarToggle');
                    if (toggle) toggle.addEventListener('click', () => document.body.classList.toggle('sidebar-collapsed'));
                    setTimeout(() => {
                        document.querySelectorAll('.alert').forEach(el => {
                            try { new bootstrap.Alert(el).close(); } catch (e) { }
                        });
                    }, 5000);
                    setMode('NORMAL');
                });

                function setMode(mode) {
                    clickMode = mode;
                    document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
                    const map = { NORMAL: 'normal', VIP: 'vip', COUPLE: 'couple' };
                    document.querySelector('.type-btn.' + map[mode])?.classList.add('active');
                    document.getElementById('modeLabel').textContent = mode;
                }

                function toggleSeat(el) {
                    const id = el.getAttribute('data-seat-id');
                    if (selectedSeats.has(id)) {
                        selectedSeats.delete(id);
                        el.classList.remove('selected');
                        // restore DB type
                        const dbType = el.getAttribute('data-seat-type');
                        el.classList.remove('seat-NORMAL', 'seat-VIP', 'seat-COUPLE');
                        el.classList.add('seat-' + dbType);
                    } else {
                        selectedSeats.add(id);
                        el.classList.add('selected');
                        el.classList.remove('seat-NORMAL', 'seat-VIP', 'seat-COUPLE');
                        el.classList.add('seat-' + clickMode);
                    }
                    document.getElementById('selCount').textContent = selectedSeats.size;
                }

                function clearSelection() {
                    document.querySelectorAll('.seat.selected').forEach(el => {
                        el.classList.remove('selected');
                        const dbType = el.getAttribute('data-seat-type');
                        el.classList.remove('seat-NORMAL', 'seat-VIP', 'seat-COUPLE');
                        el.classList.add('seat-' + dbType);
                    });
                    selectedSeats.clear();
                    document.getElementById('selCount').textContent = 0;
                }

                function saveChanges() {
                    if (!selectedSeats.size) { alert('Hãy chọn ít nhất một ghế.'); return; }
                    if (!confirm(`Cập nhật ${selectedSeats.size} ghế → loại ${clickMode}?`)) return;

                    const container = document.getElementById('seatIdsContainer');
                    container.innerHTML = '';
                    selectedSeats.forEach(id => {
                        const inp = document.createElement('input');
                        inp.type = 'hidden'; inp.name = 'seatIds[]'; inp.value = id;
                        container.appendChild(inp);
                    });
                    document.getElementById('bulkSeatType').value = clickMode;
                    document.getElementById('bulkForm').submit();
                }
            </script>
        </body>

        </html>