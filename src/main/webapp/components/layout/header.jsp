<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Header</title>
</head>
<body>

<div class="modal fade" id="exampleModal2" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content bg-dark border-0">
            <div class="modal-header border-0">
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="input-group">
                    <input type="text" class="form-control" placeholder="Search...">
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

        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">
            <i class="fa fa-modx text-warning"></i> Movie Theme
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">

            <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/home">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/about">
                        About Us
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/contact">
                        Contact Us
                    </a>
                </li>
            </ul>

            <ul class="navbar-nav mb-0">
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="modal" href="#exampleModal2">
                        <i class="fa fa-search"></i>
                    </a>
                </li>

                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle"
                       href="#"
                       role="button"
                       data-bs-toggle="dropdown">
                        <i class="fa fa-user"></i>
                        <c:if test="${not empty sessionScope.user}">
                            <span class="ms-1">${sessionScope.user.username}</span>
                        </c:if>
                    </a>

                    <ul class="dropdown-menu dropdown-menu-end end-0">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                        Profile
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                                        Logout
                                    </a>
                                </li>
                            </c:when>
                            <c:otherwise>
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/login">
                                        Login
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/register">
                                        Register
                                    </a>
                                </li>
                            </c:otherwise>
                        </c:choose>
                    </ul>
                </li>
            </ul>

        </div>
    </div>
</nav>

</body>
</html>
