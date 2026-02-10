<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${room != null ? 'Cập nhật' : 'Thêm'} Phòng chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
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
                <li class="breadcrumb-item"><a href="rooms" class="text-decoration-none text-secondary">Phòng chiếu</a></li>
                <li class="breadcrumb-item active" style="color: #d96c2c;">${room != null ? 'Cập nhật' : 'Thêm mới'}</li>
            </ol>
        </nav>

        <form action="rooms" method="post">
            <input type="hidden" name="action" value="${room != null ? 'update' : 'create'}">
            <c:if test="${room != null}">
                <input type="hidden" name="roomId" value="${room.roomId}">
            </c:if>

            <div class="card card-custom">
                <div class="card-header-custom">
                    <h5 class="mb-0 fw-bold">
                        <i class="fa ${room != null ? 'fa-edit' : 'fa-plus-circle'} me-2" style="color: #d96c2c;"></i>
                        ${room != null ? 'Thông tin phòng chiếu' : 'Tạo phòng chiếu mới'}
                    </h5>
                </div>

                <div class="card-body p-5">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger mb-4">${error}</div>
                    </c:if>

                    <div class="row g-4">
                        <div class="col-12">
                            <label class="form-label fw-bold">Tên Phòng <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-lg" name="roomName"
                                   value="${room.roomName}" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Số lượng ghế</label>
                            <input type="number" class="form-control" name="totalSeats"
                                   value="${room.totalSeats}" min="0" placeholder="0">
                            <div class="form-text text-muted">Số ghế sẽ tự động cập nhật khi vẽ sơ đồ.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Trạng thái vận hành</label>
                            <select class="form-select" name="status">
                                <option value="ACTIVE" ${room.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Hoạt động)</option>
                                <option value="MAINTENANCE" ${room.status == 'MAINTENANCE' ? 'selected' : ''}>MAINTENANCE (Bảo trì)</option>
                                <option value="CLOSED" ${room.status == 'CLOSED' ? 'selected' : ''}>CLOSED (Đóng cửa)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="card-footer bg-white p-4 d-flex justify-content-end gap-2">
                    <a href="rooms" class="btn btn-light px-4">Hủy bỏ</a>
                    <button type="submit" class="btn btn-orange px-5 fw-bold">
                        <i class="fa fa-save me-2"></i>Lưu thông tin
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>