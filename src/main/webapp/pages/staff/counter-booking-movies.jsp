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

        .sidebar-menu a.schedule-link i {
            color: #fff;
        }

        .sidebar-menu a.schedule-link:hover i {
            color: #d96c2c;
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

        /* Search and Filter Section */
        .search-filter-section {
            background: #1a1a1a;
            border: 1px solid #262625;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            margin-bottom: 30px;
        }

        .search-filter-section h3 {
            font-size: 18px;
            color: white;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .search-filter-section h3 i {
            color: #d96c2c;
        }

        .search-filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            align-items: flex-end;
        }

        .form-group {
            flex: 1;
            min-width: 200px;
        }

        .form-group label {
            display: block;
            color: #ccc;
            font-size: 14px;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-group label i {
            color: #fff;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #262625;
            background: #0c121d;
            color: white;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #d96c2c;
            box-shadow: 0 0 0 3px rgba(217, 108, 44, 0.2);
        }

        /* Icon lịch bên trong ô date (Chrome, Edge, Safari) → màu trắng */
        .form-group input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(1);
            opacity: 0.9;
            cursor: pointer;
        }

        .form-group input::placeholder {
            color: #666;
        }

        .form-group select option {
            background: #1a1a1a;
            color: white;
        }

        .search-btn {
            padding: 12px 24px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .search-btn:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
        }

        .reset-btn {
            padding: 12px 24px;
            background: transparent;
            color: #ccc;
            border: 2px solid #262625;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .reset-btn:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        /* Results Info */
        .results-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            color: #ccc;
            font-size: 14px;
        }

        .results-info .count {
            color: #d96c2c;
            font-weight: 600;
        }

        /* Pagination */
        .pagination-section {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 40px;
            padding: 20px;
        }

        .pagination-btn {
            padding: 10px 16px;
            background: #1a1a1a;
            color: #ccc;
            border: 1px solid #262625;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .pagination-btn:hover:not(.disabled) {
            background: #d96c2c;
            border-color: #d96c2c;
            color: white;
        }

        .pagination-btn.active {
            background: #d96c2c;
            border-color: #d96c2c;
            color: white;
        }

        .pagination-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
        }

        .pagination-info {
            color: #ccc;
            font-size: 14px;
            padding: 0 15px;
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
                <a href="${pageContext.request.contextPath}/staff/schedule" class="schedule-link">
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

        <!-- Select Date & Search and Filter Section -->
        <div class="search-filter-section">
            <h3><i class="fas fa-calendar-day"></i> Select Date & Search & Filter Movies</h3>
            <form class="search-filter-form" id="filterForm" method="get" action="${pageContext.request.contextPath}/staff/counter-booking">
                <div class="form-group">
                    <label for="dateSelect"><i class="fas fa-calendar-day"></i> Date</label>
                    <input type="date" id="dateSelect" value="${selectedDate}" 
                           min="${today}" onchange="changeDate(this.value)" name="date">
                </div>
                
                <div class="form-group" style="flex: 2;">
                    <label for="search"><i class="fas fa-search"></i> Search</label>
                    <input type="text" id="search" name="search" 
                           placeholder="Search by title, director, cast..." 
                           value="${searchQuery}">
                </div>
                
                <div class="form-group">
                    <label for="genre"><i class="fas fa-theater-masks"></i> Genre</label>
                    <select id="genre" name="genre">
                        <option value="">All Genres</option>
                        <c:forEach items="${genres}" var="g">
                            <option value="${g}" ${selectedGenre == g ? 'selected' : ''}>${g}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="ageRating"><i class="fas fa-user-shield"></i> Age Rating</label>
                    <select id="ageRating" name="ageRating">
                        <option value="">All Ratings</option>
                        <c:forEach items="${ageRatings}" var="ar">
                            <option value="${ar}" ${selectedAgeRating == ar ? 'selected' : ''}>${ar}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <button type="submit" class="search-btn">
                    <i class="fas fa-search"></i> Search
                </button>
                <button type="button" class="reset-btn" onclick="resetFilters()">
                    <i class="fas fa-redo"></i> Reset
                </button>
            </form>
        </div>

        <!-- Results Info -->
        <c:if test="${not empty movies}">
            <div class="results-info">
                <span>
                    Showing <span class="count">${(currentPage - 1) * pageSize + 1}</span> - 
                    <span class="count">${(currentPage - 1) * pageSize + movies.size()}</span> 
                    of <span class="count">${totalMovies}</span> movies
                    <c:if test="${not empty searchQuery}">
                        for "<strong>${searchQuery}</strong>"
                    </c:if>
                </span>
                <span>Page ${currentPage} of ${totalPages}</span>
            </div>
        </c:if>

        <!-- Movies Grid -->
        <c:choose>
            <c:when test="${not empty movies}">
                <div class="movies-grid">
                    <c:forEach items="${movies}" var="movie">
                        <div class="movie-card">
                            <c:set var="defaultPoster" value="https://placehold.co/280x380/1a1a1a/666?text=No+Poster" />
                            <c:set var="posterSrc" value="${not empty movie.posterUrl ? movie.posterUrl : defaultPoster}" />
                            <img src="${posterSrc}" alt="${movie.title}" class="movie-poster"
                                 onerror="this.onerror=null; this.src='${defaultPoster}';">
                            
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
                    <h3>No Movies Found</h3>
                    <p>
                        <c:choose>
                            <c:when test="${not empty searchQuery || not empty selectedGenre || not empty selectedAgeRating}">
                                No movies match your search criteria. Try adjusting your filters.
                            </c:when>
                            <c:otherwise>
                                There are no movies showing on this date. Please select another date.
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${not empty searchQuery || not empty selectedGenre || not empty selectedAgeRating}">
                        <button class="reset-btn" onclick="resetFilters()" style="margin-top: 20px;">
                            <i class="fas fa-redo"></i> Reset Filters
                        </button>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="pagination-section">
                <!-- Previous Button -->
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}&page=${currentPage - 1}&search=${searchQuery}&genre=${selectedGenre}&ageRating=${selectedAgeRating}" 
                           class="pagination-btn">
                            <i class="fas fa-chevron-left"></i> Prev
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="pagination-btn disabled">
                            <i class="fas fa-chevron-left"></i> Prev
                        </span>
                    </c:otherwise>
                </c:choose>

                <!-- Page Numbers -->
                <c:set var="startPage" value="${currentPage - 2 > 0 ? currentPage - 2 : 1}" />
                <c:set var="endPage" value="${startPage + 4 > totalPages ? totalPages : startPage + 4}" />
                <c:if test="${endPage - startPage < 4 && startPage > 1}">
                    <c:set var="startPage" value="${endPage - 4 > 0 ? endPage - 4 : 1}" />
                </c:if>

                <c:if test="${startPage > 1}">
                    <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}&page=1&search=${searchQuery}&genre=${selectedGenre}&ageRating=${selectedAgeRating}" 
                       class="pagination-btn">1</a>
                    <c:if test="${startPage > 2}">
                        <span class="pagination-info">...</span>
                    </c:if>
                </c:if>

                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <span class="pagination-btn active">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}&page=${i}&search=${searchQuery}&genre=${selectedGenre}&ageRating=${selectedAgeRating}" 
                               class="pagination-btn">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}">
                        <span class="pagination-info">...</span>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}&page=${totalPages}&search=${searchQuery}&genre=${selectedGenre}&ageRating=${selectedAgeRating}" 
                       class="pagination-btn">${totalPages}</a>
                </c:if>

                <!-- Next Button -->
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="${pageContext.request.contextPath}/staff/counter-booking?date=${selectedDate}&page=${currentPage + 1}&search=${searchQuery}&genre=${selectedGenre}&ageRating=${selectedAgeRating}" 
                           class="pagination-btn">
                            Next <i class="fas fa-chevron-right"></i>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="pagination-btn disabled">
                            Next <i class="fas fa-chevron-right"></i>
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
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

        // Change date (preserve search and filter)
        function changeDate(date) {
            const search = document.getElementById('search').value;
            const genre = document.getElementById('genre').value;
            const ageRating = document.getElementById('ageRating').value;
            
            let url = '${pageContext.request.contextPath}/staff/counter-booking?date=' + date;
            if (search) url += '&search=' + encodeURIComponent(search);
            if (genre) url += '&genre=' + encodeURIComponent(genre);
            if (ageRating) url += '&ageRating=' + encodeURIComponent(ageRating);
            
            window.location.href = url;
        }

        // Reset all filters
        function resetFilters() {
            const date = document.getElementById('dateSelect').value;
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking?date=' + date;
        }

        // Submit form on filter change (optional - for instant filter)
        document.getElementById('genre').addEventListener('change', function() {
            document.getElementById('filterForm').submit();
        });

        document.getElementById('ageRating').addEventListener('change', function() {
            document.getElementById('filterForm').submit();
        });

        // Search on Enter key
        document.getElementById('search').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                document.getElementById('filterForm').submit();
            }
        });
    </script>
</body>
</html>
