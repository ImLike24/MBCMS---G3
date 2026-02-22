<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${branch != null ? 'Cập nhật' : 'Thêm'} Chi nhánh</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="branch"/>
</jsp:include>

<main>
    <div class="container-fluid" style="max-width: 900px;">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="branches" class="text-decoration-none text-secondary">Chi nhánh</a></li>
                <li class="breadcrumb-item active" style="color: #d96c2c;">${branch != null ? 'Cập nhật' : 'Thêm mới'}</li>
            </ol>
        </nav>

        <form action="branches" method="post">
            <input type="hidden" name="action" value="${branch != null ? 'update' : 'create'}">
            <c:if test="${branch != null}">
                <input type="hidden" name="branchId" value="${branch.branchId}">
            </c:if>

            <div class="card card-custom">
                <div class="card-header-custom">
                    <h5 class="mb-0 fw-bold">
                        <i class="fa ${branch != null ? 'fa-edit' : 'fa-plus-circle'} me-2" style="color: #d96c2c;"></i>
                        ${branch != null ? 'Cập nhật thông tin' : 'Tạo chi nhánh mới'}
                    </h5>
                </div>

                <div class="card-body p-5">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger mb-4">${error}</div>
                    </c:if>

                    <div class="row g-4">
                        <div class="col-12">
                            <label class="form-label fw-bold">Tên Chi nhánh <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-lg" name="branchName"
                                   value="${branch.branchName}" required placeholder="Ví dụ: Hola Cinema">
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-bold">Địa chỉ</label>
                            <input type="text" class="form-control" name="address"
                                   value="${branch.address}" placeholder="Số nhà, đường, quận...">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Số điện thoại</label>
                            <input type="text" class="form-control" name="phone" value="${branch.phone}">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" class="form-control" name="email" value="${branch.email}">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Quản lý (Manager)</label>
                            <select class="form-select" name="managerId">
                                <option value="">-- Chọn quản lý --</option>
                                <c:forEach var="mgr" items="${managers}">
                                    <option value="${mgr.userId}" ${branch.managerId == mgr.userId ? 'selected' : ''}>
                                            ${mgr.fullName} (${mgr.username})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-6 d-flex align-items-center">
                            <div class="form-check form-switch ps-5 mt-4">
                                <input class="form-check-input" type="checkbox" name="isActive"
                                       style="width: 3em; height: 1.5em; background-color: #d96c2c; border-color: #d96c2c;"
                                ${branch == null || branch.active ? 'checked' : ''}>
                                <label class="form-check-label fw-bold ms-2 pt-1">Kích hoạt hoạt động</label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card-footer bg-white p-4 d-flex justify-content-end gap-2">
                    <a href="branches" class="btn btn-light px-4">Hủy bỏ</a>
                    <button type="submit" class="btn btn-orange px-5 fw-bold">
                        <i class="fa fa-save me-2"></i>Lưu lại
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>