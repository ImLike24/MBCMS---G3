<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="utf-8">
                <title>${movie.title}</title>
                <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
                <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
                <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
                <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Platypi:ital,wght@0,300..800;1,300..800&display=swap"
                    rel="stylesheet">
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
                <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

                <style>
                    .movie-detail-container {
                        padding-top: 120px;
                        padding-bottom: 60px;
                        min-height: 100vh;
                        background: #fff;
                        background-size: cover;
                    }

                    .movie-card {
                        background: #212529;
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        border-radius: 15px;
                        padding: 30px;
                        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
                    }

                    .poster-wrapper {
                        position: relative;
                        overflow: hidden;
                        border-radius: 10px;
                        box-shadow: 0 10px 30px rgba(217, 108, 44, 0.3);
                        transition: transform 0.3s ease;
                    }

                    .poster-wrapper:hover {
                        transform: scale(1.02);
                    }

                    .poster-img {
                        width: 100%;
                        height: auto;
                        border-radius: 10px;
                    }

                    .movie-title {
                        font-size: 3.5rem;
                        font-weight: 700;
                        color: #fff;
                        margin-bottom: 10px;
                        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
                    }

                    .movie-meta {
                        font-size: 1.1rem;
                        color: #ccc;
                        margin-bottom: 20px;
                    }

                    .meta-item {
                        display: inline-block;
                        margin-right: 20px;
                    }

                    .meta-item i {
                        color: #d96c2c;
                        margin-right: 5px;
                    }

                    .rating-badge {
                        background-color: #d96c2c;
                        color: #fff;
                        padding: 5px 10px;
                        border-radius: 5px;
                        font-weight: bold;
                    }

                    .section-title {
                        font-size: 1.5rem;
                        color: #d96c2c;
                        margin-top: 30px;
                        margin-bottom: 15px;
                        border-bottom: 2px solid #d96c2c;
                        display: inline-block;
                        padding-bottom: 5px;
                    }

                    .btn-book {
                        background-color: #d96c2c;
                        color: #fff;
                        padding: 15px 40px;
                        font-size: 1.2rem;
                        border-radius: 50px;
                        text-transform: uppercase;
                        font-weight: bold;
                        letter-spacing: 1px;
                        transition: all 0.3s ease;
                        display: inline-block;
                        margin-top: 30px;
                        border: 2px solid #d96c2c;
                    }

                    .btn-book:hover {
                        background-color: transparent;
                        color: #d96c2c;
                        box-shadow: 0 0 15px rgba(217, 108, 44, 0.5);
                    }

                    .btn-load {
                        background-color: #fff;
                        color: #212529;
                        border: 1px solid #212529;
                        border-radius: 10px;
                        padding: 5px 10px;
                        transition: all 0.3s ease;
                    }

                    .btn-load:hover {
                        background-color: #212529;
                        color: #fff
                    }

                    .star-rating .star-icon {
                        font-size: 1rem;
                        cursor: pointer;
                        margin-right: 5px;
                        color: #fff;
                        -webkit-text-stroke: 1px #ffc107;
                        transition: all 0.2s ease;
                    }

                    .star-rating .star-icon.hovered {
                        color: #ffc107;
                    }

                    .star-rating .star-icon.selected {
                        color: #ffc107;
                    }
                </style>
            </head>

            <body>

                <!-- Header -->
                <jsp:include page="/components/layout/Header.jsp" />

                <div class="movie-detail-container">
                    <div class="container">
                        <div class="movie-card">
                            <div class="row">
                                <!-- Left Column: Poster -->
                                <div class="col-lg-4 col-md-5 mb-4 mb-md-0">
                                    <div class="poster-wrapper">
                                        <img src="${movie.posterUrl}" class="poster-img">
                                    </div>
                                </div>

                                <!-- Right Column: Details -->
                                <div class="col-lg-8 col-md-7">
                                    <h1 class="movie-title">${movie.title}</h1>

                                    <div class="movie-meta">
                                        <span class="meta-item"><i class="fa fa-calendar"></i>
                                            ${movie.releaseDate}</span>
                                        <span class="meta-item"><i class="fa fa-clock-o"></i> ${movie.duration}
                                            min</span>
                                        <span class="meta-item"><span class="rating-badge"><i class="fa fa-star"></i>
                                                ${movie.rating}</span></span>
                                        <span class="meta-item"
                                            style="border: 1px solid #777; padding: 2px 8px; border-radius: 4px;">${movie.ageRating}</span>
                                    </div>

                                    <p class="lead" style="color: #fff;">${movie.description}</p>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <h4 class="section-title">Đạo diễn</h4>
                                            <p class="text-light">${movie.director}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <h4 class="section-title">Thể loại</h4>
                                            <p class="text-light">${movie.genre}</p>
                                        </div>
                                    </div>

                                    <div>
                                        <h4 class="section-title">Diễn Viên</h4>
                                        <p class="text-light">${movie.cast}</p>
                                    </div>

                                    <c:if test="${movie.active}">
                                        <a href="${pageContext.request.contextPath}/booking?movieId=${movie.movieId}"
                                            class="btn-book"> Đặt vé ngay <i class="fa fa-ticket ms-2"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${!movie.active}">
                                        <button class="btn btn-secondary btn-lg mt-4" disabled>Phim đã dừng chiếu</button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                        <!-- Review Section -->
                        <div class="row mt-5">
                            <div class="col-12">
                                <h3 class="section-title">Đánh giá phim</h3>
                            </div>

                            <!-- Review Form  -->
                            <c:if test="${sessionScope.user != null}">
                                <div class="col-12 mb-4">
                                    <div class="card bg-dark border-secondary">
                                        <div class="card-body">
                                            <h5 class="card-title text-warning">Viết đánh giá</h5>
                                            <form action="movie" method="post">
                                                <input type="hidden" name="movieId" value="${movie.movieId}">
                                                <div>
                                                    <div class="star-rating mb-2">
                                                        <i class="fa fa-star star-icon" data-value="1"></i>
                                                        <i class="fa fa-star star-icon" data-value="2"></i>
                                                        <i class="fa fa-star star-icon" data-value="3"></i>
                                                        <i class="fa fa-star star-icon" data-value="4"></i>
                                                        <i class="fa fa-star star-icon" data-value="5"></i>
                                                    </div>
                                                    <input type="hidden" name="rating" id="ratingInput" value="0">
                                                </div>
                                                <div class="mb-3">
                                                    <textarea class="form-control bg-light text-secondary border-0"
                                                        name="comment" rows="3"
                                                        placeholder="Hãy viết cảm nhận của bạn về bộ phim này..."></textarea>
                                                </div>
                                                <button type="submit" class="btn btn-warning">Đánh giá</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${sessionScope.user == null}">
                                <div class="col-12 mb-4">
                                    <div class="alert alert-dark border-secondary">
                                        Please <a href="${pageContext.request.contextPath}/login"
                                            class="text-warning">login</a> to write a review.
                                    </div>
                                </div>
                            </c:if>

                            <!-- Reviews List -->
                            <div class="col-12" id="reviewsList">
                                <jsp:include page="/components/fragments/list-reviews.jsp" />

                                <c:if test="${reviews.isEmpty()}">
                                    <p class="text-muted" id="noReviewsMsg">No reviews yet. Be the first to review!</p>
                                </c:if>
                            </div>

                            <!-- Load More Button -->
                            <div class="col-12 text-center mt-3">
                                <button id="loadMoreBtn" class="btn-load" onclick="loadMoreReviews()">
                                    Load More Reviews
                                </button>
                                <p id="noMoreReviews" class="text-dark mt-2" style="display:none;">No more reviews.</p>
                            </div>
                        </div>
                    </div>
                </div>
                </div>

                <script>
                    var currentOffset = ${ reviews != null ? reviews.size() : 0};
                    var limit = 3;
                    var movieId = ${ movie.movieId };

                    function loadMoreReviews() {
                        $('#loadMoreBtn').prop('disabled', true).text('Loading...');

                        $.ajax({
                            url: '${pageContext.request.contextPath}/load-reviews',
                            type: 'GET',
                            data: {
                                movieId: movieId,
                                offset: currentOffset,
                                limit: limit
                            },
                            success: function (response) {
                                var trimmedResponse = response.trim();
                                if (trimmedResponse.length > 0) {
                                    $('#reviewsList').append(response);

                                    var newItemsCount = (response.match(/class="card/g) || []).length;
                                    currentOffset += newItemsCount;

                                    if (newItemsCount < limit) {
                                        $('#loadMoreBtn').hide();
                                        $('#noMoreReviews').show();
                                    } else {
                                        $('#loadMoreBtn').prop('disabled', false).text('Load More Reviews');
                                    }
                                } else {
                                    $('#loadMoreBtn').hide();
                                    $('#noMoreReviews').show();
                                }
                            },
                            error: function () {
                                $('#loadMoreBtn').prop('disabled', false).text('Load More Reviews');
                            }
                        });
                    }

                   
                    // Star Rating Interaction
                    $(document).ready(function () {
                        const stars = $('.star-icon');
                        const ratingInput = $('#ratingInput');

                        // Hover effect
                        stars.on('mouseenter', function () {
                            const value = $(this).data('value');
                            highlightStars(value, 'hovered');
                        });

                        stars.on('mouseleave', function () {
                            stars.removeClass('hovered');
                        });

                        // Click to select
                        stars.on('click', function () {
                            const value = $(this).data('value');
                            ratingInput.val(value);
                            stars.removeClass('selected');
                            highlightStars(value, 'selected');
                        });

                        function highlightStars(count, className) {
                            stars.each(function () {
                                if ($(this).data('value') <= count) {
                                    $(this).addClass(className);
                                }
                            });
                        }
                    });

                    const urlParams = new URLSearchParams(window.location.search);
                    const message = urlParams.get('message');

                    if (message) {
                        const savedScroll = sessionStorage.getItem('scrollPosition');
                        if (savedScroll) {
                            window.scrollTo(0, parseInt(savedScroll));
                            sessionStorage.removeItem('scrollPosition');
                        }
                    }

                    if (message === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Review posted successfully!',
                            confirmButtonColor: '#d96c2c'
                        });
                        // Optional: Clean URL
                        window.history.replaceState({}, document.title, window.location.pathname + "?movieId=" + movieId);
                    } else if (message === 'invalid_rating_or_comment') {
                        Swal.fire({
                            icon: 'error',
                            title: 'Oops...',
                            text: 'Invalid Review: Please provide a rating greater than 0 and a non-empty comment.',
                            confirmButtonColor: '#d96c2c'
                        });
                        // Optional: Clean URL
                        window.history.replaceState({}, document.title, window.location.pathname + "?movieId=" + movieId);
                    }

                    $('form[action="movie"]').on('submit', function () {
                        sessionStorage.setItem('scrollPosition', window.scrollY);
                    });
                </script>

                <!-- Footer -->

                <script src="${pageContext.request.contextPath}/js/common.js"></script>
            </body>

            </html>