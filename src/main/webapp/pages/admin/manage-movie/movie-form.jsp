<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${mode == 'edit' ? 'Chỉnh sửa Phim' : 'Thêm Phim Mới'} - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
        }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/>
</jsp:include>

<main class="container-fluid py-4">
    <h3 class="mb-4">${mode == 'edit' ? 'Chỉnh sửa phim' : 'Thêm phim mới'}</h3>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Form dùng chung cho cả add và edit -->
    <form action="${pageContext.request.contextPath}/admin/movies/${mode == 'edit' ? 'edit' : 'add'}"
          method="post" class="row g-3 needs-validation" novalidate>

        <!-- Hidden field chỉ có khi edit (gửi ID phim cần update) -->
        <c:if test="${mode == 'edit'}">
            <input type="hidden" name="id" value="${movie.movieId}">
        </c:if>

        <!-- Tên phim -->
        <div class="col-md-8">
            <label class="form-label">Tên phim <span class="text-danger">*</span></label>
            <input type="text" class="form-control" name="title" value="${movie.title}" required>
            <div class="invalid-feedback">Vui lòng nhập tên phim</div>
        </div>

        <!-- Thời lượng -->
        <div class="col-md-4">
            <label class="form-label">Thời lượng (phút) <span class="text-danger">*</span></label>
            <input type="number" class="form-control" name="duration" value="${movie.duration}" min="1" required>
        </div>

        <!-- Đánh giá -->
        <div class="col-md-4">
            <label class="form-label">Đánh giá (0-5) <span class="text-danger">*</span></label>
            <input type="number" step="0.1" class="form-control" name="rating"
                   value="${movie.rating != null ? movie.rating : '0.0'}"
                   min="0" max="5"
                   required
                   oninput="if(Number(this.value) > 5) this.value = 5;
                            if(Number(this.value) < 0) this.value = 0;"
                   placeholder="Ví dụ: 2.5">
            <div class="invalid-feedback">Đánh giá phải từ 0.0 đến 5.0</div>
        </div>

        <!-- Độ tuổi -->
        <div class="col-md-4">
            <label class="form-label">Độ tuổi</label>
            <select class="form-select" name="ageRating">
                <option value="">Chọn độ tuổi</option>
                <option value="P" ${movie.ageRating == 'P' ? 'selected' : ''}>P - Mọi lứa tuổi</option>
                <option value="C13" ${movie.ageRating == 'C13' ? 'selected' : ''}>C13</option>
                <option value="C16" ${movie.ageRating == 'C16' ? 'selected' : ''}>C16</option>
                <option value="C18" ${movie.ageRating == 'C18' ? 'selected' : ''}>C18</option>
            </select>
        </div>

        <!-- Đạo diễn, Diễn viên -->
        <div class="col-md-6">
            <label class="form-label">Đạo diễn</label>
            <input type="text" class="form-control" name="director" value="${movie.director}">
        </div>
        <div class="col-md-6">
            <label class="form-label">Diễn viên chính</label>
            <input type="text" class="form-control" name="cast" value="${movie.cast}">
        </div>

        <!-- Poster URL -->
        <div class="col-12">
            <label class="form-label">Link Poster (URL)</label>
            <input type="url" class="form-control" name="posterUrl" value="${movie.posterUrl}">
        </div>

        <!-- Ngày phát hành -->
        <div class="col-md-4">
            <label class="form-label">Ngày phát hành</label>
            <input type="date" class="form-control" name="releaseDate"
                   value="${movie.releaseDate != null ? movie.releaseDate : ''}">
        </div>

        <!-- Trạng thái -->
        <div class="col-md-4">
            <label class="form-label">Trạng thái</label>
            <div class="form-check form-switch mt-2">
                <input class="form-check-input" type="checkbox" name="active" id="activeSwitch"
                       ${movie.active || mode == 'add' ? 'checked' : ''}>
                <label class="form-check-label" for="activeSwitch">Hoạt động</label>
            </div>
        </div>

        <!-- Thể loại (checkbox multiple) -->
        <div class="col-12">
            <label class="form-label">Thể loại <span class="text-danger">*</span></label>
            <div class="row">
                <c:forEach var="g" items="${allGenres}">
                    <div class="col-auto mb-2">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="genreIds"
                                   value="${g.genreId}" id="genre${g.genreId}"
                                   <c:if test="${movieGenres.contains(g.genreName)}">checked</c:if>>
                            <label class="form-check-label" for="genre${g.genreId}">${g.genreName}</label>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Mô tả -->
        <div class="col-12">
            <label class="form-label">Mô tả phim</label>
            <textarea class="form-control" name="description" rows="5">${movie.description}</textarea>
        </div>

        <div class="col-12 mt-4">
            <button type="submit" class="btn btn-orange px-5 me-2">
                <i class="fas fa-save me-2"></i>
                ${mode == 'edit' ? 'Cập nhật phim' : 'Thêm phim mới'}
            </button>
            <a href="${pageContext.request.contextPath}/admin/movies" class="btn btn-secondary px-4">
                <i class="fas fa-arrow-left me-2"></i>Hủy
            </a>
        </div>
    </form>
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
</script>
</body>
</html>