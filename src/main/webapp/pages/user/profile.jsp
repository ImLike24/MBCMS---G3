<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>User Profile</title>

    <!-- CSS -->
    <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">

    <!-- JS -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>

    <!-- CLOUDINARY -->
    <script src="https://widget.cloudinary.com/v2.0/global/all.js"></script>

    <style>
        .profile-wrapper {
            width: 1000px;
            margin: 90px auto;
            display: flex;
            gap: 24px;
        }

        .profile-left {
            width: 260px;
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .profile-right {
            flex: 3;
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .avatar-img {
            width: 160px;
            height: 160px;
            border-radius: 50%;
            object-fit: cover;
            cursor: pointer;
            border: 3px solid #ddd;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

        .password-mask {
            letter-spacing: 3px;
        }
    </style>
</head>

<body>

<!-- HEADER -->
<jsp:include page="/components/layout/Header.jsp" />

<div class="profile-wrapper">

    <!-- LEFT PANEL -->
    <div class="profile-left">
        <div style="position: relative; display: inline-block;">
            <img id="avatar"
                 class="avatar-img"
                 src="${empty u.avatarUrl ? 'assets/default-avatar.png' : u.avatarUrl}"
                 alt="Ảnh đại diện">

            <form id="avatarForm" action="${pageContext.request.contextPath}/profile/avatar"
                  method="post" enctype="multipart/form-data" style="display: none;">
                <input type="file" name="avatarFile" id="avatarInput" accept="image/*" onchange="document.getElementById('avatarForm').submit()">
            </form>

            <label for="avatarInput" style="position: absolute; bottom: 10px; right: 10px;
                   background: rgba(0,123,255,0.8); color: white; padding: 8px 12px;
                   border-radius: 50%; cursor: pointer;">
                <i class="fa fa-camera"></i>
            </label>
        </div>

        <h5 class="mt-3">${u.username}</h5>

        <button class="btn btn-outline-primary w-100 mt-3" onclick="showView()">
            View Profile
        </button>

        <button class="btn btn-primary w-100 mt-2" onclick="showEdit()">
            Update Profile
        </button>
    </div>

    <!-- RIGHT PANEL -->
    <div class="profile-right">

        <!-- VIEW MODE -->
        <div id="viewMode">
            <h4 class="mb-3">User Information</h4>

            <div class="info-row">
                <span>Full Name</span>
                <span>${u.fullName}</span>
            </div>

            <div class="info-row">
                <span>Email</span>
                <span>${u.email}</span>
            </div>

            <div class="info-row">
                <span>Phone</span>
                <span>${u.phone}</span>
            </div>

            <div class="info-row">
                <span>Birthday</span>
                <span>
                    ${u.birthday != null ? u.birthday.toLocalDate() : ''}
                </span>

            </div>

            <div class="info-row">
                <span>Points</span>
                <span class="text-warning fw-bold">${u.points}</span>
            </div>
        </div>

        <!-- EDIT MODE -->
        <div id="editMode" class="d-none">
            <h4 class="mb-3">Update Information</h4>

            <form action="${pageContext.request.contextPath}/profile" method="post">

                <!-- Full Name -->
                <div class="mb-2">
                    <label>Full Name</label>
                    <input class="form-control"
                           name="fullName"
                           value="${u.fullName}"
                           required>
                </div>

                <!-- Email -->
                <div class="mb-2">
                    <label>Email</label>
                    <input type="email"
                           class="form-control"
                           name="email"
                           value="${u.email}"
                           required>
                </div>

                <!-- Phone -->
                <div class="mb-2">
                    <label>Phone</label>
                    <input class="form-control"
                           name="phone"
                           value="${u.phone}">
                </div>

                <!-- Birthday -->
                <div class="mb-2">
                    <label>Birthday</label>
                    <input type="date"
                           class="form-control"
                           name="birthday"
                           value="${u.birthday != null ? u.birthday.toLocalDate() : ''}">
                </div>

                <!-- Password -->
                <div class="mb-2">
                    <label>New Password</label>
                    <input type="password"
                           class="form-control"
                           name="password"
                           placeholder="Leave blank if not change">
                </div>

                <!-- Confirm Password -->
                <div class="mb-3">
                    <label>Confirm Password</label>
                    <input type="password"
                           class="form-control"
                           name="confirmPassword">
                </div>

                <button class="btn btn-success">Save Changes</button>
                <button type="button"
                        class="btn btn-secondary ms-2"
                        onclick="showView()">
                    Cancel
                </button>
            </form>
        </div>


    </div>
</div>

<script>
    function showEdit() {
        $("#viewMode").addClass("d-none");
        $("#editMode").removeClass("d-none");
    }

    function showView() {
        $("#editMode").addClass("d-none");
        $("#viewMode").removeClass("d-none");
    }
</script>

</body>
</html>
