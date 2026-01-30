<%-- 
    Document   : about
    Created on : Jan 29, 2026, 9:27:57 AM
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giới Thiệu - MBCMS Cinema Management</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/font-awesome.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/global.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/about.css">
</head>
<body>
    <!-- Header -->
    <jsp:include page="../layout/header.jsp"></jsp:include>

    <!-- About Header -->
    <div class="about-header">
        <div class="container">
            <h1><i class="fa fa-info-circle"></i> Giới Thiệu Về Chúng Tôi</h1>
            <p>Nơi mang đến trải nghiệm điện ảnh tuyệt vời cho mọi gia đình Việt Nam</p>
        </div>
    </div>

    <!-- About Content -->
    <div class="about-content">
        <div class="container">
            <!-- Company Overview -->
            <section class="mb-5">
                <h2 class="section-title"><i class="fa fa-building"></i> Về MBCMS Cinema</h2>
                <p class="lead">
                    MBCMS (Movie Box Cinema Management System) là hệ thống quản lý rạp chiếu phim hiện đại, 
                    được thiết kế để mang lại trải nghiệm xem phim tuyệt vời và tiện lợi nhất cho khán giả.
                </p>
                <p>
                    Với công nghệ tiên tiến, giao diện thân thiện, và dịch vụ chuyên nghiệp, 
                    chúng tôi cam kết đem đến những bộ phim hay nhất thế giới đến gần hơn với bạn.
                </p>
            </section>

            <!-- Mission & Vision -->
            <section class="mb-5">
                <h2 class="section-title"><i class="fa fa-target"></i> Sứ Mệnh & Tầm Nhìn</h2>
                <div class="row">
                    <div class="col-md-4">
                        <div class="mission-item">
                            <i class="fa fa-eye"></i>
                            <h3>Tầm Nhìn</h3>
                            <p>Trở thành nền tảng quản lý rạp chiếu phim hàng đầu tại Việt Nam, 
                               cung cấp giải pháp công nghệ tốt nhất cho ngành điện ảnh.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mission-item">
                            <i class="fa fa-heart"></i>
                            <h3>Sứ Mệnh</h3>
                            <p>Mang đến trải nghiệm xem phim tuyệt vời, dễ dàng và tiện lợi 
                               cho hàng triệu khán giả trên khắp đất nước.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mission-item">
                            <i class="fa fa-star"></i>
                            <h3>Giá Trị Cốt Lõi</h3>
                            <p>Chất lượng, Đổi mới, Tin tưởng - ba giá trị nền tảng 
                               hướng dẫn mọi hoạt động của chúng tôi.</p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Statistics -->
            <section class="stats-section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="stat-item">
                                <div class="stat-number">50+</div>
                                <div class="stat-label">Rạp Chiếu Phim</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-item">
                                <div class="stat-number">500K+</div>
                                <div class="stat-label">Khán Giả Hài Lòng</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-item">
                                <div class="stat-number">1000+</div>
                                <div class="stat-label">Bộ Phim</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-item">
                                <div class="stat-number">99%</div>
                                <div class="stat-label">Độ Hài Lòng</div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Timeline -->
            <section class="my-5">
                <h2 class="section-title"><i class="fa fa-history"></i> Hành Trình Của Chúng Tôi</h2>
                <div class="timeline">
                    <div class="timeline-item">
                        <span class="timeline-year">2020</span>
                        <h4>Khởi Đầu</h4>
                        <p>MBCMS được thành lập với mục tiêu cách mạng hóa ngành quản lý rạp chiếu phim.</p>
                    </div>
                    <div class="timeline-item">
                        <span class="timeline-year">2021</span>
                        <h4>Mở Rộng</h4>
                        <p>Phát triển hệ thống đặt vé online, kết nối 20 rạp chiếu phim lớn.</p>
                    </div>
                    <div class="timeline-item">
                        <span class="timeline-year">2022</span>
                        <h4>Đổi Mới</h4>
                        <p>Ra mắt ứng dụng mobile, hệ thống thanh toán điện tử, quản lý thành viên VIP.</p>
                    </div>
                    <div class="timeline-item">
                        <span class="timeline-year">2024</span>
                        <h4>Hiện Tại</h4>
                        <p>Phục vụ 500K+ khán giả, quản lý 50+ rạp chiếu phim trên toàn quốc.</p>
                    </div>
                </div>
            </section>

            <!-- Core Features -->
            <section class="mb-5">
                <h2 class="section-title"><i class="fa fa-lightbulb-o"></i> Tính Năng Nổi Bật</h2>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <div class="card border-left-primary">
                            <div class="card-body">
                                <h5><i class="fa fa-ticket"></i> Đặt Vé Trực Tuyến</h5>
                                <p>Đặt vé xem phim dễ dàng chỉ trong vài cú click, chọn ghế theo sở thích.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <div class="card border-left-success">
                            <div class="card-body">
                                <h5><i class="fa fa-credit-card"></i> Thanh Toán An Toàn</h5>
                                <p>Hỗ trợ nhiều phương thức thanh toán an toàn, bảo mật cao.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <div class="card border-left-warning">
                            <div class="card-body">
                                <h5><i class="fa fa-star"></i> Chương Trình Thành Viên</h5>
                                <p>Tích điểm, nhận quà thưởng, ưu đãi độc quyền cho thành viên VIP.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <div class="card border-left-info">
                            <div class="card-body">
                                <h5><i class="fa fa-headphones"></i> Hỗ Trợ 24/7</h5>
                                <p>Đội hỗ trợ khách hàng chuyên nghiệp sẵn sàng giúp đỡ mọi lúc.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Contact & Call to Action -->
            <section class="bg-light p-5 rounded mb-5">
                <div class="text-center">
                    <h2 class="mb-3">Liên Hệ Với Chúng Tôi</h2>
                    <p class="lead mb-4">Bạn có câu hỏi hoặc muốn biết thêm thông tin?</p>
                    <p>
                        <i class="fa fa-phone"></i> <strong>Hotline:</strong> 1900 1234 <br>
                        <i class="fa fa-envelope"></i> <strong>Email:</strong> support@mbcms.com <br>
                        <i class="fa fa-map-marker"></i> <strong>Địa chỉ:</strong> 123 Phố Cổ, Hoàn Kiếm, Hà Nội
                    </p>
                    <div class="mt-4">
                        <a href="<%= request.getContextPath() %>/auth/login" class="btn btn-primary btn-lg">
                            <i class="fa fa-sign-in"></i> Bắt Đầu Ngay
                        </a>
                        <a href="<%= request.getContextPath() %>/pages/index.jsp" class="btn btn-secondary btn-lg ms-2">
                            <i class="fa fa-home"></i> Về Trang Chủ
                        </a>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="../layout/footer.jsp"></jsp:include>

    <script src="<%= request.getContextPath() %>/js/bootstrap.bundle.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery-3.7.1.min.js"></script>
</body>
</html>

