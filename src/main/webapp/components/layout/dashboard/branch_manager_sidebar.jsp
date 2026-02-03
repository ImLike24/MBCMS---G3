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
                <a href="${pageContext.request.contextPath}/branch-manager/manage-cinema-halls"
                    class="nav-link text-white">
                    <i class="fa fa-building me-2"></i>
                    Manage Cinema Halls
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/configure-seat-layout"
                    class="nav-link text-white">
                    <i class="fa fa-th me-2"></i>
                    Configure Seat Layout
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/manage-seat-type"
                    class="nav-link text-white">
                    <i class="fa fa-wheelchair me-2"></i>
                    Manage Seat Type
                </a>
            </li>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/manage-seat-status"
                    class="nav-link text-white">
                    <i class="fa fa-wrench me-2"></i>
                    Manage Seat Status
                </a>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link text-white">
                    <i class="fa fa-calendar me-2"></i>
                    Manage Showtime
                </a>
            </li>
        </ul>
    </div>