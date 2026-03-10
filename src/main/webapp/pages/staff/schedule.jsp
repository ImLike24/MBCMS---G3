<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Working Schedule - Cinema Staff</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        .schedule-filter-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 16px;
        }
        .schedule-filter-bar h1 {
            font-size: 24px;
            color: #fff;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .schedule-filter-bar h1 i {
            color: #d96c2c;
        }
        .schedule-date-picker {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .schedule-date-picker label {
            color: #ccc;
            font-size: 14px;
        }
        .schedule-date-picker input[type="date"] {
            background: #0c121d;
            border: 1px solid #262625;
            border-radius: 6px;
            color: #fff;
            padding: 6px 10px;
            font-size: 14px;
        }
        /* Make native date picker icon white on dark background (WebKit/Blink) */
        .schedule-date-picker input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(1);
        }
        .branch-schedule-card {
            background: #101623;
            border-radius: 10px;
            padding: 16px 18px;
            margin-bottom: 18px;
            border: 1px solid #262625;
        }
        .branch-schedule-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        .branch-schedule-header h3 {
            color: #d96c2c;
            font-size: 18px;
            margin: 0;
        }
        .branch-schedule-header span {
            color: #888;
            font-size: 13px;
        }
        .schedule-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .schedule-table thead {
            background: #151b2b;
        }
        .schedule-table th,
        .schedule-table td {
            padding: 8px 10px;
            border-bottom: 1px solid #262625;
            color: #ddd;
        }
        .schedule-table th {
            font-weight: 600;
            color: #ccc;
        }
        .schedule-status {
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
        }
        .schedule-status.SCHEDULED {
            background: rgba(33, 150, 243, 0.15);
            color: #29b6f6;
        }
        .schedule-status.ONGOING {
            background: rgba(76, 175, 80, 0.18);
            color: #66bb6a;
        }
        .schedule-status.COMPLETED {
            background: rgba(158, 158, 158, 0.2);
            color: #bdbdbd;
        }
        .schedule-status.CANCELLED {
            background: rgba(244, 67, 54, 0.2);
            color: #ef9a9a;
        }
        .empty-schedule {
            padding: 8px 0;
            color: #777;
            font-size: 13px;
            font-style: italic;
        }
        .schedule-week-grid {
            table-layout: fixed;
        }
        .schedule-week-grid th,
        .schedule-week-grid td {
            vertical-align: top;
        }
        .schedule-slot {
            padding: 6px 6px;
            margin-bottom: 6px;
            border-radius: 6px;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.05);
            font-size: 12px;
        }
        .schedule-slot .time {
            color: #ffd27f;
            font-weight: 600;
            margin-bottom: 2px;
        }
        .schedule-slot .movie {
            color: #fff;
        }
        .schedule-slot .room {
            color: #aaa;
            font-size: 11px;
        }
    </style>
</head>
<body>
<div class="sidebar" id="sidebar">
    <button class="sidebar-toggle" onclick="toggleSidebar()">
        <i class="fas fa-chevron-left"></i>
    </button>

    <div class="sidebar-header">
        <div class="logo-icon">
            <i class="fas fa-film"></i>
        </div>
        <h3>Cinema Staff</h3>
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/staff/dashboard">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/staff/counter-booking">
                <i class="fas fa-ticket-alt"></i>
                <span>Counter Booking</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/staff/schedule" class="active">
                <i class="fas fa-calendar-alt"></i>
                <span>View Working Schedule</span>
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
                    <c:otherwise>
                        <i class="fas fa-user"></i>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="user-details">
                <div class="user-name">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName}
                        </c:when>
                        <c:otherwise>
                            Staff User
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="user-role">Cinema Staff</div>
            </div>
        </div>
    </div>
</div>

<div class="main-content">
    <div class="top-bar">
        <h1><i class="fas fa-calendar-alt"></i> Working Schedule</h1>
        <div class="top-bar-actions">
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fas fa-sign-out-alt"></i>
                Logout
            </a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="schedule-filter-bar">
        <h1>
            <i class="fas fa-calendar-day"></i>
            <span>
                Week:
                ${weekLabel}
            </span>
        </h1>
        <form method="get" action="${pageContext.request.contextPath}/staff/schedule" class="schedule-date-picker">
            <label for="dateInput">Select date:</label>
            <input type="date" id="dateInput" name="date" value="${referenceDateStr}">
            <button type="submit" class="btn btn-primary" style="padding:6px 14px;font-size:13px;">
                <i class="fas fa-search"></i> View
            </button>
        </form>
    </div>

    <c:forEach items="${branches}" var="branch">
        <c:set var="branchId" value="${branch.branchId}"/>

        <div class="branch-schedule-card">
            <div class="branch-schedule-header">
                <h3>${branch.branchName}</h3>
                <span><i class="fas fa-map-marker-alt"></i> ${branch.address}</span>
            </div>

            <c:choose>
                <c:when test="${empty scheduleByBranch[branchId]}">
                    <div class="empty-schedule">
                        <i class="fas fa-info-circle"></i>
                        No showtimes scheduled for this branch on selected date.
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="schedule-table schedule-week-grid">
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
                                <td>
                                    <c:set var="dayKey" value="${wd.key}"/>
                                    <c:set var="dayShowtimes" value="${scheduleByBranch[branchId][dayKey]}"/>

                                    <c:choose>
                                        <c:when test="${empty dayShowtimes}">
                                            <div class="empty-schedule">-</div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${dayShowtimes}" var="st">
                                                <div class="schedule-slot">
                                                    <div class="time">${st.startTime} - ${st.endTime}</div>
                                                    <div class="movie">${st.movieTitle}</div>
                                                    <div class="room">Room ${st.roomName}</div>
                                                    <span class="schedule-status ${st.status}">
                                                        ${st.status}
                                                    </span>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </c:forEach>
                        </tr>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </c:forEach>
</div>

<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('collapsed');

        const icon = document.querySelector('.sidebar-toggle i');
        if (sidebar.classList.contains('collapsed')) {
            icon.className = 'fas fa-chevron-right';
        } else {
            icon.className = 'fas fa-chevron-left';
        }
    }
</script>

</body>
</html>

