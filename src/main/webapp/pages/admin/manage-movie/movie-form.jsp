<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${mode == 'edit' ? 'Chỉnh sửa Phim' : 'Thêm Phim Mới'} - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body { margin-left: 350px; margin-right: 80px; }
        .genre-checkbox { min-width: 140px; }
        .form-section {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
            max-width: 1200px;
        }
        .form-header {
            background: linear-gradient(135deg, #0d6efd, #6610f2);
            color: white;
            padding: 1.5rem 2rem;
        }
        .poster-preview {
            max-width: 100%;
            width: 240px;
            height: 360px;
            border-radius: 10px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            object-fit: cover;
            border: 4px solid #fff;
            background: #f8f9fa;
        }
        .genre-container {
            max-height: 240px;
            overflow-y: auto;
            padding: 1rem;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            background: #f8f9fa;
        }
        .btn-orange {
            background-color: #fd7e14;
            border-color: #fd7e14;
        }
        .btn-orange:hover {
            background-color: #e06b00;
            border-color: #e06b00;
        }
        .required::after { content: " *"; color: #dc3545; }
        .upload-area {
            border: 2px dashed #dee2e6;
            border-radius: 10px;
            padding: 1.5rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        .upload-area:hover {
            border-color: #0d6efd;
            background: #f0f6ff;
        }
        #uploadStatus { font-size: 0.9rem; margin-top: 8px; min-height: 1.2em; }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/>
</jsp:include>

<main class="container-fluid py-4">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-4">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin" class="text-decoration-none">Admin</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/movies" class="text-decoration-none">Quản lý Phim</a></li>
            <li class="breadcrumb-item active" aria-current="page">${mode == 'edit' ? 'Chỉnh sửa' : 'Thêm mới'}</li>
        </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold mb-0">
            <i class="fas fa-film me-2 text-primary"></i>
            ${mode == 'edit' ? 'Chỉnh sửa phim' : 'Thêm phim mới'}
        </h3>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="card form-section border-0">
        <div class="form-header">
            <h4 class="mb-0">${mode == 'edit' ? 'Cập nhật thông tin phim' : 'Nhập thông tin phim mới'}</h4>
            <small>Điền đầy đủ các trường bắt buộc (*)</small>
        </div>
        <div class="card-body p-4">
            <form id="movieForm" action="${pageContext.request.contextPath}/admin/movies/${mode == 'edit' ? 'edit' : 'add'}"
                  method="post" class="row g-4 needs-validation" novalidate>

                <c:if test="${mode == 'edit'}">
                    <input type="hidden" name="id" value="${movie.movieId}">
                </c:if>

                <input type="hidden" name="posterUrl" id="posterUrl" value="${movie.posterUrl}">

                <!-- Cột trái -->
                <div class="col-lg-8">
                    <div class="mb-3">
                        <label class="form-label fw-semibold required">Tên phim</label>
                        <input type="text" class="form-control form-control-lg" name="title" value="${movie.title}" required autofocus>
                        <div class="invalid-feedback">Vui lòng nhập tên phim</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Mô tả phim</label>
                        <textarea class="form-control" name="description" rows="5">${movie.description}</textarea>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold required">Thời lượng (phút)</label>
                            <input type="number" class="form-control" name="duration" value="${movie.duration}" min="1" max="200" required
                                   oninput="this.value = Math.max(0, Math.min(200, this.value));">
                            <div class="invalid-feedback">Thời lượng phải từ 1 đến 200 phút</div>
                        </div>
                        <c:if test="${mode == 'add'}">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold required">Đánh giá (0-5)</label>
                                <input type="number" step="0.1" class="form-control" name="rating"
                                       value="${movie.rating != null ? movie.rating : '0.0'}" min="0" max="5" required
                                       oninput="this.value = Math.max(0, Math.min(5, this.value));">
                                <div class="invalid-feedback">Đánh giá từ 0.0 đến 5.0</div>
                            </div>
                        </c:if>
                    </div>
                    <hr class="my-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Đạo diễn</label>
                            <input type="text" class="form-control" name="director" value="${movie.director}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Diễn viên chính</label>
                            <input type="text" class="form-control" name="cast" value="${movie.cast}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Ngày phát hành</label>
                            <input type="date" class="form-control" name="releaseDate"
                                   value="${movie.releaseDate != null ? movie.releaseDate : ''}"
                                   id="releaseDate">
                        </div>
                    </div>
                    <hr class="my-4">
                    <label class="form-label fw-semibold required">Thể loại</label>
                    <div class="genre-container">
                        <div class="row g-2">
                            <c:forEach var="g" items="${allGenres}">
                                <div class="col-auto genre-checkbox">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="genreIds" value="${g.genreId}" id="genre${g.genreId}"
                                               <c:if test="${movieGenres.contains(g.genreName) || (movie.genres != null && movie.genres.contains(g.genreName))}">checked</c:if>>
                                        <label class="form-check-label" for="genre${g.genreId}">${g.genreName}</label>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="invalid-feedback d-block">Vui lòng chọn ít nhất một thể loại</div>
                </div>

                <!-- Cột phải -->
                <div class="col-lg-4">
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Poster phim</label>
                        <div id="posterPreviewContainer" class="text-center mb-3">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="${movie.posterUrl}" alt="Poster" class="poster-preview" id="posterPreview">
                                </c:when>
                                <c:otherwise>
                                    <div class="poster-preview d-flex align-items-center justify-content-center text-muted" id="posterPreview">
                                        <i class="fas fa-image fa-4x"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="upload-area" id="uploadArea">
                            <input type="file" id="posterFileInput" name="posterFile" accept="image/*" style="display:none;">
                            <i class="fas fa-cloud-upload-alt fa-2x mb-2 text-primary"></i>
                            <p class="mb-1 fw-semibold">Chọn ảnh poster hoặc kéo thả</p>
                            <small class="text-muted">jpg, png, webp - tối đa 10MB</small>
                        </div>
                        <div id="uploadStatus" class="text-center text-muted"></div>
                    </div>

                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold">Độ tuổi</label>
                            <select class="form-select" name="ageRating">
                                <option value="">Chọn độ tuổi</option>
                                <option value="P" ${movie.ageRating == 'P' ? 'selected' : ''}>P - Mọi lứa tuổi</option>
                                <option value="C13" ${movie.ageRating == 'C13' ? 'selected' : ''}>C13</option>
                                <option value="C16" ${movie.ageRating == 'C16' ? 'selected' : ''}>C16</option>
                                <option value="C18" ${movie.ageRating == 'C18' ? 'selected' : ''}>C18</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold">Trạng thái</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" name="active" id="activeSwitch"
                                       ${movie.active || mode == 'add' ? 'checked' : ''}>
                                <label class="form-check-label" for="activeSwitch">Hoạt động</label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 mt-5 text-end">
                    <a href="${pageContext.request.contextPath}/admin/movies" class="btn btn-secondary px-5 me-3">
                        <i class="fas fa-arrow-left me-2"></i>Hủy
                    </a>
                    <button type="submit" class="btn btn-orange px-5">
                        <i class="fas fa-save me-2"></i>
                        ${mode == 'edit' ? 'Cập nhật phim' : 'Thêm phim mới'}
                    </button>
                </div>
            </form>
        </div>
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

// AJAX upload poster - chỉ preview, không reload trang
const uploadArea = document.getElementById('uploadArea');
const fileInput = document.getElementById('posterFileInput');
const statusDiv = document.getElementById('uploadStatus');

uploadArea.addEventListener('click', () => fileInput.click());

fileInput.addEventListener('change', async function() {
    if (!this.files || this.files.length === 0) return;

    const file = this.files[0];
    statusDiv.textContent = 'Đang upload...';
    statusDiv.className = 'text-center text-info';

    const formData = new FormData();
    formData.append('posterFile', file);
    formData.append('movieId', '${movie.movieId}');  // nếu edit
    formData.append('mode', '${mode}');

    try {
        const response = await fetch('${pageContext.request.contextPath}/admin/movies/poster/upload', {
            method: 'POST',
            body: formData
        });

        const result = await response.json();

        if (result.success && result.posterUrl) {
            // Cập nhật preview
            let preview = document.getElementById('posterPreview');
            if (!preview || preview.tagName !== 'IMG') {
                const img = document.createElement('img');
                img.id = 'posterPreview';
                img.alt = 'Poster';
                img.className = 'poster-preview';
                document.getElementById('posterPreviewContainer').innerHTML = '';
                document.getElementById('posterPreviewContainer').appendChild(img);
                preview = img;
            }
            preview.src = result.posterUrl + '?t=' + new Date().getTime(); // tránh cache

            // Cập nhật hidden field để submit form chính
            document.getElementById('posterUrl').value = result.posterUrl;

            statusDiv.textContent = 'Upload thành công!';
            statusDiv.className = 'text-center text-success';
        } else {
            statusDiv.textContent = result.message || 'Upload thất bại';
            statusDiv.className = 'text-center text-danger';
        }
    } catch (err) {
        console.error(err);
        statusDiv.textContent = 'Lỗi kết nối';
        statusDiv.className = 'text-center text-danger';
    }

    // Reset input để có thể chọn lại cùng file nếu cần
    this.value = '';
});
    // Validate ngày nhập vào
    const today = new Date().toISOString().split("T")[0];
    const dateInput = document.getElementById("releaseDate");

    // đặt ngày tối đa là hôm nay
    dateInput.max = today;

    // nếu nhập lớn hơn hôm nay thì tự chỉnh về hôm nay
    dateInput.addEventListener("input", function () {
        if (this.value > today) {
            this.value = today;
        }
    });
</script>
</body>
</html>