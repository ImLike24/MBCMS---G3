<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán VNPAY - Vé Xem Phim</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- VNPAY CSS -->
    <link href="https://pay.vnpay.vn/lib/vnpay/vnpay.css" rel="stylesheet"/>
    
    <style>
        body {
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            color: #fff;
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .payment-container {
            max-width: 600px;
            margin: 80px auto 40px;
            background: rgba(30, 30, 50, 0.92);
            backdrop-filter: blur(12px);
            border-radius: 24px;
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 20px 50px rgba(0,0,0,0.7);
            overflow: hidden;
        }
        .payment-header {
            background: #d96c2c;
            padding: 0;
        }
        .payment-header .d-flex {
            padding: 16px 24px;
            align-items: center;
        }
        .payment-header h3 {
            margin: 0;
            font-weight: 700;
            color: white;
            font-size: 1.45rem;
            flex: 1;                /* Chiếm hết phần còn lại */
            text-align: center;     /* Căn giữa tiêu đề */
        }
        .btn-back {
            color: black !important;
            background: none !important;
            border: none !important;
            padding: 8px 20px;
            font-size: 1.1rem;
            font-weight: 500;
            transition: opacity 0.2s;
            opacity: 0.85;
            background: white !important;
            border-radius: 8px;
        }
        .btn-back:hover {
            color: white !important;
            opacity: 0.85;
            background: rgba(255,255,255,0.1) !important;
            border-radius: 8px;
        }
        .payment-body {
            padding: 35px 40px 40px;
        }
        .amount-box {
            background: rgba(217, 108, 44, 0.15);
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            margin: 25px 0 35px;
            border: 1px solid rgba(217, 108, 44, 0.3);
        }
        .amount-label {
            font-size: 1.1rem;
            color: #ddd;
            margin-bottom: 12px;
        }
        .amount-value {
            font-size: 2.8rem;
            font-weight: 800;
            color: #d96c2c;
            letter-spacing: 1px;
        }
        .btn-pay {
            background: #d96c2c;
            border: none;
            font-size: 1.25rem;
            font-weight: 700;
            padding: 16px;
            transition: all 0.3s;
            border-radius: 12px;
        }
        .btn-pay:hover {
            background: #e07e3e;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(217, 108, 44, 0.4);
        }
        .method-box {
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 18px;
            margin-bottom: 30px;
        }
        footer {
            text-align: center;
            padding: 25px;
            color: #aaa;
            font-size: 0.95rem;
        }
    </style>
</head>
<body>

    <div class="payment-container">
        <!-- Header: nút quay lại nhỏ bên trái, tiêu đề chiếm phần còn lại và căn giữa -->
        <div class="payment-header">
            <div class="d-flex align-items-center">
                <!-- Nút quay lại: chiếm khoảng nhỏ bên trái -->
                <button type="button" class="btn-back" onclick="history.back()">
                    <i class="bi bi-arrow-left me-2"></i> Quay lại
                </button>
                
                <!-- Tiêu đề: chiếm hết phần còn lại, căn giữa -->
                <h3>VNPAY - Thanh toán vé xem phim</h3>
            </div>
        </div>

        <div class="payment-body">
            <h4 class="text-center mb-4 fw-semibold">Xác nhận thanh toán</h4>

            <!-- Phần giá tiền (chỉ hiển thị, không gửi) -->
            <div class="amount-box">
                <div class="amount-label">Tổng số tiền phải thanh toán</div>
                <%
                    String totalParam = request.getParameter("total");
                    long amountValue = 100000; // fallback
                    if (totalParam != null && !totalParam.isEmpty()) {
                        try {
                            String cleanTotal = totalParam.replaceAll("[^0-9]", "");
                            amountValue = Long.parseLong(cleanTotal);
                        } catch (NumberFormatException e) {}
                    }
                    String formattedAmount = String.format("%,d", amountValue);
                %>
                <div class="amount-value"><%= formattedAmount %>&nbsp;₫</div>
            </div>

            <!-- Form bắt đầu từ đây -->
            <form action="${pageContext.request.contextPath}/payment/vnpayajax/createOrder"
                  method="post" id="frmCreateOrder" class="needs-validation" novalidate>

                <!-- Input hidden PHẢI nằm ở đây, bên trong form -->
                <input type="hidden" name="amount" value="<%= amountValue %>">

                <!-- Phương thức thanh toán -->
                <div class="method-box">
                    <label class="form-label fw-medium">Phương thức thanh toán</label>
                    <div class="d-flex align-items-center mt-2">
                        <input type="radio" name="bankCode" value="VNBANK" checked class="me-3" id="vnbank">
                        <label for="vnbank" class="mb-0 fs-5">
                            Thanh toán qua thẻ ATM / Tài khoản ngân hàng nội địa
                        </label>
                    </div>
                </div>

                <!-- Ngôn ngữ -->
                <div class="mb-4">
                    <label class="form-label fw-medium">Ngôn ngữ giao diện</label>
                    <div class="d-flex gap-5 mt-2">
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="language" value="vn" id="langVn" checked>
                            <label class="form-check-label fs-5" for="langVn">Tiếng Việt</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="language" value="en" id="langEn">
                            <label class="form-check-label fs-5" for="langEn">English</label>
                        </div>
                    </div>
                </div>

                <!-- Nút thanh toán -->
                <button type="submit" class="btn btn-pay w-100" id="btnSubmit">
                    <i class="bi bi-credit-card-2-front me-2"></i> Thanh toán ngay
                </button>
            </form>
        </div>
    </div>

    <footer>
        <p>© 2025 VNPAY - Hệ thống thanh toán vé xem phim</p>
    </footer>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://pay.vnpay.vn/lib/vnpay/vnpay.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            $("#frmCreateOrder").submit(function (e) {
                e.preventDefault();
                const btn = $("#btnSubmit");
                btn.prop("disabled", true).html('<span class="spinner-border spinner-border-sm me-2"></span> Đang xử lý...');

                var postData = $(this).serialize();
                var submitUrl = $(this).attr("action");

                $.ajax({
                    type: "POST",
                    url: submitUrl,
                    data: postData,
                    dataType: 'json',
                    success: function (x) {
                        btn.prop("disabled", false).html('<i class="bi bi-credit-card-2-front me-2"></i> Thanh toán ngay');
                        if (x.code === '00') {
                            if (window.vnpay) {
                                vnpay.open({width: 768, height: 600, url: x.data});
                            } else {
                                window.location.href = x.data;
                            }
                        } else {
                            alert(x.Message || "Có lỗi xảy ra khi tạo đơn hàng");
                        }
                    },
                    error: function () {
                        btn.prop("disabled", false).html('<i class="bi bi-credit-card-2-front me-2"></i> Thanh toán ngay');
                        alert("Lỗi kết nối đến cổng thanh toán. Vui lòng thử lại.");
                    }
                });
            });
        });
    </script>
</body>
</html>