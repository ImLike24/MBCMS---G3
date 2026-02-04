<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Phòng chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f3f4f6; padding-top: 56px; }
        #sidebarMenu {
            position: fixed;
            top: 56px;
            left: 0;
            bottom: 0;
            z-index: 100;
            overflow-y: auto;
        }
        main { margin-left: 280px; padding: 30px; }
        .status-badge { font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; font-weight: 500; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="rooms"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-dark">Phòng chiếu</h2>
            <a href="rooms?action=create" class="btn btn-primary shadow-sm">
                <i class="fa fa-plus me-2"></i>Thêm Phòng mới
            </a>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show">
                Thao tác thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <table class="table table-hover align-middle">
                    <thead class="table-light text-secondary">
                    <tr>
                        <th>ID</th>
                        <th>Tên Phòng</th>
                        <th>Tổng ghế</th>
                        <th>Trạng thái</th>
                        <th>Ngày tạo</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="r" items="${rooms}">
                        <tr>
                            <td class="fw-bold text-muted">#${r.roomId}</td>
                            <td class="fw-bold text-primary">${r.roomName}</td>
                            <td>${r.totalSeats} ghế</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status == 'ACTIVE'}">
                                        <span class="status-badge bg-success-subtle text-success">Hoạt động</span>
                                    </c:when>
                                    <c:when test="${r.status == 'MAINTENANCE'}">
                                        <span class="status-badge bg-warning-subtle text-warning">Bảo trì</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge bg-danger-subtle text-danger">Đóng cửa</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${r.createdAt.toLocalDate()}</td>
                            <td class="text-end">
                                <a href="rooms?action=edit&id=${r.roomId}" class="btn btn-sm btn-light text-primary me-2">
                                    <i class="fa fa-pencil"></i>
                                </a>
                                <a href="rooms?action=delete&id=${r.roomId}" class="btn btn-sm btn-light text-danger"
                                   onclick="return confirm('Xóa phòng này? (Lưu ý: Chỉ xóa được khi chưa có lịch chiếu)')">
                                    <i class="fa fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty rooms}">
                        <tr><td colspan="6" class="text-center py-4 text-muted">Chưa có phòng chiếu nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>