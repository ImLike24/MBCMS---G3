<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="sidebarMenu" class="d-flex flex-column p-3">

    <a href="${pageContext.request.contextPath}/admin/dashboard" class="d-flex align-items-center mb-4 text-white text-decoration-none">
        <span class="fs-4 fw-bold" style="letter-spacing: 1px;">
            <i class="fa fa-film me-2" style="color: #d96c2c;"></i>MyCinema
        </span>
    </a>
    <hr class="text-secondary mt-0">

    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="nav-link ${param.page == 'dashboard' ? 'active' : ''}">
                <i class="fa fa-home me-3"></i>Dashboard
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-users"
               class="nav-link ${param.page == 'user' ? 'active' : ''}">
                <i class="fa fa-users me-3"></i>Quản lý người dùng
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/branches"
               class="nav-link ${param.page == 'branch' ? 'active' : ''}">
                <i class="fa fa-building me-3"></i>Quản lý Chi nhánh
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/movies" class="nav-link">
                <i class="fa fa-film me-3"></i>Quản lý Phim
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-genres" class="nav-link">
                <i class="fa fa-tags me-3"></i>Quản lý thể loại
            </a>
        </li>
        <li class="nav-item">
            <a href="#" class="nav-link">
                <i class="fa fa-coffee me-3"></i>Quản lý đồ ăn & nước uống
            </a>
        </li>
    </ul>

    <div class="mt-auto pt-3 border-top border-secondary">

        <a href="${pageContext.request.contextPath}/profile" class="nav-link text-white-50 hover-white">
            <i class="fa fa-user me-2 text-danger"></i> Hồ sơ cá nhân
        </a>

        <a href="${pageContext.request.contextPath}/logout" class="nav-link text-white-50 hover-white">
            <i class="fa fa-sign-out me-2 text-danger"></i> Đăng xuất
        </a>
    </div>
</div>