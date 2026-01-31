<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Counter Booking - Select Movie</title>
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

        .top-bar-actions .btn-outline-secondary {
            border-color: #262625;
            color: #ccc;
        }

        .top-bar-actions .btn-outline-secondary:hover {
            background: #d96c2c;
            border-color: #d96c2c;
            color: white;
        }

        /* Date Selector */
        .date-selector {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            margin-bottom: 30px;
        }

        .date-selector h3 {
            font-size: 18px;
            color: white;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .date-selector h3 i {
            color: #d96c2c;
        }

        .date-selector input[type="date"] {
            padding: 12px 20px;
            border: 2px solid #262625;
            background: #0c121d;
            color: white;
            border-radius: 8px;
            font-size: 16px;
            width: 250px;
            transition: all 0.3s;
        }

        .date-selector input[type="date"]:focus {
            outline: none;
            border-color: #d96c2c;
            box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
        }

        /* Movies Grid */
        .movies-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .movie-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .movie-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(217, 108, 44, 0.2);
            border-color: #d96c2c;
        }

        .movie-poster {
            width: 100%;
            height: 380px;
            object-fit: cover;
            background: #262625;
        }

        .movie-info {
            padding: 20px;
        }

        .movie-title {
            font-size: 18px;
            font-weight: 600;
            color: white;
            margin-bottom: 10px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .movie-meta {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }

        .movie-meta span {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 14px;
            color: #ccc;
        }

        .movie-meta i {
            color: #d96c2c;
        }

        .movie-genre {
            display: inline-block;
            padding: 5px 12px;
            background: rgba(217, 108, 44, 0.2);
            color: #d96c2c;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            margin-top: 10px;
        }

        .movie-actions {
            margin-top: 15px;
            display: flex;
            gap: 10px;
        }

        .btn-select-movie {
            flex: 1;
            padding: 12px 20px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-select-movie:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(217, 108, 44, 0.4);
        }

        /* Empty State */
        .empty-state {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 60px 40px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .empty-state i {
            font-size: 64px;
            color: #d96c2c;
            margin-bottom: 20px;
        }

        .empty-state h3 {
            font-size: 24px;
            color: white;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #ccc;
            font-size: 16px;
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

            .movies-grid {
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 15px;
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
                <a href="${pageContext.request.contextPath}/staff/dashboard">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="active">
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
            <h1><i class="fas fa-film"></i> Counter Booking - Select Movie</h1>
            <div class="top-bar-actions">
                <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-outline-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>

        <!-- Date Selector -->
        <div class="date-selector">
            <h3><i class="fas fa-calendar-day"></i> Select Date</h3>
            <input type="date" id="dateSelect" value="${selectedDate}" 
                   min="${today}" onchange="changeDate(this.value)">
        </div>

        <!-- Movies Grid -->
        <c:choose>
            <c:when test="${not empty movies}">
                <div class="movies-grid">
                    <c:forEach items="${movies}" var="movie">
                        <div class="movie-card">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="${movie.posterUrl}" alt="${movie.title}" class="movie-poster">
                                </c:when>
                                <c:otherwise>
                                    <div class="movie-poster"></div>
                                </c:otherwise>
                            </c:choose>
                            
                            <div class="movie-info">
                                <h3 class="movie-title">${movie.title}</h3>
                                
                                <div class="movie-meta">
                                    <span>
                                        <i class="fas fa-clock"></i>
                                        ${movie.duration} min
                                    </span>
                                    <span>
                                        <i class="fas fa-star"></i>
                                        <fmt:formatNumber value="${movie.rating}" maxFractionDigits="1"/>
                                    </span>
                                    <span>
                                        <i class="fas fa-tag"></i>
                                        ${movie.ageRating}
                                    </span>
                                </div>
                                
                                <span class="movie-genre">${movie.genre}</span>
                                
                                <div class="movie-actions">
                                    <a href="${pageContext.request.contextPath}/staff/counter-booking-showtimes?movieId=${movie.movieId}&date=${selectedDate}" 
                                       class="btn-select-movie">
                                        <i class="fas fa-arrow-right"></i> Select Showtime
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-film"></i>
                    <h3>No Movies Available</h3>
                    <p>There are no movies showing on this date. Please select another date.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

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

        // Change date
        function changeDate(date) {
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking?date=' + date;
        }
    </script>
</body>
</html>
