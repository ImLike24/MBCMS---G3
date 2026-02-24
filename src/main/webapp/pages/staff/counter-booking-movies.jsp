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
                    <input type="date" id="dateSelect" value="" 
                           min="${today}" onchange="changeDate(this.value)" name="date" autocomplete="off">
                    <c:choose>
                        <c:when test="${showAllMovies}">
                        <script>
                            document.getElementById('dateSelect').value = '';
                        </script>
                        </c:when>
                        <c:when test="${!showAllMovies && selectedDate != null}">
                        <script>
                            document.getElementById('dateSelect').value = '${selectedDate}';
                        </script>
                        </c:when>
                    </c:choose>
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
                    <c:if test="${showAllMovies}">
                        <span style="color: #d96c2c;"> (All Movies)</span>
                    </c:if>
                    <c:if test="${!showAllMovies && selectedDate != null}">
                        <span style="color: #d96c2c;"> (Date: ${selectedDate})</span>
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
                            <c:set var="defaultPoster" value="${pageContext.request.contextPath}/images/default_poster.jpg" />
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
                                <c:if test="${showAllMovies && !movie.hasShowtimesToday}">
                                    <span class="movie-badge">
                                        <i class="fas fa-info-circle"></i>
                                        No showtimes today
                                    </span>
                                </c:if>
                                
                                <div class="movie-actions">
                                    <c:choose>
                                        <c:when test="${selectedDate != null}">
                                            <a href="${pageContext.request.contextPath}/staff/counter-booking-showtimes?movieId=${movie.movieId}&date=${selectedDate}" 
                                               class="btn-select-movie">
                                                <i class="fas fa-arrow-right"></i> Select Showtime
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn-select-movie" onclick="alert('Please select a date first'); document.getElementById('dateSelect').focus();">
                                                <i class="fas fa-arrow-right"></i> Select Showtime
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
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
                            <c:when test="${showAllMovies}">
                                There are no active movies in the system.
                            </c:when>
                            <c:when test="${selectedDate != null}">
                                There are no movies showing on ${selectedDate}. Please select another date.
                            </c:when>
                            <c:otherwise>
                                There are no movies available.
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${not empty searchQuery || not empty selectedGenre || not empty selectedAgeRating || showAllMovies}">
                        <button class="reset-btn" onclick="window.location.href='${pageContext.request.contextPath}/staff/counter-booking'" style="margin-top: 20px;">
                            <i class="fas fa-calendar-day"></i> Show Today's Movies
                        </button>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <c:set var="baseUrl" value="${pageContext.request.contextPath}/staff/counter-booking?" />
            <c:set var="resetParam" value="${showAllMovies ? 'reset=true&' : ''}" />
            <c:set var="dateParam" value="${!showAllMovies && selectedDate != null ? 'date='.concat(selectedDate).concat('&') : ''}" />
            <c:set var="searchParam" value="${not empty searchQuery ? 'search='.concat(searchQuery).concat('&') : ''}" />
            <c:set var="genreParam" value="${not empty selectedGenre ? 'genre='.concat(selectedGenre).concat('&') : ''}" />
            <c:set var="ageRatingParam" value="${not empty selectedAgeRating ? 'ageRating='.concat(selectedAgeRating).concat('&') : ''}" />
            
            <div class="pagination-section">
                <!-- Previous Button -->
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="${baseUrl}${resetParam}${dateParam}${searchParam}${genreParam}${ageRatingParam}page=${currentPage - 1}" 
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
                    <a href="${baseUrl}${resetParam}${dateParam}${searchParam}${genreParam}${ageRatingParam}page=1" 
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
                            <a href="${baseUrl}${resetParam}${dateParam}${searchParam}${genreParam}${ageRatingParam}page=${i}" 
                               class="pagination-btn">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}">
                        <span class="pagination-info">...</span>
                    </c:if>
                    <a href="${baseUrl}${resetParam}${dateParam}${searchParam}${genreParam}${ageRatingParam}page=${totalPages}" 
                       class="pagination-btn">${totalPages}</a>
                </c:if>

                <!-- Next Button -->
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="${baseUrl}${resetParam}${dateParam}${searchParam}${genreParam}${ageRatingParam}page=${currentPage + 1}" 
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

        // Reset all filters including date - show ALL movies
        function resetFilters() {
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking?reset=true';
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
