<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Thể Loại - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        body {
            margin-left: 350px;
            margin-right: 80px;
        }
        .genre-checkbox {
            min-width: 120px;
        }
    </style>
</head>
<body>
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="genre"/>
</jsp:include>

<main class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Chi Tiết Thể Loại</h3>
        <a href="${pageContext.request.contextPath}/admin/manage-genres" class="btn btn-secondary">Quay lại danh sách</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-3 fw-bold">ID:</div>
                <div class="col-md-9">${genre.genreId}</div>
            </div>
            <div class="row mb-3">
                <div class="col-md-3 fw-bold">Tên thể loại:</div>
                <div class="col-md-9">${genre.genreName}</div>
            </div>
            <div class="row mb-3">
                <div class="col-md-3 fw-bold">Mô tả:</div>
                <div class="col-md-9">
                    <c:out value="${genre.description}" default="Chưa có mô tả"/>
                </div>
            </div>
            <div class="row mb-3">
                <div class="col-md-3 fw-bold">Trạng thái:</div>
                <div class="col-md-9">
                    <c:choose>
                        <c:when test="${genre.active}">
                            <span class="badge bg-success px-3 py-2">HOẠT ĐỘNG</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-secondary px-3 py-2">TẮT</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="mt-4">
                <a href="${pageContext.request.contextPath}/admin/genres/edit?id=${genre.genreId}"
                   class="btn btn-warning">Chỉnh sửa</a>
                <a href="${pageContext.request.contextPath}/admin/manage-genres" class="btn btn-secondary ms-2">Quay lại</a>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>