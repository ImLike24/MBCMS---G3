<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Movies - Admin</title>
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
                <h2><i class="fa fa-film"></i>Quản lý phim</h2>
                <a href="${pageContext.request.contextPath}/admin/create-movie"
                    class="btn btn-primary btn-create-movie">
                    <i class="fa fa-plus me-2"></i>Tạo bộ phim mới
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

            <!-- Search Form -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="GET" action="${pageContext.request.contextPath}/admin/manage-movies" class="row g-3">
                        <div class="col-md-8">
                            <label for="search" class="form-label">Tìm kiếm bộ phim</label>
                            <input type="text" class="form-control" id="search" name="search"
                                   value="${searchKeyword}" placeholder="Search by title, director, or cast...">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">&nbsp;</label>
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-search me-2"></i>Search
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/manage-movies"
                                   class="btn btn-secondary">
                                    <i class="fa fa-refresh me-2"></i>Clear
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Movies Table -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Movies (${movies.size()})</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Poster</th>
                                    <th>Title</th>
                                    <th>Genre</th>
                                    <th>Duration</th>
                                    <th>Rating</th>
                                    <th>Age Rating</th>
                                    <th>Status</th>
                                    <th>Release Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="movie" items="${movies}">
                                    <tr>
                                        <td>${movie.movieId}</td>
                                        <td>
                                            <c:if test="${not empty movie.posterUrl}">
                                                <img src="${movie.posterUrl}" alt="${movie.title}"
                                                     class="movie-poster-thumbnail" style="width: 50px; height: 75px; object-fit: cover;">
                                            </c:if>
                                            <c:if test="${empty movie.posterUrl}">
                                                <div class="movie-poster-placeholder" style="width: 50px; height: 75px; background: #f8f9fa; display: flex; align-items: center; justify-content: center;">
                                                    <i class="fa fa-film text-muted"></i>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <strong>${movie.title}</strong>
                                            <br>
                                            <small class="text-muted">${movie.director}</small>
                                        </td>
                                        <td>${movie.genre}</td>
                                        <td>${movie.duration} min</td>
                                        <td>
                                            <c:if test="${movie.rating > 0}">
                                                <span class="badge bg-warning text-dark">
                                                    <i class="fa fa-star"></i> ${movie.rating}
                                                </span>
                                            </c:if>
                                            <c:if test="${movie.rating == 0}">
                                                <span class="text-muted">No rating</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty movie.ageRating}">
                                                <span class="badge bg-info">${movie.ageRating}</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${movie.active}">
                                                <span class="badge bg-success">Active</span>
                                            </c:if>
                                            <c:if test="${!movie.active}">
                                                <span class="badge bg-secondary">Inactive</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty movie.releaseDate}">
                                                <fmt:formatDate value="${movie.releaseDate}" pattern="dd/MM/yyyy" />
                                            </c:if>
                                        </td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <a href="${pageContext.request.contextPath}/admin/edit-movie?id=${movie.movieId}"
                                                   class="btn btn-sm btn-outline-primary" title="Edit">
                                                    <i class="fa fa-edit"></i>
                                                </a>
                                                <button type="button" class="btn btn-sm btn-outline-warning"
                                                        onclick="toggleStatus(${movie.movieId}, ${movie.active})"
                                                        title="${movie.active ? 'Deactivate' : 'Activate'}">
                                                    <i class="fa ${movie.active ? 'fa-ban' : 'fa-check'}"></i>
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-danger"
                                                        onclick="deleteMovie(${movie.movieId}, '${movie.title}')"
                                                        title="Delete">
                                                    <i class="fa fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty movies}">
                                    <tr>
                                        <td colspan="10" class="text-center text-muted py-4">
                                            <i class="fa fa-film fa-3x mb-3"></i>
                                            <br>
                                            Không tìm thấy bộ phim nào.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteModalLabel">Xác nhận xóa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    Bạn có chắc bạn muốn xóa bộ phim này? "<span id="deleteMovieTitle"></span>"?
                    <br><small class="text-muted">Hành động này không thể hoàn tác.</small>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form id="deleteForm" method="POST" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="movieId" id="deleteMovieId">
                        <button type="submit" class="btn btn-danger">Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Status Toggle Modal -->
    <div class="modal fade" id="statusModal" tabindex="-1" aria-labelledby="statusModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="statusModalLabel">Xác nhận thay đổi trạng thái</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    Bạn có chắc bạn muốn <span id="statusAction"></span> bộ phim "<span id="statusMovieTitle"></span>"?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form id="statusForm" method="POST" style="display: inline;">
                        <input type="hidden" name="action" value="toggle_status">
                        <input type="hidden" name="movieId" id="statusMovieId">
                        <button type="submit" class="btn btn-warning">Xác nhận</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/jquery-3.7.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteMovie(movieId, movieTitle) {
            document.getElementById('deleteMovieId').value = movieId;
            document.getElementById('deleteMovieTitle').textContent = movieTitle;
            document.getElementById('deleteForm').action = '${pageContext.request.contextPath}/admin/manage-movies';
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        function toggleStatus(movieId, isActive) {
            document.getElementById('statusMovieId').value = movieId;
            const action = isActive ? 'deactivate' : 'activate';
            document.getElementById('statusAction').textContent = action;
            document.getElementById('statusMovieTitle').textContent = 'this movie';
            document.getElementById('statusForm').action = '${pageContext.request.contextPath}/admin/manage-movies';
            new bootstrap.Modal(document.getElementById('statusModal')).show();
        }
    </script>
</body>
</html>