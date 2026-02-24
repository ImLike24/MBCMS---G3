<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Lên lịch Suất Chiếu</title>
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

                .movie-option-detail {
                    font-size: 0.8rem;
                    color: #6c757d;
                }

                .required-star::after {
                    content: " *";
                    color: #dc3545;
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
                                <i class="fa-solid fa-calendar-plus me-2" style="color:#d96c2c;"></i>Lên lịch Suất Chiếu
                            </h3>
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb mb-0 mt-1">
                                    <li class="breadcrumb-item"><a
                                            href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                            class="text-decoration-none text-secondary">Suất chiếu</a></li>
                                    <li class="breadcrumb-item active" style="color:#d96c2c;">Lên lịch mới</li>
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
                                <form id="scheduleForm" method="post"
                                    action="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                    novalidate>
                                    <input type="hidden" name="action" value="create">

                                    <!-- Movie -->
                                    <div class="mb-4">
                                        <p class="section-label mb-2"><i class="fa-solid fa-film me-1"></i>Thông tin
                                            phim</p>
                                        <label for="movieId" class="form-label fw-semibold required-star">Chọn
                                            phim</label>
                                        <select id="movieId" name="movieId" class="form-select" required>
                                            <option value="">-- Chọn phim --</option>
                                            <c:forEach var="m" items="${movies}">
                                                <option value="${m.movieId}" data-duration="${m.duration}"
                                                    ${prefMovieId==m.movieId ? 'selected' : '' }>
                                                    ${m.title} (${m.duration} phút)
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div id="movieInfo" class="text-muted small mt-1" style="display:none;">
                                            <i class="fa-regular fa-clock me-1"></i>Thời lượng: <span
                                                id="movieDurationDisplay"></span> phút
                                        </div>
                                    </div>

                                    <hr>

                                    <!-- Room + Date + Time -->
                                    <div class="mb-4">
                                        <p class="section-label mb-2"><i class="fa-solid fa-door-open me-1"></i>Thời
                                            gian & Phòng chiếu</p>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label for="roomId" class="form-label fw-semibold required-star">Phòng
                                                    chiếu</label>
                                                <select id="roomId" name="roomId" class="form-select" required>
                                                    <option value="">-- Chọn phòng chiếu --</option>
                                                    <c:forEach var="r" items="${rooms}">
                                                        <option value="${r.roomId}" ${prefRoomId==r.roomId ? 'selected'
                                                            : '' }>
                                                            ${r.roomName} (${r.totalSeats} ghế)
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="showDate" class="form-label fw-semibold required-star">Ngày
                                                    chiếu</label>
                                                <input type="date" id="showDate" name="showDate" class="form-control"
                                                    required min="${java.time.LocalDate.now()}" value="${prefDate}">
                                            </div>
                                            <div class="col-md-6">
                                                <label for="startTime" class="form-label fw-semibold required-star">Giờ
                                                    bắt đầu</label>
                                                <input type="time" id="startTime" name="startTime" class="form-control"
                                                    required value="${prefStartTime}">
                                            </div>
                                            <div class="col-md-6">
                                                <label for="endTime" class="form-label fw-semibold">Giờ kết thúc</label>
                                                <input type="time" id="endTime" name="endTime" class="form-control"
                                                    readonly style="background:#f8f9fa;">
                                                <small class="text-muted">Tự động tính từ thời lượng phim</small>
                                            </div>
                                        </div>
                                    </div>

                                    <hr>

                                    <!-- Pricing -->
                                    <div class="mb-4">
                                        <p class="section-label mb-2"><i class="fa-solid fa-tag me-1"></i>Giá vé</p>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label for="basePrice" class="form-label fw-semibold required-star">Giá
                                                    cơ bản (VNĐ)</label>
                                                <div class="input-group">
                                                    <input type="number" id="basePrice" name="basePrice"
                                                        class="form-control" min="0" step="1000" required
                                                        placeholder="70000" value="${prefPrice}">
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
                                            <i class="fa-solid fa-calendar-check me-2"></i>Lên lịch
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Info / Preview Column -->
                        <div class="col-lg-4">
                            <div class="form-card p-4 mb-3">
                                <p class="section-label mb-3"><i class="fa-solid fa-circle-info me-1"></i>Xem trước</p>
                                <div class="preview-box p-3">
                                    <div class="mb-2">
                                        <div class="small text-muted">Phim</div>
                                        <div class="fw-semibold" id="previewMovie">—</div>
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

                            <div class="form-card p-4">
                                <p class="section-label mb-2"><i class="fa-solid fa-lightbulb me-1"></i>Lưu ý</p>
                                <ul class="small text-muted ps-3 mb-0">
                                    <li class="mb-1">Giờ kết thúc được tự động tính = Giờ bắt đầu + Thời lượng phim.
                                    </li>
                                    <li class="mb-1">Hệ thống tự kiểm tra xung đột lịch phòng chiếu.</li>
                                    <li class="mb-1">Chỉ phòng đang <strong>hoạt động</strong> mới được chọn.</li>
                                    <li>Ngày chiếu phải từ hôm nay trở đi.</li>
                                </ul>
                            </div>
                        </div>
                    </div>

                </div>
            </main>

            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            <script>
                // Movie duration map
                const movieSelect = document.getElementById('movieId');
                const roomSelect = document.getElementById('roomId');
                const startInput = document.getElementById('startTime');
                const endInput = document.getElementById('endTime');
                const showDate = document.getElementById('showDate');
                const priceInput = document.getElementById('basePrice');

                // Set min date to today
                const today = new Date().toISOString().split('T')[0];
                document.getElementById('showDate').setAttribute('min', today);
                if (!document.getElementById('showDate').value) {
                    document.getElementById('showDate').value = today;
                }

                function getDuration() {
                    const opt = movieSelect.options[movieSelect.selectedIndex];
                    return parseInt(opt ? opt.dataset.duration : '0') || 0;
                }

                function calcEndTime() {
                    const duration = getDuration();
                    const startVal = startInput.value;
                    if (!startVal || !duration) { endInput.value = ''; return; }
                    const [h, m] = startVal.split(':').map(Number);
                    const totalMin = h * 60 + m + duration;
                    const eh = Math.floor(totalMin / 60) % 24;
                    const em = totalMin % 60;
                    endInput.value = String(eh).padStart(2, '0') + ':' + String(em).padStart(2, '0');
                    updatePreview();
                }

                function updatePreview() {
                    const movieText = movieSelect.options[movieSelect.selectedIndex]?.text || '—';
                    const roomText = roomSelect.options[roomSelect.selectedIndex]?.text || '—';
                    const dateVal = showDate.value ? new Date(showDate.value).toLocaleDateString('vi-VN') : '—';
                    const startVal = startInput.value || '—';
                    const endVal = endInput.value || '—';
                    const price = priceInput.value ? parseInt(priceInput.value).toLocaleString('vi-VN') + ' ₫' : '—';

                    document.getElementById('previewMovie').textContent = movieText !== '-- Chọn phim --' ? movieText : '—';
                    document.getElementById('previewRoom').textContent = roomText !== '-- Chọn phòng chiếu --' ? roomText : '—';
                    document.getElementById('previewDate').textContent = dateVal;
                    document.getElementById('previewTime').textContent = startVal !== '—' ? startVal + ' → ' + endVal : '—';
                    document.getElementById('previewPrice').textContent = price;
                }

                function onMovieChange() {
                    const duration = getDuration();
                    const infoBox = document.getElementById('movieInfo');
                    if (duration > 0) {
                        document.getElementById('movieDurationDisplay').textContent = duration;
                        infoBox.style.display = 'block';
                    } else {
                        infoBox.style.display = 'none';
                    }
                    calcEndTime();
                }

                movieSelect.addEventListener('change', onMovieChange);
                startInput.addEventListener('change', calcEndTime);
                priceInput.addEventListener('input', updatePreview);
                roomSelect.addEventListener('change', updatePreview);
                showDate.addEventListener('change', updatePreview);

                // Init on load
                onMovieChange();
                updatePreview();

                // Form validation
                document.getElementById('scheduleForm').addEventListener('submit', function (e) {
                    const movie = movieSelect.value;
                    const room = roomSelect.value;
                    const date = showDate.value;
                    const start = startInput.value;
                    const end = endInput.value;
                    const price = priceInput.value;

                    if (!movie || !room || !date || !start || !end || !price) {
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