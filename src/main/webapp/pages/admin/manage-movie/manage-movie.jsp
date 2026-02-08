<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List"%>
<%@ page import="models.Movie"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="movie"/> </jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold" style="color: #212529;">Quản lý Phim</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Admin</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Phim</li>
                    </ol>
                </nav>
            </div>
            <a href="#" class="btn btn-orange shadow-sm px-4">
                <i class="fa fa-plus me-2"></i>Thêm Phim mới
            </a>
        </div>

        <div class="card card-custom">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">Tên Phim</th>
                            <th>Thời lượng</th>
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
                            <td class="ps-4 fw-bold text-dark"><%= m.getTitle() %></td>
                            <td class="text-secondary"><%= m.getDuration() %> phút</td>
                            <td>
                                <% if(m.isActive()) { %>
                                <span class="badge bg-success rounded-pill px-3">ACTIVE</span>
                                <% } else { %>
                                <span class="badge bg-secondary rounded-pill px-3">INACTIVE</span>
                                <% } %>
                            </td>

                            <td class="text-center">
                                <a href="MovieDetail?id=<%= m.getMovieId() %>" class="btn btn-outline-info btn-sm me-1" title="Chi tiết">
                                    <i class="fa fa-eye"></i>
                                </a>
                                <a href="MovieEdit?id=<%= m.getMovieId() %>" class="btn btn-outline-warning btn-sm me-1" title="Sửa">
                                    <i class="fa fa-pencil"></i>
                                </a>
                                <a href="MovieDelete?id=<%= m.getMovieId() %>" class="btn btn-outline-danger btn-sm"
                                   title="Xóa" onclick="return confirm('Bạn có chắc chắn xóa phim này?')">
                                    <i class="fa fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="4" class="text-center text-muted py-5">
                                <i class="fa fa-film fa-3x mb-3 text-secondary opacity-25"></i>
                                <p>Không tìm thấy phim nào.</p>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>