<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.Movie"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Movies - Admin</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
</head>
<body class="bg-light">

    <!-- Header -->
    <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

    <div class="d-flex">
        <!-- Sidebar -->
        <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp" />

        <!-- Main Content -->
        <main class="flex-fill p-4">
            <div class="container-fluid">

                <h3 class="mb-4">
                    <i class="fa fa-film"></i> Manage Movies
                </h3>

                <!-- Add Movie Card -->
                <div class="card mb-4">
                    <div class="card-header">
                        Add New Movie
                    </div>
                    <div class="card-body">
                        <form action="ManageMovie" method="post" class="row g-3">
                            <input type="hidden" name="action" value="add"/>

                            <div class="col-md-4">
                                <label class="form-label">Title</label>
                                <input type="text" name="title" class="form-control" required>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label">Genre</label>
                                <input type="text" name="genre" class="form-control" required>
                            </div>

                            <div class="col-md-2">
                                <label class="form-label">Duration (min)</label>
                                <input type="number" name="duration" class="form-control" required>
                            </div>

                            <div class="col-md-2">
                                <label class="form-label">Rating</label>
                                <input type="number" step="0.1" name="rating" class="form-control" value="0">
                            </div>

                            <div class="col-md-1 d-flex align-items-end">
                                <button class="btn btn-primary w-100">
                                    <i class="fa fa-plus"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Movie List -->
                <div class="card">
                    <div class="card-header">
                        Movie List
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped table-hover mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Genre</th>
                                    <th>Duration</th>
                                    <th>Rating</th>
                                    <th width="120">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                                    if (movies != null && !movies.isEmpty()) {
                                        for (Movie m : movies) {
                                %>
                                <tr>
                                    <td><%= m.getMovieId() %></td>
                                    <td><%= m.getTitle() %></td>
                                    <td><%= m.getGenre() %></td>
                                    <td><%= m.getDuration() %> min</td>
                                    <td><%= m.getRating() %></td>
                                    <td>
                                        <form action="ManageMovie" method="post">
                                            <input type="hidden" name="action" value="delete"/>
                                            <input type="hidden" name="id" value="<%= m.getMovieId() %>"/>
                                            <button class="btn btn-sm btn-danger"
                                                    onclick="return confirm('Delete this movie?')">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-3">
                                        No movies found
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

</body>
</html>
