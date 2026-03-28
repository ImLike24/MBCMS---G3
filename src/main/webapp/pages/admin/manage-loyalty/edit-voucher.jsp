<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Chỉnh sửa Voucher - Admin</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
        </head>

        <body>

            <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
            <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
                <jsp:param name="page" value="manage-vouchers" />
            </jsp:include>

            <main>
                <div class="container-fluid py-4">

                    <!-- Page Title -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h3 class="fw-bold mb-1" style="color: #212529;">Chỉnh sửa Voucher</h3>
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb mb-0">
                                    <li class="breadcrumb-item"><a href="#"
                                            class="text-decoration-none text-secondary">Admin</a></li>
                                    <li class="breadcrumb-item">
                                        <a href="${pageContext.request.contextPath}/admin/manage-vouchers"
                                            class="text-decoration-none text-secondary">Vouchers</a>
                                    </li>
                                    <li class="breadcrumb-item active" style="color: #d96c2c;">Chỉnh sửa</li>
                                </ol>
                            </nav>
                        </div>
                    </div>

                    <!-- Error Alert -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Form -->
                    <form action="${pageContext.request.contextPath}/admin/edit-voucher" method="POST"
                        class="row g-3 needs-validation" novalidate>

                        <input type="hidden" name="voucherId" value="${voucher.voucherId}">

                        <!-- Tên Campaign / Voucher -->
                        <div class="col-md-8">
                            <label class="form-label">Tên Voucher <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="voucherName" value="${voucher.voucherName}"
                                placeholder="VD: Giảm 50K Cuối Tuần" required>
                            <div class="invalid-feedback">Vui lòng nhập tên voucher</div>
                        </div>

                        <!-- Phân loại -->
                        <div class="col-md-4">
                            <label class="form-label">Phân loại <span class="text-danger">*</span></label>
                            <select class="form-select" name="voucherType" id="voucherType"
                                onchange="handleTypeChange()" required>
                                <option value="LOYALTY" ${voucher.voucherType eq 'LOYALTY' ? 'selected' : '' }>LOYALTY —
                                    Khách dùng điểm để đổi</option>
                                <option value="PUBLIC" ${voucher.voucherType eq 'PUBLIC' ? 'selected' : '' }>PUBLIC — Mã
                                    chung công khai</option>
                            </select>
                        </div>

                        <!-- Mã / Prefix -->
                        <div class="col-md-6">
                            <label class="form-label" id="codeLabel">Mã / Tiền tố Mã</label>
                            <input type="text" class="form-control font-monospace ${not empty voucherCodeError ? 'is-invalid' : ''}" name="voucherCode" id="voucherCode"
                                value="${voucher.voucherCode}" placeholder="VD: SALE50K-">
                            <c:choose>
                                <c:when test="${not empty voucherCodeError}">
                                    <div class="invalid-feedback d-block">${voucherCodeError}</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="invalid-feedback">Vui lòng nhập mã hoặc tiền tố voucher</div>
                                </c:otherwise>
                            </c:choose>
                            <div class="form-text" id="codeHint">Hệ thống sẽ tự ghép prefix + chuỗi ngẫu nhiên khi khách
                                đổi.</div>
                        </div>

                        <!-- Số tiền giảm -->
                        <div class="col-md-6">
                            <label class="form-label">Số tiền giảm giá (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="discountAmount"
                                value="${voucher.discountAmount.intValue()}" min="1000" max="500000" step="1000" required>
                            <div class="invalid-feedback">Số tiền giảm từ 1.000đ đến 500.000đ</div>
                        </div>

                        <!-- Giá đổi điểm (chỉ LOYALTY) -->
                        <div class="col-md-4" id="pointsCostGroup">
                            <label class="form-label">Giá đổi (Điểm) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="pointsCost" id="pointsCost"
                                   value="${voucher.pointsCost}" min="0" max="1000">
                            <div class="form-text">Số điểm khách cần tiêu để lấy voucher này.</div>
                            <div class="invalid-feedback">Số điểm từ 0 đến 1000</div>
                        </div>

                        <!-- Lượt dùng tối đa -->
                        <div class="col-md-4">
                            <label class="form-label">Lượt dùng tối đa</label>
                            <input type="number" class="form-control" name="maxUsage" id="maxUsage"
                                   value="${voucher.maxUsageLimit}" min="1" max="100">
                            <div class="form-text" id="usageHint">Nhập số lượt dùng tối đa.</div>
                            <div class="invalid-feedback">Lượt dùng tối đa từ 1 đến 100</div>
                        </div>

                        <!-- Lượt dùng hiện tại -->
                        <div class="col-md-4">
                            <label class="form-label">Lượt dùng hiện tại</label>
                            <input type="number" class="form-control" name="currentUsage"
                                   value="${voucher.currentUsage}" min="0" max="${voucher.maxUsageLimit}">
                            <div class="form-text">Số lượt voucher đã được sử dụng.</div>
                            <div class="invalid-feedback">Số lượt đã được sử dụng phải nhỏ hơn ${voucher.maxUsageLimit}</div>
                        </div>

                        <!-- Hạn sử dụng -->
                        <div class="col-md-4">
                            <label class="form-label">Hạn sử dụng (Ngày) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="validDays" value="${voucher.validDays}"
                                   min="1" max="30" required>
                            <div class="form-text">Với LOYALTY: tính từ lúc khách đổi quà thành công.</div>
                            <div class="invalid-feedback">Hạn sử dụng từ 1 đến 30 ngày</div>
                        </div>

                        <!-- Trạng thái -->
                        <div class="col-md-4">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="isActive">
                                <option value="1" ${voucher.isActive ? 'selected' : '' }>Hoạt động</option>
                                <option value="0" ${!voucher.isActive ? 'selected' : '' }>Tạm ngưng</option>
                            </select>
                        </div>

                        <!-- Buttons -->
                        <div class="col-12 mt-4 pt-3 border-top">
                            <button type="submit" class="btn btn-orange px-5 me-2">
                                <i class="fas fa-save me-2"></i>Cập nhật Voucher
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/manage-vouchers"
                                class="btn btn-secondary px-4">
                                <i class="fas fa-arrow-left me-2"></i>Hủy
                            </a>
                        </div>

                    </form>
                </div>
            </main>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                // Bootstrap validation
                (function () {
                    'use strict';
                    var forms = document.querySelectorAll('.needs-validation');
                    Array.prototype.slice.call(forms).forEach(function (form) {
                        form.addEventListener('submit', function (event) {
                            if (!form.checkValidity()) {
                                event.preventDefault();
                                event.stopPropagation();
                            }
                            form.classList.add('was-validated');
                        }, false);
                    });
                })();

                const voucherType = document.getElementById('voucherType');
                const codeLabel = document.getElementById('codeLabel');
                const codeHint = document.getElementById('codeHint');
                const voucherCode = document.getElementById('voucherCode');
                const pointsGroup = document.getElementById('pointsCostGroup');
                const pointsCost = document.getElementById('pointsCost');

                function handleTypeChange() {
                    if (voucherType.value === 'PUBLIC') {
                        codeLabel.innerHTML = 'Nhập mã khuyến mãi';
                        codeHint.innerText = 'Khách hàng phải gõ đúng mã này khi thanh toán.';
                        voucherCode.placeholder = 'VD: TET2026';
                        voucherCode.required = true;

                        pointsGroup.style.display = 'none';
                        pointsCost.required = false;
                        pointsCost.disabled = true;

                        document.getElementById('maxUsage').readOnly = false;
                        document.getElementById('usageHint').innerText = 'Nhập số lượt dùng tối đa.';
                    } else {
                        codeLabel.innerHTML = 'Tiền tố Mã (Prefix)';
                        codeHint.innerText = 'Hệ thống sẽ tự ghép prefix + chuỗi ngẫu nhiên khi khách đổi.';
                        voucherCode.placeholder = 'VD: SALE50K-';
                        voucherCode.required = false;

                        pointsGroup.style.display = 'block';
                        pointsCost.required = true;
                        pointsCost.disabled = false;

                        document.getElementById('maxUsage').readOnly = false;
                        document.getElementById('usageHint').innerText = 'Nhập số lượt dùng tối đa.';
                    }
                }

                handleTypeChange();
            </script>
        </body>

        </html>