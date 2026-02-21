<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Quản lý Suất Chiếu</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
                <style>
                    .stat-card {
                        border-left: 4px solid;
                        border-radius: 8px;
                    }

                    .stat-card.scheduled {
                        border-color: #0d6efd;
                    }

                    .stat-card.ongoing {
                        border-color: #198754;
                    }

                    .stat-card.completed {
                        border-color: #6c757d;
                    }

                    .stat-card.cancelled {
                        border-color: #dc3545;
                    }

                    .badge-scheduled {
                        background-color: #0d6efd;
                    }

                    .badge-ongoing {
                        background-color: #198754;
                    }

                    .badge-completed {
                        background-color: #6c757d;
                    }

                    .badge-cancelled {
                        background-color: #dc3545;
                    }

                    .filter-card {
                        background: #f8f9fa;
                        border-radius: 10px;
                    }

                    .btn-orange {
                        background-color: #d96c2c;
                        border-color: #d96c2c;
                        color: #fff;
                    }

                    .btn-orange:hover {
                        background-color: #b85a22;
                        border-color: #b85a22;
                        color: #fff;
                    }

                    .table-custom th {
                        background-color: #f1f1f1;
                        font-weight: 600;
                        font-size: 0.85rem;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
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

                        <!-- Page Header -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h3 class="fw-bold text-dark mb-1">
                                    <i class="fa-solid fa-film me-2" style="color:#d96c2c;"></i>Quản lý Suất Chiếu
                                </h3>
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb mb-0">
                                        <li class="breadcrumb-item"><a href="#"
                                                class="text-decoration-none text-secondary">Manager</a></li>
                                        <li class="breadcrumb-item active" style="color: #d96c2c;">Suất chiếu</li>
                                    </ol>
                                </nav>
                            </div>
                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes?action=create"
                                class="btn btn-orange shadow-sm px-4">
                                <i class="fa-solid fa-plus me-2"></i>Lên lịch suất chiếu
                            </a>
                        </div>

                        <!-- Alerts -->
                        <c:if test="${param.message == 'created'}">
                            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert"
                                style="border-left:4px solid #198754 !important;">
                                <i class="fa-solid fa-circle-check me-2"></i>Lên lịch suất chiếu thành công!
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${param.message == 'updated'}">
                            <div class="alert alert-info alert-dismissible fade show border-0 shadow-sm" role="alert">
                                <i class="fa-solid fa-pencil me-2"></i>Cập nhật suất chiếu thành công!
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${param.message == 'cancelled'}">
                            <div class="alert alert-warning alert-dismissible fade show border-0 shadow-sm" role="alert"
                                style="border-left:4px solid #e97d2c !important;">
                                <i class="fa-solid fa-ban me-2"></i>
                                <strong>Đã huỷ suất chiếu thành công.</strong>
                                <c:if test="${param.onlineRefunds > 0 or param.counterRefunds > 0}">
                                    &nbsp;·&nbsp;
                                    <span class="badge bg-primary">${param.onlineRefunds} online → REFUND_PENDING</span>
                                    <c:if test="${param.counterRefunds > 0}">
                                        &nbsp;<span class="badge bg-warning text-dark">${param.counterRefunds} quầy →
                                            hoàn tay</span>
                                    </c:if>
                                    <c:if test="${not empty param.refundAmt and param.refundAmt != '0'}">
                                        &nbsp;·&nbsp;Tổng hoàn dự kiến:
                                        <fmt:parseNumber value="${param.refundAmt}" var="rAmt" integerOnly="false" />
                                        <strong>
                                            <fmt:formatNumber value="${rAmt}" type="number" groupingUsed="true" /> ₫
                                        </strong>
                                    </c:if>
                                </c:if>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${param.error == 'cancelfailed'}">
                            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                                <i class="fa-solid fa-circle-xmark me-2"></i>
                                Huỷ suất chiếu thất bại: ${param.detail}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${param.error == 'noteditable'}">
                            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                                <i class="fa-solid fa-triangle-exclamation me-2"></i>Chỉ có thể chỉnh sửa suất chiếu ở
                                trạng thái Đã lên lịch.
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Stats Cards -->
                        <div class="row g-3 mb-4">
                            <div class="col-6 col-md-3">
                                <div class="card stat-card scheduled shadow-sm h-100 p-3">
                                    <div class="small text-muted text-uppercase fw-semibold mb-1">Tổng cộng</div>
                                    <div class="fs-3 fw-bold">${stats.total}</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="card stat-card scheduled shadow-sm h-100 p-3">
                                    <div class="small text-muted text-uppercase fw-semibold mb-1">Đã lên lịch</div>
                                    <div class="fs-3 fw-bold text-primary">${stats.SCHEDULED}</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="card stat-card ongoing shadow-sm h-100 p-3">
                                    <div class="small text-muted text-uppercase fw-semibold mb-1">Đang chiếu</div>
                                    <div class="fs-3 fw-bold text-success">${stats.ONGOING}</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="card stat-card cancelled shadow-sm h-100 p-3">
                                    <div class="small text-muted text-uppercase fw-semibold mb-1">Đã huỷ</div>
                                    <div class="fs-3 fw-bold text-danger">${stats.CANCELLED}</div>
                                </div>
                            </div>
                        </div>

                        <!-- Filter Panel -->
                        <div class="filter-card p-3 mb-4 shadow-sm">
                            <form method="get"
                                action="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                class="row g-2 align-items-end">
                                <div class="col-md-3">
                                    <label class="form-label small fw-semibold mb-1">Ngày chiếu</label>
                                    <input type="date" name="filterDate" class="form-control form-control-sm"
                                        value="${filterDate}">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-semibold mb-1">Trạng thái</label>
                                    <select name="filterStatus" class="form-select form-select-sm">
                                        <option value="">-- Tất cả --</option>
                                        <option value="SCHEDULED" ${filterStatus=='SCHEDULED' ? 'selected' : '' }>Đã lên
                                            lịch</option>
                                        <option value="ONGOING" ${filterStatus=='ONGOING' ? 'selected' : '' }>Đang chiếu
                                        </option>
                                        <option value="COMPLETED" ${filterStatus=='COMPLETED' ? 'selected' : '' }>Đã
                                            hoàn thành</option>
                                        <option value="CANCELLED" ${filterStatus=='CANCELLED' ? 'selected' : '' }>Đã huỷ
                                        </option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-semibold mb-1">Tên phim</label>
                                    <input type="text" name="filterMovie" class="form-control form-control-sm"
                                        placeholder="Tìm kiếm theo tên phim..." value="${filterMovie}">
                                </div>
                                <div class="col-md-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-orange btn-sm flex-fill">
                                        <i class="fa-solid fa-magnifying-glass me-1"></i>Lọc
                                    </button>
                                    <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes"
                                        class="btn btn-outline-secondary btn-sm flex-fill">
                                        <i class="fa-solid fa-rotate-left"></i>
                                    </a>
                                </div>
                            </form>
                        </div>

                        <!-- Showtimes Table -->
                        <div class="card card-custom shadow-sm">
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-custom table-hover align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th class="ps-4">#ID</th>
                                                <th>Phim</th>
                                                <th>Phòng chiếu</th>
                                                <th>Ngày chiếu</th>
                                                <th>Giờ bắt đầu</th>
                                                <th>Giờ kết thúc</th>
                                                <th>Giá (VNĐ)</th>
                                                <th>Trạng thái</th>
                                                <th class="text-end pe-4">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="st" items="${showtimes}">
                                                <tr>
                                                    <td class="ps-4 fw-bold" style="color:#d96c2c;">#${st.showtimeId}
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold">${st.movieTitle}</div>
                                                        <div class="text-muted small">${st.duration} phút</div>
                                                    </td>
                                                    <td>${st.roomName}</td>
                                                    <td>
                                                        <fmt:parseDate value="${st.showDate}" pattern="yyyy-MM-dd"
                                                            var="parsedDate" type="date" />
                                                        <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                                                    </td>
                                                    <td class="fw-semibold">${st.startTime}</td>
                                                    <td class="text-muted">${st.endTime}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${st.basePrice}" type="number"
                                                            groupingUsed="true" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${st.status == 'SCHEDULED'}">
                                                                <span class="badge badge-scheduled rounded-pill px-3">Đã
                                                                    lên lịch</span>
                                                            </c:when>
                                                            <c:when test="${st.status == 'ONGOING'}">
                                                                <span class="badge badge-ongoing rounded-pill px-3">Đang
                                                                    chiếu</span>
                                                            </c:when>
                                                            <c:when test="${st.status == 'COMPLETED'}">
                                                                <span
                                                                    class="badge badge-completed rounded-pill px-3">Hoàn
                                                                    thành</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-cancelled rounded-pill px-3">Đã
                                                                    huỷ</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end pe-4">
                                                        <c:if test="${st.status == 'SCHEDULED'}">
                                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes?action=edit&id=${st.showtimeId}"
                                                                class="btn btn-outline-primary btn-sm me-1"
                                                                title="Chỉnh sửa">
                                                                <i class="fa-solid fa-pencil"></i>
                                                            </a>
                                                            <!-- Cancel → confirmation page -->
                                                            <a href="${pageContext.request.contextPath}/branch-manager/manage-showtimes?action=cancel-preview&id=${st.showtimeId}"
                                                                class="btn btn-outline-danger btn-sm"
                                                                title="Huỷ suất chiếu">
                                                                <i class="fa-solid fa-ban"></i>
                                                            </a>
                                                        </c:if>
                                                        <c:if test="${st.status != 'SCHEDULED'}">
                                                            <span class="text-muted small">—</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty showtimes}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-5 text-muted">
                                                        <i class="fa-solid fa-calendar-xmark fa-2x mb-2 d-block"></i>
                                                        Không có suất chiếu nào.
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                    </div>
                </main>

                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>