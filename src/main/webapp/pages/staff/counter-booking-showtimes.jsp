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
