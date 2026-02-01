<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Showtime - Counter Booking</title>
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
            color: white;
        }

        /* Sidebar Styles - Simplified */
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

        .btn-back {
            padding: 10px 20px;
            background: transparent;
            color: #ccc;
            border: 2px solid #262625;
            border-radius: 8px;
            text-decoration: none;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-back:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        /* Movie Info Card */
        .movie-info-card {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .movie-info-content {
            display: flex;
            gap: 30px;
        }

        .movie-poster-container {
            flex-shrink: 0;
        }

        .movie-poster-img {
            width: 200px;
            height: 280px;
            object-fit: cover;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
        }

        .movie-details {
            flex: 1;
        }

        .movie-details h2 {
            font-size: 32px;
            margin-bottom: 15px;
            color: white;
        }

        .movie-meta {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .movie-meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #ccc;
            font-size: 16px;
        }

        .movie-meta-item i {
            color: #d96c2c;
        }

        .movie-meta-item .badge {
            padding: 5px 12px;
            background: rgba(217, 108, 44, 0.2);
            color: #d96c2c;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
        }

        .movie-description {
            color: #aaa;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        /* Showtimes Section */
        .showtimes-section {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .showtimes-section h3 {
            font-size: 24px;
            color: white;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .showtimes-section h3 i {
            color: #d96c2c;
        }

        .date-display {
            background: rgba(217, 108, 44, 0.1);
            border: 2px solid #d96c2c;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: #d96c2c;
            font-weight: 500;
            font-size: 16px;
        }

        .date-display i {
            font-size: 20px;
        }

        /* Showtimes Grid */
        .showtimes-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .showtime-card {
            background: #0c121d;
            border: 2px solid #262625;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
        }

        .showtime-card:hover {
            border-color: #d96c2c;
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(217, 108, 44, 0.3);
        }

        .showtime-card.no-seats {
            opacity: 0.5;
            cursor: not-allowed;
            border-color: #555;
        }

        .showtime-card.no-seats:hover {
            transform: none;
            border-color: #555;
            box-shadow: none;
        }

        .showtime-time {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
        }

        .showtime-time i {
            color: #d96c2c;
            font-size: 24px;
        }

        .showtime-time span {
            font-size: 28px;
            font-weight: 600;
            color: white;
        }

        .showtime-info {
            margin-bottom: 15px;
        }

        .showtime-info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            color: #ccc;
            font-size: 14px;
        }

        .showtime-info-item strong {
            color: white;
        }

        .seat-availability {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            background: rgba(217, 108, 44, 0.1);
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .seat-availability.no-seats {
            background: rgba(255, 0, 0, 0.1);
        }

        .seat-availability-label {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #ccc;
            font-size: 14px;
        }

        .seat-availability-label i {
            color: #d96c2c;
        }

        .seat-availability.no-seats .seat-availability-label i {
            color: #ff4444;
        }

        .seat-count {
            font-size: 18px;
            font-weight: 600;
            color: #d96c2c;
        }

        .seat-count.no-seats {
            color: #ff4444;
        }

        .btn-select-showtime {
            width: 100%;
            padding: 12px 20px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: block;
            text-align: center;
        }

        .btn-select-showtime:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
        }

        .btn-select-showtime:disabled {
            background: #555;
            cursor: not-allowed;
            opacity: 0.5;
        }

        .btn-select-showtime:disabled:hover {
            background: #555;
            color: white;
            transform: none;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 40px;
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

        /* Status Badge */
        .status-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-badge.available {
            background: rgba(76, 175, 80, 0.2);
            color: #4caf50;
        }

        .status-badge.limited {
            background: rgba(255, 152, 0, 0.2);
            color: #ff9800;
        }

        .status-badge.sold-out {
            background: rgba(244, 67, 54, 0.2);
            color: #f44336;
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

            .movie-info-content {
                flex-direction: column;
            }

            .showtimes-grid {
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
            <h1><i class="fas fa-clock"></i> Select Showtime</h1>
            <div class="top-bar-actions">
                <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Movies
                </a>
            </div>
        </div>

        <!-- Movie Info Card -->
        <c:if test="${not empty movie}">
            <div class="movie-info-card">
                <div class="movie-info-content">
                    <div class="movie-poster-container">
                        <c:set var="defaultPoster" value="${pageContext.request.contextPath}/images/default_poster.jpg" />
                        <c:set var="posterSrc" value="${not empty movie.posterUrl ? movie.posterUrl : defaultPoster}" />
                        <img src="${posterSrc}" alt="${movie.title}" class="movie-poster-img"
                             onerror="this.onerror=null; this.src='${defaultPoster}';">
                    </div>
                    <div class="movie-details">
                        <h2>${movie.title}</h2>
                        <div class="movie-meta">
                            <div class="movie-meta-item">
                                <i class="fas fa-theater-masks"></i>
                                <span>${movie.genre}</span>
                            </div>
                            <div class="movie-meta-item">
                                <i class="fas fa-clock"></i>
                                <span>${movie.duration} min</span>
                            </div>
                            <div class="movie-meta-item">
                                <i class="fas fa-star"></i>
                                <span><fmt:formatNumber value="${movie.rating}" maxFractionDigits="1"/>/5</span>
                            </div>
                            <div class="movie-meta-item">
                                <span class="badge">${movie.ageRating}</span>
                            </div>
                        </div>
                        <c:if test="${not empty movie.description}">
                            <p class="movie-description">${movie.description}</p>
                        </c:if>
                        <div class="movie-meta">
                            <c:if test="${not empty movie.director}">
                                <div class="movie-meta-item">
                                    <i class="fas fa-user-tie"></i>
                                    <span><strong>Director:</strong> ${movie.director}</span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Showtimes Section -->
        <div class="showtimes-section">
            <h3><i class="fas fa-calendar-day"></i> Available Showtimes</h3>
            
            <div class="date-display">
                <i class="fas fa-calendar-check"></i>
                <span>
                    <fmt:formatDate value="${java.sql.Date.valueOf(selectedDate)}" pattern="EEEE, MMMM dd, yyyy" />
                </span>
            </div>

            <c:choose>
                <c:when test="${not empty showtimes}">
                    <div class="showtimes-grid">
                        <c:forEach items="${showtimes}" var="showtime">
                            <c:set var="availableSeats" value="${availableSeatsMap[showtime.showtimeId]}" />
                            <c:set var="totalSeats" value="${totalSeatsMap[showtime.showtimeId]}" />
                            <c:set var="hasSeats" value="${availableSeats > 0}" />
                            
                            <div class="showtime-card ${!hasSeats ? 'no-seats' : ''}">
                                <!-- Status Badge -->
                                <c:choose>
                                    <c:when test="${availableSeats == 0}">
                                        <span class="status-badge sold-out">Sold Out</span>
                                    </c:when>
                                    <c:when test="${availableSeats < totalSeats * 0.2}">
                                        <span class="status-badge limited">Limited</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge available">Available</span>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Showtime -->
                                <div class="showtime-time">
                                    <i class="fas fa-clock"></i>
                                    <span><fmt:formatDate value="${java.sql.Time.valueOf(showtime.startTime)}" pattern="HH:mm" /></span>
                                </div>

                                <!-- Info -->
                                <div class="showtime-info">
                                    <div class="showtime-info-item">
                                        <span>Base Price:</span>
                                        <strong><fmt:formatNumber value="${showtime.basePrice}" pattern="#,###" /> VND</strong>
                                    </div>
                                    <div class="showtime-info-item">
                                        <span>Status:</span>
                                        <strong>${showtime.status}</strong>
                                    </div>
                                </div>

                                <!-- Seat Availability -->
                                <div class="seat-availability ${!hasSeats ? 'no-seats' : ''}">
                                    <div class="seat-availability-label">
                                        <i class="fas fa-couch"></i>
                                        <span>Available Seats</span>
                                    </div>
                                    <span class="seat-count ${!hasSeats ? 'no-seats' : ''}">${availableSeats} / ${totalSeats}</span>
                                </div>

                                <!-- Select Button -->
                                <c:choose>
                                    <c:when test="${hasSeats}">
                                        <a href="${pageContext.request.contextPath}/staff/counter-booking-seats?showtimeId=${showtime.showtimeId}" 
                                           class="btn-select-showtime">
                                            <i class="fas fa-arrow-right"></i> Select Seats
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn-select-showtime" disabled>
                                            <i class="fas fa-ban"></i> Sold Out
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <h3>No Showtimes Available</h3>
                        <p>There are no scheduled showtimes for this movie on the selected date.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
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
    </script>
</body>
</html>
