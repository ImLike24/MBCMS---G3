<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn ghế - Bán vé quầy</title>
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
            <h3>Nhân viên rạp</h3>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/dashboard">
                    <i class="fas fa-home"></i>
                    <span>Trang tổng quan</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/counter-booking" class="active">
                    <i class="fas fa-ticket-alt"></i>
                    <span>Bán vé quầy</span>
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
            <h1><i class="fas fa-couch"></i> Chọn ghế</h1>
            <div class="top-bar-actions">
                <a href="javascript:history.back()" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Quay lại chọn suất chiếu
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
                    <h3><i class="fas fa-couch"></i> Phòng chiếu</h3>
                    <span style="color: #ccc; font-size: 14px;">
                        <i class="fas fa-info-circle"></i> Ghế trống: ${availableSeats} / ${totalSeats}
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
                        <span>Còn trống</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box selected"></div>
                        <span>Đang chọn</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box booked"></div>
                        <span>Đã bán</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box vip"></div>
                        <span>Ghế VIP</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box couple"></div>
                        <span>Ghế đôi</span>
                    </div>
                </div>
            </div>

            <!-- Booking Summary Panel -->
            <div class="booking-summary">
                <h3><i class="fas fa-shopping-cart"></i> Tóm tắt đặt ghế</h3>

                <div class="info-box">
                    <p>
                        <i class="fas fa-info-circle"></i>
                        Nhấn vào ghế còn trống để chọn, sau đó chọn loại vé cho từng ghế.
                    </p>
                </div>

                <div id="selectedSeatsList" class="selected-seats-list">
                    <div class="empty-selection">
                        <i class="fas fa-hand-pointer"></i>
                        <p>Chưa chọn ghế nào.<br>Hãy bấm vào một ghế còn trống để bắt đầu.</p>
                    </div>
                </div>

                <div id="priceSummary" class="price-summary" style="display: none;">
                    <div class="price-row">
                        <span>Vé người lớn:</span>
                        <span class="price-amount" id="adultCount">0</span>
                    </div>
                    <div class="price-row">
                        <span>Vé trẻ em:</span>
                        <span class="price-amount" id="childCount">0</span>
                    </div>
                    <div class="price-row total">
                        <span>Tổng tiền vé:</span>
                        <span class="price-amount" id="totalAmount">0&nbsp;₫</span>
                    </div>
                </div>

                <div class="action-buttons">
                    <button class="btn-proceed" id="btnProceed" disabled onclick="proceedToConcessions()">
                        <i class="fas fa-arrow-right"></i>
                        Tiếp tục
                    </button>
                    <button class="btn-clear" onclick="clearAllSeats()">
                        <i class="fas fa-times"></i>
                        Xóa lựa chọn
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
        const ticketPrices = {
            'ADULT': ${adultPrice},
            'CHILD': ${childPrice}
        };
        const surchargeRates = {
            <c:forEach var="s" items="${surchargeList}" varStatus="vs">'${s.seatType}': ${s.surchargeRate}<c:if test="${!vs.last}">,</c:if></c:forEach>
        };

        // Selected seats storage
        let selectedSeats = [];

        // Store seat elements by ID for quick lookup
        const seatElementsById = {};

        // Render seat map
        function renderSeatMap() {
            const adultPriceJs = parseFloat(ticketPrices['ADULT']);
            const childPriceJs = parseFloat(ticketPrices['CHILD']);
            if (isNaN(adultPriceJs) || isNaN(childPriceJs)) {
                console.error('Ticket prices not loaded correctly from backend:', ticketPrices);
                alert('Không lấy được giá vé động cho suất chiếu này. Vui lòng kiểm tra cấu hình ticket_prices trong database.');
                return;
            }
            const seatMap = document.getElementById('seatMap');
            seatMap.innerHTML = '';
            
            // Clear previous references
            Object.keys(seatElementsById).forEach(key => delete seatElementsById[key]);

            // Group seats by row
            const seatsByRow = {};
            seatsData.forEach(seat => {
                if (!seatsByRow[seat.rowNumber]) {
                    seatsByRow[seat.rowNumber] = [];
                }
                seatsByRow[seat.rowNumber].push(seat);
            });

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
                        const currentSeatId = seat.seatId;
                        seatElement.onclick = function() { toggleSeatById(currentSeatId); };
                    } else {
                        seatElement.classList.add('booked');
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
        }

        // Toggle seat selection by ID
        function toggleSeatById(seatId) {
            const seat = seatsData.find(s => s.seatId === seatId);
            if (!seat) return;
            toggleSeat(seat);
        }

        // Toggle seat selection
        function toggleSeat(seat) {
            const seatElement = seatElementsById[seat.seatId];
            if (!seatElement) return;

            const index = selectedSeats.findIndex(s => s.seatId === seat.seatId);
            if (index > -1) {
                selectedSeats.splice(index, 1);
                seatElement.classList.remove('selected');
            } else {
                selectedSeats.push({ ...seat, ticketType: 'ADULT' });
                seatElement.classList.add('selected');
            }
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
                        <p>Chưa chọn ghế nào.<br>Hãy bấm vào một ghế còn trống để bắt đầu.</p>
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
                            <i class="fas fa-user"></i> Người lớn
                        </button>
                        <button class="ticket-type-btn ` + childActiveClass + `" 
                                onclick="setTicketType(` + seat.seatId + `, 'CHILD')">
                            <i class="fas fa-child"></i> Trẻ em
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
                let price = ticketPrices[seat.ticketType] || ticketPrices['ADULT'] || 0;

                const rate = surchargeRates[seat.seatType];
                if (rate != null && rate > 0) {
                    price *= (1 + rate / 100);
                }

                if (seat.ticketType === 'CHILD') {
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
                title:       'Xóa lựa chọn ghế',
                message:     'Bạn có chắc chắn muốn xóa toàn bộ ghế đang chọn không?',
                confirmText: 'Xóa tất cả',
                cancelText:  'Giữ lại'
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

        // Proceed to concessions page
        function proceedToConcessions() {
            if (selectedSeats.length === 0) {
                alert('Vui lòng chọn ít nhất một ghế.');
                return;
            }

            const bookingData = {
                showtimeId: showtimeId,
                seats: selectedSeats.map(seat => ({
                    seatId: seat.seatId,
                    seatCode: seat.seatCode,
                    seatType: seat.seatType,
                    ticketType: seat.ticketType
                })),
                concessions: []
            };

            sessionStorage.setItem('bookingData', JSON.stringify(bookingData));
            window.location.href = '${pageContext.request.contextPath}/staff/counter-booking-concessions?showtimeId=' + showtimeId;
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
