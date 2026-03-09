<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chi tiết Suất Chiếu #${showtime.showtimeId}</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
                <style>
                    .stat-card {
                        border-left: 4px solid;
                        border-radius: 8px;
                    }

                    .stat-card.total {
                        border-color: #6c757d;
                    }

                    .stat-card.online {
                        border-color: #0d6efd;
                    }

                    .stat-card.counter {
                        border-color: #fd7e14;
                    }

                    .stat-card.revenue {
                        border-color: #198754;
                    }

                    .badge-SCHEDULED {
                        background-color: #0d6efd;
                    }

                    .badge-ONGOING {
                        background-color: #198754;
                    }

                    .badge-COMPLETED {
                        background-color: #6c757d;
                    }

                    .info-label {
                        font-size: 0.78rem;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        color: #6c757d;
                        font-weight: 600;
                    }

                    .info-value {
                        font-size: 0.95rem;
                        color: #212529;
                    }

                    .poster-wrap {
                        width: 120px;
                        min-width: 120px;
                        height: 170px;
                        overflow: hidden;
                        border-radius: 8px;
                        background: #dee2e6;
                    }

                    .poster-wrap img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                    }

                    .table-sm th {
                        font-size: 0.78rem;
                        text-transform: uppercase;
                        letter-spacing: .4px;
                        background: #f8f9fa;
                    }

                    .nav-tabs .nav-link.active {
                        font-weight: 600;
                        color: #d96c2c;
                        border-bottom-color: #d96c2c;
                    }

                    .nav-tabs .nav-link {
                        color: #495057;
                    }
                </style>
            </head>

            <body>

                <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
                <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
                    <jsp:param name="page" value="showtimes" />
                </jsp:include>

                <main>
                    <div class="container-fluid">

                        <%-- ── Breadcrumb ──────────────────────────────────── --%>
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h3 class="fw-bold text-dark mb-1">
                                        <i class="fa-solid fa-circle-info me-2" style="color:#d96c2c;"></i>Chi tiết Suất
                                        Chiếu
                                    </h3>
                                    <nav aria-label="breadcrumb">
                                        <ol class="breadcrumb mb-0">
                                            <li class="breadcrumb-item"><a
                                                    href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                    class="text-decoration-none text-secondary">Suất chiếu</a></li>
                                            <li class="breadcrumb-item active" style="color:#d96c2c;">
                                                #${showtime.showtimeId}</li>
                                        </ol>
                                    </nav>
                                </div>
                                <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                    class="btn btn-outline-secondary">
                                    <i class="fa-solid fa-arrow-left me-1"></i>Quay lại
                                </a>
                            </div>

                            <%-- ── Showtime Info Card ──────────────────────────── --%>
                                <div class="card shadow-sm mb-4">
                                    <div class="card-body p-4">
                                        <div class="d-flex gap-4">

                                            <%-- Poster --%>
                                                <div class="poster-wrap flex-shrink-0">
                                                    <c:choose>
                                                        <c:when test="${not empty detail.moviePosterUrl}">
                                                            <img src="${detail.moviePosterUrl}" alt="Poster">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div
                                                                class="d-flex align-items-center justify-content-center h-100 text-muted">
                                                                <i class="fa-solid fa-film fa-2x"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <%-- Info grid --%>
                                                    <div class="flex-grow-1">
                                                        <div class="d-flex align-items-center gap-3 mb-3">
                                                            <h4 class="fw-bold mb-0">${detail.movieTitle}</h4>
                                                            <span
                                                                class="badge rounded-pill badge-${detail.status} px-3">
                                                                <c:choose>
                                                                    <c:when test="${detail.status == 'SCHEDULED'}">Đã
                                                                        lên lịch</c:when>
                                                                    <c:when test="${detail.status == 'ONGOING'}">Đang
                                                                        chiếu</c:when>
                                                                    <c:otherwise>Hoàn thành</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                            <span
                                                                class="badge bg-warning text-dark">${detail.movieAgeRating}</span>
                                                        </div>

                                                        <div class="row g-3">
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Mã suất chiếu</div>
                                                                <div class="info-value fw-bold" style="color:#d96c2c;">
                                                                    #${showtime.showtimeId}</div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Ngày chiếu</div>
                                                                <div class="info-value">
                                                                    <fmt:parseDate value="${detail.showDate}"
                                                                        pattern="yyyy-MM-dd" var="sd" type="date" />
                                                                    <fmt:formatDate value="${sd}"
                                                                        pattern="dd/MM/yyyy" />
                                                                </div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Giờ chiếu</div>
                                                                <div class="info-value">${detail.startTime} –
                                                                    ${detail.endTime}</div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Thời lượng</div>
                                                                <div class="info-value">${detail.movieDuration} phút
                                                                </div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Phòng chiếu</div>
                                                                <div class="info-value">${detail.roomName}</div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Chi nhánh</div>
                                                                <div class="info-value">${detail.branchName}</div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Giá vé cơ bản</div>
                                                                <div class="info-value fw-semibold">
                                                                    <fmt:formatNumber value="${detail.basePrice}"
                                                                        type="number" groupingUsed="true" /> ₫
                                                                </div>
                                                            </div>
                                                            <div class="col-sm-6 col-md-3">
                                                                <div class="info-label">Tổng ghế phòng</div>
                                                                <div class="info-value">${detail.totalSeats} ghế</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                        </div>
                                    </div>
                                </div>

                                <%-- ── Revenue Stats ───────────────────────────────── --%>
                                    <div class="row g-3 mb-4">
                                        <div class="col-6 col-md-3">
                                            <div class="card stat-card total shadow-sm h-100 p-3">
                                                <div class="small text-muted text-uppercase fw-semibold mb-1">Tổng vé
                                                    bán</div>
                                                <div class="fs-3 fw-bold">${detail.totalCount}</div>
                                                <div class="small text-muted">${detail.onlineCount} online ·
                                                    ${detail.counterCount} quầy</div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="card stat-card online shadow-sm h-100 p-3">
                                                <div class="small text-muted text-uppercase fw-semibold mb-1">Doanh thu
                                                    Online</div>
                                                <div class="fs-4 fw-bold text-primary">
                                                    <fmt:formatNumber value="${detail.onlineRevenue}" type="number"
                                                        groupingUsed="true" /> ₫
                                                </div>
                                                <div class="small text-muted">${detail.onlineCount} vé</div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="card stat-card counter shadow-sm h-100 p-3">
                                                <div class="small text-muted text-uppercase fw-semibold mb-1">Doanh thu
                                                    Quầy</div>
                                                <div class="fs-4 fw-bold text-warning">
                                                    <fmt:formatNumber value="${detail.counterRevenue}" type="number"
                                                        groupingUsed="true" /> ₫
                                                </div>
                                                <div class="small text-muted">${detail.counterCount} vé</div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="card stat-card revenue shadow-sm h-100 p-3">
                                                <div class="small text-muted text-uppercase fw-semibold mb-1">Tổng Doanh
                                                    thu</div>
                                                <div class="fs-4 fw-bold text-success">
                                                    <fmt:formatNumber value="${detail.totalRevenue}" type="number"
                                                        groupingUsed="true" /> ₫
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- ── Ticket List Tabs ────────────────────────────── --%>
                                        <div class="card shadow-sm">
                                            <div class="card-body p-0">
                                                <ul class="nav nav-tabs px-4 pt-3" id="ticketTabs">
                                                    <li class="nav-item">
                                                        <a class="nav-link active" data-bs-toggle="tab"
                                                            href="#tab-online">
                                                            <i class="fa-solid fa-globe me-1"></i>Vé Online
                                                            <span
                                                                class="badge bg-primary rounded-pill ms-1">${detail.onlineCount}</span>
                                                        </a>
                                                    </li>
                                                    <li class="nav-item">
                                                        <a class="nav-link" data-bs-toggle="tab" href="#tab-counter">
                                                            <i class="fa-solid fa-ticket me-1"></i>Vé Quầy
                                                            <span
                                                                class="badge bg-warning text-dark rounded-pill ms-1">${detail.counterCount}</span>
                                                        </a>
                                                    </li>
                                                </ul>

                                                <div class="tab-content p-3">

                                                    <%-- Online tickets tab --%>
                                                        <div class="tab-pane fade show active" id="tab-online">
                                                            <div class="table-responsive">
                                                                <table
                                                                    class="table table-sm table-hover align-middle mb-0">
                                                                    <thead>
                                                                        <tr>
                                                                            <th class="ps-3">Mã vé</th>
                                                                            <th>Mã đặt vé</th>
                                                                            <th>Khách hàng</th>
                                                                            <th>Email</th>
                                                                            <th>Ghế</th>
                                                                            <th>Loại ghế</th>
                                                                            <th>Loại vé</th>
                                                                            <th class="text-end">Giá (₫)</th>
                                                                            <th>Thanh toán</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${empty detail.onlineTickets}">
                                                                                <tr>
                                                                                    <td colspan="9"
                                                                                        class="text-center py-4 text-muted">
                                                                                        Chưa có vé online nào.</td>
                                                                                </tr>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <c:forEach var="t"
                                                                                    items="${detail.onlineTickets}">
                                                                                    <tr>
                                                                                        <td
                                                                                            class="ps-3 font-monospace small">
                                                                                            ${t.ticketCode}</td>
                                                                                        <td class="fw-semibold"
                                                                                            style="color:#d96c2c;">
                                                                                            ${t.bookingCode}</td>
                                                                                        <td>${t.customerName}</td>
                                                                                        <td class="text-muted small">
                                                                                            ${t.customerEmail}</td>
                                                                                        <td><span
                                                                                                class="badge bg-light text-dark border">${t.seatCode}</span>
                                                                                        </td>
                                                                                        <td>${t.seatType}</td>
                                                                                        <td>${t.ticketType}</td>
                                                                                        <td
                                                                                            class="text-end fw-semibold">
                                                                                            <fmt:formatNumber
                                                                                                value="${t.price}"
                                                                                                type="number"
                                                                                                groupingUsed="true" />
                                                                                        </td>
                                                                                        <td>
                                                                                            <c:choose>
                                                                                                <c:when
                                                                                                    test="${t.paymentStatus == 'PAID'}">
                                                                                                    <span
                                                                                                        class="badge bg-success rounded-pill">Đã
                                                                                                        thanh
                                                                                                        toán</span>
                                                                                                </c:when>
                                                                                                <c:when
                                                                                                    test="${t.paymentStatus == 'PENDING'}">
                                                                                                    <span
                                                                                                        class="badge bg-secondary rounded-pill">Chờ
                                                                                                        TT</span>
                                                                                                </c:when>
                                                                                                <c:when
                                                                                                    test="${t.paymentStatus == 'REFUND_PENDING'}">
                                                                                                    <span
                                                                                                        class="badge bg-warning text-dark rounded-pill">Chờ
                                                                                                        hoàn</span>
                                                                                                </c:when>
                                                                                                <c:otherwise>
                                                                                                    <span
                                                                                                        class="badge bg-light text-dark border">${t.paymentStatus}</span>
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                        </td>
                                                                                    </tr>
                                                                                </c:forEach>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>

                                                        <%-- Counter tickets tab --%>
                                                            <div class="tab-pane fade" id="tab-counter">
                                                                <div class="table-responsive">
                                                                    <table
                                                                        class="table table-sm table-hover align-middle mb-0">
                                                                        <thead>
                                                                            <tr>
                                                                                <th class="ps-3">Mã vé</th>
                                                                                <th>Khách hàng</th>
                                                                                <th>SĐT</th>
                                                                                <th>Email</th>
                                                                                <th>Ghế</th>
                                                                                <th>Loại ghế</th>
                                                                                <th>Loại vé</th>
                                                                                <th class="text-end">Giá (₫)</th>
                                                                                <th>Phương thức TT</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${empty detail.counterTickets}">
                                                                                    <tr>
                                                                                        <td colspan="9"
                                                                                            class="text-center py-4 text-muted">
                                                                                            Chưa có vé quầy nào.</td>
                                                                                    </tr>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <c:forEach var="t"
                                                                                        items="${detail.counterTickets}">
                                                                                        <tr>
                                                                                            <td
                                                                                                class="ps-3 font-monospace small">
                                                                                                ${t.ticketCode}</td>
                                                                                            <td>${t.customerName}</td>
                                                                                            <td class="text-muted">
                                                                                                ${t.customerPhone}</td>
                                                                                            <td
                                                                                                class="text-muted small">
                                                                                                ${t.customerEmail}</td>
                                                                                            <td><span
                                                                                                    class="badge bg-light text-dark border">${t.seatCode}</span>
                                                                                            </td>
                                                                                            <td>${t.seatType}</td>
                                                                                            <td>${t.ticketType}</td>
                                                                                            <td
                                                                                                class="text-end fw-semibold">
                                                                                                <fmt:formatNumber
                                                                                                    value="${t.price}"
                                                                                                    type="number"
                                                                                                    groupingUsed="true" />
                                                                                            </td>
                                                                                            <td>
                                                                                                <span
                                                                                                    class="badge bg-light text-dark border">${t.paymentMethod}</span>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>

                                                </div><%-- /tab-content --%>
                                            </div>
                                        </div>

                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>