<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Thành Viên | MyCinema</title>
                <!-- CSS -->
                <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&family=Roboto:wght@300;400;500&display=swap"
                    rel="stylesheet">
                <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">

                <style>
                    body {
                        background-color: #f4f7f6;
                        font-family: 'Roboto', sans-serif;
                        color: #333;
                    }

                    .membership-header {
                        background: linear-gradient(135deg, #d96c2c 0%, #ff9e64 100%);
                        padding: 100px 0;
                        color: white;
                        border-bottom-left-radius: 50px;
                        border-bottom-right-radius: 50px;
                        margin-bottom: -50px;
                    }

                    .membership-card {
                        background: white;
                        border-radius: 20px;
                        padding: 30px;
                        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                        border: none;
                        transition: transform 0.3s ease;
                        position: relative;
                        overflow: hidden;
                    }

                    .tier-badge {
                        font-size: 1.2rem;
                        font-weight: 700;
                        padding: 8px 25px;
                        border-radius: 50px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: white;
                        display: inline-block;
                        margin-bottom: 20px;
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                    }

                    
                    .tier-member {
                        background: #757575;

                        color: white;
                    }

                    .tier-bronze {
                        background: linear-gradient(135deg, #8B4513 0%, #CD853F 100%);
                        color: white;
                    }

                    .tier-silver {
                        background: linear-gradient(135deg, #a9afb3 0%, #f1f0f0 100%);
                        color: #2c3e50;
                    }

                    .tier-gold {
                        background: linear-gradient(135deg, #ffc400 0%, #fade83 100%);
                        color: #5d4037;
                    }

                    .tier-diamond {
                        background: linear-gradient(135deg, #00BFFF 0%, #E0FFFF 100%);
                        color: #008080;
                    }

                    .points-display {
                        font-family: 'Montserrat', sans-serif;
                        font-size: 3rem;
                        font-weight: 700;
                        color: #d96c2c;
                        margin-bottom: 5px;
                    }

                    .points-label {
                        font-size: 0.9rem;
                        color: #6c757d;
                        text-transform: uppercase;
                        font-weight: 600;
                        letter-spacing: 1px;
                    }

                    .progress-container {
                        margin-top: 40px;
                    }

                    .custom-progress {
                        height: 12px;
                        border-radius: 10px;
                        background-color: #e9ecef;
                        overflow: visible;
                        position: relative;
                    }

                    .custom-progress-bar {
                        background: linear-gradient(135deg, #d96c2c 0%, #ff9e64 100%);
                        border-radius: 10px;
                        position: relative;
                        transition: width 1s ease-in-out;
                    }

                    .progress-marker {
                        position: absolute;
                        right: 0;
                        top: -30px;
                        background: #333;
                        color: white;
                        padding: 2px 8px;
                        border-radius: 4px;
                        font-size: 0.75rem;
                    }

                    .progress-marker::after {
                        content: '';
                        position: absolute;
                        bottom: -5px;
                        left: 50%;
                        transform: translateX(-50%);
                        border-left: 5px solid transparent;
                        border-right: 5px solid transparent;
                        border-top: 5px solid #333;
                    }

                    .history-section {
                        padding-top: 80px;
                        padding-bottom: 60px;
                    }

                    .table-custom {
                        background: white;
                        border-radius: 15px;
                        overflow: hidden;
                        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
                    }

                    .table-custom thead {
                        background-color: #f8f9fa;
                        border-bottom: 2px solid #eee;
                    }

                    .table-custom th {
                        font-weight: 600;
                        text-transform: uppercase;
                        font-size: 0.85rem;
                        padding: 15px 20px;
                        color: #555;
                    }

                    .table-custom td {
                        padding: 15px 20px;
                        vertical-align: middle;
                        border-bottom: 1px solid #f1f1f1;
                    }

                    .earn-points {
                        color: #28a745;
                        font-weight: 600;
                    }

                    .redeem-points {
                        color: #dc3545;
                        font-weight: 600;
                    }

                    .back-to-home {
                        position: fixed;
                        bottom: 30px;
                        right: 30px;
                        background: white;
                        width: 50px;
                        height: 50px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                        color: #d96c2c;
                        text-decoration: none;
                        z-index: 100;
                        transition: all 0.3s ease;
                    }

                    .back-to-home:hover {
                        background: #d96c2c;
                        color: white;
                        transform: translateY(-5px);
                    }
                </style>
            </head>

            <body>

                <jsp:include page="/components/layout/Header.jsp" />
                <jsp:include page="/components/layout/Sidebar.jsp" />

                <div class="membership-header text-center">
                    <div class="container">
                        <h1 class="fw-bold mb-3">Chương Trình Thành Viên</h1>
                        <p class="lead opacity-75">Tích điểm mỗi lần mua vé, thăng hạng nhận ưu đãi bất tận.</p>
                    </div>
                </div>

                <div class="container">
                    <div class="row justify-content-center">
                        <div class="col-lg-10">
                            <div class="membership-card">
                                <div class="row align-items-center">
                                    <div class="col-md-6 text-center text-md-start mb-4 mb-md-0">
                                        <span class="tier-badge tier-${currentTier.tierName.toLowerCase()}">
                                            <i class="fa fa-trophy me-2"></i> ${currentTier.tierName}
                                        </span>
                                        <div class="points-display">${user.points}</div>
                                        <div class="points-label">Điểm hiện có của bạn</div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="d-flex justify-content-between align-items-end mb-2">
                                            <div class="fw-bold">Tiến độ thăng hạng</div>
                                            <div class="small text-muted">Tích lũy:
                                                <strong>${user.totalAccumulatedPoints}</strong> điểm
                                            </div>
                                        </div>

                                        <div class="progress-container">
                                            <div class="custom-progress progress">
                                                <div class="custom-progress-bar progress-bar" role="progressbar"
                                                    style="width: ${progress}%" aria-valuenow="${progress}"
                                                    aria-valuemin="0" aria-valuemax="100">
                                                    <span class="progress-marker">${progress}%</span>
                                                </div>
                                            </div>
                                        </div>

                                        <c:if test="${not empty nextTier}">
                                            <div class="mt-3 small text-center text-md-end text-muted italic">
                                                Cần thêm <strong>${nextTier.minPointsRequired -
                                                    user.totalAccumulatedPoints}</strong> điểm để thăng hạng
                                                <strong>${nextTier.tierName}</strong>
                                            </div>
                                        </c:if>
                                        <c:if test="${empty nextTier}">
                                            <div class="mt-3 small text-center text-md-end text-success fw-bold">
                                                <i class="fa fa-check-circle me-1"></i> Bạn đã đạt cấp bậc cao nhất!
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quy tắc tích điểm (từ cấu hình Admin) -->
                    <c:if test="${not empty loyaltyConfig}">
                        <div class="row justify-content-center mb-4">
                            <div class="col-lg-10">
                                <div class="alert alert-light border border-secondary d-flex align-items-center" role="alert">
                                    <i class="fa fa-info-circle me-3" style="font-size: 1.5rem; color: #d96c2c;"></i>
                                    <div>
                                        <strong>Quy tắc tích điểm (cấu hình từ Admin):</strong>
                                        Mỗi <fmt:formatNumber value="${loyaltyConfig.earnRateAmount}" type="number" groupingUsed="true"/> VND thanh toán (từ hóa đơn đặt vé), bạn nhận <strong>${loyaltyConfig.earnPoints}</strong> điểm.
                                        Điểm tối thiểu để đổi ưu đãi: <strong>${loyaltyConfig.minRedeemPoints}</strong> điểm.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Point History Section - Lịch sử điểm từ hóa đơn & giao dịch -->
                    <div class="history-section">
                        <div class="row justify-content-center">
                            <div class="col-lg-10">
                                <div class="d-flex align-items-center mb-4">
                                    <div class="icon-box me-3" style="font-size: 1.5rem; color: #d96c2c;">
                                        <i class="fa fa-history"></i>
                                    </div>
                                    <div>
                                        <h3 class="fw-bold m-0">Lịch sử điểm thành viên</h3>
                                        <p class="text-muted small mb-0 mt-1">Từ hóa đơn đặt vé online và giao dịch tại quầy.</p>
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <table class="table table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Thời gian</th>
                                                <th>Loại giao dịch</th>
                                                <th>Số điểm</th>
                                                <th>Nội dung</th>
                                                <th>Hóa đơn</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${pointHistory}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-500">${item.createdAtFormatted}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.transactionType == 'EARN'}">
                                                                <span
                                                                    class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 rounded-3">Tích
                                                                    điểm</span>
                                                            </c:when>
                                                            <c:when test="${item.transactionType == 'REDEEM'}">
                                                                <span
                                                                    class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2 rounded-3">Đổi
                                                                    điểm</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span
                                                                    class="badge bg-secondary-subtle text-secondary border border-secondary-subtle px-3 py-2 rounded-3">${item.transactionType}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td
                                                        class="${item.pointsChanged > 0 ? 'earn-points' : 'redeem-points'}">
                                                        ${item.pointsChanged > 0 ? '+' : ''}${item.pointsChanged}
                                                    </td>
                                                    <td>
                                                        <div class="text-muted small">${item.description}</div>
                                                    </td>
                                                    <td>
                                                        <c:if test="${item.transactionType == 'EARN' && item.referenceId != null}">
                                                            <a href="${pageContext.request.contextPath}/customer/booking-history" class="btn btn-sm btn-outline-secondary">Xem hóa đơn</a>
                                                        </c:if>
                                                        <c:if test="${item.transactionType != 'EARN' || item.referenceId == null}">
                                                            <span class="text-muted">—</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty pointHistory}">
                                                <tr>
                                                    <td colspan="5" class="text-center py-5 text-muted">
                                                        <i class="fa fa-info-circle me-2"></i> Bạn chưa có lịch sử giao
                                                        dịch điểm.
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <jsp:include page="/components/layout/Footer.jsp" />

                <a href="${pageContext.request.contextPath}/" class="back-to-home" title="Về Trang Chủ">
                    <i class="fa fa-home"></i>
                </a>

                <!-- Scripts -->
                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>