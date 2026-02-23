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
                        ${formattedStartTime}
                    </span>
                    <span>
                        <i class="fas fa-calendar-day"></i>
                        ${formattedShowDate}
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

    <%@ include file="confirm-modal.jsp" %>

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
        async function clearAllSeats() {
            if (selectedSeats.length === 0) return;

            const confirmed = await showConfirmModal({
                title:       'Clear Selection',
                message:     'Are you sure you want to remove all selected seats?',
                confirmText: 'Clear All',
                cancelText:  'Keep Selection'
            });

            if (confirmed) {
                selectedSeats.forEach(seat => {
                    const seatElement = seatElementsById[seat.seatId];
                    if (seatElement) {
                        seatElement.classList.remove('selected');
                    }
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
