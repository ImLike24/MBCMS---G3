<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
                <a href="${pageContext.request.contextPath}/admin/create-user" class="nav-link text-white">
                    <i class="fa fa-user-plus me-2"></i>
                    Create User
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-movie/manage-movies" class="nav-link text-white">
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
                <a href="#" class="nav-link text-white">
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
    </div>