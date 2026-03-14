<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán VNPAY</title>
    
    <link href="${pageContext.request.contextPath}/assets/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/jumbotron-narrow.css" rel="stylesheet">
    
    <script src="${pageContext.request.contextPath}/assets/jquery-1.11.3.min.js"></script>
    <link href="https://pay.vnpay.vn/lib/vnpay/vnpay.css" rel="stylesheet"/>
    <script src="https://pay.vnpay.vn/lib/vnpay/vnpay.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="header clearfix">
            <h3 class="text-muted">VNPAY - Thanh toán vé xem phim</h3>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                <i class="bi bi-house-door-fill"></i> Trang chủ
            </a>
        </div>

        <h3>Tạo đơn hàng thanh toán</h3>

        <div class="table-responsive">
            <form action="${pageContext.request.contextPath}/payment/vnpayajax/createOrder" 
                  method="post" id="frmCreateOrder" class="form-horizontal">

                <div class="form-group">
                    <label for="amount" class="col-sm-3 control-label">Số tiền thanh toán (VND)</label>
                    <div class="col-sm-9">
                        <%
                            java.math.BigDecimal amount = (java.math.BigDecimal) request.getAttribute("vnpay_total_amount");
                            long amountValue = (amount != null) ? amount.longValue() : 100000;
                        %>
                        <input class="form-control" id="amount" name="amount" type="number"
                               value="<%= amountValue %>" min="10000" max="100000000" required readonly />
                        <small class="text-muted">Số tiền đã được lấy từ giỏ vé của bạn</small>
                    </div>
                </div>

                <h4>Phương thức thanh toán</h4>
                <div class="form-group">
                    <div class="col-sm-offset-3 col-sm-9">
                        <label>
                            <input type="radio" name="bankCode" value="" checked>
                            Cổng thanh toán VNPAYQR (Chọn phương thức sau khi chuyển hướng)
                        </label><br>
                        
                        <label>
                            <input type="radio" name="bankCode" value="VNPAYQR">
                            Thanh toán bằng ứng dụng hỗ trợ VNPAY-QR
                        </label><br>
                        
                        <label>
                            <input type="radio" name="bankCode" value="VNBANK">
                            Thanh toán qua thẻ ATM / Tài khoản ngân hàng nội địa
                        </label><br>
                        
                        <label>
                            <input type="radio" name="bankCode" value="INTCARD">
                            Thanh toán qua thẻ quốc tế (Visa, Master, JCB)
                        </label>
                    </div>
                </div>

                <h4>Ngôn ngữ giao diện</h4>
                <div class="form-group">
                    <div class="col-sm-offset-3 col-sm-9">
                        <label>
                            <input type="radio" name="language" value="vn" checked> Tiếng Việt
                        </label><br>
                        <label>
                            <input type="radio" name="language" value="en"> English
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <div class="col-sm-offset-3 col-sm-9">
                        <button type="submit" class="btn btn-lg btn-primary">
                            <i class="fa fa-credit-card"></i> Thanh toán ngay
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <footer class="footer mt-5">
            <p>&copy; VNPAY 2025</p>
        </footer>
    </div>

    <script type="text/javascript">
        $("#frmCreateOrder").submit(function (e) {
            e.preventDefault();

            var postData = $(this).serialize();
            var submitUrl = $(this).attr("action");

            $.ajax({
                type: "POST",
                url: submitUrl,
                data: postData,
                dataType: 'json',
                success: function (x) {
                    if (x.code === '00') {
                        if (window.vnpay) {
                            vnpay.open({width: 768, height: 600, url: x.data});
                        } else {
                            location.href = x.data;
                        }
                    } else {
                        alert(x.Message || "Có lỗi xảy ra khi tạo đơn hàng");
                    }
                },
                error: function () {
                    alert("Lỗi kết nối đến cổng thanh toán. Vui lòng thử lại.");
                }
            });
        });
    </script>
</body>
</html>