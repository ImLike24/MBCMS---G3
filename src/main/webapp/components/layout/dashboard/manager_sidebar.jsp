<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="sidebarMenu" class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark"
     style="width: 280px; min-height: 100vh; transition: all 0.3s;">

    <a href="${pageContext.request.contextPath}/manager/dashboard" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
        <span class="fs-4 fw-bold"><i class="fa fa-user-secret me-2"></i>Manager</span>
    </a>
    <hr>

    <ul class="nav nav-pills flex-column mb-auto">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/manager/dashboard"
               class="nav-link text-white ${param.page == 'dashboard' ? 'active' : ''}">
                <i class="fa fa-home me-2" style="width: 20px; text-align: center;"></i>
                Dashboard
            </a>
        </li>

        <li class="nav-item">
            <a href="#" class="nav-link text-white">
                <i class="fa fa-building me-2" style="width: 20px; text-align: center;"></i>
                My Branch Info
            </a>
        </li>

        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/manager/rooms"
               class="nav-link text-white ${param.page == 'rooms' ? 'active' : ''}">
                <i class="fa fa-desktop me-2" style="width: 20px; text-align: center;"></i>
                Screening Rooms
            </a>
        </li>

        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/branch-manager/configure-seat-layout" class="nav-link text-white">
                <i class="fa fa-th me-2" style="width: 20px; text-align: center;"></i>
                Seat Layouts
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/branch-manager/manage-seat-type" class="nav-link text-white">
                <i class="fa fa-wheelchair me-2" style="width: 20px; text-align: center;"></i>
                Seat Types
            </a>
        </li>

        <li class="nav-item mt-3"> <a href="#" class="nav-link text-white">
            <i class="fa fa-calendar me-2" style="width: 20px; text-align: center;"></i>
            Manage Showtimes
        </a>
        </li>
    </ul>

    <hr>

    <div class="dropdown">
        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" id="dropdownUser1" data-bs-toggle="dropdown" aria-expanded="false">
            <img src="https://github.com/mdo.png" alt="" width="32" height="32" class="rounded-circle me-2">
            <strong>${sessionScope.user.username}</strong>
        </a>
        <ul class="dropdown-menu dropdown-menu-dark text-small shadow" aria-labelledby="dropdownUser1">
            <li><a class="dropdown-item" href="#">Profile</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Sign out</a></li>
        </ul>
    </div>
</div>