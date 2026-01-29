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

                <style>
                    body {
                        background-color: #0c121d;
                        color: #fff;
                    }

                    .movie-detail-container {
                        padding-top: 120px;
                        padding-bottom: 60px;
                        min-height: 100vh;
                        background: linear-gradient(180deg, rgba(12, 18, 29, 0.8) 0%, rgba(12, 18, 29, 1) 100%),
                        url('${movie.posterUrl}') no-repeat center center fixed;
                        background-size: cover;
                    }

                    .movie-card {
                        background: rgba(0, 0, 0, 0.6);
                        backdrop-filter: blur(10px);
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
                </style>
            </head>

            <body>

                <!-- Header Section -->
                <jsp:include page="/components/layout/header.jsp" />

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
                                            <h4 class="section-title">Director</h4>
                                            <p>${movie.director}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <h4 class="section-title">Genre</h4>
                                            <p>${movie.genre}</p>
                                        </div>
                                    </div>

                                    <div>
                                        <h4 class="section-title">Cast</h4>
                                        <p>${movie.cast}</p>
                                    </div>

                                    <c:if test="${movie.active}">
                                        <a href="${pageContext.request.contextPath}/booking?movieId=${movie.movieId}"
                                            class="btn-book">
                                            Book Now <i class="fa fa-ticket ms-2"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${!movie.active}">
                                        <button class="btn btn-secondary btn-lg mt-4" disabled>Not Available</button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Footer could be included here if available -->

                <script src="${pageContext.request.contextPath}/js/common.js"></script>
            </body>

            </html>