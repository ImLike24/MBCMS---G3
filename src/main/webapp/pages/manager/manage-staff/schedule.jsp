<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch làm việc nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-layout.css">
    <style>
        body { padding-top: 56px; background-color: #f8f9fa; }
        main { margin-left: 280px; padding: 24px; transition: margin-left .3s; }
        .sidebar-collapsed #sidebarMenu { margin-left: -280px; }
        .sidebar-collapsed main { margin-left: 0; }

        .schedule-table { table-layout: fixed; }
        .schedule-table th, .schedule-table td { vertical-align: top; min-width: 100px; }
        .shift-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            margin-bottom: 4px;
            cursor: default;
        }
        .shift-MORNING   { background: #fff3cd; color: #856404; }
        .shift-AFTERNOON { background: #cfe2ff; color: #0a58ca; }
        .shift-EVENING   { background: #d1e7dd; color: #0f5132; }
        .shift-NIGHT     { background: #e2d9f3; color: #59359a; }
        .status-CANCELLED { text-decoration: line-through; opacity: .55; }
        .day-col { width: 13%; }
        .staff-col { width: 13%; }
    </style>
</head>
<body>
    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
    <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
        <jsp:param name="page" value="staff-schedule"/>
    </jsp:include>

    <main>
        <div class="container-fluid">

            <!-- Page header -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0"><i class="fa fa-calendar me-2"></i>Lịch làm việc nhân viên</h4>
                <a href="${pageContext.request.contextPath}/branch-manager/manage-staff?branchId=${selectedBranchId}"
                   class="btn btn-outline-secondary btn-sm">
                    <i class="fa fa-arrow-left me-1"></i>Quản lý nhân viên
                </a>
            </div>

            <!-- Branch selector -->
            <c:if test="${managedBranches.size() > 1}">
                <div class="mb-3">
                    <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-staff" class="d-flex gap-2 align-items-center">
                        <input type="hidden" name="action" value="schedule">
                        <label class="form-label mb-0 fw-semibold">Chi nhánh:</label>
                        <select name="branchId" class="form-select form-select-sm w-auto" onchange="this.form.submit()">
                            <c:forEach items="${managedBranches}" var="b">
                                <option value="${b.branchId}" ${b.branchId == selectedBranchId ? 'selected' : ''}>${b.branchName}</option>
                            </c:forEach>
                        </select>
                    </form>
                </div>
            </c:if>

            <!-- Week nav + date picker -->
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <h6 class="mb-0 text-muted"><i class="fa fa-calendar-week me-1"></i>Tuần: <strong>${weekLabel}</strong></h6>
                <form method="get" action="${pageContext.request.contextPath}/branch-manager/manage-staff" class="d-flex align-items-center gap-2">
                    <input type="hidden" name="action" value="schedule">
                    <input type="hidden" name="branchId" value="${selectedBranchId}">
                    <label class="mb-0 small">Chọn ngày:</label>
                    <input type="date" name="date" value="${referenceDateStr}" class="form-control form-control-sm" style="width:160px">
                    <button type="submit" class="btn btn-sm btn-primary"><i class="fa fa-search"></i> Xem</button>
                </form>
            </div>

            <!-- Alerts -->
            <c:if test="${param.message == 'schedule_created'}">
                <div class="alert alert-success alert-dismissible fade show">Đã tạo lịch làm việc thành công. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.message == 'schedule_cancelled'}">
                <div class="alert alert-info alert-dismissible fade show">Đã hủy lịch làm việc. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.message == 'schedule_deleted'}">
                <div class="alert alert-info alert-dismissible fade show">Đã xóa lịch làm việc. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.error == 'duplicate'}">
                <div class="alert alert-warning alert-dismissible fade show">Nhân viên đã có ca này trong ngày đó. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.error == 'invalid_staff'}">
                <div class="alert alert-danger alert-dismissible fade show">Nhân viên không thuộc chi nhánh này. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.error == 'invalid_shift'}">
                <div class="alert alert-danger alert-dismissible fade show">Ca làm việc không hợp lệ. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>
            <c:if test="${param.error == 'past_date'}">
                <div class="alert alert-danger alert-dismissible fade show">Không được chọn ngày trong quá khứ. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            </c:if>

            <!-- Add schedule button -->
            <div class="mb-3">
                <button class="btn btn-success btn-sm" data-bs-toggle="modal" data-bs-target="#addScheduleModal">
                    <i class="fa fa-plus me-1"></i>Thêm lịch làm việc
                </button>
            </div>

            <!-- Schedule grid -->
            <c:choose>
                <c:when test="${empty staffList}">
                    <div class="alert alert-info">Chi nhánh chưa có nhân viên nào. <a href="${pageContext.request.contextPath}/branch-manager/manage-staff?branchId=${selectedBranchId}">Phân công nhân viên</a></div>
                </c:when>
                <c:otherwise>
                    <div class="card shadow-sm">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-bordered schedule-table mb-0">
                                    <thead class="table-dark">
                                        <tr>
                                            <th class="staff-col">Nhân viên</th>
                                            <c:forEach items="${weekDays}" var="wd">
                                                <th class="day-col text-center">${wd.label}</th>
                                            </c:forEach>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${staffList}" var="staff">
                                            <tr>
                                                <td class="fw-semibold small">${staff.fullName}</td>
                                                <c:forEach items="${weekDays}" var="wd">
                                                    <td class="p-1">
                                                        <c:set var="daySchedules" value="${scheduleMap[staff.userId][wd.key]}"/>
                                                        <c:choose>
                                                            <c:when test="${empty daySchedules}">
                                                                <span class="text-muted small">—</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach items="${daySchedules}" var="sc">
                                                                    <div class="shift-badge shift-${sc.shift} ${sc.status == 'CANCELLED' ? 'status-CANCELLED' : ''}">
                                                                        <c:choose>
                                                                            <c:when test="${sc.shift == 'MORNING'}">Sáng</c:when>
                                                                            <c:when test="${sc.shift == 'AFTERNOON'}">Chiều</c:when>
                                                                            <c:when test="${sc.shift == 'EVENING'}">Tối</c:when>
                                                                            <c:otherwise>Đêm</c:otherwise>
                                                                        </c:choose>
                                                                        <c:if test="${sc.status != 'CANCELLED'}">
                                                                            <span class="ms-1"
                                                                                  style="cursor:pointer;font-size:10px;"
                                                                                  onclick="confirmCancel(${sc.scheduleId}, '${referenceDateStr}', ${selectedBranchId})"
                                                                                  title="Hủy ca">✕</span>
                                                                        </c:if>
                                                                    </div>
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
                    </div>

                    <!-- Legend -->
                    <div class="mt-2 d-flex gap-3 flex-wrap">
                        <span class="shift-badge shift-MORNING">Sáng (06:00–12:00)</span>
                        <span class="shift-badge shift-AFTERNOON">Chiều (12:00–17:00)</span>
                        <span class="shift-badge shift-EVENING">Tối (17:00–22:00)</span>
                        <span class="shift-badge shift-NIGHT">Đêm (22:00–06:00)</span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <!-- Add Schedule Modal -->
    <div class="modal fade" id="addScheduleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="post" action="${pageContext.request.contextPath}/branch-manager/manage-staff" onsubmit="return validateScheduleForm()">
                    <input type="hidden" name="action" value="create-schedule">
                    <input type="hidden" name="branchId" value="${selectedBranchId}">
                    <input type="hidden" name="date" value="${referenceDateStr}">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa fa-plus-circle me-2"></i>Thêm lịch làm việc</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Nhân viên <span class="text-danger">*</span></label>
                            <select name="staffId" class="form-select" required>
                                <option value="">-- Chọn nhân viên --</option>
                                <c:forEach items="${staffList}" var="s">
                                    <option value="${s.userId}">${s.fullName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Ngày làm việc <span class="text-danger">*</span></label>
                            <input type="date" name="workDate" id="workDate" class="form-control" required
                                   min="<%= java.time.LocalDate.now() %>">
                            <div id="workDateError" class="text-danger small mt-1" style="display:none;">Không được chọn ngày trong quá khứ.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Ca làm việc <span class="text-danger">*</span></label>
                            <select name="shift" class="form-select" required>
                                <option value="">-- Chọn ca --</option>
                                <option value="MORNING">Sáng (06:00 – 12:00)</option>
                                <option value="AFTERNOON">Chiều (12:00 – 17:00)</option>
                                <option value="EVENING">Tối (17:00 – 22:00)</option>
                                <option value="NIGHT">Đêm (22:00 – 06:00)</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Ghi chú</label>
                            <input type="text" name="note" class="form-control" placeholder="Tùy chọn...">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" id="saveScheduleBtn" class="btn btn-success"><i class="fa fa-save me-1"></i>Lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Cancel Schedule Form (hidden) -->
    <form id="cancelScheduleForm" method="post" action="${pageContext.request.contextPath}/branch-manager/manage-staff">
        <input type="hidden" name="action" value="cancel-schedule">
        <input type="hidden" name="scheduleId" id="cancelScheduleId">
        <input type="hidden" name="date" id="cancelScheduleDate">
        <input type="hidden" name="branchId" id="cancelScheduleBranch">
    </form>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('sidebarToggle')?.addEventListener('click', () =>
            document.body.classList.toggle('sidebar-collapsed'));

        const workDateInput = document.getElementById('workDate');
        const saveBtn = document.getElementById('saveScheduleBtn');
        const todayStr = workDateInput ? workDateInput.min : '';

        function checkWorkDate() {
            if (!workDateInput) return;
            const errorDiv = document.getElementById('workDateError');
            const isPast = workDateInput.value && workDateInput.value < todayStr;
            const isEmpty = !workDateInput.value;
            if (isPast) {
                errorDiv.style.display = 'block';
                workDateInput.classList.add('is-invalid');
                workDateInput.classList.remove('is-valid');
                saveBtn.disabled = true;
            } else if (isEmpty) {
                errorDiv.style.display = 'none';
                workDateInput.classList.remove('is-invalid', 'is-valid');
                saveBtn.disabled = false;
            } else {
                errorDiv.style.display = 'none';
                workDateInput.classList.remove('is-invalid');
                workDateInput.classList.add('is-valid');
                saveBtn.disabled = false;
            }
        }

        if (workDateInput) {
            workDateInput.addEventListener('change', checkWorkDate);
            workDateInput.addEventListener('input', checkWorkDate);
        }

        function validateScheduleForm() {
            checkWorkDate();
            if (!workDateInput.value || workDateInput.value < todayStr) {
                workDateInput.focus();
                return false;
            }
            return true;
        }

        function confirmCancel(scheduleId, date, branchId) {
            if (!confirm('Hủy ca làm việc này?')) return;
            document.getElementById('cancelScheduleId').value = scheduleId;
            document.getElementById('cancelScheduleDate').value = date;
            document.getElementById('cancelScheduleBranch').value = branchId;
            document.getElementById('cancelScheduleForm').submit();
        }
    </script>
</body>
</html>
