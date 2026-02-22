<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Chỉnh sửa Suất Chiếu</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
                <style>
                    .form-card {
                        background: #fff;
                        border-radius: 12px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
                    }

                    .section-label {
                        font-size: 0.75rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.8px;
                        color: #d96c2c;
                    }

                    .preview-box {
                        background: #f8f9fa;
                        border-radius: 8px;
                        border: 1px dashed #dee2e6;
                    }

                    .btn-orange {
                        background-color: #d96c2c;
                        border-color: #d96c2c;
                        color: #fff;
                    }

                    .btn-orange:hover {
                        background-color: #b85a22;
                        border-color: #b85a22;
                        color: #fff;
                    }

                    .required-star::after {
                        content: " *";
                        color: #dc3545;
                    }

                    .info-readonly {
                        background: #f0f4ff;
                        border: 1px solid #c7d2fe;
                        border-radius: 8px;
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
                        <!-- Page Header -->
                        <div class="d-flex align-items-center mb-4">
                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                class="btn btn-outline-secondary btn-sm me-3">
                                <i class="fa-solid fa-arrow-left me-1"></i>Quay lại
                            </a>
                            <div>
                                <h3 class="fw-bold text-dark mb-0">
                                    <i class="fa-solid fa-calendar-days me-2" style="color:#d96c2c;"></i>
                                    Chỉnh sửa Suất Chiếu <span class="text-muted fs-5">#${showtime.showtimeId}</span>
                                </h3>
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb mb-0 mt-1">
                                        <li class="breadcrumb-item">
                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                class="text-decoration-none text-secondary">Suất chiếu</a>
                                        </li>
                                        <li class="breadcrumb-item active" style="color:#d96c2c;">Chỉnh sửa</li>
                                    </ol>
                                </nav>
                            </div>
                        </div>

                        <!-- Error Alert -->
                        <c:if test="${not empty errorMsg}">
                            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                                <i class="fa-solid fa-triangle-exclamation me-2"></i>${errorMsg}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <div class="row g-4">
                            <!-- Form Column -->
                            <div class="col-lg-8">
                                <div class="form-card p-4">

                                    <!-- Current movie (readonly) -->
                                    <div class="mb-4 info-readonly p-3">
                                        <p class="section-label mb-2"><i class="fa-solid fa-film me-1"></i>Phim (không
                                            thể thay đổi)</p>
                                        <div class="fw-bold fs-6">${currentMovie.title}</div>
                                        <div class="text-muted small mt-1">
                                            <i class="fa-regular fa-clock me-1"></i>${currentMovie.duration} phút
                                            <c:if test="${not empty currentMovie.ageRating}">
                                                &nbsp;·&nbsp; <span
                                                    class="badge bg-warning text-dark">${currentMovie.ageRating}</span>
                                            </c:if>
                                        </div>
                                    </div>

                                    <form id="editForm" method="post"
                                        action="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                        data-duration="${currentMovie.duration}" novalidate>
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="showtimeId" value="${showtime.showtimeId}">
                                        <input type="hidden" name="movieId" value="${showtime.movieId}">

                                        <!-- Room + Date + Time -->
                                        <div class="mb-4">
                                            <p class="section-label mb-2"><i
                                                    class="fa-solid fa-door-open me-1"></i>Phòng & Thời gian</p>
                                            <div class="row g-3">
                                                <div class="col-md-6">
                                                    <label for="roomId"
                                                        class="form-label fw-semibold required-star">Phòng chiếu</label>
                                                    <select id="roomId" name="roomId" class="form-select" required>
                                                        <c:forEach var="r" items="${rooms}">
                                                            <option value="${r.roomId}" ${(not empty prefRoomId and
                                                                prefRoomId==r.roomId) ? 'selected' : (empty prefRoomId
                                                                and showtime.roomId==r.roomId) ? 'selected' : '' }>
                                                                ${r.roomName} (${r.totalSeats} ghế)
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-md-6">
                                                    <label for="showDate"
                                                        class="form-label fw-semibold required-star">Ngày chiếu</label>
                                                    <input type="date" id="showDate" name="showDate"
                                                        class="form-control" required
                                                        value="${not empty prefDate ? prefDate : showtime.showDate}">
                                                </div>
                                                <div class="col-md-6">
                                                    <label for="startTime"
                                                        class="form-label fw-semibold required-star">Giờ bắt đầu</label>
                                                    <input type="time" id="startTime" name="startTime"
                                                        class="form-control" required
                                                        value="${not empty prefStartTime ? prefStartTime : showtime.startTime}">
                                                </div>
                                                <div class="col-md-6">
                                                    <label for="endTime" class="form-label fw-semibold">Giờ kết
                                                        thúc</label>
                                                    <input type="time" id="endTime" name="endTime" class="form-control"
                                                        readonly style="background:#f8f9fa;"
                                                        value="${showtime.endTime}">
                                                    <small class="text-muted">Tự động tính từ thời lượng phim
                                                        (${currentMovie.duration} phút)</small>
                                                </div>
                                            </div>
                                        </div>

                                        <hr>

                                        <!-- Pricing -->
                                        <div class="mb-4">
                                            <p class="section-label mb-2"><i class="fa-solid fa-tag me-1"></i>Giá vé</p>
                                            <div class="row g-3">
                                                <div class="col-md-6">
                                                    <label for="basePrice"
                                                        class="form-label fw-semibold required-star">Giá cơ bản
                                                        (VNĐ)</label>
                                                    <div class="input-group">
                                                        <input type="number" id="basePrice" name="basePrice"
                                                            class="form-control" min="0" step="1000" required
                                                            value="${not empty prefPrice ? prefPrice : showtime.basePrice}">
                                                        <span class="input-group-text">₫</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Submit -->
                                        <div class="d-flex gap-3 justify-content-end pt-2">
                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                class="btn btn-outline-secondary px-4">Hủy</a>
                                            <button type="submit" class="btn btn-orange px-5 fw-semibold">
                                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Preview + Info Column -->
                            <div class="col-lg-4">
                                <div class="form-card p-4 mb-3">
                                    <p class="section-label mb-3"><i class="fa-solid fa-circle-info me-1"></i>Xem trước
                                    </p>
                                    <div class="preview-box p-3">
                                        <div class="mb-2">
                                            <div class="small text-muted">Phim</div>
                                            <div class="fw-semibold">${currentMovie.title}</div>
                                        </div>
                                        <div class="mb-2">
                                            <div class="small text-muted">Phòng</div>
                                            <div class="fw-semibold" id="previewRoom">—</div>
                                        </div>
                                        <div class="mb-2">
                                            <div class="small text-muted">Ngày chiếu</div>
                                            <div class="fw-semibold" id="previewDate">—</div>
                                        </div>
                                        <div class="mb-2">
                                            <div class="small text-muted">Khung giờ</div>
                                            <div class="fw-semibold" id="previewTime">—</div>
                                        </div>
                                        <div>
                                            <div class="small text-muted">Giá cơ bản</div>
                                            <div class="fw-semibold text-success" id="previewPrice">—</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Original info card -->
                                <div class="form-card p-4 mb-3">
                                    <p class="section-label mb-2"><i class="fa-solid fa-history me-1"></i>Thông tin gốc
                                    </p>
                                    <div class="small">
                                        <div class="d-flex justify-content-between mb-1">
                                            <span class="text-muted">Ngày gốc:</span>
                                            <span class="fw-semibold">
                                                <fmt:parseDate value="${showtime.showDate}" pattern="yyyy-MM-dd"
                                                    var="origDate" type="date" />
                                                <fmt:formatDate value="${origDate}" pattern="dd/MM/yyyy" />
                                            </span>
                                        </div>
                                        <div class="d-flex justify-content-between mb-1">
                                            <span class="text-muted">Giờ gốc:</span>
                                            <span class="fw-semibold">${showtime.startTime} → ${showtime.endTime}</span>
                                        </div>
                                        <div class="d-flex justify-content-between">
                                            <span class="text-muted">Giá gốc:</span>
                                            <span class="fw-semibold">
                                                <fmt:formatNumber value="${showtime.basePrice}" type="number"
                                                    groupingUsed="true" /> ₫
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-card p-4">
                                    <p class="section-label mb-2"><i
                                            class="fa-solid fa-triangle-exclamation me-1"></i>Lưu ý</p>
                                    <ul class="small text-muted ps-3 mb-0">
                                        <li class="mb-1">Chỉ suất chiếu ở trạng thái <strong>Đã lên lịch</strong> mới có
                                            thể chỉnh sửa.</li>
                                        <li class="mb-1">Hệ thống kiểm tra xung đột giờ chiếu khi thay đổi phòng hoặc
                                            giờ.</li>
                                        <li>Giờ kết thúc tự động cập nhật theo giờ bắt đầu mới.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    const DURATION = parseInt(document.getElementById('editForm').dataset.duration, 10) || 0;  // movie duration in minutes
                    const roomSelect = document.getElementById('roomId');
                    const startInput = document.getElementById('startTime');
                    const endInput = document.getElementById('endTime');
                    const showDate = document.getElementById('showDate');
                    const priceInput = document.getElementById('basePrice');

                    function calcEndTime() {
                        const startVal = startInput.value;
                        if (!startVal || !DURATION) { endInput.value = ''; return; }
                        const [h, m] = startVal.split(':').map(Number);
                        const totalMin = h * 60 + m + DURATION;
                        const eh = Math.floor(totalMin / 60) % 24;
                        const em = totalMin % 60;
                        endInput.value = String(eh).padStart(2, '0') + ':' + String(em).padStart(2, '0');
                        updatePreview();
                    }

                    function updatePreview() {
                        const roomText = roomSelect.options[roomSelect.selectedIndex]?.text || '—';
                        const dateVal = showDate.value ? new Date(showDate.value + 'T00:00:00').toLocaleDateString('vi-VN') : '—';
                        const startVal = startInput.value || '—';
                        const endVal = endInput.value || '—';
                        const price = priceInput.value ? parseInt(priceInput.value).toLocaleString('vi-VN') + ' ₫' : '—';

                        document.getElementById('previewRoom').textContent = roomText;
                        document.getElementById('previewDate').textContent = dateVal;
                        document.getElementById('previewTime').textContent = startVal !== '—' ? startVal + ' → ' + endVal : '—';
                        document.getElementById('previewPrice').textContent = price;
                    }

                    startInput.addEventListener('change', calcEndTime);
                    roomSelect.addEventListener('change', updatePreview);
                    showDate.addEventListener('change', updatePreview);
                    priceInput.addEventListener('input', updatePreview);

                    // Init
                    calcEndTime();
                    updatePreview();

                    // Form validation
                    document.getElementById('editForm').addEventListener('submit', function (e) {
                        const start = startInput.value;
                        const end = endInput.value;
                        const price = priceInput.value;

                        if (!start || !end || !price) {
                            e.preventDefault();
                            alert('Vui lòng điền đầy đủ thông tin bắt buộc.');
                            return;
                        }
                        if (parseFloat(price) < 0) {
                            e.preventDefault();
                            alert('Giá vé không được âm.');
                        }
                    });
                </script>
            </body>

            </html>