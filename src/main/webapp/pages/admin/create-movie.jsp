<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Movie - Admin</title>
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
                <h2><i class="fa fa-plus"></i>Create New Movie</h2>
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

            <!-- Create Movie Form -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Movie Information</h5>
                </div>
                <div class="card-body">
                    <form id="movieForm" method="POST" action="${pageContext.request.contextPath}/admin/create-movie" enctype="multipart/form-data">
                        <div class="row">
                            <div class="col-md-8">
                                <!-- Basic Information -->
                                <div class="mb-3">
                                    <label for="title" class="form-label">Title <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="title" name="title" required
                                           maxlength="150" placeholder="Enter movie title">
                                </div>

                                <div class="mb-3">
                                    <label for="description" class="form-label">Description</label>
                                    <textarea class="form-control" id="description" name="description" rows="4"
                                              maxlength="4000" placeholder="Enter movie description"></textarea>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="genre" class="form-label">Genre <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="genre" name="genre" required
                                                   maxlength="100" placeholder="e.g., Action, Comedy, Drama">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="duration" class="form-label">Duration (minutes) <span class="text-danger">*</span></label>
                                            <input type="number" class="form-control" id="duration" name="duration" required
                                                   min="1" max="500" placeholder="120">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="releaseDate" class="form-label">Release Date</label>
                                            <input type="date" class="form-control" id="releaseDate" name="releaseDate">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="endDate" class="form-label">End Date</label>
                                            <input type="date" class="form-control" id="endDate" name="endDate">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="ageRating" class="form-label">Age Rating</label>
                                            <select class="form-control" id="ageRating" name="ageRating">
                                                <option value="">Select age rating</option>
                                                <option value="G">G - General Audiences</option>
                                                <option value="PG">PG - Parental Guidance</option>
                                                <option value="PG-13">PG-13 - Parents Strongly Cautioned</option>
                                                <option value="R">R - Restricted</option>
                                                <option value="NC-17">NC-17 - No Children Under 17</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="director" class="form-label">Director</label>
                                            <input type="text" class="form-control" id="director" name="director"
                                                   maxlength="100" placeholder="Director name">
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="cast" class="form-label">Cast</label>
                                    <textarea class="form-control" id="cast" name="cast" rows="2"
                                              maxlength="500" placeholder="Main actors (comma separated)"></textarea>
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
                                               placeholder="https://example.com/poster.jpg">
                                        <div class="form-text">Enter a direct link to the poster image</div>
                                    </div>

                                    <!-- File Input -->
                                    <div id="fileInputGroup" style="display: none;">
                                        <input type="file" class="form-control" id="posterFileInput" name="posterFile"
                                               accept="image/*">
                                        <div class="form-text">Select an image file from your computer (max 5MB)</div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
                                        <label class="form-check-label" for="isActive">
                                            Active (visible to customers)
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-4">
                                <!-- Poster Preview -->
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0">Poster Preview</h6>
                                    </div>
                                    <div class="card-body text-center">
                                        <div id="posterPreview" class="movie-poster-preview">
                                            <i class="fa fa-film fa-3x text-muted"></i>
                                            <p class="text-muted mt-2">No poster selected</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Form Actions -->
                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save me-2"></i>Create Movie
                            </button>
                            <button type="reset" class="btn btn-secondary">
                                <i class="fa fa-refresh me-2"></i>Reset
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/manage-movies"
                               class="btn btn-outline-secondary">
                                <i class="fa fa-times me-2"></i>Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
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
                preview.innerHTML = `<img src="${url}" alt="Poster" class="img-fluid" style="max-height: 300px;" onerror="showPlaceholder()">`;
            } else {
                showPlaceholder();
            }
        }

        function updatePosterPreviewFromFile(file) {
            const preview = document.getElementById('posterPreview');

            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.innerHTML = `<img src="${e.target.result}" alt="Poster" class="img-fluid" style="max-height: 300px;">`;
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
                alert('Please enter a movie title.');
                e.preventDefault();
                return;
            }

            if (!genre) {
                alert('Please enter a genre.');
                e.preventDefault();
                return;
            }

            if (!duration || duration < 1) {
                alert('Please enter a valid duration.');
                e.preventDefault();
                return;
            }

            // Validate poster
            if (posterType === 'url') {
                const url = document.getElementById('posterUrlInput').value.trim();
                if (!url) {
                    alert('Please enter a poster URL.');
                    e.preventDefault();
                    return;
                }
            } else {
                const file = document.getElementById('posterFileInput').files[0];
                if (!file) {
                    alert('Please select a poster file.');
                    e.preventDefault();
                    return;
                }
            }
        });
    </script>
</body>
</html>