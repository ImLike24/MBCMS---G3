<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Xác nhận Huỷ Suất Chiếu</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
                <style>
                    .form-card {
                        background: #fff;
                        border-radius: 12px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, .08);
                    }

                    .section-label {
                        font-size: .75rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .8px;
                        color: #d96c2c;
                    }

                    .danger-zone {
                        background: #fff5f5;
                        border: 1px solid #fca5a5;
                        border-radius: 10px;
                    }

                    .stat-pill {
                        border-radius: 50px;
                        padding: 6px 18px;
                        font-weight: 600;
                        font-size: .9rem;
                    }

                    .ticket-row-online {
                        border-left: 3px solid #0d6efd;
                    }

                    .ticket-row-counter {
                        border-left: 3px solid #f59e0b;
                    }

                    .refund-badge {
                        font-size: .75rem;
                        border-radius: 4px;
                        padding: 2px 8px;
                    }
                </style>
            </head>

            <body>

                <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
                <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
                    <jsp:param name="page" value="showtimes" />
                </jsp:include>

                <main>
                    <div class="container-fluid">

                        <!-- Header -->
                        <div class="d-flex align-items-center mb-4">
                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                class="btn btn-outline-secondary btn-sm me-3">
                                <i class="fa-solid fa-arrow-left me-1"></i>Quay lại
                            </a>
                            <div>
                                <h3 class="fw-bold text-danger mb-0">
                                    <i class="fa-solid fa-triangle-exclamation me-2"></i>Xác nhận Huỷ Suất Chiếu
                                </h3>
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb mb-0 mt-1">
                                        <li class="breadcrumb-item">
                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                class="text-decoration-none text-secondary">Suất chiếu</a>
                                        </li>
                                        <li class="breadcrumb-item active text-danger">Huỷ suất chiếu</li>
                                    </ol>
                                </nav>
                            </div>
                        </div>

                        <div class="row g-4">

                            <!-- Left: Showtime info + reason form -->
                            <div class="col-lg-7">

                                <!-- Showtime summary card -->
                                <div class="form-card p-4 mb-4">
                                    <p class="section-label mb-3"><i class="fa-solid fa-film me-1"></i>Suất chiếu sẽ bị
                                        huỷ</p>
                                    <div class="row g-3">
                                        <div class="col-6">
                                            <div class="small text-muted mb-1">Phim</div>
                                            <div class="fw-bold">${movie.title}</div>
                                            <div class="text-muted small">${movie.duration} phút</div>
                                        </div>
                                        <div class="col-6">
                                            <div class="small text-muted mb-1">ID Suất chiếu</div>
                                            <div class="fw-bold" style="color:#d96c2c;">#${showtime.showtimeId}</div>
                                        </div>
                                        <div class="col-6">
                                            <div class="small text-muted mb-1">Ngày chiếu</div>
                                            <div class="fw-semibold">
                                                <fmt:parseDate value="${showtime.showDate}" pattern="yyyy-MM-dd"
                                                    var="sd" type="date" />
                                                <fmt:formatDate value="${sd}" pattern="dd/MM/yyyy" />
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="small text-muted mb-1">Khung giờ</div>
                                            <div class="fw-semibold">${showtime.startTime} → ${showtime.endTime}</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Affected bookings table -->
                                <div class="form-card p-4 mb-4">
                                    <p class="section-label mb-3">
                                        <i class="fa-solid fa-ticket me-1"></i>Vé đã bán / đặt chỗ bị ảnh hưởng
                                        <span class="badge bg-danger ms-2">${affected.size()} vé</span>
                                    </p>

                                    <c:choose>
                                        <c:when test="${empty affected}">
                                            <div class="text-center py-4 text-muted">
                                                <i class="fa-solid fa-circle-check fa-2x text-success mb-2 d-block"></i>
                                                Chưa có vé nào được bán cho suất chiếu này. An toàn để huỷ.
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="table-responsive">
                                                <table class="table table-sm align-middle mb-0">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>Mã vé</th>
                                                            <th>Khách hàng</th>
                                                            <th>Kênh</th>
                                                            <th class="text-end">Số tiền</th>
                                                            <th>Hoàn tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="b" items="${affected}">
                                                            <tr
                                                                class="${b.source == 'ONLINE' ? 'ticket-row-online' : 'ticket-row-counter'}">
                                                                <td class="fw-semibold">${b.bookingCode}</td>
                                                                <td>
                                                                    <div>${b.customerName}</div>
                                                                    <div class="text-muted small">${b.customerEmail}
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${b.source == 'ONLINE'}">
                                                                            <span class="badge bg-primary">Online</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                class="badge bg-warning text-dark">Quầy</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td class="text-end fw-semibold">
                                                                    <fmt:formatNumber value="${b.finalAmount}"
                                                                        type="number" groupingUsed="true" /> ₫
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${b.source == 'ONLINE' and (b.paymentStatus == 'PAID' or b.paymentStatus == 'COMPLETED')}">
                                                                            <span
                                                                                class="refund-badge bg-info text-dark">Tự
                                                                                động hoàn</span>
                                                                        </c:when>
                                                                        <c:when test="${b.source == 'COUNTER'}">
                                                                            <span
                                                                                class="refund-badge bg-warning text-dark">Hoàn
                                                                                tay</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                class="refund-badge bg-secondary text-white">Không
                                                                                cần</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Cancellation form -->
                                <div class="form-card p-4 danger-zone">
                                    <p class="section-label text-danger mb-3">
                                        <i class="fa-solid fa-ban me-1"></i>Xác nhận huỷ
                                    </p>
                                    <form method="post"
                                        action="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                        id="cancelForm">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="showtimeId" value="${showtime.showtimeId}">

                                        <div class="mb-3">
                                            <label for="reason" class="form-label fw-semibold">
                                                Lý do huỷ <span class="text-danger">*</span>
                                            </label>
                                            <textarea id="reason" name="reason" rows="3" class="form-control" required
                                                placeholder="Ví dụ: Sự cố kỹ thuật, thay đổi lịch chiếu, ..."></textarea>
                                            <div class="form-text text-muted">
                                                Lý do này sẽ được ghi lại trên tất cả các đơn đặt vé liên quan.
                                            </div>
                                        </div>

                                        <!-- Confirm checkbox -->
                                        <div class="form-check mb-4">
                                            <input class="form-check-input" type="checkbox" id="confirmCheck" required>
                                            <label class="form-check-label fw-semibold text-danger" for="confirmCheck">
                                                Tôi xác nhận muốn huỷ suất chiếu này và kích hoạt quy trình hoàn tiền
                                                cho
                                                <strong>${affected.size()}</strong> vé.
                                            </label>
                                        </div>

                                        <div class="d-flex gap-3 justify-content-end">
                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                class="btn btn-outline-secondary px-4">
                                                <i class="fa-solid fa-arrow-left me-1"></i>Không, quay lại
                                            </a>
                                            <button type="submit" class="btn btn-danger px-5 fw-semibold" id="submitBtn"
                                                disabled>
                                                <i class="fa-solid fa-ban me-2"></i>Huỷ suất chiếu
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Right: Impact summary -->
                            <div class="col-lg-5">
                                <div class="form-card p-4 mb-4">
                                    <p class="section-label mb-3"><i class="fa-solid fa-chart-bar me-1"></i>Tóm tắt ảnh
                                        hưởng</p>

                                    <%-- Compute totals server-side --%>
                                        <c:set var="onlineCount" value="0" />
                                        <c:set var="counterCount" value="0" />
                                        <c:set var="totalAmt" value="0" />
                                        <c:forEach var="b" items="${affected}">
                                            <c:if test="${b.source == 'ONLINE'}">
                                                <c:set var="onlineCount" value="${onlineCount + 1}" />
                                            </c:if>
                                            <c:if test="${b.source == 'COUNTER'}">
                                                <c:set var="counterCount" value="${counterCount + 1}" />
                                            </c:if>
                                        </c:forEach>

                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <span class="text-muted">Vé online bị ảnh hưởng</span>
                                            <span class="stat-pill bg-primary text-white">${onlineCount}</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <span class="text-muted">Vé quầy bị ảnh hưởng</span>
                                            <span class="stat-pill bg-warning text-dark">${counterCount}</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <span class="text-muted">Tổng vé</span>
                                            <span class="stat-pill bg-danger text-white">${affected.size()}</span>
                                        </div>
                                        <hr>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="text-muted fw-semibold">Tổng tiền hoàn dự kiến</span>
                                            <span class="fw-bold text-danger fs-5" id="totalRefundDisplay">Đang
                                                tính...</span>
                                        </div>
                                </div>

                                <div class="form-card p-4 mb-4">
                                    <p class="section-label mb-2"><i class="fa-solid fa-circle-info me-1"></i>Quy trình
                                        hoàn tiền</p>
                                    <ul class="small text-muted ps-3 mb-0">
                                        <li class="mb-2">
                                            <span class="badge bg-primary me-1">Online</span>
                                            Đơn được đánh dấu <code>REFUND_PENDING</code> — bộ phận tài chính xử lý hoàn
                                            trả.
                                        </li>
                                        <li class="mb-2">
                                            <span class="badge bg-warning text-dark me-1">Quầy</span>
                                            Hoàn tiền mặt tại quầy — nhân viên liên hệ khách hàng trực tiếp.
                                        </li>
                                        <li>
                                            Lý do huỷ sẽ được lưu vào tất cả các đơn liên quan.
                                        </li>
                                    </ul>
                                </div>

                                <div class="form-card p-4">
                                    <p class="section-label mb-2 text-danger"><i
                                            class="fa-solid fa-triangle-exclamation me-1"></i>Cảnh báo</p>
                                    <ul class="small text-muted ps-3 mb-0">
                                        <li class="mb-1">Hành động này <strong>không thể hoàn tác</strong>.</li>
                                        <li class="mb-1">Suất chiếu sẽ bị đánh dấu <strong>CANCELLED</strong> ngay lập
                                            tức.</li>
                                        <li>Tất cả ghế đã đặt sẽ được giải phóng.</li>
                                    </ul>
                                </div>
                            </div>

                        </div>
                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    // Enable submit only when checkbox ticked + reason filled
                    const check = document.getElementById('confirmCheck');
                    const reason = document.getElementById('reason');
                    const btn = document.getElementById('submitBtn');

                    function toggleBtn() {
                        btn.disabled = !(check.checked && reason.value.trim().length > 0);
                    }
                    check.addEventListener('change', toggleBtn);
                    reason.addEventListener('input', toggleBtn);

                    // Compute total refund from table
                    let total = 0;
                    document.querySelectorAll('tbody tr').forEach(row => {
                        const amtCell = row.cells[3];
                        if (amtCell) {
                            const txt = amtCell.textContent.replace(/[^0-9]/g, '');
                            total += parseInt(txt) || 0;
                        }
                    });
                    document.getElementById('totalRefundDisplay').textContent =
                        total > 0 ? total.toLocaleString('vi-VN') + ' ₫' : '0 ₫ (không có vé)';
                </script>
            </body>

            </html>