<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo Doanh thu theo Phương thức thanh toán</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-layout.css">
</head>
<body>

<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />
<jsp:include page="/components/layout/dashboard/manager_sidebar.jsp">
    <jsp:param name="page" value="revenue"/>
</jsp:include>

<main>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">Doanh thu theo Phương thức thanh toán</h3>
                <span class="text-secondary small">Phân tích doanh thu theo tiền mặt, chuyển khoản, ZaloPay...</span>
            </div>
            <a href="${pageContext.request.contextPath}/manager/report/revenue" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-2"></i>Quay lại
            </a>
        </div>

        <div class="card card-custom mb-4">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/manager/report/revenue/payment-method" method="get" class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Từ ngày</label>
                        <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Đến ngày</label>
                        <input type="date" class="form-control" name="toDate" value="${toDate}">
                    </div>
                    <div class="col-md-4 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-orange px-4">
                            <i class="fa fa-filter me-2"></i>Lọc
                        </button>
                        <button type="submit" name="generate" value="1" class="btn btn-outline-primary px-4">
                            <i class="fa fa-file-export me-2"></i>Generate Report
                        </button>
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
                            <th class="ps-4">Phương thức</th>
                            <th>Số hóa đơn</th>
                            <th class="text-end pe-4">Doanh thu (VNĐ)</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${rows}">
                            <tr>
                                <td class="ps-4">
                                    <c:choose>
                                        <c:when test="${r.paymentMethod == 'CASH'}">
                                            <i class="fa fa-money text-success me-2"></i>Tiền mặt
                                        </c:when>
                                        <c:when test="${r.paymentMethod == 'BANKING'}">
                                            <i class="fa fa-university text-primary me-2"></i>Chuyển khoản
                                        </c:when>
                                        <c:when test="${r.paymentMethod == 'ZALOPA' || r.paymentMethod == 'ZALOPAY'}">
                                            <i class="fa fa-credit-card text-info me-2"></i>ZaloPay
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa fa-credit-card text-muted me-2"></i>${r.paymentMethod}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${r.invoiceCount}</td>
                                <td class="text-end pe-4 fw-bold text-success">
                                    <fmt:formatNumber value="${r.totalRevenue}" type="number" maxFractionDigits="0"/> đ
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty rows}">
                            <tr><td colspan="3" class="text-center py-4 text-muted">Không có dữ liệu trong khoảng thời gian này.</td></tr>
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
