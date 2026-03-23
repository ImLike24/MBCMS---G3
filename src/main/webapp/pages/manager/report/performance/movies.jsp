<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Phim bán chạy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
    <style>
        .filter-card { background: #f8f9fa; border-radius: 10px; }
        .table-custom th {
            background-color: #070707;
            color: #fff;
            font-weight: 600;
            font-size: 0.85rem;
        }
        .btn-orange {
            background-color: #d96c2c;
            border-color: #d96c2c;
            color: #fff;
        }
        .btn-orange:hover { background-color: #b85a22; border-color: #b85a22; color: #fff; }
    </style>
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp"/>
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="performance"/>
</jsp:include>

<main>
    <div class="container-fluid py-4">

        <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-3">
            <div>
                <h3 class="fw-bold text-dark mb-1">
                    <i class="fa-solid fa-film me-2" style="color:#d96c2c;"></i>Phim bán chạy
                </h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/branch-manager/dashboard" class="text-decoration-none text-secondary">Manager</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/manager/report/performance" class="text-decoration-none text-secondary">Hiệu suất</a></li>
                        <li class="breadcrumb-item active" style="color: #d96c2c;">Theo phim</li>
                    </ol>
                </nav>
            </div>
        </div>

        <c:if test="${not empty reportFilterError}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <c:out value="${reportFilterError}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
            </div>
        </c:if>

        <form method="get" action="${pageContext.request.contextPath}/manager/report/performance/movies" class="filter-card p-4 mb-4 shadow-sm">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Chi nhánh</label>
                    <select name="branchId" class="form-select border-dark">
                        <option value="all" ${empty selectedBranchId ? 'selected' : ''}>Tất cả chi nhánh</option>
                        <c:forEach var="b" items="${managedBranches}">
                            <option value="${b.branchId}" ${selectedBranchId != null && selectedBranchId == b.branchId ? 'selected' : ''}>
                                <c:out value="${b.branchName}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Từ ngày</label>
                    <input type="date" name="from" class="form-control border-dark" value="${fromDate}">
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Đến ngày</label>
                    <input type="date" name="to" class="form-control border-dark" value="${toDate}" max="${todayMaxDate}">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-orange w-100">
                        <i class="fa-solid fa-filter me-1"></i> Áp dụng
                    </button>
                </div>
            </div>
        </form>

        <div class="card border-0 shadow-sm">
            <div class="card-header bg-dark text-white py-3">
                <i class="fa-solid fa-ranking-star me-2"></i> Danh sách phim bán chạy
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 table-custom">
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Tên phim</th>
                            <th class="text-end">Tổng vé</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${empty topMovies}">
                                <tr>
                                    <td colspan="3" class="text-center text-muted py-4">Không có dữ liệu vé trong khoảng thời gian này.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="row" items="${topMovies}" varStatus="st">
                                    <tr>
                                        <td>${st.index + 1}</td>
                                        <td><c:out value="${row.title}"/></td>
                                        <td class="text-end fw-semibold">${row.totalTickets}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="mt-3">
            <a href="${pageContext.request.contextPath}/manager/report/performance?from=${fromDate}&to=${toDate}&branchId=${empty selectedBranchId ? 'all' : selectedBranchId}"
               class="btn btn-outline-secondary">
                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại báo cáo hiệu suất
            </a>
        </div>

    </div>
</main>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
