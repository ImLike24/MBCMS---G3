<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Ưu Đãi | MyCinema</title>
                <!-- CSS -->
                <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&family=Roboto:wght@300;400;500&display=swap"
                    rel="stylesheet">
                <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">

                <style>
                    :root {
                        --primary-gradient: linear-gradient(135deg, #d96c2c 0%, #ff9e64 100%);
                        --secondary-gradient: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
                    }

                    body {
                        background-color: #f8f9fa;
                        font-family: 'Roboto', sans-serif;
                    }

                    .promo-header {
                        background: var(--primary-gradient);
                        padding: 80px 0;
                        color: white;
                        border-bottom-left-radius: 50px;
                        border-bottom-right-radius: 50px;
                        margin-bottom: 40px;
                    }

                    .nav-pills-custom {
                        background: white;
                        padding: 8px;
                        border-radius: 50px;
                        display: inline-flex;
                        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
                        margin-bottom: 40px;
                    }

                    .nav-pills-custom .nav-link {
                        border-radius: 50px;
                        padding: 10px 30px;
                        color: #666;
                        font-weight: 600;
                        transition: all 0.3s ease;
                    }

                    .nav-pills-custom .nav-link.active {
                        background: var(--primary-gradient);
                        color: white;
                        box-shadow: 0 4px 15px rgba(217, 108, 44, 0.3);
                    }

                    .voucher-card {
                        background: white;
                        border-radius: 20px;
                        border: none;
                        overflow: hidden;
                        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
                        transition: all 0.3s ease;
                        height: 100%;
                        display: flex;
                        flex-direction: column;
                    }

                    .voucher-card:hover {
                        transform: translateY(-5px);
                        box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
                    }

                    .voucher-top {
                        background: var(--secondary-gradient);
                        color: white;
                        padding: 25px;
                        text-align: center;
                        position: relative;
                    }

                    .voucher-top::after {
                        content: '';
                        position: absolute;
                        bottom: -10px;
                        left: 0;
                        right: 0;
                        height: 20px;
                        background: white;
                        clip-path: polygon(0% 100%, 5% 40%, 10% 100%, 15% 40%, 20% 100%, 25% 40%, 30% 100%, 35% 40%, 40% 100%, 45% 40%, 50% 100%, 55% 40%, 60% 100%, 65% 40%, 70% 100%, 75% 40%, 80% 100%, 85% 40%, 90% 100%, 95% 40%, 100% 100%);
                    }

                    .voucher-discount {
                        font-family: 'Montserrat', sans-serif;
                        font-size: 2rem;
                        font-weight: 700;
                    }

                    .voucher-body {
                        padding: 30px 20px 20px;
                        flex-grow: 1;
                        display: flex;
                        flex-direction: column;
                        justify-content: space-between;
                    }

                    .points-cost {
                        display: inline-block;
                        background: #fff3e0;
                        color: #e65100;
                        padding: 5px 15px;
                        border-radius: 50px;
                        font-weight: 700;
                        font-size: 0.9rem;
                        margin-bottom: 15px;
                    }

                    .badge-free {
                        display: inline-block;
                        background: #e8f5e9;
                        color: #2e7d32;
                        padding: 5px 15px;
                        border-radius: 50px;
                        font-weight: 700;
                        font-size: 0.9rem;
                        margin-bottom: 15px;
                    }

                    .redeem-btn {
                        background: #383bff 0%;
                        border: none;
                        color: white;
                        font-weight: 600;
                        padding: 10px;
                        border-radius: 12px;
                        width: 100%;
                        transition: all 0.3s ease;
                    }

                    .redeem-btn:hover {
                        opacity: 0.9;
                        transform: translateY(-2px);
                    }

                    .redeem-btn:disabled {
                        background: #ccc;
                        cursor: not-allowed;
                        transform: none;
                    }

                    .my-voucher-code {
                        background: #f1f1f1;
                        padding: 10px;
                        border-radius: 8px;
                        font-family: monospace;
                        font-weight: 700;
                        font-size: 1.1rem;
                        text-align: center;
                        letter-spacing: 1px;
                        color: #333;
                        margin-bottom: 15px;
                        border: 1px dashed #ccc;
                    }

                    .points-badge {
                        background: white;
                        color: #d96c2c;
                        padding: 8px 20px;
                        border-radius: 50px;
                        font-weight: 700;
                        display: inline-flex;
                        align-items: center;
                        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                    }

                    .empty-state {
                        padding: 80px 0;
                        text-align: center;
                        color: #999;
                    }

                    .empty-state i {
                        font-size: 4rem;
                        margin-bottom: 20px;
                        opacity: 0.3;
                    }
                </style>
            </head>

            <body>

                <jsp:include page="/components/layout/Header.jsp" />
                <jsp:include page="/components/layout/Sidebar.jsp" />

                <div class="promo-header text-center">
                    <div class="container">
                        <h1 class="fw-bold mb-3">Ưu Đãi Đặc Quyền</h1>
                        <p class="lead opacity-75 mb-4">Sử dụng điểm tích lũy để đổi những phần quà hấp dẫn nhất.</p>
                        <div class="points-badge">
                            <i class="fa fa-coins me-2"></i> ${user.points} Điểm hiện có
                        </div>
                    </div>
                </div>

                <div class="container mb-5">
                    <div class="text-center">
                        <ul class="nav nav-pills nav-pills-custom" id="promoTabs" role="tablist">
                            <li class="nav-item">
                                <a class="nav-link active" id="public-tab" data-bs-toggle="pill" href="#public"
                                    role="tab">Voucher công khai</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="redeem-tab" data-bs-toggle="pill" href="#redeem" role="tab">Đổi
                                    điểm tích lũy</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="mybag-tab" data-bs-toggle="pill" href="#mybag"
                                    role="tab">Voucher của tôi</a>
                            </li>
                        </ul>
                    </div>

                    <div class="tab-content" id="promoTabsContent">
                        <!-- Public Vouchers Tab -->
                        <div class="tab-pane fade show active" id="public" role="tabpanel">
                            <div class="row g-4 justify-content-center">
                                <c:forEach var="v" items="${publicVouchers}">
                                    <div class="col-md-6 col-lg-4">
                                        <div class="voucher-card">
                                            <div class="voucher-top"
                                                style="background: linear-gradient(135deg, #ff9966 0%, #ff5e62 100%);">
                                                <div class="voucher-discount">
                                                    <fmt:formatNumber value="${v.discountAmount}" type="currency"
                                                        currencySymbol="đ" maxFractionDigits="0" />
                                                </div>
                                                <div class="small opacity-75">VOUCHER CÔNG KHAI</div>
                                            </div>
                                            <div class="voucher-body text-center">
                                                <div>
                                                    <h5 class="fw-bold mb-2">${v.voucherName}</h5>
                                                    <div class="badge-free">Miễn phí</div>
                                                    <p class="text-muted small mb-3">Lưu lại để sử dụng khi thanh toán.
                                                    </p>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/customer/promotions"
                                                    method="post">
                                                    <input type="hidden" name="action" value="savePublic">
                                                    <input type="hidden" name="voucherId" value="${v.voucherId}">
                                                    <button type="submit" class="redeem-btn"
                                                        style="background: #ff5e62;">
                                                        Lưu voucher
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty publicVouchers}">
                                    <div class="empty-state w-100">
                                        <i class="fa fa-bullhorn"></i>
                                        <h5>Hiện không có voucher công khai nào.</h5>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- Redeem Tab -->
                        <div class="tab-pane fade" id="redeem" role="tabpanel">
                            <div class="row g-4 justify-content-center">
                                <c:if test="${not empty loyaltyConfig && user.points < loyaltyConfig.minRedeemPoints}">
                                    <div class="col-12">
                                        <div class="alert alert-warning border-0 shadow-sm d-flex align-items-center"
                                            style="border-radius: 15px; background: rgba(255, 193, 7, 0.1);">
                                            <i class="fa fa-info-circle fa-2x me-3 text-warning"></i>
                                            <div>
                                                <h6 class="fw-bold mb-1 text-dark">Bạn chưa đủ điều kiện đổi quà</h6>
                                                <p class="mb-0 text-muted small">Cần đạt tối thiểu
                                                    <strong>${loyaltyConfig.minRedeemPoints} điểm</strong> để bắt đầu
                                                    đổi các ưu đãi đặc biệt. Hiện bạn đang có ${user.points} điểm.
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <c:forEach var="voucher" items="${loyaltyVouchers}">
                                    <div class="col-md-6 col-lg-4">
                                        <div class="voucher-card">
                                            <div class="voucher-top">
                                                <div class="voucher-discount">
                                                    <fmt:formatNumber value="${voucher.discountAmount}" type="currency"
                                                        currencySymbol="đ" maxFractionDigits="0" />
                                                </div>
                                                <div class="small opacity-75">GIẢM GIÁ TRỰC TIẾP</div>
                                            </div>
                                            <div class="voucher-body text-center">
                                                <div>
                                                    <h5 class="fw-bold mb-2">${voucher.voucherName}</h5>
                                                    <div class="points-cost">
                                                        <i class="fa fa-star me-1"></i> ${voucher.pointsCost} Điểm
                                                    </div>
                                                    <p class="text-muted small mb-4">Hạn dùng ${voucher.validDays} ngày
                                                        kể từ khi đổi.</p>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/customer/promotions"
                                                    method="post">
                                                    <input type="hidden" name="action" value="redeem">
                                                    <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                                    <c:set var="canRedeem"
                                                        value="${user.points >= loyaltyConfig.minRedeemPoints && user.points >= voucher.pointsCost}" />
                                                    <button type="submit" class="redeem-btn" ${!canRedeem ? 'disabled'
                                                        : '' }>
                                                        <c:choose>
                                                            <c:when
                                                                test="${user.points < loyaltyConfig.minRedeemPoints}">
                                                                Chưa đủ điều kiện</c:when>
                                                            <c:when test="${user.points < voucher.pointsCost}">Không đủ
                                                                điểm</c:when>
                                                            <c:otherwise>Đổi ngay</c:otherwise>
                                                        </c:choose>
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty loyaltyVouchers}">
                                    <div class="empty-state w-100">
                                        <i class="fa fa-gift"></i>
                                        <h5>Hiện không có voucher nào khả dụng để đổi.</h5>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- My Voucher Tab -->
                        <div class="tab-pane fade" id="mybag" role="tabpanel">
                            <div class="row g-4 justify-content-center">
                                <!-- User's Redeemed/Saved Vouchers -->
                                <c:forEach var="uv" items="${myVouchers}">
                                    <div class="col-md-6 col-lg-4">
                                        <div class="voucher-card" style="opacity: 0.9;">
                                            <div class="voucher-top"
                                                style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);">
                                                <div class="voucher-discount"><i class="fa fa-ticket-alt"></i></div>
                                                <div class="small opacity-75">VOUCHER CỦA BẠN</div>
                                            </div>
                                            <div class="voucher-body text-center">
                                                <div>
                                                    <div class="my-voucher-code">${uv.voucherCode}</div>
                                                    <p class="mb-1 fw-bold text-success">Trạng thái: ${uv.status}</p>
                                                    <p class="text-muted small">Hết hạn:
                                                        <fmt:parseDate value="${uv.expiresAt}"
                                                            pattern="yyyy-MM-dd'T'HH:mm" var="expDate" type="both" />
                                                        <fmt:formatDate value="${expDate}" pattern="dd/MM/yyyy" />
                                                    </p>
                                                </div>
                                                <button class="redeem-btn mt-3" style="background: #28a745;"
                                                    onclick="copyCode('${uv.voucherCode}')">
                                                    <i class="fa fa-copy me-2"></i> Sao chép mã
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty myVouchers}">
                                    <div class="empty-state w-100">
                                        <i class="fa fa-shopping-bag"></i>
                                        <h5>Túi đồ của bạn đang trống.</h5>
                                        <p>Hãy săn các voucher công khai hoặc đổi điểm nhé!</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <jsp:include page="/components/layout/Footer.jsp" />

                <!-- Toast Notifications -->
                <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1100">
                    <div id="statusToast" class="toast hide" role="alert" aria-live="assertive" aria-atomic="true">
                        <div class="toast-header">
                            <strong class="me-auto" id="toastTitle">Thông báo</strong>
                            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                        </div>
                        <div class="toast-body" id="toastBody"></div>
                    </div>
                </div>

                <!-- Scripts -->
                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script>
                    function copyCode(code) {
                        navigator.clipboard.writeText(code).then(() => {
                            alert("Đã sao chép mã: " + code);
                        });
                    }

                    document.addEventListener('DOMContentLoaded', function () {
                        const toastMsg = "${sessionScope.toastMessage}";
                        const toastType = "${sessionScope.toastType}";

                        if (toastMsg) {
                            const toastEl = document.getElementById('statusToast');
                            const toastBody = document.getElementById('toastBody');
                            const toastTitle = document.getElementById('toastTitle');

                            toastBody.innerText = toastMsg;
                            if (toastType === 'success') {
                                toastEl.classList.add('bg-success', 'text-white');
                                toastTitle.innerText = "Thành công";
                            } else if (toastType === 'error' || toastType === 'warning') {
                                toastEl.classList.add('bg-danger', 'text-white');
                                toastTitle.innerText = "Lỗi";
                            }

                            const toast = new bootstrap.Toast(toastEl);
                            toast.show();
                        }
                    });
                </script>
                <c:remove var="toastMessage" scope="session" />
                <c:remove var="toastType" scope="session" />
            </body>

            </html>