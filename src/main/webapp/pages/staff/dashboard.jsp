<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cinema Staff Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #0c121d;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            height: 100vh;
            width: 260px;
            background: #010202;
            border-right: 1px solid #262625;
            padding: 20px 0;
            transition: all 0.3s ease;
            z-index: 1000;
            box-shadow: 4px 0 10px rgba(0, 0, 0, 0.3);
        }

        .sidebar.collapsed {
            width: 80px;
        }

        .sidebar-header {
            padding: 20px;
            text-align: center;
            color: white;
            border-bottom: 1px solid #262625;
            margin-bottom: 20px;
        }

        .sidebar-header h3 {
            font-size: 22px;
            font-weight: 600;
            margin: 0;
            transition: opacity 0.3s;
        }

        .sidebar.collapsed .sidebar-header h3 {
            opacity: 0;
            display: none;
        }

        .sidebar-header .logo-icon {
            font-size: 32px;
            margin-bottom: 10px;
        }

        /* Sidebar Menu */
        .sidebar-menu {
            list-style: none;
            padding: 0 10px;
        }

        .sidebar-menu li {
            margin-bottom: 5px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            color: #ccc;
            text-decoration: none;
            border-radius: 10px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .sidebar-menu a:hover {
            background: #111;
            color: #d96c2c;
            transform: translateX(5px);
        }

        .sidebar-menu a.active {
            background: rgba(217, 108, 44, 0.2);
            color: #d96c2c;
            border-left: 3px solid #d96c2c;
        }

        .sidebar-menu a i {
            font-size: 20px;
            width: 30px;
            text-align: center;
            margin-right: 15px;
        }

        .sidebar.collapsed .sidebar-menu a span {
            opacity: 0;
            display: none;
        }

        .sidebar.collapsed .sidebar-menu a {
            justify-content: center;
        }

        .sidebar.collapsed .sidebar-menu a i {
            margin-right: 0;
        }

        /* User Profile in Sidebar */
        .sidebar-user {
            position: absolute;
            bottom: 20px;
            left: 0;
            right: 0;
            padding: 20px;
            border-top: 1px solid #262625;
        }

        .sidebar-user .user-info {
            display: flex;
            align-items: center;
            color: white;
        }

        .sidebar-user .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #d96c2c;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            font-size: 18px;
            color: white;
            font-weight: 600;
        }

        .sidebar-user .user-details {
            flex: 1;
            transition: opacity 0.3s;
        }

        .sidebar.collapsed .user-details {
            opacity: 0;
            display: none;
        }

        .sidebar-user .user-name {
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 2px;
        }

        .sidebar-user .user-role {
            font-size: 12px;
            opacity: 0.8;
        }

        /* Toggle Button */
        .sidebar-toggle {
            position: absolute;
            top: 20px;
            right: -15px;
            width: 30px;
            height: 30px;
            background: #d96c2c;
            border: none;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            z-index: 1001;
            transition: transform 0.3s;
        }

        .sidebar-toggle:hover {
            transform: scale(1.1);
        }

        /* Main Content */
        .main-content {
            margin-left: 260px;
            padding: 30px;
            transition: margin-left 0.3s ease;
            min-height: 100vh;
        }

        .sidebar.collapsed ~ .main-content {
            margin-left: 80px;
        }

        /* Top Bar */
        .top-bar {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 20px 30px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .top-bar h1 {
            font-size: 28px;
            color: white;
            margin: 0;
            font-weight: 600;
        }

        .top-bar h1 i {
            color: #d96c2c;
        }

        .top-bar-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .current-time {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #ccc;
            font-size: 14px;
        }

        .current-time i {
            color: #d96c2c;
        }

        .btn-logout {
            padding: 10px 20px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-logout:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(217, 108, 44, 0.4);
        }

        /* Dashboard Cards */
        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .dashboard-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(217, 108, 44, 0.2);
            border-color: #d96c2c;
        }

        .dashboard-card .card-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
        }

        .dashboard-card.card-primary .card-icon {
            background: #d96c2c;
            color: white;
        }

        .dashboard-card.card-success .card-icon {
            background: rgba(217, 108, 44, 0.8);
            color: white;
        }

        .dashboard-card.card-warning .card-icon {
            background: rgba(217, 108, 44, 0.6);
            color: white;
        }

        .dashboard-card.card-info .card-icon {
            background: #262625;
            color: #d96c2c;
        }

        .dashboard-card h3 {
            font-size: 32px;
            font-weight: 700;
            color: white;
            margin-bottom: 5px;
        }

        .dashboard-card p {
            color: #ccc;
            font-size: 14px;
            margin: 0;
        }

        /* Welcome Section */
        .welcome-section {
            background: #1a1a1a;
            border: 1px solid #262625;
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
        }

        .welcome-section h2 {
            color: #d96c2c;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .welcome-section p {
            font-size: 16px;
            color: #ccc;
            opacity: 0.9;
        }

        /* Quick Actions */
        .quick-actions {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .quick-actions h3 {
            font-size: 20px;
            color: white;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .quick-actions h3 i {
            color: #d96c2c;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 20px;
            background: #262625;
            border: 2px solid #262625;
            border-radius: 10px;
            text-decoration: none;
            color: #ccc;
            font-weight: 500;
            transition: all 0.3s;
        }

        .action-btn:hover {
            background: transparent;
            border-color: #d96c2c;
            color: #d96c2c;
            transform: translateX(5px);
        }

        .action-btn i {
            font-size: 24px;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #d96c2c;
            color: white;
            border-radius: 8px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
            }

            .top-bar {
                flex-direction: column;
                gap: 15px;
            }

            .dashboard-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>
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
            <h3>Cinema Staff</h3>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard" class="active">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Counter Booking</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/schedule">
                    <i class="fas fa-calendar-alt"></i>
                    <span>View Working Schedule</span>
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
                                Staff User
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-role">Cinema Staff</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Top Bar -->
        <div class="top-bar">
            <h1><i class="fas fa-tachometer-alt"></i> Dashboard</h1>
            <div class="top-bar-actions">
                <div class="current-time">
                    <i class="fas fa-clock"></i>
                    <span id="currentDateTime"></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </div>
        </div>

        <!-- Welcome Section -->
        <div class="welcome-section">
            <h2>Welcome back, 
                <c:choose>
                    <c:when test="${not empty sessionScope.user.fullName}">
                        ${sessionScope.user.fullName}
                    </c:when>
                    <c:otherwise>
                        Staff
                    </c:otherwise>
                </c:choose>!
            </h2>
            <p>Ready to provide excellent service to our customers today.</p>
        </div>

        <!-- Dashboard Cards -->
        <div class="dashboard-cards">
            <div class="dashboard-card card-primary">
                <div class="card-icon">
                    <i class="fas fa-ticket-alt"></i>
                </div>
                <h3>0</h3>
                <p>Tickets Sold Today</p>
            </div>

            <div class="dashboard-card card-success">
                <div class="card-icon">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <h3>0 đ</h3>
                <p>Today's Revenue</p>
            </div>

            <div class="dashboard-card card-warning">
                <div class="card-icon">
                    <i class="fas fa-film"></i>
                </div>
                <h3>0</h3>
                <p>Active Showtimes</p>
            </div>

            <div class="dashboard-card card-info">
                <div class="card-icon">
                    <i class="fas fa-users"></i>
                </div>
                <h3>0</h3>
                <p>Customers Served</p>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="action-btn">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Start Counter Booking</span>
                </a>
                <a href="${pageContext.request.contextPath}/staff/schedule" class="action-btn">
                    <i class="fas fa-calendar-check"></i>
                    <span>View My Schedule</span>
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
