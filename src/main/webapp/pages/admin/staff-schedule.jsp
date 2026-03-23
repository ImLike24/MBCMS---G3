<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch làm việc nhân viên - Admin</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        :root {
            --primary-color: #d96c2c;
            --dark-bg: #141414;
            --card-bg: #1f1f1f;
            --text-color: #ffffff;
            --text-muted: #b3b3b3;
        }
        body {
            background-color: var(--dark-bg);
            color: var(--text-color);
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 4px;
        }
        .page-subtitle {
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        /* Filter bar */
        .filter-card {
            background: var(--card-bg);
            border-radius: 10px;
            padding: 16px 20px;
            margin-bottom: 24px;
            border: 1px solid #2a2a2a;
        }
        .filter-card .form-label {
            color: var(--text-muted);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .filter-card .form-select,
        .filter-card .form-control {
            background: #2a2a2a;
            border-color: #3a3a3a;
            color: #fff;
            font-size: 0.875rem;
        }
        .filter-card .form-select:focus,
        .filter-card .form-control:focus {
            background: #2a2a2a;
            border-color: var(--primary-color);
            color: #fff;
            box-shadow: 0 0 0 0.2rem rgba(217,108,44,.25);
        }
        .filter-card .form-select option { background: #2a2a2a; }
        .filter-card input[type="date"]::-webkit-calendar-picker-indicator { filter: invert(1); }

        .week-label {
            color: var(--primary-color);
            font-weight: 700;
            font-size: 1rem;
        }

        /* Schedule table */
        .schedule-card {
            background: var(--card-bg);
            border-radius: 10px;
            border: 1px solid #2a2a2a;
            overflow: hidden;
        }
        .schedule-table {
            margin: 0;
            table-layout: fixed;
        }
        .schedule-table thead th {
            background: #141414;
            color: var(--text-muted);
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 12px 10px;
            border-color: #2a2a2a;
            vertical-align: middle;
        }
        .schedule-table thead th:first-child {
            color: #fff;
        }
        .schedule-table tbody td {
            background: var(--card-bg);
            border-color: #2a2a2a;
            padding: 10px 8px;
            vertical-align: top;
            min-height: 60px;
        }
        .schedule-table tbody tr:hover td {
            background: #252525;
        }
        .staff-name {
            font-weight: 600;
            font-size: 0.875rem;
            color: #fff;
        }

        /* Shift badges */
        .shift-badge {
            display: inline-block;
            padding: 3px 9px;
            border-radius: 5px;
            font-size: 11px;
            font-weight: 700;
            margin-bottom: 3px;
            white-space: nowrap;
        }
        .shift-MORNING   { background: rgba(255,193,7,.15);  color: #ffc107; border: 1px solid rgba(255,193,7,.3); }
        .shift-AFTERNOON { background: rgba(13,110,253,.15); color: #6ea8fe; border: 1px solid rgba(13,110,253,.3); }
        .shift-EVENING   { background: rgba(25,135,84,.15);  color: #75b798; border: 1px solid rgba(25,135,84,.3); }
        .shift-NIGHT     { background: rgba(111,66,193,.15); color: #c29ffa; border: 1px solid rgba(111,66,193,.3); }
        .status-CANCELLED { text-decoration: line-through; opacity: .45; }

        /* Legend */
        .legend-bar {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            margin-top: 16px;
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-muted);
        }
        .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .4; }

        /* Btn */
        .btn-filter {
            background: var(--primary-color);
            border: none;
            color: #fff;
            font-size: 0.875rem;
            padding: 7px 16px;
            border-radius: 6px;
            font-weight: 600;
        }
        .btn-filter:hover { background: #c05a20; color: #fff; }
    </style>
</head>
<body>

    <!-- Header -->
    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

    <!-- Sidebar -->
    <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
        <jsp:param name="page" value="staff-schedule"/>
    </jsp:include>

    <!-- Main Content -->
    <main>
        <div class="container-fluid">

            <!-- Page header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="page-title"><i class="fas fa-calendar-alt me-2" style="color:var(--primary-color);"></i>Lịch làm việc nhân viên</h3>
                    <p class="page-subtitle">Xem lịch ca làm việc theo tuần của từng chi nhánh</p>
                </div>
            </div>

            <!-- Filter card -->
            <div class="filter-card">
                <form method="get" action="${pageContext.request.contextPath}/admin/staff-schedule" class="row align-items-end g-3">
                    <div class="col-auto">
                        <label for="branchSelect" class="form-label">Chi nhánh</label>
                        <select id="branchSelect" name="branchId" class="form-select form-select-sm" style="min-width:200px;" onchange="this.form.submit()">
                            <c:forEach items="${allBranches}" var="b">
                                <option value="${b.branchId}" ${b.branchId == selectedBranchId ? 'selected' : ''}>${b.branchName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <input type="hidden" name="date" value="${referenceDateStr}">
                    <div class="col-auto ms-auto d-flex align-items-end pb-1">
                        <span class="week-label"><i class="fas fa-calendar-week me-1"></i>Tuần: ${weekLabel}</span>
                    </div>
                </form>
            </div>

            <!-- Schedule grid -->
            <c:choose>
                <c:when test="${empty staffList}">
                    <div class="schedule-card">
                        <div class="empty-state">
                            <i class="fas fa-users-slash d-block"></i>
                            <p class="mb-0">Chi nhánh này chưa có nhân viên nào được phân công.</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="schedule-card">
                        <div class="table-responsive">
                            <table class="table table-borderless schedule-table">
                                <thead>
                                    <tr>
                                        <th style="width:14%">Nhân viên</th>
                                        <c:forEach items="${weekDays}" var="wd">
                                            <th class="text-center" style="width:12.3%">${wd.label}</th>
                                        </c:forEach>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${staffList}" var="staff">
                                        <tr>
                                            <td class="staff-name">${staff.fullName}</td>
                                            <c:forEach items="${weekDays}" var="wd">
                                                <td>
                                                    <c:set var="daySchedules" value="${scheduleMap[staff.userId][wd.key]}"/>
                                                    <c:choose>
                                                        <c:when test="${empty daySchedules}">
                                                            <span style="color:#444;font-size:12px;">—</span>
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
                                                                    <div style="font-size:10px;color:#888;margin-top:1px;">${sc.note}</div>
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </c:forEach>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Legend -->
                    <div class="legend-bar">
                        <span class="shift-badge shift-MORNING"><i class="fas fa-sun me-1"></i>Sáng (06:00–12:00)</span>
                        <span class="shift-badge shift-AFTERNOON"><i class="fas fa-cloud-sun me-1"></i>Chiều (12:00–17:00)</span>
                        <span class="shift-badge shift-EVENING"><i class="fas fa-moon me-1"></i>Tối (17:00–22:00)</span>
                        <span class="shift-badge shift-NIGHT"><i class="fas fa-star me-1"></i>Đêm (22:00–06:00)</span>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const toggleBtn = document.getElementById('sidebarToggle');
            if (toggleBtn) {
                toggleBtn.addEventListener('click', function () {
                    document.body.classList.toggle('sidebar-collapsed');
                });
            }
        });
    </script>
</body>
</html>
