<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch làm việc - Nhân viên rạp</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        .shift-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .shift-MORNING   { background: rgba(255,193,7,0.2);  color: #ffc107; }
        .shift-AFTERNOON { background: rgba(33,150,243,0.2); color: #29b6f6; }
        .shift-EVENING   { background: rgba(76,175,80,0.2);  color: #66bb6a; }
        .shift-NIGHT     { background: rgba(156,39,176,0.2); color: #ce93d8; }
        .status-CANCELLED { text-decoration: line-through; opacity: .5; }

        .schedule-filter-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 16px;
            flex-wrap: wrap;
        }
        .schedule-filter-bar h1 {
            font-size: 22px;
            color: #fff;
            margin: 0;
        }
        .schedule-date-picker {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .schedule-date-picker label { color: #ccc; font-size: 14px; }
        .schedule-date-picker input[type="date"] {
            background: #0c121d;
            border: 1px solid #262625;
            border-radius: 6px;
            color: #fff;
            padding: 6px 10px;
            font-size: 14px;
        }
        .schedule-date-picker input[type="date"]::-webkit-calendar-picker-indicator { filter: invert(1); }

        .week-grid { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .week-grid th, .week-grid td {
            padding: 10px 8px;
            border: 1px solid #262625;
            vertical-align: top;
            color: #ddd;
        }
        .week-grid thead { background: #151b2b; }
        .week-grid th { font-weight: 600; color: #ccc; text-align: center; font-size: 13px; }
        .week-grid td { background: #101623; font-size: 13px; min-height: 60px; }
        .week-grid td.today-col { border-top: 2px solid #d96c2c; }
        .empty-day { color: #555; font-style: italic; font-size: 12px; }
        .branch-info { color: #d96c2c; font-weight: 600; font-size: 15px; }
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
            <a href="${pageContext.request.contextPath}/staff/dashboard">
                <i class="fas fa-home"></i><span>Bảng điều khiển</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/staff/counter-booking">
                <i class="fas fa-ticket-alt"></i><span>Bán vé tại quầy</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/staff/schedule" class="active">
                <i class="fas fa-calendar-alt"></i><span>Lịch làm việc</span>
            </a>
        </li>
    </ul>
    <div class="sidebar-user">
        <div class="user-info">
            <div class="user-avatar">
                <c:choose>
                    <c:when test="${not empty sessionScope.user.fullName}">
                        ${sessionScope.user.fullName.substring(0, 1).toUpperCase()}
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
        <h1><i class="fas fa-calendar-alt"></i> Lịch làm việc</h1>
        <div class="top-bar-actions">
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fas fa-sign-out-alt"></i> Đăng xuất
            </a>
        </div>
    </div>

    <%-- Branch warning (not assigned) --%>
    <c:if test="${not empty branchWarning}">
        <div class="alert alert-warning">${branchWarning}</div>
    </c:if>

    <c:if test="${empty branchWarning}">

        <%-- Branch info --%>
        <c:if test="${not empty branch}">
            <div class="mb-3">
                <span class="branch-info"><i class="fas fa-map-marker-alt me-1"></i>${branch.branchName}</span>
                <span class="text-muted ms-2" style="font-size:13px;">${branch.address}</span>
            </div>
        </c:if>

        <%-- Week nav + date picker --%>
        <div class="schedule-filter-bar">
            <h1><i class="fas fa-calendar-day me-2"></i>Tuần: <strong>${weekLabel}</strong></h1>
            <form method="get" action="${pageContext.request.contextPath}/staff/schedule" class="schedule-date-picker">
                <label for="dateInput">Chọn ngày:</label>
                <input type="date" id="dateInput" name="date" value="${referenceDateStr}">
                <button type="submit" class="btn btn-primary" style="padding:6px 14px;font-size:13px;">
                    <i class="fas fa-search"></i> Xem
                </button>
            </form>
        </div>

        <%-- Schedule table --%>
        <c:choose>
            <c:when test="${empty scheduleByDay}">
                <div class="alert alert-info">Không có dữ liệu lịch làm việc.</div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="week-grid">
                        <thead>
                            <tr>
                                <c:forEach items="${weekDays}" var="wd">
                                    <th>${wd.label}</th>
                                </c:forEach>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <c:forEach items="${weekDays}" var="wd">
                                    <td class="${wd.key == referenceDateStr ? 'today-col' : ''}">
                                        <c:set var="daySchedules" value="${scheduleByDay[wd.key]}"/>
                                        <c:choose>
                                            <c:when test="${empty daySchedules}">
                                                <span class="empty-day">—</span>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach items="${daySchedules}" var="sc">
                                                    <div class="shift-badge shift-${sc.shift} ${sc.status == 'CANCELLED' ? 'status-CANCELLED' : ''}">
                                                        <c:choose>
                                                            <c:when test="${sc.shift == 'MORNING'}"><i class="fas fa-sun me-1"></i>Sáng</c:when>
                                                            <c:when test="${sc.shift == 'AFTERNOON'}"><i class="fas fa-cloud-sun me-1"></i>Chiều</c:when>
                                                            <c:when test="${sc.shift == 'EVENING'}"><i class="fas fa-moon me-1"></i>Tối</c:when>
                                                            <c:otherwise><i class="fas fa-star me-1"></i>Đêm</c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${sc.status == 'CANCELLED'}">
                                                            <span style="font-size:10px;"> (Đã hủy)</span>
                                                        </c:if>
                                                    </div>
                                                    <c:if test="${not empty sc.note}">
                                                        <div style="font-size:11px;color:#aaa;margin-top:2px;">${sc.note}</div>
                                                    </c:if>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </c:forEach>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <%-- Legend --%>
                <div class="mt-3 d-flex gap-3 flex-wrap">
                    <span class="shift-badge shift-MORNING"><i class="fas fa-sun me-1"></i>Sáng (06:00–12:00)</span>
                    <span class="shift-badge shift-AFTERNOON"><i class="fas fa-cloud-sun me-1"></i>Chiều (12:00–17:00)</span>
                    <span class="shift-badge shift-EVENING"><i class="fas fa-moon me-1"></i>Tối (17:00–22:00)</span>
                    <span class="shift-badge shift-NIGHT"><i class="fas fa-star me-1"></i>Đêm (22:00–06:00)</span>
                </div>
            </c:otherwise>
        </c:choose>
    </c:if>
</div>

<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('collapsed');
        const icon = document.querySelector('.sidebar-toggle i');
        icon.className = sidebar.classList.contains('collapsed') ? 'fas fa-chevron-right' : 'fas fa-chevron-left';
    }
</script>
</body>
</html>
