<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 1/15/2026
  Time: 7:43 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<div class="modal fade" id="exampleModal2" tabindex="-1" aria-labelledby="exampleModalLabel" style="display: none; top:0;" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content bg-transparent border-0">
            <div class="modal-header border-0">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"><i class="fa fa-close"></i></button>
            </div>
            <div class="modal-body p-0">
                <div class="search_1">
                    <div class="input-group">
                        <input type="text" class="form-control bg-white border-0" placeholder="Search...">
                        <span class="input-group-btn">
					<button class="btn btn-primary bg_oran border_1 rounded-0 p-3 px-4" type="button">
						<i class="fa fa-search"></i></button>
				</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="main_1 clearfix position-absolute top-0 w-100">
    <section id="header">
        <nav class="navbar navbar-expand-md navbar-light px_4" id="navbar_sticky">
            <div class="container-fluid">
                <a class="navbar-brand  p-0 fw-bold text-white" href="index.html"><i class="fa fa-modx col_oran"></i> Movie Theme </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarSupportedContent">
                    <ul class="navbar-nav mb-0 ms-auto">

                        <li class="nav-item">
                            <a class="nav-link active" aria-current="page" href="index.html">Home</a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="about.html">About Us</a>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                Movies
                            </a>
                            <ul class="dropdown-menu drop_1" aria-labelledby="navbarDropdown">
                                <li><a class="dropdown-item" href="movies.html"><i class="fa fa-chevron-right font_12 me-1"></i> Movies</a></li>
                                <li><a class="dropdown-item border-0" href="detail.html"><i class="fa fa-chevron-right font_12 me-1"></i> Movie Details</a></li>
                            </ul>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                Blogs
                            </a>
                            <ul class="dropdown-menu drop_1" aria-labelledby="navbarDropdown">
                                <li><a class="dropdown-item" href="blog.html"><i class="fa fa-chevron-right font_12 me-1"></i> Blogs</a></li>
                                <li><a class="dropdown-item border-0" href="blog_detail.html"><i class="fa fa-chevron-right font_12 me-1"></i> Blog Details</a></li>
                            </ul>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                Pages
                            </a>
                            <ul class="dropdown-menu drop_1" aria-labelledby="navbarDropdown">
                                <li><a class="dropdown-item" href="faq.html"><i class="fa fa-chevron-right font_12 me-1"></i> Faqs</a></li>
                                <li><a class="dropdown-item" href="login.html"><i class="fa fa-chevron-right font_12 me-1"></i> Login</a></li>
                                <li><a class="dropdown-item" href="register.html"><i class="fa fa-chevron-right font_12 me-1"></i> Register</a></li>
                                <li><a class="dropdown-item border-0" href="ticket.html"><i class="fa fa-chevron-right font_12 me-1"></i> Ticket</a></li>
                            </ul>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="contact.html">Contact Us</a>
                        </li>
                    </ul>
                    <ul class="navbar-nav mb-0 ms-auto">
                        <li class="nav-item">
                            <a class="nav-link fs-5 drop_icon" data-bs-target="#exampleModal2" data-bs-toggle="modal" href="#"><i class="fa fa-search"></i></a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link fs-5 drop_icon" href="#"><i class="fa fa-user"></i></a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </section>
</div>
</body>
</html>
