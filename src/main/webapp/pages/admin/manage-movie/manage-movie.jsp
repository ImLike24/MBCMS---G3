<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List"%>
<%@ page import="models.Movie"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Phim - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        .movie-poster {
            width: 70px;
            height: 105px;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid #dee2e6;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .table-custom th, .table-custom td {
            vertical-align: middle;
        }
        .rating-badge {
            font-weight: bold;
            min-width: 60px;
            text-align: center;
        }
        .action-btn {
            width: 38px;
            height: 38px;
            padding: 0;
            font-size: 1.1rem;
            border-radius: 50% !important;
            transition: all 0.25s ease;
            box-shadow: 0 2px 6px rgba(0,0,0,0.12);
            color: white !important;
            border: none !important;
        }
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(0,0,0,0.2);
            filter: brightness(1.1);
        }
        .action-btn:focus {
            outline: none;
            box-shadow: 0 0 0 0.25rem rgba(13,110,253,.25);
        }
        .btn-view { background-color: #0d6efd; }
        .btn-view:hover { background-color: #0b5ed7; }
        .btn-edit { background-color: #ffc107; color: #212529 !important; }
        .btn-edit:hover { background-color: #e0a800; }
        .btn-delete { background-color: #dc3545; }
        .btn-delete:hover { background-color: #bb2d3b; }
        .btn-group-sm .action-btn + .action-btn {
            margin-left: 8px;
        }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold" style="color: #212529;">Quản lý Phim</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Phim</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/admin/movies/add"
               class="btn btn-orange shadow-sm px-4">
                <i class="fa fa-plus me-2"></i>Thêm Phim mới
            </a>
        </div>

        <div class="card card-custom shadow-sm border-0">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-custom align-middle mb-0">
                        <thead class="table-light">
                        <tr style="color: black;">
                            <th class="ps-4">Poster</th>
                            <th>Tên Phim</th>
                            <th>Thời lượng</th>
                            <th>Đánh giá</th>
                            <th>Độ tuổi</th>
                            <th>Đạo diễn</th>
                            <th>Trạng thái</th>
                            <th class="text-center" width="160">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                            if (movies != null && !movies.isEmpty()) {
                                for (Movie m : movies) {
                        %>
                        <tr>
                            <td class="ps-4">
                                <% if (m.getPosterUrl() != null && !m.getPosterUrl().isEmpty()) { %>
                                <img src="<%= m.getPosterUrl() %>"
                                     alt="<%= m.getTitle() %>"
                                     class="movie-poster">
                                <% } else { %>
                                <div class="movie-poster bg-light d-flex align-items-center justify-content-center text-muted">
                                    <i class="fa fa-film fa-lg"></i>
                                </div>
                                <% } %>
                            </td>
                            <td class="fw-semibold text-dark"><%= m.getTitle() %></td>
                            <td><%= m.getDuration() %> phút</td>
                            <td>
                                <span class="badge rating-badge <%= m.getRating() >= 4.0 ? "bg-success" :
                                      m.getRating() >= 3.0 ? "bg-warning text-dark" : "bg-danger" %>">
                                    <%= String.format("%.1f", m.getRating()) %> ★
                                </span>
                            </td>
                            <td>
                                <%= m.getAgeRating() != null && !m.getAgeRating().trim().isEmpty()
                                    ? m.getAgeRating() : "-" %>
                            </td>
                            <td>
                                <%= m.getDirector() != null && !m.getDirector().trim().isEmpty()
                                    ? m.getDirector() : "<i class='text-muted'>Chưa cập nhật</i>" %>
                            </td>
                            <td>
                                <% if (m.isActive()) { %>
                                <span class="badge bg-success rounded-pill px-3">HOẠT ĐỘNG</span>
                                <% } else { %>
                                <span class="badge bg-secondary rounded-pill px-3">TẮT</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <div class="btn-group btn-group-sm" role="group">
                                    <button type="button"
                                            class="btn action-btn btn-view"
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="top"
                                            title="Xem chi tiết"
                                            onclick="window.location='${pageContext.request.contextPath}/admin/movies/detail?id=<%= m.getMovieId() %>'">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button type="button"
                                            class="btn action-btn btn-edit"
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="top"
                                            title="Chỉnh sửa"
                                            onclick="window.location='${pageContext.request.contextPath}/admin/movies/edit?id=<%= m.getMovieId() %>'">
                                        <i class="fas fa-pencil-alt"></i>
                                    </button>
                                    <button type="button"
                                            class="btn action-btn btn-delete"
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="top"
                                            title="Xóa phim"
                                            onclick="if(confirm('Bạn có chắc chắn muốn xóa phim \'<%= m.getTitle().replace("'", "\\'").replace("\"", "\\\"") %>\' không?')) { window.location='${pageContext.request.contextPath}/admin/movies/delete?id=<%= m.getMovieId() %>'; }">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="fas fa-film fa-4x mb-3 opacity-50"></i>
                                <h5>Chưa có phim nào trong hệ thống</h5>
                                <p>Bạn có thể thêm phim mới ngay bây giờ.</p>
                                <a href="${pageContext.request.contextPath}/admin/movies/add"
                                   class="btn btn-orange mt-3">
                                    <i class="fa fa-plus me-2"></i>Thêm Phim ngay
                                </a>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Phần phân trang -->
        <%
            Integer currentPage = (Integer) request.getAttribute("currentPage");
            Integer totalPages = (Integer) request.getAttribute("totalPages");
            Integer totalMovies = (Integer) request.getAttribute("totalMovies");

            if (totalPages != null && totalPages > 1) {
                int pageSize = 5;
                int startItem = (currentPage - 1) * pageSize + 1;
                int endItem = Math.min(currentPage * pageSize, totalMovies);
        %>
        <div class="d-flex justify-content-between align-items-center mt-4 flex-wrap gap-3">
            <div class="text-muted">
                Hiển thị <strong><%= startItem %> - <%= endItem %></strong>
                trong tổng số <strong><%= totalMovies %></strong> phim
            </div>

            <nav aria-label="Phân trang phim">
                <ul class="pagination mb-0">
                    <!-- Trang đầu -->
                    <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                        <a class="page-link" href="?page=1" aria-label="First">
                            <span aria-hidden="true">&laquo;&laquo;</span>
                        </a>
                    </li>

                    <!-- Trang trước -->
                    <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage - 1 %>" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>

                    <!-- Các trang số -->
                    <%
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, currentPage + 2);

                        for (int i = startPage; i <= endPage; i++) {
                    %>
                    <li class="page-item <%= i == currentPage ? "active" : "" %>">
                        <a class="page-link" href="?page=<%= i %>"><%= i %></a>
                    </li>
                    <% } %>

                    <!-- Trang sau -->
                    <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage + 1 %>" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>

                    <!-- Trang cuối -->
                    <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= totalPages %>" aria-label="Last">
                            <span aria-hidden="true">&raquo;&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>

    </div>
</main>

<!-- Bootstrap JS + Tooltip -->
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    // Khởi tạo tooltip
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
</script>

</body>
</html>