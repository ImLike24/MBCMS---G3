<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>User Profile</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet" >
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet" >
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Platypi:ital,wght@0,300..800;1,300..800&display=swap" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f8;
        }

        .profile-card {
            width: 420px;
            margin: 80px auto;
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .avatar {
            text-align: center;
            margin-bottom: 16px;
        }

        .avatar img {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #ddd;
        }

        h2 {
            text-align: center;
            margin-bottom: 20px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }

        .label {
            color: #666;
        }

        .value {
            font-weight: 500;
        }

        .points {
            color: #ff9800;
            font-weight: bold;
        }
    </style>
</head>

<body>

<!-- HEADER -->
<jsp:include page="/components/layout/header.jsp" />

<!-- PROFILE -->
<div class="profile-card">

    <div class="avatar">
        <img src="${empty u.avatarUrl ? 'assets/default-avatar.png' : u.avatarUrl}">
    </div>

    <h2>${u.fullName}</h2>

    <div class="info-row">
        <span class="label">Username</span>
        <span class="value">${u.username}</span>
    </div>

    <div class="info-row">
        <span class="label">Email</span>
        <span class="value">${u.email}</span>
    </div>

    <div class="info-row">
        <span class="label">Phone</span>
        <span class="value">${u.phone}</span>
    </div>

    <div class="info-row">
        <span class="label">Birthday</span>
        <span class="value">${u.birthday}</span>
    </div>

    <div class="info-row">
        <span class="label">Points</span>
        <span class="value points">${u.points}</span>
    </div>

</div>

</body>
</html>
