<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển nhân viên rạp</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }
        .chart-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 12px;
            padding: 24px;
        }
        .chart-card h3 {
            color: #d96c2c;
            font-size: 15px;
            font-weight: 600;
            margin: 0 0 20px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .chart-card.full-width {
            grid-column: 1 / -1;
        }
        .table-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
        }
        .table-card h3 {
            color: #d96c2c;
            font-size: 15px;
            font-weight: 600;
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .data-table th {
            background: #0c121d;
            color: #d96c2c;
            padding: 10px 14px;
            text-align: left;
            font-weight: 600;
            border-bottom: 1px solid #262625;
        }
        .data-table td {
            padding: 10px 14px;
            color: #ccc;
            border-bottom: 1px solid #1e1e1e;
        }
        .data-table tr:last-child td { border-bottom: none; }
        .data-table tr:hover td { background: #222; }
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-scheduled  { background: rgba(59,130,246,.15); color: #60a5fa; }
        .badge-ongoing    { background: rgba(16,185,129,.15); color: #34d399; }
        .badge-completed  { background: rgba(107,114,128,.15); color: #9ca3af; }
        .badge-cancelled  { background: rgba(239,68,68,.15);  color: #f87171; }
        .seat-bar {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .seat-bar-track {
            flex: 1;
            height: 6px;
            background: #2a2a2a;
            border-radius: 3px;
            overflow: hidden;
        }
        .seat-bar-fill {
            height: 100%;
            background: #d96c2c;
            border-radius: 3px;
        }
        .seat-bar-text { font-size: 11px; color: #888; white-space: nowrap; }
        .no-data { color: #666; text-align: center; padding: 40px; font-size: 14px; }
        canvas { max-height: 260px; }
    </style>
</head>
<body>
    <div class="sidebar" id="sidebar">
        <button class="sidebar-toggle" onclick="toggleSidebar()">
            <i class="fas fa-chevron-left"></i>
        </button>
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fas fa-film"></i></div>
            <h3>Nhân viên rạp</h3>
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard" class="active">
                    <i class="fas fa-home"></i><span>Bảng điều khiển</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking">
                    <i class="fas fa-ticket-alt"></i><span>Bán vé tại quầy</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i><span>Lịch làm việc</span>
                </a>
            </li>
        </ul>
        <div class="sidebar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName.substring(0,1).toUpperCase()}
                        </c:when>
                        <c:otherwise><i class="fas fa-user"></i></c:otherwise>
                    </c:choose>
                </div>
                <div class="user-details">
                    <div class="user-name">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.fullName}">${sessionScope.user.fullName}</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Nhân viên rạp</div>
                </div>
            </div>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <h1><i class="fas fa-tachometer-alt"></i> Bảng điều khiển</h1>
            <div class="top-bar-actions">
                <div class="current-time">
                    <i class="fas fa-clock"></i>
                    <span id="currentDateTime"></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>

        <div class="welcome-section">
            <h2>Chào mừng,
                <c:choose>
                    <c:when test="${not empty sessionScope.user.fullName}">${sessionScope.user.fullName}</c:when>
                    <c:otherwise>Nhân viên</c:otherwise>
                </c:choose>!
            </h2>
            <p>Dữ liệu hôm nay tại chi nhánh của bạn.</p>
        </div>

        <c:choose>
        <c:when test="${noBranch}">
            <div class="table-card">
                <p class="no-data"><i class="fas fa-exclamation-triangle"></i> Tài khoản chưa được gán chi nhánh. Vui lòng liên hệ quản lý.</p>
            </div>
        </c:when>
        <c:otherwise>

        <%-- Charts row --%>
        <div class="dashboard-grid">
            <div class="chart-card">
                <h3><i class="fas fa-clock"></i> Vé bán theo giờ hôm nay</h3>
                <canvas id="chartHour"></canvas>
            </div>
            <div class="chart-card">
                <h3><i class="fas fa-chart-line"></i> Doanh thu 7 ngày gần nhất</h3>
                <canvas id="chartRevenue"></canvas>
            </div>
            <div class="chart-card full-width">
                <h3><i class="fas fa-fire"></i> Top 5 phim bán chạy nhất (quầy)</h3>
                <canvas id="chartMovies"></canvas>
            </div>
        </div>

        <%-- Today showtimes table --%>
        <div class="table-card">
            <h3><i class="fas fa-film"></i> Suất chiếu hôm nay</h3>
            <c:choose>
            <c:when test="${empty todayShowtimes}">
                <p class="no-data">Không có suất chiếu nào hôm nay.</p>
            </c:when>
            <c:otherwise>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Phim</th>
                        <th>Phòng</th>
                        <th>Giờ chiếu</th>
                        <th>Trạng thái</th>
                        <th>Ghế đã bán / Tổng</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${todayShowtimes}" var="st">
                    <tr>
                        <td>${st.movieTitle}</td>
                        <td>${st.roomName}</td>
                        <td>${st.startTime} – ${st.endTime}</td>
                        <td>
                            <c:choose>
                                <c:when test="${st.status == 'SCHEDULED'}"><span class="badge badge-scheduled">Đã lên lịch</span></c:when>
                                <c:when test="${st.status == 'ONGOING'}"><span class="badge badge-ongoing">Đang chiếu</span></c:when>
                                <c:when test="${st.status == 'COMPLETED'}"><span class="badge badge-completed">Đã kết thúc</span></c:when>
                                <c:otherwise><span class="badge badge-cancelled">${st.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="seat-bar">
                                <div class="seat-bar-track">
                                    <c:set var="pct" value="${st.totalSeats > 0 ? st.soldSeats * 100 / st.totalSeats : 0}"/>
                                    <div class="seat-bar-fill" style="width:${pct}%"></div>
                                </div>
                                <span class="seat-bar-text">${st.soldSeats}/${st.totalSeats}</span>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                </tbody>
            </table>
            </c:otherwise>
            </c:choose>
        </div>

        <%-- Recent transactions table --%>
        <div class="table-card">
            <h3><i class="fas fa-receipt"></i> Giao dịch gần nhất (quầy)</h3>
            <c:choose>
            <c:when test="${empty recentTransactions}">
                <p class="no-data">Chưa có giao dịch nào.</p>
            </c:when>
            <c:otherwise>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Phim</th>
                        <th>Khách hàng</th>
                        <th>SĐT</th>
                        <th>Loại vé</th>
                        <th>Loại ghế</th>
                        <th>Giá (VND)</th>
                        <th>Thanh toán</th>
                        <th>Thời gian</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${recentTransactions}" var="tx">
                    <tr>
                        <td>${tx.ticketId}</td>
                        <td>${tx.movieTitle}</td>
                        <td>${tx.customerName}</td>
                        <td>${not empty tx.customerPhone ? tx.customerPhone : '—'}</td>
                        <td>${tx.ticketType}</td>
                        <td>${tx.seatType}</td>
                        <td><fmt:formatNumber value="${tx.price}" type="number" maxFractionDigits="0"/></td>
                        <td>${tx.paymentMethod}</td>
                        <td>${tx.soldAt}</td>
                    </tr>
                    </c:forEach>
                </tbody>
            </table>
            </c:otherwise>
            </c:choose>
        </div>

        </c:otherwise>
        </c:choose>
    </div>

    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
            const icon = document.querySelector('.sidebar-toggle i');
            icon.className = sidebar.classList.contains('collapsed') ? 'fas fa-chevron-right' : 'fas fa-chevron-left';
        }

        function updateDateTime() {
            document.getElementById('currentDateTime').textContent =
                new Date().toLocaleDateString('vi-VN', {
                    weekday:'long', year:'numeric', month:'long', day:'numeric',
                    hour:'2-digit', minute:'2-digit', second:'2-digit'
                });
        }
        updateDateTime();
        setInterval(updateDateTime, 1000);

        <c:if test="${not noBranch}">
        const chartDefaults = {
            plugins: { legend: { display: false } },
            scales: {
                x: { ticks: { color: '#888' }, grid: { color: '#1e1e1e' } },
                y: { ticks: { color: '#888' }, grid: { color: '#1e1e1e' } }
            }
        };

        // --- Chart 1: tickets by hour today ---
        (function() {
            const raw = ${ticketsByHourJson};
            const labels = [], data = [];
            for (let h = 7; h <= 23; h++) {
                labels.push(h + ':00');
                const found = raw.find(r => r.hour === h);
                data.push(found ? found.count : 0);
            }
            new Chart(document.getElementById('chartHour'), {
                type: 'bar',
                data: {
                    labels,
                    datasets: [{
                        label: 'Vé bán',
                        data,
                        backgroundColor: 'rgba(217,108,44,0.7)',
                        borderRadius: 4
                    }]
                },
                options: { ...chartDefaults, plugins: { legend: { display: false } } }
            });
        })();

        // --- Chart 2: revenue last 7 days ---
        (function() {
            const raw = ${revenueLast7Json};
            const labels = raw.map(r => {
                const d = new Date(r.date);
                return (d.getDate()) + '/' + (d.getMonth()+1);
            });
            const data = raw.map(r => r.revenue);
            new Chart(document.getElementById('chartRevenue'), {
                type: 'line',
                data: {
                    labels,
                    datasets: [{
                        label: 'Doanh thu (VND)',
                        data,
                        borderColor: '#d96c2c',
                        backgroundColor: 'rgba(217,108,44,0.1)',
                        fill: true,
                        tension: 0.3,
                        pointBackgroundColor: '#d96c2c'
                    }]
                },
                options: {
                    ...chartDefaults,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { ticks: { color: '#888' }, grid: { color: '#1e1e1e' } },
                        y: { ticks: { color: '#888', callback: v => (v/1000).toFixed(0)+'K' }, grid: { color: '#1e1e1e' } }
                    }
                }
            });
        })();

        // --- Chart 3: top movies ---
        (function() {
            const raw = ${topMoviesJson};
            const labels = raw.map(r => r.title);
            const data   = raw.map(r => r.tickets);
            new Chart(document.getElementById('chartMovies'), {
                type: 'bar',
                data: {
                    labels,
                    datasets: [{
                        label: 'Số vé bán',
                        data,
                        backgroundColor: [
                            'rgba(217,108,44,0.8)','rgba(59,130,246,0.8)','rgba(16,185,129,0.8)',
                            'rgba(251,191,36,0.8)','rgba(168,85,247,0.8)'
                        ],
                        borderRadius: 4
                    }]
                },
                options: {
                    indexAxis: 'y',
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { ticks: { color: '#888' }, grid: { color: '#1e1e1e' } },
                        y: { ticks: { color: '#ccc' }, grid: { color: '#1e1e1e' } }
                    }
                }
            });
        })();
        </c:if>
    </script>
</body>
</html>
