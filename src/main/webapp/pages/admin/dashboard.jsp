<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

<jsp:include page="/components/layout/dashboard/admin_sidebar.jsp">
    <jsp:param name="page" value="dashboard"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold text-dark">Dashboard</h3>
                <p class="text-secondary mb-0">Chào mừng trở lại, Administrator!</p>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <div class="card card-custom h-100 border-0" style="border-left: 5px solid #d96c2c !important;">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-muted text-uppercase mb-2">Người dùng</h6>
                                <h3 class="fw-bold mb-0">1,250</h3>
                            </div>
                            <div class="bg-light rounded-circle p-3">
                                <i class="fa fa-users fa-2x" style="color: #d96c2c;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>