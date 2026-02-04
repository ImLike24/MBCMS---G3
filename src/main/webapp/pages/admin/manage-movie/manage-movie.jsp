<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.Movie"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movies Management - Admin</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">

</head>
<body class="bg-light">

<!-- Header (fixed) -->
<jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

<div class="d-flex" style="padding-top:50px;">
    
    <!-- Sidebar -->
    <jsp:include page="/components/layout/dashboard/admin_sidebar.jsp" />

    <!-- Main Content -->
    <main class="flex-fill p-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3 class="fw-bold">
                <i class="fa fa-film me-2"></i>Movie Management
            </h3>

            <!-- CREATE -->
            <a href="#" class="btn btn-success">
                <i class="fa fa-plus"></i> Add Movie
            </a>
        </div>

        <!-- Movie Table -->
        <div class="card shadow-sm">
            <div class="card-body p-0">

                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Title</th>
                            <th>Genre</th>
                            <th>Duration</th>
                            <th>Rating</th>
                            <th>Status</th>
                            <th class="text-center" width="160">Actions</th>
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
                            <td class="fw-semibold"><%= m.getTitle() %></td>
                            <td><%= m.getGenre() %></td>
                            <td><%= m.getDuration() %> min</td>
                            <td><%= m.getRating() %></td>
                            <td>
                                <span class="badge <%= m.isActive() ? "bg-success" : "bg-secondary" %>">
                                    <%= m.isActive() ? "ACTIVE" : "INACTIVE" %>
                                </span>
                            </td>

                            <!-- CRUD BUTTONS -->
                            <td class="text-center">
                                <!-- DETAIL -->
                                <a href="MovieDetail?id=<%= m.getMovieId() %>"
                                   class="btn btn-sm btn-outline-info me-1"
                                   title="View">
                                    <i class="fa fa-eye"></i>
                                </a>

                                <!-- EDIT -->
                                <a href="MovieEdit?id=<%= m.getMovieId() %>"
                                   class="btn btn-sm btn-outline-warning me-1"
                                   title="Edit">
                                    <i class="fa fa-pencil"></i>
                                </a>

                                <!-- DELETE -->
                                <a href="MovieDelete?id=<%= m.getMovieId() %>"
                                   class="btn btn-sm btn-outline-danger"
                                   title="Delete"
                                   onclick="return confirm('Delete this movie?')">
                                    <i class="fa fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                No movies found
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>

            </div>
        </div>

    </main>
</div>

</body>


</html>
