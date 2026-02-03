<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${branch != null ? 'Cập nhật Chi nhánh' : 'Thêm Chi nhánh mới'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f3f4f6; padding-top: 56px; }
        #sidebarMenu { position: fixed; top: 56px; left: 0; bottom: 0; z-index: 100; }
        main { margin-left: 280px; padding: 30px; transition: margin-left 0.3s; }
        .sidebar-collapsed #sidebarMenu { margin-left: -280px; }
        .sidebar-collapsed main { margin-left: 0; }
    </style>
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
                <li class="breadcrumb-item"><a href="branches" class="text-decoration-none">Chi nhánh</a></li>
                <li class="breadcrumb-item active">${branch != null ? 'Sửa Chi nhánh' : 'Thêm mới'}</li>
            </ol>
        </nav>

        <form action="branches" method="post" class="needs-validation">
            <input type="hidden" name="action" value="${branch != null ? 'update' : 'create'}">
            <c:if test="${branch != null}">
                <input type="hidden" name="branchId" value="${branch.branchId}">
            </c:if>

            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-white p-4 border-bottom-0">
                    <h4 class="fw-bold mb-0">
                        <i class="fa ${branch != null ? 'fa-pencil-square-o' : 'fa-plus-circle'} me-2 text-primary"></i>
                        ${branch != null ? 'Cập nhật thông tin Chi nhánh' : 'Tạo Chi nhánh mới'}
                    </h4>
                </div>

                <div class="card-body p-4 pt-0">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger mb-4">
                            <i class="fa fa-exclamation-triangle me-2"></i> ${error}
                        </div>
                    </c:if>

                    <div class="row g-4">
                        <div class="col-12">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="branchName" name="branchName"
                                       placeholder="Tên chi nhánh" value="${branch.branchName}" required>
                                <label for="branchName">Tên Chi nhánh <span class="text-danger">*</span></label>
                            </div>
                        </div>

                        <div class="col-12">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="address" name="address"
                                       placeholder="Địa chỉ" value="${branch.address}">
                                <label for="address">Địa chỉ đầy đủ</label>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="phone" name="phone"
                                       placeholder="Số điện thoại" value="${branch.phone}">
                                <label for="phone">Số điện thoại</label>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="email" class="form-control" id="email" name="email"
                                       placeholder="Email" value="${branch.email}">
                                <label for="email">Địa chỉ Email</label>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-floating">
                                <select class="form-select" id="managerId" name="managerId">
                                    <option value="">-- Chọn Quản lý --</option>
                                    <c:forEach var="mgr" items="${managers}">
                                        <option value="${mgr.userId}"
                                            ${branch != null && branch.managerId == mgr.userId ? 'selected' : ''}>
                                                ${mgr.fullName} (ID: ${mgr.userId})
                                        </option>
                                    </c:forEach>
                                </select>
                                <label for="managerId">Phân công Quản lý</label>
                                <div class="form-text">Chỉ hiển thị tài khoản có quyền Quản lý Chi nhánh.</div>
                            </div>
                        </div>

                        <div class="col-md-6 d-flex align-items-center">
                            <div class="form-check form-switch ps-5">
                                <input class="form-check-input" type="checkbox" id="isActive" name="isActive"
                                       style="width: 3em; height: 1.5em;" ${branch == null || branch.active ? 'checked' : ''}>
                                <label class="form-check-label fw-bold ms-2 pt-1" for="isActive">
                                    Trạng thái hoạt động
                                </label>
                                <div class="form-text">Chi nhánh ngừng hoạt động sẽ ẩn với khách hàng.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card-footer bg-white p-4 d-flex justify-content-end gap-2 rounded-bottom-4">
                    <a href="branches" class="btn btn-light btn-lg px-4">Hủy</a>
                    <button type="submit" class="btn btn-primary btn-lg px-4">
                        <i class="fa fa-save me-2"></i>Lưu lại
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('sidebarToggle').addEventListener('click', function () {
        document.body.classList.toggle('sidebar-collapsed');
    });
</script>
</body>
</html>