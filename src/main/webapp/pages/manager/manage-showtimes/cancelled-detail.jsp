<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Chi tiết Suất Chiếu Đã Hủy</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
                <style>
                    .form-card {
                        background: #fff;
                        border-radius: 12px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, .08);
                    }

                    .section-label {
                        font-size: .75rem;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .8px;
                        color: #d96c2c;
                    }

                    .stat-pill {
                        border-radius: 50px;
                        padding: 6px 18px;
                        font-weight: 600;
                        font-size: .9rem;
                    }

                    .reason-box {
                        background: #fff5f5;
                        border: 1px solid #fca5a5;
                        border-radius: 10px;
                        border-left: 4px solid #dc3545;
                    }

                    .badge-refund-pending {
                        background: #0dcaf0;
                        color: #000;
                    }

                    .badge-refunded {
                        background: #198754;
                        color: #fff;
                    }

                    .badge-paid {
                        background: #0d6efd;
                        color: #fff;
                    }

                    .badge-pending {
                        background: #6c757d;
                        color: #fff;
                    }

                    .seat-type-VIP {
                        color: #f59e0b;
                        font-weight: 600;
                    }

                    .seat-type-COUPLE {
                        color: #8b5cf6;
                        font-weight: 600;
                    }

                    .seat-type-NORMAL {
                        color: #6c757d;
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

                        <%-- Header --%>
                            <div class="d-flex align-items-center mb-4">
                                <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                    class="btn btn-outline-secondary btn-sm me-3">
                                    <i class="fa-solid fa-arrow-left me-1"></i>Quay lại
                                </a>
                                <div>
                                    <h3 class="fw-bold text-danger mb-0">
                                        <i class="fa-solid fa-circle-info me-2"></i>Chi tiết Suất Chiếu Đã Hủy
                                    </h3>
                                    <nav aria-label="breadcrumb">
                                        <ol class="breadcrumb mb-0 mt-1">
                                            <li class="breadcrumb-item">
                                                <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                                    class="text-decoration-none text-secondary">Suất chiếu</a>
                                            </li>
                                            <li class="breadcrumb-item active text-danger">Chi tiết
                                                #${showtime.showtimeId}</li>
                                        </ol>
                                    </nav>
                                </div>
                            </div>

                            <div class="row g-4">

                                <%-- LEFT: Showtime info + cancellation reason --%>
                                    <div class="col-lg-4">

                                        <%-- Showtime info --%>
                                            <div class="form-card p-4 mb-4">
                                                <p class="section-label mb-3"><i class="fa-solid fa-film me-1"></i>Thông
                                                    tin suất chiếu</p>
                                                <div class="row g-3">
                                                    <div class="col-12">
                                                        <div class="small text-muted mb-1">Phim</div>
                                                        <div class="fw-bold">${movie.title}</div>
                                                        <div class="text-muted small">${movie.duration} phút</div>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="small text-muted mb-1">ID Suất chiếu</div>
                                                        <div class="fw-bold" style="color:#d96c2c;">
                                                            #${showtime.showtimeId}</div>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="small text-muted mb-1">Trạng thái</div>
                                                        <span class="badge bg-danger">Đã hủy</span>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="small text-muted mb-1">Ngày chiếu</div>
                                                        <div class="fw-semibold">
                                                            <fmt:parseDate value="${showtime.showDate}"
                                                                pattern="yyyy-MM-dd" var="sd" type="date" />
                                                            <fmt:formatDate value="${sd}" pattern="dd/MM/yyyy" />
                                                        </div>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="small text-muted mb-1">Khung giờ</div>
                                                        <div class="fw-semibold">${showtime.startTime} →
                                                            ${showtime.endTime}</div>
                                                    </div>
                                                    <div class="col-12">
                                                        <div class="small text-muted mb-1">Giá vé gốc</div>
                                                        <div class="fw-bold">
                                                            <fmt:formatNumber value="${showtime.basePrice}"
                                                                type="number" groupingUsed="true"
                                                                maxFractionDigits="0" /> ₫
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Cancellation Reason --%>
                                                <div class="form-card p-4 mb-4">
                                                    <p class="section-label text-danger mb-3">
                                                        <i class="fa-solid fa-ban me-1"></i>Lý do hủy
                                                    </p>
                                                    <c:choose>
                                                        <c:when test="${not empty detail.cancellationReason}">
                                                            <div class="reason-box p-3">
                                                                <p class="mb-2 fw-semibold text-danger">
                                                                    "${detail.cancellationReason}"</p>
                                                                <c:if test="${not empty detail.cancelledAt}">
                                                                    <div class="small text-muted">
                                                                        <i class="fa-regular fa-clock me-1"></i>
                                                                        Hủy lúc: ${detail.cancelledAt}
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-muted fst-italic">
                                                                <i class="fa-solid fa-circle-minus me-1"></i>Không có lý
                                                                do được ghi lại
                                                                (có thể hủy qua hệ thống hoặc không có booking nào).
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <%-- Stats summary --%>
                                                    <div class="form-card p-4">
                                                        <p class="section-label mb-3"><i
                                                                class="fa-solid fa-chart-bar me-1"></i>Tóm tắt doanh thu
                                                        </p>
                                                        <div
                                                            class="d-flex justify-content-between align-items-center mb-3">
                                                            <span class="text-muted">Vé online</span>
                                                            <span
                                                                class="stat-pill bg-primary text-white">${detail.onlineCount}</span>
                                                        </div>
                                                        <div
                                                            class="d-flex justify-content-between align-items-center mb-3">
                                                            <span class="text-muted">Vé quầy</span>
                                                            <span
                                                                class="stat-pill bg-warning text-dark">${detail.counterCount}</span>
                                                        </div>
                                                        <div
                                                            class="d-flex justify-content-between align-items-center mb-3">
                                                            <span class="text-muted">Tổng vé</span>
                                                            <span
                                                                class="stat-pill bg-secondary text-white">${detail.totalCount}</span>
                                                        </div>
                                                        <hr>
                                                        <div
                                                            class="d-flex justify-content-between align-items-center mb-2">
                                                            <span class="text-muted small">Doanh thu online</span>
                                                            <span class="fw-semibold">
                                                                <fmt:formatNumber value="${detail.onlineRevenue}"
                                                                    type="number" groupingUsed="true"
                                                                    maxFractionDigits="0" /> ₫
                                                            </span>
                                                        </div>
                                                        <div
                                                            class="d-flex justify-content-between align-items-center mb-3">
                                                            <span class="text-muted small">Doanh thu quầy</span>
                                                            <span class="fw-semibold">
                                                                <fmt:formatNumber value="${detail.counterRevenue}"
                                                                    type="number" groupingUsed="true"
                                                                    maxFractionDigits="0" /> ₫
                                                            </span>
                                                        </div>
                                                        <div class="d-flex justify-content-between align-items-center">
                                                            <span class="fw-bold">Tổng cộng</span>
                                                            <span class="fw-bold text-danger fs-5">
                                                                <fmt:formatNumber value="${detail.totalRevenue}"
                                                                    type="number" groupingUsed="true"
                                                                    maxFractionDigits="0" /> ₫
                                                            </span>
                                                        </div>
                                                    </div>

                                    </div>

                                    <%-- RIGHT: Ticket tables --%>
                                        <div class="col-lg-8">

                                            <%-- Online tickets table --%>
                                                <div class="form-card p-4 mb-4">
                                                    <p class="section-label mb-3">
                                                        <i class="fa-solid fa-globe me-1"></i>Vé Online
                                                        <span class="badge bg-primary ms-2">${detail.onlineCount}</span>
                                                    </p>
                                                    <c:choose>
                                                        <c:when test="${empty detail.onlineTickets}">
                                                            <div class="text-center py-4 text-muted">
                                                                <i
                                                                    class="fa-solid fa-ticket fa-2x mb-2 d-block text-secondary"></i>
                                                                Không có vé online nào.
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="table-responsive">
                                                                <table class="table table-sm align-middle mb-0">
                                                                    <thead class="table-dark">
                                                                        <tr>
                                                                            <th>Mã booking</th>
                                                                            <th>Mã e-ticket</th>
                                                                            <th>Khách hàng</th>
                                                                            <th>Ghế</th>
                                                                            <th>Loại vé</th>
                                                                            <th class="text-end">Giá</th>
                                                                            <th>Hoàn tiền</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:forEach var="t"
                                                                            items="${detail.onlineTickets}">
                                                                            <tr>
                                                                                <td class="fw-semibold text-primary">
                                                                                    ${t.bookingCode}</td>
                                                                                <td class="text-muted small">
                                                                                    ${t.ticketCode}</td>
                                                                                <td>
                                                                                    <div>${t.customerName}</div>
                                                                                    <div class="text-muted small">
                                                                                        ${t.customerEmail}</div>
                                                                                </td>
                                                                                <td>
                                                                                    <span
                                                                                        class="fw-bold">${t.seatCode}</span>
                                                                                    <span
                                                                                        class="seat-type-${t.seatType} small ms-1">${t.seatType}</span>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${t.ticketType == 'ADULT'}">
                                                                                            <span
                                                                                                class="badge bg-secondary">Người
                                                                                                lớn</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span
                                                                                                class="badge bg-info text-dark">Trẻ
                                                                                                em</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td class="text-end fw-semibold">
                                                                                    <fmt:formatNumber value="${t.price}"
                                                                                        type="number"
                                                                                        groupingUsed="true"
                                                                                        maxFractionDigits="0" /> ₫
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${t.paymentStatus == 'REFUND_PENDING'}">
                                                                                            <span
                                                                                                class="badge badge-refund-pending">Chờ
                                                                                                hoàn</span>
                                                                                        </c:when>
                                                                                        <c:when
                                                                                            test="${t.paymentStatus == 'REFUNDED'}">
                                                                                            <span
                                                                                                class="badge badge-refunded">Đã
                                                                                                hoàn</span>
                                                                                        </c:when>
                                                                                        <c:when
                                                                                            test="${t.paymentStatus == 'PAID'}">
                                                                                            <span
                                                                                                class="badge badge-paid">Đã
                                                                                                thanh toán</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span
                                                                                                class="badge badge-pending">${t.paymentStatus}</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </tbody>
                                                                    <tfoot class="table-light">
                                                                        <tr>
                                                                            <td colspan="5" class="fw-bold text-end">
                                                                                Tổng online:</td>
                                                                            <td class="text-end fw-bold text-primary">
                                                                                <fmt:formatNumber
                                                                                    value="${detail.onlineRevenue}"
                                                                                    type="number" groupingUsed="true"
                                                                                    maxFractionDigits="0" /> ₫
                                                                            </td>
                                                                            <td></td>
                                                                        </tr>
                                                                    </tfoot>
                                                                </table>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <%-- Counter tickets table --%>
                                                    <div class="form-card p-4">
                                                        <p class="section-label mb-3">
                                                            <i class="fa-solid fa-store me-1"></i>Vé Quầy
                                                            <span
                                                                class="badge bg-warning text-dark ms-2">${detail.counterCount}</span>
                                                        </p>
                                                        <c:choose>
                                                            <c:when test="${empty detail.counterTickets}">
                                                                <div class="text-center py-4 text-muted">
                                                                    <i
                                                                        class="fa-solid fa-ticket fa-2x mb-2 d-block text-secondary"></i>
                                                                    Không có vé quầy nào.
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="table-responsive">
                                                                    <table class="table table-sm align-middle mb-0">
                                                                        <thead class="table-warning">
                                                                            <tr>
                                                                                <th>Mã vé</th>
                                                                                <th>Khách hàng</th>
                                                                                <th>SĐT</th>
                                                                                <th>Ghế</th>
                                                                                <th>Loại vé</th>
                                                                                <th class="text-end">Giá</th>
                                                                                <th>Thanh toán</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="t"
                                                                                items="${detail.counterTickets}">
                                                                                <tr>
                                                                                    <td
                                                                                        class="fw-semibold text-warning-emphasis">
                                                                                        ${t.ticketCode}</td>
                                                                                    <td>${t.customerName}</td>
                                                                                    <td class="text-muted small">
                                                                                        ${t.customerPhone}</td>
                                                                                    <td>
                                                                                        <span
                                                                                            class="fw-bold">${t.seatCode}</span>
                                                                                        <span
                                                                                            class="seat-type-${t.seatType} small ms-1">${t.seatType}</span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${t.ticketType == 'ADULT'}">
                                                                                                <span
                                                                                                    class="badge bg-secondary">Người
                                                                                                    lớn</span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="badge bg-info text-dark">Trẻ
                                                                                                    em</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                    <td class="text-end fw-semibold">
                                                                                        <fmt:formatNumber
                                                                                            value="${t.price}"
                                                                                            type="number"
                                                                                            groupingUsed="true"
                                                                                            maxFractionDigits="0" /> ₫
                                                                                    </td>
                                                                                    <td>
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${t.paymentMethod == 'CASH'}">
                                                                                                <span
                                                                                                    class="badge bg-success">Tiền
                                                                                                    mặt</span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="badge bg-info text-dark">${t.paymentMethod}</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                        <tfoot class="table-light">
                                                                            <tr>
                                                                                <td colspan="5"
                                                                                    class="fw-bold text-end">Tổng quầy:
                                                                                </td>
                                                                                <td
                                                                                    class="text-end fw-bold text-warning-emphasis">
                                                                                    <fmt:formatNumber
                                                                                        value="${detail.counterRevenue}"
                                                                                        type="number"
                                                                                        groupingUsed="true"
                                                                                        maxFractionDigits="0" /> ₫
                                                                                </td>
                                                                                <td></td>
                                                                            </tr>
                                                                        </tfoot>
                                                                    </table>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>

                                        </div>
                            </div>
                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>