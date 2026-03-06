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

        </head>

        <body>

            <jsp:include page="/components/layout/Sidebar.jsp" />
            <jsp:include page="/components/layout/Header.jsp" />

            <div class="main clearfix position-relative" style="margin-top: 100px; min-height: 600px;">
                <div class="container-xl">
                    <div class="row mb-4">
                        <div class="col-12 text-center">
                            <h1 class="mb-0 font_50">Lịch Chiếu Phim</h1>
                            <p class="text-muted">Xem lịch chiếu mới nhất tại các rạp</p>
                        </div>
                    </div>

                    <!-- Filter Bar -->
                    <div class="row mb-4 p-4 bg-light rounded shadow-sm">
                        <div class="col-md-10 mb-3 mb-md-0">
                            <label for="branchSelect" class="form-label fw-bold">Chọn Rạp</label>
                            <select id="branchSelect" class="form-select form-select-lg">
                                <option value="" disabled selected>-- Vui lòng chọn Rạp --</option>
                                <c:forEach var="branch" items="${branches}">
                                    <option value="${branch.branchId}">${branch.branchName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button id="resetBtn" class="btn btn-outline-secondary w-100 btn-lg">Đặt lại</button>
                        </div>
                    </div>

                    <div id="dateBarContainer" style="display: none;">
                        <h5 class="mb-3">Chọn ngày chiếu:</h5>
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
                        <div class="text-center p-5 bg-light rounded">
                            <i class="fa fa-film fa-3x text-muted mb-3"></i>
                            <h4>Vui lòng chọn rạp để xem lịch chiếu</h4>
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
                        $('#showtimesGrid').html('<div class="text-center p-5 bg-light rounded"><i class="fa fa-film fa-3x text-muted mb-3"></i><h4>Vui lòng chọn rạp để xem lịch chiếu</h4></div>');
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