<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>

    <link href="${pageContext.request.contextPath}/web/img/logo/favicon/DC-Symbol.png" rel="icon"/>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Roboto', sans-serif; background: linear-gradient(135deg, #9ACBD0 0%, #006A71 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .container { display: flex; width: 100%; max-width: 1100px; height: auto; min-height: 700px; background: white; border-radius: 15px; box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1); overflow: hidden; position: relative; }
        .left-panel { flex: 1; background: linear-gradient(135deg, #D84040 0%, #667eea 100%); position: relative; display: flex; align-items: center; justify-content: center; overflow: hidden; min-height: 700px; }
        .logo { position: absolute; top: 30px; left: 30px; color: white; font-size: 24px; font-weight: bold; display: flex; align-items: center; gap: 15px; z-index: 2; cursor: pointer; transition: all 0.3s ease; }
        .logo:hover { transform: translateY(-2px); filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2)); }
        .logo img { width: 48px; height: 48px; object-fit: contain; filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3)); transition: transform 0.3s ease; }
        .logo:hover img { transform: rotate(5deg) scale(1.05); }
        .logo span { font-size: 32px; font-weight: bold; letter-spacing: 2px; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
        .scene { position: relative; width: 100%; height: 100%; }
        .stars { position: absolute; width: 100%; height: 100%; }
        .star { position: absolute; background: white; border-radius: 50%; animation: twinkle 2s infinite alternate; }
        .star:nth-child(1) { width: 2px; height: 2px; top: 20%; left: 20%; animation-delay: 0s; }
        .star:nth-child(2) { width: 1px; height: 1px; top: 30%; left: 80%; animation-delay: 0.5s; }
        .star:nth-child(3) { width: 2px; height: 2px; top: 60%; left: 15%; animation-delay: 1s; }
        .star:nth-child(4) { width: 1px; height: 1px; top: 80%; left: 70%; animation-delay: 1.5s; }
        .star:nth-child(5) { width: 3px; height: 3px; top: 15%; left: 60%; animation-delay: 0.8s; }
        .ufo { position: absolute; top: 25%; left: 50%; transform: translateX(-50%); animation: float 3s ease-in-out infinite; }
        .ufo-body { width: 120px; height: 40px; background: linear-gradient(135deg, #a78bfa 0%, #8b5cf6 100%); border-radius: 50px; position: relative; box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2); }
        .ufo-dome { width: 60px; height: 30px; background: linear-gradient(135deg, #c4b5fd 0%, #a78bfa 100%); border-radius: 30px 30px 0 0; position: absolute; top: -15px; left: 50%; transform: translateX(-50%); }
        .ufo-lights { position: absolute; bottom: -5px; left: 50%; transform: translateX(-50%); display: flex; gap: 10px; }
        .ufo-light { width: 8px; height: 8px; background: #10f6f6; border-radius: 50%; animation: blink 1s infinite alternate; }
        .ufo-light:nth-child(2) { animation-delay: 0.3s; }
        .ufo-light:nth-child(3) { animation-delay: 0.6s; }
        .beam { position: absolute; top: 100%; left: 50%; transform: translateX(-50%); width: 0; height: 0; border-left: 60px solid transparent; border-right: 60px solid transparent; border-top: 100px solid rgba(16, 246, 246, 0.3); animation: beamPulse 2s ease-in-out infinite; }
        .houses { position: absolute; bottom: 0; left: 0; right: 0; height: 200px; }
        .house { position: absolute; bottom: 0; }
        .house1 { left: 10%; width: 80px; height: 100px; background: #3b4cca; clip-path: polygon(0 100%, 0 40%, 50% 0, 100% 40%, 100% 100%); }
        .house2 { left: 25%; width: 60px; height: 80px; background: #4c51bf; clip-path: polygon(0 100%, 0 30%, 50% 0, 100% 30%, 100% 100%); }
        .house3 { right: 20%; width: 90px; height: 120px; background: #5a67d8; clip-path: polygon(0 100%, 0 35%, 50% 0, 100% 35%, 100% 100%); }
        .tree { position: absolute; bottom: 0; width: 20px; height: 40px; background: #10b981; border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%; }
        .tree:nth-child(1) { left: 5%; } .tree:nth-child(2) { left: 45%; } .tree:nth-child(3) { right: 10%; } .tree:nth-child(4) { right: 35%; }
        .right-panel { flex: 1; padding: 30px 40px; display: flex; flex-direction: column; justify-content: flex-start; background: white; position: relative; overflow-y: auto; max-height: 100vh; }
        .signup-header { margin-bottom: 20px; text-align: center; }
        .signup-title { font-size: 24px; font-weight: 600; color: #1a202c; margin-bottom: 8px; }
        .signup-subtitle { color: #718096; font-size: 14px; }
        .form-group { margin-bottom: 12px; }
        .form-label { display: block; margin-bottom: 5px; color: #4a5568; font-weight: 500; font-size: 13px; }
        .form-input { width: 100%; padding: 10px 12px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 14px; transition: all 0.3s ease; outline: none; }
        .form-input:focus { border-color: #4c51bf; box-shadow: 0 0 0 3px rgba(76, 81, 191, 0.1); }
        .form-row { display: flex; gap: 12px; }
        .form-row .form-group { flex: 1; }
        .form-radio-group { display: flex; gap: 20px; margin-top: 5px; }
        .form-radio-group label { display: flex; align-items: center; gap: 8px; font-size: 14px; color: #4a5568; cursor: pointer; }
        .form-radio-group input[type="radio"] { width: 16px; height: 16px; accent-color: #4c51bf; }
        .checkbox-group { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 15px; }
        .checkbox { width: 16px; height: 16px; accent-color: #4c51bf; margin-top: 2px; flex-shrink: 0; }
        .checkbox-label { color: #4a5568; font-size: 12px; line-height: 1.4; }
        .checkbox-label a { color: #FFACAC; text-decoration: none; }
        .checkbox-label a:hover { text-decoration: underline; }
        .signup-btn { width: 100%; padding: 12px; background: linear-gradient(135deg, #FFBFA9 0%, #FFACAC 100%); color: white; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; margin-bottom: 15px; }
        .signup-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255, 172, 172, 0.3); }
        .signin-link { text-align: center; color: #FFACAC; text-decoration: none; font-size: 13px; margin-bottom: 15px; display: block; }
        .signin-link:hover { text-decoration: underline; color: #FF9A9A; }
        .decorative-elements { position: absolute; top: 0; right: 0; width: 150px; height: 150px; background: linear-gradient(135deg, #FFBFA9, #FFACAC); opacity: 0.1; clip-path: polygon(100% 0, 0 0, 100% 100%); }
        .alert { padding: 10px 12px; border-radius: 6px; margin-bottom: 12px; font-size: 13px; text-align: center; }
        .alert-error { background-color: #fed7d7; color: #e53e3e; border: 1px solid #feb2b2; animation: shake 0.5s ease-in-out; box-shadow: 0 2px 4px rgba(229, 62, 62, 0.1); }
        @keyframes shake { 0%, 100% { transform: translateX(0); } 25% { transform: translateX(-5px); } 75% { transform: translateX(5px); } }
        @keyframes float { 0%, 100% { transform: translateX(-50%) translateY(0px); } 50% { transform: translateX(-50%) translateY(-10px); } }
        @keyframes twinkle { 0% { opacity: 0.3; } 100% { opacity: 1; } }
        @keyframes blink { 0% { opacity: 1; } 100% { opacity: 0.3; } }
        @keyframes beamPulse { 0%, 100% { opacity: 0.3; } 50% { opacity: 0.6; } }
        @media (max-width: 768px) { body { padding: 10px; } .container { flex-direction: column; height: auto; min-height: auto; max-width: 100%; } .left-panel { height: 250px; flex: none; min-height: auto; } .right-panel { padding: 20px; max-height: none; } .form-row { flex-direction: column; gap: 0; } .logo span { font-size: 24px; } .signup-title { font-size: 20px; } }
        @media (max-width: 480px) { .right-panel { padding: 15px; } .logo { top: 20px; left: 20px; gap: 10px; } .logo img { width: 36px; height: 36px; } .logo span { font-size: 20px; } }
    </style>
</head>
<body>
<div class="container">
    <div class="left-panel">
        <div class="logo">
            <img src="${pageContext.request.contextPath}/web/img/logo/website/dclogo.svg" alt="Logo" />
            <span>LOSS LAPTOP</span>
        </div>
        <div class="scene">
            <div class="stars">
                <div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div>
            </div>
            <div class="ufo">
                <div class="ufo-dome"></div>
                <div class="ufo-body">
                    <div class="ufo-lights"><div class="ufo-light"></div><div class="ufo-light"></div><div class="ufo-light"></div></div>
                </div>
                <div class="beam"></div>
            </div>
            <div class="houses">
                <div class="house house1"></div><div class="house house2"></div><div class="house house3"></div>
                <div class="tree"></div><div class="tree"></div><div class="tree"></div><div class="tree"></div>
            </div>
        </div>
    </div>

    <div class="right-panel">
        <div class="decorative-elements"></div>

        <div class="signup-header">
            <h1 class="signup-title">Đăng ký tài khoản</h1>
        </div>

        <form action="register" method="post" id="signupForm">
            <div class="form-group">
                <label for="fullName" class="form-label">Họ và tên</label>
                <input
                        type="text"
                        id="fullName"
                        name="fullName"
                        class="form-input"
                        required
                        pattern="^[a-zA-ZÀ-ỹ\s]{2,100}$"
                        title="Họ tên phải từ 2 ký tự trở lên"
                        value="${fullName != null ? fullName : param.fullName}"
                        placeholder="Nhập họ và tên của bạn"
                >
            </div>

            <div class="form-group">
                <label for="username" class="form-label">Tên đăng nhập</label>
                <input
                        type="text"
                        id="username"
                        name="username"
                        class="form-input"
                        required
                        pattern="^(?=.{3,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
                        title="Tên đăng nhập phải từ 3-20 ký tự, chỉ bao gồm chữ cái, số và dấu chấm"
                        value="${username != null ? username : param.username}"
                        placeholder="Chọn tên đăng nhập"
                >
            </div>

            <div class="form-group">
                <label for="email" class="form-label">Địa chỉ email</label>
                <input
                        type="email"
                        id="email"
                        name="email"
                        class="form-input"
                        required
                        pattern="[a-zA-Z0-9._%25+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
                        title="Email không hợp lệ"
                        value="${email != null ? email : param.email}"
                        placeholder="vidu@email.com"
                >
            </div>

            <div class="form-group">
                <label for="phone" class="form-label">Số điện thoại</label>
                <input
                        type="text"
                        class="form-input"
                        id="phone"
                        name="phone"
                        placeholder="Nhập số điện thoại"
                        required
                        pattern="^0\d{9,10}$"
                        title="Số điện thoại phải bắt đầu bằng 0 và có 10-11 số"
                        value="${phone != null ? phone : param.phone}"
                >
            </div>

            <div class="form-group">
                <label for="birthday" class="form-label">Ngày sinh</label>
                <input
                        type="date"
                        id="birthday"
                        name="birthday"
                        class="form-input"
                        value="${birthday != null ? birthday : param.birthday}"
                >
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="password" class="form-label">Mật khẩu</label>
                    <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-input"
                            required
                            pattern="^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$"
                            title="Mật khẩu >8 ký tự, gồm chữ, số và ký tự đặc biệt"
                    >
                </div>
                <div class="form-group">
                    <label for="confirmPassword" class="form-label">Xác nhận mật khẩu</label>
                    <input
                            type="password"
                            id="confirmPassword"
                            name="confirmPassword"
                            class="form-input"
                            required
                    >
                </div>
            </div>

            <div class="checkbox-group">
                <input type="checkbox" id="agreeTerms" name="agreeTerms" value="on" class="checkbox" required>
                <label for="agreeTerms" class="checkbox-label">
                    Tôi đồng ý với <a href="#" style="color: #FFACAC;">Điều Khoản Dịch Vụ</a> &
                    <a href="#" style="color: #FFACAC;">Chính Sách Bảo Mật</a>
                </label>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-error" id="serverErrorMessage" style="display: block;">
                        ${error}
                </div>
            </c:if>
            <div class="alert alert-error" id="clientErrorMessage" style="display: none;">
                Vui lòng kiểm tra lại thông tin!
            </div>

            <button type="submit" class="signup-btn">Tạo tài khoản</button>
        </form>

        <a href="${pageContext.request.contextPath}/login" class="signin-link">Bạn đã có tài khoản?</a>
    </div>
</div>

<script>
    // Form validation
    document.getElementById('signupForm').addEventListener('submit', function (e) {
        const fullName = document.getElementById('fullName').value.trim();
        const phone = document.getElementById('phone').value.trim();
        const email = document.getElementById('email').value.trim();
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const agreeTerms = document.getElementById('agreeTerms').checked;
        const clientErrorMessage = document.getElementById('clientErrorMessage');

        // Hide previous error messages
        if(clientErrorMessage) clientErrorMessage.style.display = 'none';

        // Check if all fields are filled
        if (!fullName || !phone || !email || !username || !password || !confirmPassword) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Vui lòng điền đầy đủ tất cả thông tin!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Validate full name
        const namePattern = /^[a-zA-ZÀ-ỹ\s]{2,100}$/;
        if (!namePattern.test(fullName)) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Họ tên không hợp lệ!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Validate phone
        const phonePattern = /^0\d{9,10}$/;
        if (!phonePattern.test(phone)) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Số điện thoại không hợp lệ!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Validate username
        const usernamePattern = /^(?=.{3,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$/;
        if (!usernamePattern.test(username)) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Tên đăng nhập không hợp lệ!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Validate password (Match new regex in backend)
        const passwordPattern = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$/;
        if (!passwordPattern.test(password)) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ cái, số và ký tự đặc biệt!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Check password match
        if (password !== confirmPassword) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Mật khẩu xác nhận không khớp!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        // Check terms agreement
        if (!agreeTerms) {
            e.preventDefault();
            clientErrorMessage.textContent = 'Bạn phải đồng ý với điều khoản dịch vụ!';
            clientErrorMessage.style.display = 'block';
            return false;
        }

        return true;
    });

    // Auto-hide error messages
    const errorMessages = document.querySelectorAll('.alert-error');
    errorMessages.forEach(function(errorMsg) {
        if (errorMsg.style.display === 'block') {
            setTimeout(() => {
                errorMsg.style.display = 'none';
            }, 5000);
        }
    });

    // Clear client error messages when user starts typing
    const formInputs = document.querySelectorAll('.form-input');
    const clientErrorMessage = document.getElementById('clientErrorMessage');
    formInputs.forEach(input => {
        input.addEventListener('input', function() {
            if(clientErrorMessage) clientErrorMessage.style.display = 'none';
        });
    });

    // Add loading state
    const submitBtn = document.querySelector('.signup-btn');
    const form = document.getElementById('signupForm');
    form.addEventListener('submit', function () {
        submitBtn.innerHTML = 'Đang tạo tài khoản...';
        submitBtn.disabled = true;
        setTimeout(() => {
            submitBtn.innerHTML = 'Tạo tài khoản';
            submitBtn.disabled = false;
        }, 3000);
    });
</script>
</body>
</html>