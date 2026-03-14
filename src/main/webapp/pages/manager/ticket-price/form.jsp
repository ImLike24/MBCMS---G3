<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${isViewMode ? 'Chi tiết' : (not empty priceObj.priceId ? 'Cập nhật' : 'Thêm')} Giá Vé</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="ticket-prices"/>
</jsp:include>

<main>
    <div class="container-fluid" style="max-width: 800px;">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="ticket-prices" class="text-decoration-none text-secondary">Giá Vé</a></li>
                <li class="breadcrumb-item active" style="color: #d96c2c;">
                    ${isViewMode ? 'Chi tiết' : (priceObj != null ? 'Cập nhật' : 'Thêm mới')}
                </li>
            </ol>
        </nav>

        <form action="ticket-prices" method="post">
            <input type="hidden" name="action" value="${not empty priceObj.priceId ? 'update' : 'create'}">
            <c:if test="${not empty priceObj.priceId}">
                <input type="hidden" name="priceId" value="${priceObj.priceId}">
            </c:if>

            <div class="card-header-custom">
                <h5 class="mb-0 fw-bold">
                    <i class="fa ${isViewMode ? 'fa-eye' : (not empty priceObj.priceId ? 'fa-edit' : 'fa-plus-circle')} me-2" style="color: #d96c2c;"></i>
                    ${isViewMode ? 'Chi tiết Cấu hình' : (not empty priceObj.priceId ? 'Cập nhật Cấu hình' : 'Thêm Cấu hình mới')}
                </h5>
            </div>

            <div class="card-body p-4">
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger mb-4 fw-bold">
                        <i class="fa fa-exclamation-triangle me-2"></i>${errorMessage}
                    </div>
                </c:if>

                    <h6 class="fw-bold mb-3 text-secondary border-bottom pb-2">ĐIỀU KIỆN ÁP DỤNG</h6>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Loại Khách <span class="text-danger">*</span></label>
                            <select class="form-select" name="ticketType" required ${disabledAttr}>
                                <option value="ADULT" ${priceObj.ticketType == 'ADULT' ? 'selected' : ''}>Người lớn (ADULT)</option>
                                <option value="CHILD" ${priceObj.ticketType == 'CHILD' ? 'selected' : ''}>Trẻ em (CHILD)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Loại Ngày <span class="text-danger">*</span></label>
                            <select class="form-select" name="dayType" required ${disabledAttr}>
                                <option value="WEEKDAY" ${priceObj.dayType == 'WEEKDAY' ? 'selected' : ''}>Ngày thường (T2-T6)</option>
                                <option value="WEEKEND" ${priceObj.dayType == 'WEEKEND' ? 'selected' : ''}>Cuối tuần (T7-CN)</option>
                                <option value="HOLIDAY" ${priceObj.dayType == 'HOLIDAY' ? 'selected' : ''}>Ngày Lễ</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Khung Giờ <span class="text-danger">*</span></label>
                            <select class="form-select" name="timeSlot" required ${disabledAttr}>
                                <option value="MORNING" ${priceObj.timeSlot == 'MORNING' ? 'selected' : ''}>Sáng (MORNING)</option>
                                <option value="AFTERNOON" ${priceObj.timeSlot == 'AFTERNOON' ? 'selected' : ''}>Chiều (AFTERNOON)</option>
                                <option value="EVENING" ${priceObj.timeSlot == 'EVENING' ? 'selected' : ''}>Tối (EVENING)</option>
                                <option value="NIGHT" ${priceObj.timeSlot == 'NIGHT' ? 'selected' : ''}>Khuya (NIGHT)</option>
                            </select>
                        </div>
                    </div>

                    <h6 class="fw-bold mb-3 text-secondary border-bottom pb-2">MỨC GIÁ & THỜI GIAN</h6>
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label fw-bold">Giá Vé (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control form-control-lg text-danger fw-bold"
                                   name="price" value="${priceObj.price}" required min="0" step="1000" ${disabledAttr}>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Áp dụng từ ngày <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" name="effectiveFrom" value="${priceObj.effectiveFrom}" required ${disabledAttr}>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Kết thúc ngày (Tùy chọn)</label>
                            <input type="date" class="form-control" name="effectiveTo" value="${priceObj.effectiveTo}" ${disabledAttr}>
                        </div>
                        <div class="col-12 mt-4">
                            <div class="form-check form-switch ps-5">
                                <input class="form-check-input" type="checkbox" name="isActive"
                                       style="width: 3em; height: 1.5em; background-color: #d96c2c; border-color: #d96c2c;"
                                ${priceObj == null || priceObj.active ? 'checked' : ''} ${disabledAttr}>
                                <label class="form-check-label fw-bold ms-2 pt-1">Đang hoạt động</label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card-footer bg-white p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <c:if test="${not empty priceObj.priceId && !isViewMode}">
                            <a href="ticket-prices?action=delete&id=${priceObj.priceId}"
                               class="btn btn-outline-danger px-4 fw-bold"
                               onclick="return confirm('Hành động này sẽ XÓA VĨNH VIỄN cấu hình giá. Bạn có chắc chắn không?');">
                                <i class="fa fa-trash me-2"></i>Xóa vĩnh viễn
                            </a>
                        </c:if>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="ticket-prices" class="btn btn-light px-4">${isViewMode ? 'Quay lại' : 'Hủy bỏ'}</a>
                        <c:if test="${!isViewMode}">
                            <button type="submit" class="btn btn-orange px-5 fw-bold">
                                <i class="fa fa-save me-2"></i>Lưu cấu hình
                            </button>
                        </c:if>
                    </div>
                </div>
            </div>
        </form>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>