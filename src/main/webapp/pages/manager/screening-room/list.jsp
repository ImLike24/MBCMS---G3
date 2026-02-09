<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Phòng chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="rooms"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold text-dark">Phòng chiếu phim</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-secondary">Manager</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Phòng chiếu</li>
                    </ol>
                </nav>
            </div>
            <a href="rooms?action=create" class="btn btn-orange shadow-sm px-4">
                <i class="fa fa-plus me-2"></i>Thêm Phòng
            </a>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success border-0 shadow-sm" role="alert" style="border-left: 4px solid #d96c2c !important;">
                Thao tác thành công!
            </div>
        </c:if>

        <div class="card card-custom">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Tên Phòng</th>
                            <th>Sức chứa</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th class="text-end pe-4">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${rooms}">
                            <tr>
                                <td class="ps-4 fw-bold" style="color: #d96c2c;">#${r.roomId}</td>
                                <td class="fw-bold">${r.roomName}</td>
                                <td>
                                    <span class="badge bg-light text-dark border">
                                        <i class="fa fa-users me-1"></i> ${r.totalSeats} ghế
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status == 'ACTIVE'}">
                                            <span class="badge bg-success rounded-pill px-3">Hoạt động</span>
                                        </c:when>
                                        <c:when test="${r.status == 'MAINTENANCE'}">
                                            <span class="badge bg-warning text-dark rounded-pill px-3">Bảo trì</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger rounded-pill px-3">Đóng cửa</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-secondary small">${r.createdAt.toLocalDate()}</td>
                                <td class="text-end pe-4">
                                    <a href="rooms?action=edit&id=${r.roomId}" class="btn btn-outline-dark btn-sm me-1">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                    <a href="rooms?action=delete&id=${r.roomId}" class="btn btn-outline-danger btn-sm"
                                       onclick="return confirm('Xóa phòng này?')">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty rooms}">
                            <tr><td colspan="6" class="text-center py-5 text-muted">Chưa có dữ liệu phòng chiếu.</td></tr>
                        </c:if>
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