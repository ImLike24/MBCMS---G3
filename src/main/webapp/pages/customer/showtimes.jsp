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
            <link href="${pageContext.request.contextPath}/css/showtime.css" rel="stylesheet">
            <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>

            <style>
                /* Tổng thể text */
                body {
                    background-color: #111111;
                    color: #e0e0e0;
                }
                h1, h2, h3, h4, h5, h6 {
                    color: #ffffff;
                }
                .text-muted {
                    color: #9e9e9e !important;
                }

                /* Khối Filter và Empty State (Card tối màu) */
                .dark-card {
                    background-color: #181818 !important;
                    border: 1px solid #2a2a2a;
                    box-shadow: 0 4px 15px rgba(0,0,0,0.6) !important;
                }

                /* Override ô Select */
                .form-select.dark-select {
                    background-color: #1a1a1a;
                    color: #ffffff;
                    border: 1px solid #333;
                }

                .form-select.dark-select:focus {
                    border-color: #d96c2c;
                    box-shadow: 0 0 0 0.25rem rgba(217, 108, 44, 0.25);
                    background-color: #1a1a1a;
                }

                /* Nút Reset */
                .btn-dark-outline {
                    color: #bbb;
                    border-color: #333;
                }

                .btn-dark-outline:hover {
                    background-color: #222;
                    color: #fff;
                    border-color: #d96c2c;
                }

                /* Thanh chọn ngày (Date Bar) */
                .date-bar {
                    display: flex;
                    gap: 15px;
                    overflow-x: auto;
                    padding-bottom: 10px;
                }
                .date-item {
                    background-color: #181818;
                    border: 1px solid #2a2a2a;
                }

                .date-item:hover {
                    background-color: #222;
                    border-color: #555;
                }

                .date-item.active {
                    background-color: #d96c2c;
                    border-color: #d96c2c;
                    color: #ffffff;
                }
                .date-item .day-name {
                    font-size: 0.85rem;
                    color: #9e9e9e;
                    margin-bottom: 4px;
                }
                .date-item.active .day-name {
                    color: #fff1e6;
                }
                .date-item .date-val {
                    font-size: 1.3rem;
                    font-weight: bold;
                }

                /* Ẩn scrollbar cho đẹp */
                .date-bar::-webkit-scrollbar {
                    height: 6px;
                }
                .date-bar::-webkit-scrollbar-thumb {
                    background-color: #444;
                    border-radius: 10px;
                }
            </style>

        </head>

        <body>

            <jsp:include page="/components/layout/Sidebar.jsp" />
            <jsp:include page="/components/layout/Header.jsp" />

            <div class="main clearfix position-relative" style="margin-top: 100px; min-height: 600px;">
                <div class="container-xl">
                    <div class="row mb-4">
                        <div class="col-12 text-center">
                            <h1 class="mb-0 font_50 fw-bold">Lịch Chiếu Phim</h1>
                            <p class="text-muted mt-2">Xem lịch chiếu mới nhất tại các rạp</p>
                        </div>
                    </div>

                    <div class="row mb-5 p-4 dark-card rounded">
                        <div class="col-md-10 mb-3 mb-md-0">
                            <label for="branchSelect" class="form-label fw-bold" style="color: #ccc;">Chọn Rạp</label>
                            <select id="branchSelect" class="form-select form-select-lg dark-select">
                                <option value="" disabled selected>-- Vui lòng chọn Rạp --</option>
                                <c:forEach var="branch" items="${branches}">
                                    <option value="${branch.branchId}">${branch.branchName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button id="resetBtn" class="btn btn-dark-outline w-100 btn-lg">
                                <i class="fa fa-refresh me-2"></i>Đặt lại
                            </button>
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