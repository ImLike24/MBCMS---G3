<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<<<<<<< HEAD
    <div id="sidebarMenu" class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark"
        style="width: 280px; min-height: 100vh; transition: all 0.3s;">
        <ul class="nav nav-pills flex-column mb-auto">
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/home" class="nav-link text-white">
                    <i class="fa fa-home me-2"></i>
                    Home
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-users" class="nav-link text-white">
                    <i class="fa fa-users me-2"></i>
                    Manage Users
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-movies" class="nav-link text-white">
                    <i class="fa fa-film me-2"></i>
                    Manage Movies
                </a>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link text-white">
                    <i class="fa fa-tags me-2"></i>
                    Manage Genres
                </a>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link text-white">
                    <i class="fa fa-cutlery me-2"></i>
                    Manage Concessions
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-cinema-branches" class="nav-link text-white">
                    <i class="fa fa-building me-2"></i>
                    Manage Cinema Branches
                </a>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link text-white">
                    <i class="fa fa-bar-chart me-2"></i>
                    System Analysis
                </a>
            </li>
        </ul>
=======

<div id="sidebarMenu"
     class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark"
     style="width: 280px; min-height: 100vh;">

    <!-- MAIN MENU -->
    <ul class="nav nav-pills flex-column mb-3">
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/home" class="nav-link text-white">
                <i class="fa fa-home me-2"></i>
                Home
            </a>
        </li>

        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-users" class="nav-link text-white">
                <i class="fa fa-users me-2"></i>
                Manage Users
            </a>
        </li>

        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-movie" class="nav-link text-white">
                <i class="fa fa-film me-2"></i>
                Manage Movies
            </a>
        </li>

        <li class="nav-item">
            <a href="#" class="nav-link text-white">
                <i class="fa fa-cutlery me-2"></i>
                Manage Genre
            </a>
        </li>

        <li class="nav-item">
            <a href="#" class="nav-link text-white">
                <i class="fa fa-cutlery me-2"></i>
                Manage Concessions
            </a>
        </li>

        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-cinema-branches"
               class="nav-link text-white">
                <i class="fa fa-building me-2"></i>
                Manage Cinema Branches
            </a>
        </li>

        <li class="nav-item">
            <a href="#" class="nav-link text-white">
                <i class="fa fa-bar-chart me-2"></i>
                System Analysis
            </a>
        </li>
    </ul>

    <!-- BOTTOM BUTTONS -->
    <div class="mt-auto pb-4 m-4">
        <div class="d-flex justify-content-center gap-2">
            <a href="${pageContext.request.contextPath}/profile"
               class="btn btn-outline-light">
                <i class="fa fa-user"></i>
                Profile
            </a>

            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-danger">
                <i class="fa fa-sign-out"></i>
                Logout
            </a>
        </div>
>>>>>>> 66f39e7fb98d6bf62b64f867e8326770f04fd4c5
    </div>

</div>
