<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
</head>
<body>
    <jsp:include page="/components/layout/Sidebar.jsp" />
<div class="modal fade" id="exampleModal2" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content bg-dark border-0">
            <div class="modal-header border-0">
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="input-group">
                    <input type="text" id="searchBox"
                           class="form-control form-control-lg"
                           placeholder="Search movies..."
                           style="border:2px solid #d96c2c;">
                    <div id="searchSuggest" class="list-group position-absolute w-100"></div>
                    <button class="btn btn-warning" type="button">
                        <i class="fa fa-search"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
        <button class="hamburger" onclick="toggleSidebar()">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">
            <i class="fa fa-modx text-warning"></i>
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">



            <ul class="navbar-nav mb-0">
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="modal" href="#exampleModal2">
                        <i class="fa fa-search"></i>
                    </a>
                </li>

                
            </ul>

        </div>
    </div>
</nav>

</body>
</html>