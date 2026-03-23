<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8">
            <title>Lịch Chiếu - MBCMS</title>
            <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
            <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
            <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
            <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Platypi:ital,wght@0,300..800;1,300..800&display=swap"
                rel="stylesheet">
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
            <link href="${pageContext.request.contextPath}/css/showtime.css?v=1.1" rel="stylesheet">
            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>

            <style>
                body {
                    background-color: #111 !important;
                    margin: 0;
                    padding: 0;
                }

                .main {
                    padding-top: 140px;
                    background-color: #111;
                    min-height: 100vh;
                }

                .page-title {
                    color: #d96c2c;
                    font-size: 3rem;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                }

                .dark-card {
                    background-color: #1a1a1a !important;
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5) !important;
                }

                .dark-select {
                    background-color: #222 !important;
                    color: #fff !important;
                    border: 1px solid #333 !important;
                    border-radius: 10px;
                }

                .dark-select:focus {
                    border-color: #d96c2c !important;
                    box-shadow: 0 0 0 0.25rem rgba(217, 108, 44, 0.25) !important;
                }

                .section-label {
                    color: #d96c2c;
                    font-weight: 600;
                    margin-bottom: 12px;
                    display: block;
                    font-size: 0.9rem;
                    text-transform: uppercase;
                }
            </style>

        </head>

        <body>

            <jsp:include page="/components/layout/Sidebar.jsp" />
            <jsp:include page="/components/layout/Header.jsp" />

            <div class="main clearfix position-relative">
                <div class="container">
                    <div class="row mb-5">
                        <div class="col-12 text-center">
                            <h1 class="page-title fw-bold">Lịch Chiếu Phim</h1>
                            <div class="mx-auto"
                                style="width: 60px; height: 3px; background: #d96c2c; margin-top: 10px;"></div>
                            <p class="text-muted mt-3">Khám phá trải nghiệm điện ảnh tuyệt vời tại hệ thống rạp MBCMS
                            </p>
                        </div>
                    </div>

                    <div class="row mb-5">
                        <div class="col-lg-10 mx-auto">
                            <div class="p-4 dark-card rounded-4">
                                <div class="row align-items-end">
                                    <div class="col-md-9 mb-3 mb-md-0">
                                        <label class="section-label">Lọc theo rạp</label>
                                        <select id="branchSelect" class="form-select form-select-lg dark-select">
                                            <option value="" disabled selected>-- Chọn rạp để xem lịch chiếu --</option>
                                            <c:forEach var="branch" items="${branches}">
                                                <option value="${branch.branchId}">${branch.branchName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <button id="resetBtn" class="btn btn-lg w-100 py-2">
                                            <i class="fa fa-refresh me-2"></i>Đặt lại
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="dateBarContainer" style="display: none;" class="mb-5">
                        <h5 class="mb-3 fw-bold" style="color: #ccc;">Chọn ngày chiếu:</h5>
                        <div class="date-bar" id="dateBar">
                            <c:forEach var="date" items="${dates}" varStatus="status">
                                <div class="date-item ${status.index == 0 ? 'active' : ''}"
                                    data-date="${date.fullDate}">
                                    <div class="day-name">${date.dayName}</div>
                                    <div class="date-val">${date.dayStr}</div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <div id="showtimesGrid">
                        <div class="text-center p-5 dark-card rounded">
                            <i class="fa fa-film fa-4x text-muted mb-3 opacity-50"></i>
                            <h4 class="text-muted">Vui lòng chọn rạp để xem lịch chiếu</h4>
                        </div>
                    </div>
                </div>
            </div>

            <jsp:include page="/components/layout/Footer.jsp" />

            <script>
                $(document).ready(function () {
                    $('#branchSelect').change(function () {
                        $('#dateBarContainer').slideDown();
                        loadSchedule();
                    });

                    $('#resetBtn').click(function () {
                        $('#branchSelect').val('');
                        $('#dateBarContainer').slideUp();
                        // Cập nhật lại HTML của trạng thái rỗng cho khớp giao diện tối
                        $('#showtimesGrid').html('<div class="text-center p-5 dark-card rounded"><i class="fa fa-film fa-4x text-muted mb-3 opacity-50"></i><h4 class="text-muted">Vui lòng chọn rạp để xem lịch chiếu</h4></div>');
                    });

                    $(document).on('click', '.date-item', function () {
                        $('.date-item').removeClass('active');
                        $(this).addClass('active');
                        loadSchedule();
                    });
                });

                function loadSchedule() {
                    var branchId = $('#branchSelect').val();
                    var date = $('.date-item.active').data('date');

                    if (!branchId || !date) return;

                    $.ajax({
                        url: '${pageContext.request.contextPath}/showtimes',
                        type: 'GET',
                        data: { branchId: branchId, date: date },
                        success: function (htmlResponse) {
                            $('#showtimesGrid').html(htmlResponse);
                        }
                    });
                }
            </script>

        </body>

        </html>