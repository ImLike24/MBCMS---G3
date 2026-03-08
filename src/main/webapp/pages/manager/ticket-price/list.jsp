<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cấu hình Giá Vé</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="ticket-prices"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">Cấu hình Giá vé cơ bản</h3>
                <span class="text-secondary small">Thiết lập giá theo ngày, giờ và loại ghế</span>
            </div>

            <div class="d-flex gap-3 align-items-center">
                <form action="ticket-prices" method="get" id="branchSelectForm" class="mb-0">
                    <div class="input-group shadow-sm">
                        <span class="input-group-text bg-dark text-white border-dark"><i class="fa fa-building"></i></span>
                        <select class="form-select border-dark" name="branchId" onchange="document.getElementById('branchSelectForm').submit()">
                            <c:forEach var="b" items="${managedBranches}">
                                <option value="${b.branchId}" ${b.branchId == selectedBranchId ? 'selected' : ''}>${b.branchName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </form>
                <a href="ticket-prices?action=create" class="btn btn-orange shadow-sm px-4">
                    <i class="fa fa-plus me-2"></i>Thêm Mức Giá
                </a>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success border-0 shadow-sm" style="border-left: 4px solid #d96c2c !important;">
                Thao tác thành công!
            </div>
        </c:if>

        <div class="card card-custom mb-4">
            <div class="card-body p-4">
                <form action="ticket-prices" method="get">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa fa-search text-muted"></i></span>
                                <input type="text" class="form-control border-start-0 bg-light" name="search"
                                       value="${searchQuery}" placeholder="Tìm theo loại ghế, khách (VIP, ADULT...)">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="dayType">
                                <option value="">-- Tất cả Loại Ngày --</option>
                                <option value="WEEKDAY" ${dayTypeFilter == 'WEEKDAY' ? 'selected' : ''}>Ngày thường</option>
                                <option value="WEEKEND" ${dayTypeFilter == 'WEEKEND' ? 'selected' : ''}>Cuối tuần</option>
                                <option value="HOLIDAY" ${dayTypeFilter == 'HOLIDAY' ? 'selected' : ''}>Ngày Lễ</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="status">
                                <option value="">-- Tất cả Trạng thái --</option>
                                <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>Đang áp dụng</option>
                                <option value="INACTIVE" ${statusFilter == 'INACTIVE' ? 'selected' : ''}>Vô hiệu hóa</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-dark w-100">Lọc dữ liệu</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="card card-custom">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th class="ps-4">Loại Ngày / Giờ</th>
                            <th>Loại Khách / Ghế</th>
                            <th class="text-danger fw-bold">Giá (VNĐ)</th>
                            <th>Hiệu lực từ</th>
                            <th>Hiệu lực đến</th>
                            <th>Trạng thái</th>
                            <th class="text-center">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="p" items="${prices}">
                            <tr>
                                <td class="ps-4">
                                    <div class="fw-bold text-dark">${p.dayType}</div>
                                    <small class="text-muted"><i class="fa fa-clock-o me-1"></i>${p.timeSlot}</small>
                                </td>
                                <td>
                                    <div><span class="badge bg-light text-dark border">${p.ticketType}</span></div>
                                    <div class="mt-1"><span class="badge bg-secondary">${p.seatType}</span></div>
                                </td>
                                <td class="fw-bold fs-5" style="color: #d96c2c;">${p.price}</td>
                                <td>${p.effectiveFrom}</td>
                                <td>${p.effectiveTo != null ? p.effectiveTo : '<span class="fst-italic text-muted">Vô thời hạn</span>'}</td>
                                <td>
                                    <span class="badge ${p.active ? 'bg-success' : 'bg-danger'} rounded-pill px-3">
                                            ${p.active ? 'Đang áp dụng' : 'Vô hiệu'}
                                    </span>
                                </td>
                                <td class="text-center">
                                    <a href="ticket-prices?action=view&id=${p.priceId}" class="btn btn-outline-info btn-sm me-1" title="Chi tiết">
                                        <i class="fa fa-eye"></i>
                                    </a>
                                    <a href="ticket-prices?action=edit&id=${p.priceId}" class="btn btn-outline-warning btn-sm me-1" title="Sửa">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                    <c:if test="${p.active}">
                                        <a href="ticket-prices?action=deactivate&id=${p.priceId}" class="btn btn-outline-secondary btn-sm"
                                           onclick="return confirm('Bạn muốn tạm ngưng áp dụng mức giá này?')" title="Ngưng áp dụng">
                                            <i class="fa fa-ban"></i>
                                        </a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty prices}">
                            <tr><td colspan="7" class="text-center py-4 text-muted">Không tìm thấy dữ liệu phù hợp.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <div class="card-footer bg-white border-0 py-3">
                        <nav class="d-flex justify-content-end mb-0">
                            <ul class="pagination mb-0">
                                <c:set var="q" value="&search=${searchQuery}&dayType=${dayTypeFilter}&status=${statusFilter}" />
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="ticket-prices?page=${i}${q}">${i}</a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>