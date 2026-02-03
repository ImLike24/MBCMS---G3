<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .nav-link.active {
        background-color: #0d6efd !important; /* Bootstrap Primary Color */
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    .nav-link:hover:not(.active) {
        background-color: rgba(255,255,255,0.1);
    }
</style>

<div id="sidebarMenu" class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark"
     style="width: 280px; min-height: 100vh; transition: all 0.3s;">

    <a href="${pageContext.request.contextPath}/admin/dashboard" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
        <span class="fs-4 fw-bold"><i class="fa fa-cogs me-2"></i>Admin Panel</span>
    </a>
    <hr>

    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="nav-link text-white ${param.page == 'dashboard' ? 'active' : ''}">
                <i class="fa fa-home me-2" style="width: 20px; text-align: center;"></i>
                Dashboard
            </a>
        </li>
        <li class="nav-item">
            <a href="#" class="nav-link text-white">
                <i class="fa fa-film me-2" style="width: 20px; text-align: center;"></i>
                Manage Movies
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/branches"
               class="nav-link text-white ${param.page == 'branch' ? 'active' : ''}">
                <i class="fa fa-building me-2" style="width: 20px; text-align: center;"></i>
                Cinema Branches
            </a>
        </li>
    </ul>
    <hr>
    <div class="dropdown">
        <div class="d-flex align-items-center text-white text-decoration-none">
            <img src="https://github.com/mdo.png" alt="" width="32" height="32" class="rounded-circle me-2">
            <strong>Admin</strong>
        </div>
    </div>
</div>