<%@ page contentType="text/html;charset=UTF-8" language="java" %>

    <div id="sidebarMenu" class="d-flex flex-column flex-shrink-0 p-3 text-white bg-dark">

        <!-- Header -->
        <a href="${pageContext.request.contextPath}/manager/dashboard"
            class="d-flex align-items-center mb-3 text-white text-decoration-none">
            <span class="fs-4 fw-bold">
                <i class="fa fa-user-secret me-2"></i>Quản lý
            </span>
        </a>

        <hr>

        <!-- Main Menu (flex-grow-1 để đẩy footer xuống) -->
        <ul class="nav nav-pills flex-column flex-grow-1">

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/manager/dashboard"
                    class="nav-link text-white ${param.page == 'dashboard' ? 'active' : ''}">
                    <i class="fa fa-home me-2" style="width: 20px; text-align: center;"></i>
                    Bảng điều khiển
                </a>
            </li>

            <li class="nav-item">
                <a href="#" class="nav-link text-white">
                    <i class="fa fa-building me-2" style="width: 20px; text-align: center;"></i>
                    Thông tin chi nhánh
                </a>
            </li>

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/manager/rooms"
                    class="nav-link text-white ${param.page == 'rooms' ? 'active' : ''}">
                    <i class="fa fa-desktop me-2" style="width: 20px; text-align: center;"></i>
                    Phòng chiếu
                </a>
            </li>

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/configure-seat-layout"
                    class="nav-link text-white">
                    <i class="fa fa-th me-2" style="width: 20px; text-align: center;"></i>
                    Sơ đồ ghế
                </a>
            </li>

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/manage-seat-type"
                    class="nav-link text-white">
                    <i class="fa fa-wheelchair me-2" style="width: 20px; text-align: center;"></i>
                    Loại ghế
                </a>
            </li>

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/manage-seat-status"
                    class="nav-link text-white">
                    <i class="fa fa-wrench me-2" style="width: 20px; text-align: center;"></i>
                    Trạng thái ghế
                </a>
            </li>

            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                    class="nav-link text-white ${param.page == 'showtimes' ? 'active' : ''}">
                    <i class="fa fa-calendar me-2" style="width: 20px; text-align: center;"></i>
                    Quản lý suất chiếu
                </a>
            </li>

        </ul>

        <!-- Footer Menu (luôn nằm dưới) -->
        <div class="pt-3 border-top">

            <ul class="nav nav-pills flex-column">

                <li class="nav-item">
                    <a href="#" class="nav-link text-white">
                        <i class="fa fa-user me-2" style="width: 20px; text-align: center;"></i>
                        Hồ sơ cá nhân
                    </a>
                </li>

                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-white">
                        <i class="fa fa-sign-out me-2" style="width: 20px; text-align: center;"></i>
                        Đăng xuất
                    </a>
                </li>

            </ul>
        </div>

    </div>