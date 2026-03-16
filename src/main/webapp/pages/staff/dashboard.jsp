<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển nhân viên rạp</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <button class="sidebar-toggle" onclick="toggleSidebar()">
            <i class="fas fa-chevron-left"></i>
        </button>

        <div class="sidebar-header">
            <div class="logo-icon">
                <i class="fas fa-film"></i>
            </div>
            <h3>Nhân viên rạp</h3>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard" class="active">
                    <i class="fas fa-home"></i>
                    <span>Bảng điều khiển</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Bán vé tại quầy</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i>
                    <span>Lịch làm việc</span>
                </a>
            </li>
        </ul>

        <div class="sidebar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName.substring(0, 1).toUpperCase()}
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-user"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="user-details">
                    <div class="user-name">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.fullName}">
                                ${sessionScope.user.fullName}
                            </c:when>
                            <c:otherwise>
                                Nhân viên
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Nhân viên rạp</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Top Bar -->
        <div class="top-bar">
            <h1><i class="fas fa-tachometer-alt"></i> Bảng điều khiển</h1>
            <div class="top-bar-actions">
                <div class="current-time">
                    <i class="fas fa-clock"></i>
                    <span id="currentDateTime"></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i>
                    Đăng xuất
                </a>
            </div>
        </div>

        <!-- Welcome Section -->
        <div class="welcome-section">
            <h2>Chào mừng quay lại, 
                <c:choose>
                    <c:when test="${not empty sessionScope.user.fullName}">
                        ${sessionScope.user.fullName}
                    </c:when>
                    <c:otherwise>
                        Nhân viên
                    </c:otherwise>
                </c:choose>!
            </h2>
            <p>Sẵn sàng phục vụ khách hàng thật tốt hôm nay.</p>
        </div>

        <!-- Dashboard Cards -->
        <div class="dashboard-cards">
            <div class="dashboard-card card-primary">
                <div class="card-icon">
                    <i class="fas fa-ticket-alt"></i>
                </div>
                <h3>0</h3>
                <p>Vé bán hôm nay</p>
            </div>

            <div class="dashboard-card card-success">
                <div class="card-icon">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <h3>0 đ</h3>
                <p>Doanh thu hôm nay</p>
            </div>

            <div class="dashboard-card card-warning">
                <div class="card-icon">
                    <i class="fas fa-film"></i>
                </div>
                <h3>0</h3>
                <p>Suất chiếu đang hoạt động</p>
            </div>

            <div class="dashboard-card card-info">
                <div class="card-icon">
                    <i class="fas fa-users"></i>
                </div>
                <h3>0</h3>
                <p>Khách đã phục vụ</p>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3><i class="fas fa-bolt"></i> Thao tác nhanh</h3>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="action-btn">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Bắt đầu bán vé quầy</span>
                </a>
                <a href="${pageContext.request.contextPath}/staff/schedule" class="action-btn">
                    <i class="fas fa-calendar-check"></i>
                    <span>Xem lịch làm việc</span>
                </a>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/jquery-3.7.1.min.js"></script>
    <script>
        // Toggle Sidebar
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
            
            const icon = document.querySelector('.sidebar-toggle i');
            if (sidebar.classList.contains('collapsed')) {
                icon.className = 'fas fa-chevron-right';
            } else {
                icon.className = 'fas fa-chevron-left';
            }
        }

        // Update current date/time
        function updateDateTime() {
            const now = new Date();
            const options = { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            };
            document.getElementById('currentDateTime').textContent = 
                now.toLocaleDateString('vi-VN', options);
        }

        updateDateTime();
        setInterval(updateDateTime, 1000);

        // Mobile menu toggle
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        if (mobileMenuBtn) {
            mobileMenuBtn.addEventListener('click', function() {
                document.getElementById('sidebar').classList.toggle('active');
            });
        }
    </script>
</body>
</html>
