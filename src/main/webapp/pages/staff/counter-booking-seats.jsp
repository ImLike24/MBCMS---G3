<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Seats - Counter Booking</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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

        /* Content Layout */
        .content-layout {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
        }

        /* Movie Info Header */
        .movie-info-header {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .movie-poster-small {
            width: 80px;
            height: 120px;
            object-fit: cover;
            border-radius: 8px;
        }

        .movie-info-text h2 {
            font-size: 24px;
            margin-bottom: 8px;
        }

        .movie-info-meta {
            display: flex;
            gap: 15px;
            color: #ccc;
            font-size: 14px;
        }

        .movie-info-meta span {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .movie-info-meta i {
            color: #d96c2c;
        }

        /* Seat Map Section */
        .seat-map-section {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .section-header h3 {
            font-size: 20px;
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-header h3 i {
            color: #d96c2c;
        }

        /* Screen */
        .screen {
            background: linear-gradient(to bottom, #d96c2c, #262625);
            height: 8px;
            border-radius: 50% 50% 0 0;
            margin: 0 auto 40px;
            width: 80%;
            position: relative;
        }

        .screen::after {
            content: 'SCREEN';
            position: absolute;
            top: -30px;
            left: 50%;
            transform: translateX(-50%);
            color: #d96c2c;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 3px;
        }

        /* Seat Map Grid */
        .seat-map {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 30px;
            max-height: 500px;
            overflow-y: auto;
            padding: 10px;
        }

        .seat-row {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        .row-label {
            width: 40px;
            text-align: center;
            font-weight: 600;
            color: #d96c2c;
            font-size: 16px;
        }

        .seats-container {
            display: flex;
            gap: 10px;
        }

        /* Seat Styles */
        .seat {
            width: 45px;
            height: 45px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
            position: relative;
        }

        /* Available Seat */
        .seat.available {
            background: #4caf50;
            color: white;
        }

        .seat.available:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(76, 175, 80, 0.5);
        }

        /* Selected Seat */
        .seat.selected {
            background: #d96c2c;
            color: white;
            border-color: #fff;
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(217, 108, 44, 0.6);
        }

        /* Booked Seat */
        .seat.booked {
            background: #555;
            color: #888;
            cursor: not-allowed;
        }

        /* VIP Seat */
        .seat.vip {
            background: #ffd700;
            color: #000;
        }

        .seat.vip.selected {
            background: #d96c2c;
            color: white;
            border-color: #ffd700;
        }

        /* Couple Seat */
        .seat.couple {
            width: 95px;
            background: #e91e63;
            color: white;
        }

        .seat.couple.selected {
            background: #d96c2c;
            border-color: #e91e63;
        }

        /* Seat Legend */
        .seat-legend {
            display: flex;
            justify-content: center;
            gap: 30px;
            flex-wrap: wrap;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .legend-box {
            width: 35px;
            height: 35px;
            border-radius: 6px;
            border: 2px solid transparent;
        }

        .legend-box.available {
            background: #4caf50;
        }

        .legend-box.selected {
            background: #d96c2c;
            border-color: #fff;
        }

        .legend-box.booked {
            background: #555;
        }

        .legend-box.vip {
            background: #ffd700;
        }

        .legend-box.couple {
            background: #e91e63;
        }

        /* Booking Summary Panel */
        .booking-summary {
            background: #1a1a1a;
            border: 1px solid #262625;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            position: sticky;
            top: 30px;
            max-height: calc(100vh - 60px);
            overflow-y: auto;
        }

        .booking-summary h3 {
            font-size: 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .booking-summary h3 i {
            color: #d96c2c;
        }

        .selected-seats-list {
            margin-bottom: 20px;
        }

        .selected-seat-item {
            background: rgba(255, 255, 255, 0.05);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 12px;
            border: 1px solid #262625;
        }

        .seat-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .seat-code {
            font-size: 18px;
            font-weight: 600;
            color: #d96c2c;
        }

        .seat-type-badge {
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .seat-type-badge.normal {
            background: rgba(76, 175, 80, 0.2);
            color: #4caf50;
        }

        .seat-type-badge.vip {
            background: rgba(255, 215, 0, 0.2);
            color: #ffd700;
        }

        .seat-type-badge.couple {
            background: rgba(233, 30, 99, 0.2);
            color: #e91e63;
        }

        .ticket-type-selector {
            display: flex;
            gap: 8px;
        }

        .ticket-type-btn {
            flex: 1;
            padding: 8px 12px;
            border: 2px solid #262625;
            background: transparent;
            color: #ccc;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 13px;
            font-weight: 500;
        }

        .ticket-type-btn:hover {
            border-color: #d96c2c;
            color: #d96c2c;
        }

        .ticket-type-btn.active {
            background: #d96c2c;
            border-color: #d96c2c;
            color: white;
        }

        .btn-remove-seat {
            background: transparent;
            border: none;
            color: #ff4444;
            cursor: pointer;
            font-size: 18px;
            padding: 5px;
            transition: all 0.3s;
        }

        .btn-remove-seat:hover {
            color: #ff0000;
            transform: scale(1.2);
        }

        /* Price Summary */
        .price-summary {
            background: rgba(255, 255, 255, 0.05);
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            color: #ccc;
            font-size: 15px;
        }

        .price-row.total {
            border-top: 2px solid #262625;
            margin-top: 10px;
            padding-top: 15px;
            font-size: 20px;
            font-weight: 600;
            color: white;
        }

        .price-amount {
            color: #d96c2c;
            font-weight: 600;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .btn-proceed {
            width: 100%;
            padding: 15px 20px;
            background: #d96c2c;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-proceed:hover:not(:disabled) {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(217, 108, 44, 0.4);
        }

        .btn-proceed:disabled {
            background: #555;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .btn-clear {
            width: 100%;
            padding: 12px 20px;
            background: transparent;
            color: #ccc;
            border: 2px solid #262625;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-clear:hover {
            border-color: #ff4444;
            color: #ff4444;
        }

        /* Empty State */
        .empty-selection {
            text-align: center;
            padding: 40px 20px;
            color: #888;
        }

        .empty-selection i {
            font-size: 48px;
            margin-bottom: 15px;
            color: #555;
        }

        .empty-selection p {
            font-size: 15px;
        }

        /* Info Box */
        .info-box {
            background: rgba(217, 108, 44, 0.1);
            border: 1px solid #d96c2c;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .info-box p {
            color: #ccc;
            font-size: 14px;
            line-height: 1.5;
            margin: 0;
        }

        .info-box i {
            color: #d96c2c;
            margin-right: 8px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .content-layout {
                grid-template-columns: 1fr;
            }

            .booking-summary {
                position: static;
                max-height: none;
            }
        }

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

            .seat {
                width: 35px;
                height: 35px;
                font-size: 10px;
            }

            .seat.couple {
                width: 75px;
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
            <h1><i class="fas fa-couch"></i> Select Seats</h1>
            <div class="top-bar-actions">
                <a href="javascript:history.back()" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Showtimes
                </a>
            </div>
        </div>

        <!-- Movie Info Header -->
        <div class="movie-info-header">
            <c:set var="defaultPoster" value="${pageContext.request.contextPath}/images/default_poster.jpg" />
            <c:set var="posterSrc" value="${not empty moviePosterUrl ? moviePosterUrl : defaultPoster}" />
            <img src="${posterSrc}" alt="${movieTitle}" class="movie-poster-small"
                 onerror="this.onerror=null; this.src='${defaultPoster}';">
            <div class="movie-info-text">
                <h2>${movieTitle}</h2>
                <div class="movie-info-meta">
                    <span>
                        <i class="fas fa-door-open"></i>
                        ${roomName}
                    </span>
                    <span>
                        <i class="fas fa-clock"></i>
                        <fmt:formatDate value="${java.sql.Time.valueOf(showtime.startTime)}" pattern="HH:mm" />
                    </span>
                    <span>
                        <i class="fas fa-calendar-day"></i>
                        <fmt:formatDate value="${java.sql.Date.valueOf(showtime.showDate)}" pattern="dd/MM/yyyy" />
                    </span>
                    <span>
                        <i class="fas fa-map-marker-alt"></i>
                        ${branchName}
                    </span>
                </div>
            </div>
        </div>

        <!-- Content Layout -->
        <div class="content-layout">
            <!-- Seat Map Section -->
            <div class="seat-map-section">
                <div class="section-header">
                    <h3><i class="fas fa-couch"></i> Cinema Hall</h3>
                    <span style="color: #ccc; font-size: 14px;">
                        <i class="fas fa-info-circle"></i> Available: ${availableSeats} / ${totalSeats} seats
                    </span>
                </div>

                <!-- Screen -->
                <div class="screen"></div>

                <!-- Seat Map -->
                <div class="seat-map" id="seatMap">
                    <c:set var="currentRow" value="" />
                    <c:set var="rowSeats" value="${[]}" />
                    
                    <c:forEach items="${seatsWithStatus}" var="seatInfo" varStatus="status">
                        <c:set var="seat" value="${seatInfo.seat}" />
                        <c:set var="bookingStatus" value="${seatInfo.bookingStatus}" />
                        
                        <c:if test="${seat.rowNumber != currentRow && currentRow != ''}">
                            <!-- Render previous row -->
                            <div class="seat-row">
                                <div class="row-label">${currentRow}</div>
                                <div class="seats-container" id="row-${currentRow}">
                                    <!-- Seats will be rendered here by the forEach below -->
                                </div>
                                <div class="row-label">${currentRow}</div>
                            </div>
                        </c:if>
                        
                        <c:set var="currentRow" value="${seat.rowNumber}" />
                    </c:forEach>
                    
                    <!-- Render seat map using JavaScript for better control -->
                </div>

                <!-- Seat Legend -->
                <div class="seat-legend">
                    <div class="legend-item">
                        <div class="legend-box available"></div>
                        <span>Available</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box selected"></div>
                        <span>Selected</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box booked"></div>
                        <span>Booked</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box vip"></div>
                        <span>VIP</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box couple"></div>
                        <span>Couple</span>
                    </div>
                </div>
            </div>

            <!-- Booking Summary Panel -->
            <div class="booking-summary">
                <h3><i class="fas fa-shopping-cart"></i> Booking Summary</h3>

                <div class="info-box">
                    <p>
                        <i class="fas fa-info-circle"></i>
                        Click on available seats to select. Choose ticket type for each seat.
                    </p>
                </div>

                <div id="selectedSeatsList" class="selected-seats-list">
                    <div class="empty-selection">
                        <i class="fas fa-hand-pointer"></i>
                        <p>No seats selected yet.<br>Click on available seats to begin.</p>
                    </div>
                </div>

                <div id="priceSummary" class="price-summary" style="display: none;">
                    <div class="price-row">
                        <span>Adult Tickets:</span>
                        <span class="price-amount" id="adultCount">0</span>
                    </div>
                    <div class="price-row">
                        <span>Child Tickets:</span>
                        <span class="price-amount" id="childCount">0</span>
                    </div>
                    <div class="price-row total">
                        <span>Total Amount:</span>
                        <span class="price-amount" id="totalAmount">0 VND</span>
                    </div>
                </div>

                <div class="action-buttons">
                    <button class="btn-proceed" id="btnProceed" disabled onclick="proceedToPayment()">
                        <i class="fas fa-arrow-right"></i>
                        Proceed to Payment
                    </button>
                    <button class="btn-clear" onclick="clearAllSeats()">
                        <i class="fas fa-times"></i>
                        Clear Selection
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Seat data from server
        const seatsData = [
            <c:forEach items="${seatsWithStatus}" var="seatInfo" varStatus="status">
            {
                seatId: ${seatInfo.seat.seatId},
                seatCode: '${seatInfo.seat.seatCode}',
                seatType: '${seatInfo.seat.seatType}',
                rowNumber: '${seatInfo.seat.rowNumber}',
                seatNumber: ${seatInfo.seat.seatNumber},
                bookingStatus: '${seatInfo.bookingStatus}'
            }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];

        const showtimeId = ${showtimeId};
        const basePrice = ${showtime.basePrice};

        // Selected seats storage
        let selectedSeats = [];

        // Store seat elements by ID for quick lookup
        const seatElementsById = {};

        // Render seat map
        function renderSeatMap() {
            const seatMap = document.getElementById('seatMap');
            seatMap.innerHTML = '';
            
            // Clear previous references
            Object.keys(seatElementsById).forEach(key => delete seatElementsById[key]);

            console.log('Rendering seat map with', seatsData.length, 'seats');

            // Group seats by row
            const seatsByRow = {};
            seatsData.forEach(seat => {
                if (!seatsByRow[seat.rowNumber]) {
                    seatsByRow[seat.rowNumber] = [];
                }
                seatsByRow[seat.rowNumber].push(seat);
            });

            console.log('Seats grouped by row:', seatsByRow);

            // Render each row
            Object.keys(seatsByRow).sort().forEach(rowNumber => {
                const row = document.createElement('div');
                row.className = 'seat-row';

                // Row label left
                const labelLeft = document.createElement('div');
                labelLeft.className = 'row-label';
                labelLeft.textContent = rowNumber;
                row.appendChild(labelLeft);

                // Seats container
                const seatsContainer = document.createElement('div');
                seatsContainer.className = 'seats-container';

                // Sort seats by seat_number before rendering
                seatsByRow[rowNumber].sort((a, b) => a.seatNumber - b.seatNumber).forEach(seat => {
                    console.log('Rendering seat:', seat.seatCode, 'ID:', seat.seatId);
                    
                    const seatElement = document.createElement('div');
                    seatElement.className = 'seat';
                    seatElement.setAttribute('data-seat-id', seat.seatId);
                    seatElement.setAttribute('data-seat-code', seat.seatCode);
                    seatElement.setAttribute('data-seat-type', seat.seatType);
                    seatElement.textContent = seat.seatCode;
                    
                    // Store reference
                    seatElementsById[seat.seatId] = seatElement;

                    // Set seat type class
                    if (seat.seatType === 'VIP') {
                        seatElement.classList.add('vip');
                    } else if (seat.seatType === 'COUPLE') {
                        seatElement.classList.add('couple');
                    }

                    // Set booking status
                    if (seat.bookingStatus === 'AVAILABLE') {
                        seatElement.classList.add('available');
                        // Use seatId instead of seat object to avoid closure issues
                        const currentSeatId = seat.seatId; // Capture in closure
                        seatElement.onclick = function() {
                            console.log('Clicked seat element with ID:', currentSeatId, 'Code:', seat.seatCode);
                            toggleSeatById(currentSeatId);
                        };
                    } else {
                        seatElement.classList.add('booked');
                        seatElement.title = 'Already booked';
                    }

                    seatsContainer.appendChild(seatElement);
                });

                row.appendChild(seatsContainer);

                // Row label right
                const labelRight = document.createElement('div');
                labelRight.className = 'row-label';
                labelRight.textContent = rowNumber;
                row.appendChild(labelRight);

                seatMap.appendChild(row);
            });
            
            console.log('Seat map rendering completed');
            console.log('Stored seat elements:', Object.keys(seatElementsById).length);
        }

        // Toggle seat selection by ID
        function toggleSeatById(seatId) {
            console.log('toggleSeatById called with:', seatId);
            // Find seat data from seatsData array
            const seat = seatsData.find(s => s.seatId === seatId);
            if (!seat) {
                console.error('Seat not found:', seatId);
                return;
            }
            console.log('Found seat:', seat);
            toggleSeat(seat);
        }

        // Toggle seat selection
        function toggleSeat(seat) {
            console.log('toggleSeat called for:', seat.seatCode, 'ID:', seat.seatId);
            
            // Use stored reference instead of querySelector
            const seatElement = seatElementsById[seat.seatId];
            
            if (!seatElement) {
                console.error('Seat element not found in map for ID:', seat.seatId);
                return;
            }
            
            console.log('Found seat element:', seatElement, 'with code:', seatElement.textContent);
            
            const index = selectedSeats.findIndex(s => s.seatId === seat.seatId);

            if (index > -1) {
                // Deselect
                console.log('Deselecting seat:', seat.seatCode);
                selectedSeats.splice(index, 1);
                seatElement.classList.remove('selected');
            } else {
                // Select
                console.log('Selecting seat:', seat.seatCode);
                selectedSeats.push({
                    ...seat,
                    ticketType: 'ADULT' // Default to adult
                });
                seatElement.classList.add('selected');
            }

            console.log('Current selected seats:', selectedSeats.map(s => s.seatCode));
            updateBookingSummary();
        }

        // Update booking summary
        function updateBookingSummary() {
            const listContainer = document.getElementById('selectedSeatsList');
            const priceSummary = document.getElementById('priceSummary');
            const btnProceed = document.getElementById('btnProceed');

            if (selectedSeats.length === 0) {
                listContainer.innerHTML = `
                    <div class="empty-selection">
                        <i class="fas fa-hand-pointer"></i>
                        <p>No seats selected yet.<br>Click on available seats to begin.</p>
                    </div>
                `;
                priceSummary.style.display = 'none';
                btnProceed.disabled = true;
                return;
            }

            // Render selected seats
            listContainer.innerHTML = '';
            selectedSeats.forEach(seat => {
                const seatItem = document.createElement('div');
                seatItem.className = 'selected-seat-item';
                
                const adultActiveClass = seat.ticketType === 'ADULT' ? 'active' : '';
                const childActiveClass = seat.ticketType === 'CHILD' ? 'active' : '';
                
                seatItem.innerHTML = `
                    <div class="seat-item-header">
                        <span class="seat-code">` + seat.seatCode + `</span>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span class="seat-type-badge ` + seat.seatType.toLowerCase() + `">` + seat.seatType + `</span>
                            <button class="btn-remove-seat" onclick="removeSeat(` + seat.seatId + `)">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                    <div class="ticket-type-selector">
                        <button class="ticket-type-btn ` + adultActiveClass + `" 
                                onclick="setTicketType(` + seat.seatId + `, 'ADULT')">
                            <i class="fas fa-user"></i> Adult
                        </button>
                        <button class="ticket-type-btn ` + childActiveClass + `" 
                                onclick="setTicketType(` + seat.seatId + `, 'CHILD')">
                            <i class="fas fa-child"></i> Child
                        </button>
                    </div>
                `;
                listContainer.appendChild(seatItem);
            });

            // Calculate price
            let adultCount = 0;
            let childCount = 0;
            let totalAmount = 0;

            selectedSeats.forEach(seat => {
                let price = basePrice;
                
                // Adjust price for seat type
                if (seat.seatType === 'VIP') {
                    price *= 1.5; // VIP is 50% more
                } else if (seat.seatType === 'COUPLE') {
                    price *= 2; // Couple seat is double
                }

                // Adjust price for ticket type
                if (seat.ticketType === 'CHILD') {
                    price *= 0.7; // Child ticket is 30% discount
                    childCount++;
                } else {
                    adultCount++;
                }

                totalAmount += price;
            });

            document.getElementById('adultCount').textContent = adultCount;
            document.getElementById('childCount').textContent = childCount;
            document.getElementById('totalAmount').textContent = formatCurrency(totalAmount);

            priceSummary.style.display = 'block';
            btnProceed.disabled = false;
        }

        // Set ticket type for a seat
        function setTicketType(seatId, ticketType) {
            const seat = selectedSeats.find(s => s.seatId === seatId);
            if (seat) {
                seat.ticketType = ticketType;
                updateBookingSummary();
            }
        }

        // Remove seat from selection
        function removeSeat(seatId) {
            const seat = selectedSeats.find(s => s.seatId === seatId);
            if (seat) {
                toggleSeat(seat);
            }
        }

        // Clear all selected seats
        function clearAllSeats() {
            if (selectedSeats.length === 0) return;
            
            if (confirm('Are you sure you want to clear all selected seats?')) {
                selectedSeats.forEach(seat => {
                    const seatElement = document.querySelector(`[data-seat-id="${seat.seatId}"]`);
                    seatElement.classList.remove('selected');
                });
                selectedSeats = [];
                updateBookingSummary();
            }
        }

        // Proceed to payment
        function proceedToPayment() {
            if (selectedSeats.length === 0) {
                alert('Please select at least one seat.');
                return;
            }

            // Prepare data for payment
            const bookingData = {
                showtimeId: showtimeId,
                seats: selectedSeats.map(seat => ({
                    seatId: seat.seatId,
                    seatCode: seat.seatCode,
                    seatType: seat.seatType,
                    ticketType: seat.ticketType
                }))
            };

            // Store in session storage for next page
            sessionStorage.setItem('bookingData', JSON.stringify(bookingData));

            // Navigate to payment page
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking-payment?showtimeId=' + showtimeId;
        }

        // Format currency
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }

        // Toggle sidebar
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

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            renderSeatMap();
        });
    </script>
</body>
</html>
