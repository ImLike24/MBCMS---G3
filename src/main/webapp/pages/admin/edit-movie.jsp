<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Movie - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>

<body>

    <!-- Header -->
    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

    <!-- Sidebar -->
    <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp" />

    <!-- Main Content -->
    <main>
        <div class="container-fluid">
            <!-- Page Header -->
            <div class="page-header">
                <h2><i class="fa fa-edit"></i>Edit Movie</h2>
                <a href="${pageContext.request.contextPath}/admin/manage-movies"
                    class="btn btn-secondary">
                    <i class="fa fa-arrow-left me-2"></i>Back to Movies
                </a>
            </div>

            <!-- Success/Error Messages -->
            <c:if test="${param.success != null}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa fa-check-circle me-2"></i>${param.success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${param.error != null}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa fa-exclamation-circle me-2"></i>${param.error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${movie == null}">
                <div class="alert alert-danger" role="alert">
                    <i class="fa fa-exclamation-circle me-2"></i>Movie not found.
                </div>
            </c:if>

            <c:if test="${movie != null}">
                <!-- Edit Movie Form -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Movie Information</h5>
                    </div>
                    <div class="card-body">
                        <form id="movieForm" method="POST" action="${pageContext.request.contextPath}/admin/edit-movie" enctype="multipart/form-data">
                            <input type="hidden" name="movieId" value="${movie.movieId}">

                            <div class="row">
                                <div class="col-md-8">
                                    <!-- Basic Information -->
                                    <div class="mb-3">
                                        <label for="title" class="form-label">Title <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="title" name="title" required
                                               maxlength="150" value="${movie.title}" placeholder="Enter movie title">
                                    </div>

                                    <div class="mb-3">
                                        <label for="description" class="form-label">Description</label>
                                        <textarea class="form-control" id="description" name="description" rows="4"
                                                  maxlength="4000" placeholder="Enter movie description">${movie.description}</textarea>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="genre" class="form-label">Genre <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="genre" name="genre" required
                                                       maxlength="100" value="${movie.genre}" placeholder="e.g., Action, Comedy, Drama">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="duration" class="form-label">Duration (minutes) <span class="text-danger">*</span></label>
                                                <input type="number" class="form-control" id="duration" name="duration" required
                                                       min="1" max="500" value="${movie.duration}" placeholder="120">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="releaseDate" class="form-label">Release Date</label>
                                                <input type="date" class="form-control" id="releaseDate" name="releaseDate"
                                                       value="<fmt:formatDate value='${movie.releaseDate}' pattern='yyyy-MM-dd' />">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="endDate" class="form-label">End Date</label>
                                                <input type="date" class="form-control" id="endDate" name="endDate"
                                                       value="<fmt:formatDate value='${movie.endDate}' pattern='yyyy-MM-dd' />">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="ageRating" class="form-label">Age Rating</label>
                                                <select class="form-control" id="ageRating" name="ageRating">
                                                    <option value="">Select age rating</option>
                                                    <option value="G" ${movie.ageRating == 'G' ? 'selected' : ''}>G - General Audiences</option>
                                                    <option value="PG" ${movie.ageRating == 'PG' ? 'selected' : ''}>PG - Parental Guidance</option>
                                                    <option value="PG-13" ${movie.ageRating == 'PG-13' ? 'selected' : ''}>PG-13 - Parents Strongly Cautioned</option>
                                                    <option value="R" ${movie.ageRating == 'R' ? 'selected' : ''}>R - Restricted</option>
                                                    <option value="NC-17" ${movie.ageRating == 'NC-17' ? 'selected' : ''}>NC-17 - No Children Under 17</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="director" class="form-label">Director</label>
                                                <input type="text" class="form-control" id="director" name="director"
                                                       maxlength="100" value="${movie.director}" placeholder="Director name">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="cast" class="form-label">Cast</label>
                                        <textarea class="form-control" id="cast" name="cast" rows="2"
                                                  maxlength="500" placeholder="Main actors (comma separated)">${movie.cast}</textarea>
                                    </div>

                                    <div class="mb-3">
                                    <label class="form-label">Poster Image <span class="text-danger">*</span></label>
                                    <div class="mb-2">
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="posterType" id="posterUrl" value="url" checked>
                                            <label class="form-check-label" for="posterUrl">
                                                Enter URL
                                            </label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="posterType" id="posterFile" value="file">
                                            <label class="form-check-label" for="posterFile">
                                                Upload File
                                            </label>
                                        </div>
                                    </div>

                                    <!-- URL Input -->
                                    <div id="urlInputGroup">
                                        <input type="url" class="form-control" id="posterUrlInput" name="posterUrl"
                                               value="${movie.posterUrl}" placeholder="https://example.com/poster.jpg">
                                        <div class="form-text">Điền link trực tiếp đến poster của bộ phim</div>
                                    </div>

                                    <!-- File Input -->
                                    <div id="fileInputGroup" style="display: none;">
                                        <input type="file" class="form-control" id="posterFileInput" name="posterFile"
                                               accept="image/*">
                                        <div class="form-text">Lựa chọn hình ảnh từ máy tính của bạn (tối đa 5MB)</div>
                                    </div>

                                    <div class="mb-3">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="isActive" name="isActive" ${movie.active ? 'checked' : ''}>
                                            <label class="form-check-label" for="isActive">
                                                Hoạt động (bộ phim sẽ hiển thị trên hệ thống)
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <!-- Poster Preview -->
                                    <div class="card">
                                        <div class="card-header">
                                            <h6 class="mb-0">Đánh giá poster</h6>
                                        </div>
                                        <div class="card-body text-center">
                                            <div id="posterPreview" class="movie-poster-preview">
                                                <c:if test="${not empty movie.posterUrl}">
                                                    <img src="${movie.posterUrl}" alt="${movie.title}" class="img-fluid" style="max-height: 300px;" onerror="showPlaceholder()">
                                                </c:if>
                                                <c:if test="${empty movie.posterUrl}">
                                                    <i class="fa fa-film fa-3x text-muted"></i>
                                                    <p class="text-muted mt-2">Chưa chọn poster</p>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Movie Stats -->
                                    <div class="card mt-3">
                                        <div class="card-header">
                                            <h6 class="mb-0">Thống kê bộ phim</h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="row text-center">
                                                <div class="col-6">
                                                    <div class="stat-number">${movie.rating}</div>
                                                    <div class="stat-label">Rating</div>
                                                </div>
                                                <div class="col-6">
                                                    <div class="stat-number">
                                                        <c:if test="${movie.createdAt != null}">
                                                            <fmt:formatDate value="${movie.createdAt}" pattern="dd/MM/yyyy" />
                                                        </c:if>
                                                    </div>
                                                    <div class="stat-label">Đã tạo</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Form Actions -->
                            <div class="d-flex gap-2 mt-4">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save me-2"></i>Cập nhật bộ phim
                                </button>
                                <button type="reset" class="btn btn-secondary">
                                    <i class="fa fa-refresh me-2"></i>Reset
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/manage-movies"
                                   class="btn btn-outline-secondary">
                                    <i class="fa fa-times me-2"></i>Hủy
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/js/jquery-3.7.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    <script>
        // Poster type selection
        document.querySelectorAll('input[name="posterType"]').forEach(radio => {
            radio.addEventListener('change', function() {
                const urlGroup = document.getElementById('urlInputGroup');
                const fileGroup = document.getElementById('fileInputGroup');
                const urlInput = document.getElementById('posterUrlInput');
                const fileInput = document.getElementById('posterFileInput');

                if (this.value === 'url') {
                    urlGroup.style.display = 'block';
                    fileGroup.style.display = 'none';
                    fileInput.required = false;
                    urlInput.required = true;
                    updatePosterPreview(urlInput.value);
                } else {
                    urlGroup.style.display = 'none';
                    fileGroup.style.display = 'block';
                    urlInput.required = false;
                    fileInput.required = true;
                    updatePosterPreviewFromFile(fileInput.files[0]);
                }
            });
        });

        // Poster preview for URL
        document.getElementById('posterUrlInput').addEventListener('input', function() {
            updatePosterPreview(this.value);
        });

        // Poster preview for file
        document.getElementById('posterFileInput').addEventListener('change', function() {
            updatePosterPreviewFromFile(this.files[0]);
        });

        function updatePosterPreview(url) {
            const preview = document.getElementById('posterPreview');

            if (url) {
                preview.innerHTML = `<img src="${url}" alt="${document.getElementById('title').value}" class="img-fluid" style="max-height: 300px;" onerror="showPlaceholder()">`;
            } else {
                showPlaceholder();
            }
        }

        function updatePosterPreviewFromFile(file) {
            const preview = document.getElementById('posterPreview');

            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.innerHTML = `<img src="${e.target.result}" alt="${document.getElementById('title').value}" class="img-fluid" style="max-height: 300px;">`;
                };
                reader.readAsDataURL(file);
            } else {
                showPlaceholder();
            }
        }

        function showPlaceholder() {
            const preview = document.getElementById('posterPreview');
            preview.innerHTML = `<i class="fa fa-film fa-3x text-muted"></i><p class="text-muted mt-2">No poster selected</p>`;
        }

        // Form validation
        document.getElementById('movieForm').addEventListener('submit', function(e) {
            const title = document.getElementById('title').value.trim();
            const genre = document.getElementById('genre').value.trim();
            const duration = document.getElementById('duration').value;
            const posterType = document.querySelector('input[name="posterType"]:checked').value;

            if (!title) {
                alert('Xin hãy nhập tiêu đề bộ phim.');
                e.preventDefault();
                return;
            }

            if (!genre) {
                alert('Xin hãy nhập thể loại bộ phim.');
                e.preventDefault();
                return;
            }

            if (!duration || duration < 1) {
                alert('Xin hãy nhập thời lượng hợp lệ.');
                e.preventDefault();
                return;
            }

            // Validate poster
            if (posterType === 'url') {
                const url = document.getElementById('posterUrlInput').value.trim();
                if (!url) {
                    alert('Xin hãy nhập URL poster.');
                    e.preventDefault();
                    return;
                }
            } else {
                const file = document.getElementById('posterFileInput').files[0];
                if (!file) {
                    alert('Xin hãy chọn tệp poster.');
                    e.preventDefault();
                    return;
                }
            }
        });

        // Initialize poster preview on page load
        document.addEventListener('DOMContentLoaded', function() {
            const urlInput = document.getElementById('posterUrlInput');
            if (urlInput.value) {
                updatePosterPreview(urlInput.value);
            }
        });
    </script>
</body>
</html>