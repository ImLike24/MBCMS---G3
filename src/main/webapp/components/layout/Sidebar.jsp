<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <h3>Menu</h3>
        <button class="close-btn" onclick="toggleSidebar()">&times;</button>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/" onclick="toggleSidebar()"><i class="fa fa-home"></i> Trang chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/movies" onclick="toggleSidebar()"><i class="fa fa-film"></i> Phim đang chiếu</a></li>
        <li><a href="${pageContext.request.contextPath}/showtimes" onclick="toggleSidebar()"><i class="fa fa-calendar"></i> Lịch chiếu</a></li>

        <c:if test="${not empty sessionScope.user}">
            <!-- Customer menu -->
            <li><a href="${pageContext.request.contextPath}/customer/my-tickets" onclick="toggleSidebar()"><i class="fa fa-ticket"></i> Vé của tôi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/booking-history" onclick="toggleSidebar()"><i class="fa fa-history"></i> Lịch sử đặt vé</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/promotions" onclick="toggleSidebar()"><i class="fa fa-gift"></i> Ưu đãi</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/membership" onclick="toggleSidebar()"><i class="fa fa-star"></i> Thành viên</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/combos" onclick="toggleSidebar()"><i class="fa fa-utensils"></i> Combo</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/profile" onclick="toggleSidebar()"><i class="fa fa-user"></i> Tài khoản</a></li>
            <li><a href="${pageContext.request.contextPath}/logout" onclick="toggleSidebar()"><i class="fa fa-sign-out"></i> Đăng xuất</a></li>
        </c:if>

        <c:if test="${empty sessionScope.user}">
            <!-- Guest menu -->
            <li><a href="${pageContext.request.contextPath}/login" onclick="toggleSidebar()"><i class="fa fa-sign-in"></i> Đăng nhập tài khoản</a></li>
        </c:if>
    </ul>
</div>

<style>
.sidebar {
    width: 250px;
    height: 100vh;
    background-color: #343a40;
    color: white;
    position: fixed;
    top: 0;
    left: -250px; /* Hidden by default */
    overflow-y: auto;
    z-index: 1000;
    transition: left 0.3s ease;
}

.sidebar.open {
    left: 0;
}

.sidebar-header {
    padding: 20px;
    text-align: center;
    border-bottom: 1px solid #495057;
    position: relative;
}

.close-btn {
    position: absolute;
    top: 10px;
    right: 10px;
    background: none;
    border: none;
    color: white;
    font-size: 24px;
    cursor: pointer;
}

.sidebar-menu {
    list-style: none;
    padding: 0;
    margin: 0;
}

.sidebar-menu li {
    border-bottom: 1px solid #495057;
}

.sidebar-menu li a {
    display: block;
    padding: 15px 20px;
    color: white;
    text-decoration: none;
    transition: background-color 0.3s;
}

.sidebar-menu li a:hover {
    background-color: #495057;
}

.sidebar-menu li a i {
    margin-right: 10px;
}

/* Hamburger button */
.hamburger {
    display: inline-block;
    cursor: pointer;
    padding: 10px;
}

.hamburger span {
    display: block;
    width: 25px;
    height: 3px;
    background-color: white;
    margin: 5px 0;
    transition: 0.3s;
}
</style>