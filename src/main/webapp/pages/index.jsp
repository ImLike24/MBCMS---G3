<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Header</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet" >
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet" >
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Platypi:ital,wght@0,300..800;1,300..800&display=swap" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <style>
        :root {
            --dark: #212529;
            --orange: #d96c2c;
        }

        body {
            background: #111;
            color: #fff;
        }

        /* HERO */
        .hero {
            background: linear-gradient(120deg, #000, #212529);
            padding: 60px;
            border-radius: 12px;
            margin-bottom: 40px;
        }

        /* SECTION */
        .section-title {
            border-left: 6px solid var(--orange);
            padding-left: 12px;
            margin: 40px 0 20px;
            font-size: 26px;
            font-weight: bold;
        }

        /* MOVIE CARD */
        .movie-card {
            background: var(--dark);
            border-radius: 12px;
            overflow: hidden;
            transition: 0.3s;
        }

        .movie-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 10px 25px rgba(217,108,44,0.3);
        }

        .movie-card img {
            width: 100%;
            height: 280px;
            object-fit: cover;
        }

        .movie-info {
            padding: 12px;
        }

        .movie-title {
            font-weight: bold;
            font-size: 16px;
        }

        .movie-rating {
            color: var(--orange);
        }
    </style>
</head>

<body>

<!-- Header Section -->
<jsp:include page="/components/layout/Header.jsp" />

<div class="container">

    <!-- HERO -->
    <div class="hero">
        <h1>🎬 Welcome to <span style="color:#d96c2c">MyCinema</span></h1>
        <p>Book tickets fast. Discover movies. Enjoy the show.</p>
    </div>

    <!-- NOW SHOWING -->
    <div class="section-title">Now Showing</div>
    <div class="row">
        <c:forEach var="m" items="${nowShowing}">
            <div class="col-md-3 mb-4">
                <div class="movie-card">
                    <img src="${m.posterUrl}" alt="${m.title}">
                    <div class="movie-info">
                        <div class="movie-title">${m.title}</div>
                        <div class="movie-rating">⭐ ${m.rating}</div>
                        <a href="movie-detail?id=${m.movieId}" class="btn btn-sm btn-warning mt-2">
                            Book Now
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- COMING SOON -->
    <div class="section-title">Coming Soon</div>
    <div class="row">
        <c:forEach var="m" items="${comingSoon}">
            <div class="col-md-3 mb-4">
                <div class="movie-card">
                    <img src="${m.posterUrl}">
                    <div class="movie-info">
                        <div class="movie-title">${m.title}</div>
                        <span class="badge bg-secondary">Coming Soon</span>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- TOP RATED -->
    <div class="section-title">Top Rated</div>
    <div class="row">
        <c:forEach var="m" items="${topRated}">
            <div class="col-md-3 mb-4">
                <div class="movie-card">
                    <img src="${m.posterUrl}">
                    <div class="movie-info">
                        <div class="movie-title">${m.title}</div>
                        <div class="movie-rating">⭐ ${m.rating}</div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

</div>

<!-- Footer Section -->
<jsp:include page="/components/layout/Footer.jsp"/>

<!-- Video Modal -->
<div class="modal fade" id="templateVideoModal" tabindex="-1" aria-labelledby="videoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title" id="videoModalLabel">  Video</h2>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- YouTube Embed -->
                <div class="ratio ratio-16x9">
                    <iframe id="youtubeVideo" src="" title="YouTube video player" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope" loading="lazy" allowfullscreen></iframe>
                </div>


            </div>

        </div>
    </div>
</div>
<!-- JavaScript to pause the video when modal is closed -->
<script>
    var templateVideoModal = document.getElementById('templateVideoModal');
    templateVideoModal.addEventListener('hide.bs.modal', function () {
        var iframe = document.getElementById('youtubeVideo');
        iframe.src = '';
    });

    templateVideoModal.addEventListener('show.bs.modal', function () {
        var iframe = document.getElementById('youtubeVideo');
        iframe.src = 'https://www.youtube.com/embed/xHYMdZvV1f0?autoplay=1';
    });
</script>

<script src="js/common.js"></script>

</body>


</html>