<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${room != null ? 'Cập nhật' : 'Thêm'} Phòng chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        /* 1. Đẩy nội dung xuống để tránh Header che mất */
        body {
            background-color: #f3f4f6;
            padding-top: 56px;
        }

        /* 2. QUAN TRỌNG: Ghim Sidebar sang trái */
        #sidebarMenu {
            position: fixed;
            top: 56px;
            left: 0;
            bottom: 0;
            z-index: 100;
            overflow-y: auto; /* Cho phép cuộn nếu menu dài */
        }

        /* 3. Đẩy Main sang phải để không bị Sidebar che */
        main {
            margin-left: 280px;
            padding: 30px;
            transition: margin-left 0.3s;
        }

        /* 4. CSS cho trạng thái đóng/mở Sidebar (nếu dùng nút toggle) */
        .sidebar-collapsed #sidebarMenu { margin-left: -280px; }
        .sidebar-collapsed main { margin-left: 0; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="rooms"/>
</jsp:include>

<main>
    <div class="container-fluid" style="max-width: 700px;">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="rooms" class="text-decoration-none">Phòng chiếu</a></li>
                <li class="breadcrumb-item active">${room != null ? 'Cập nhật' : 'Thêm mới'}</li>
            </ol>
        </nav>

        <form action="rooms" method="post">
            <input type="hidden" name="action" value="${room != null ? 'update' : 'create'}">
            <c:if test="${room != null}">
                <input type="hidden" name="roomId" value="${room.roomId}">
            </c:if>

            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-white p-4">
                    <h4 class="fw-bold mb-0">
                        <i class="fa ${room != null ? 'fa-pencil-square-o' : 'fa-plus-circle'} me-2 text-primary"></i>
                        ${room != null ? 'Thông tin Phòng chiếu' : 'Tạo Phòng chiếu mới'}
                    </h4>
                </div>

                <div class="card-body p-4">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger mb-4">
                            <i class="fa fa-exclamation-triangle me-2"></i> ${error}
                        </div>
                    </c:if>

                    <div class="row g-4">
                        <div class="col-12">
                            <label class="form-label fw-bold">Tên Phòng chiếu <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="roomName"
                                   value="${room.roomName}" required
                                   placeholder="Ví dụ: Rạp 1, IMAX Hall...">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Tổng số ghế</label>
                            <input type="number" class="form-control" name="totalSeats"
                                   value="${room.totalSeats}" min="0" placeholder="0">
                            <div class="form-text">Số ghế sẽ được tính tự động khi vẽ sơ đồ (tạm thời nhập tay).</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="ACTIVE" ${room.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Hoạt động)</option>
                                <option value="MAINTENANCE" ${room.status == 'MAINTENANCE' ? 'selected' : ''}>MAINTENANCE (Bảo trì)</option>
                                <option value="CLOSED" ${room.status == 'CLOSED' ? 'selected' : ''}>CLOSED (Đóng cửa)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="card-footer bg-white p-4 d-flex justify-content-end gap-2">
                    <a href="rooms" class="btn btn-light px-4">Hủy</a>
                    <button type="submit" class="btn btn-primary px-4">
                        <i class="fa fa-save me-2"></i> Lưu thông tin
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    const toggleBtn = document.getElementById('sidebarToggle');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            document.body.classList.toggle('sidebar-collapsed');
        });
    }
</script>
</body>
</html>