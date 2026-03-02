<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa Thể Loại - Admin</title>
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
    <h3 class="mb-4">Sửa Thể Loại: ${genre.genreName}</h3>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/genres/edit" method="post">
        <input type="hidden" name="genreId" value="${genre.genreId}">

        <div class="mb-3">
            <label for="genreName" class="form-label">Tên thể loại <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="genreName" name="genreName" required
                   value="${genre.genreName}">
        </div>

        <div class="mb-3">
            <label for="description" class="form-label">Mô tả</label>
            <textarea class="form-control" id="description" name="description" rows="4">${genre.description}</textarea>
        </div>

        <div class="form-check mb-4">
            <input class="form-check-input" type="checkbox" id="isActive" name="isActive"
                   ${genre.active ? 'checked' : ''}>
            <label class="form-check-label" for="isActive">Hoạt động</label>
        </div>

        <button type="submit" class="btn btn-orange px-5">Lưu Thay Đổi</button>
        <a href="${pageContext.request.contextPath}/admin/manage-genres" class="btn btn-secondary px-5 ms-3">Hủy</a>
    </form>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>