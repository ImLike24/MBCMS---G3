<%@page import="java.net.URLEncoder" %>
<%@page import="java.nio.charset.StandardCharsets" %>
<%@page import="utils.VNPay" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="java.util.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết Quả Thanh Toán - Vé Xem Phim</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        body {
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            color: #fff;
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .result-container {
            max-width: 750px;
            margin: 80px auto;
            background: rgba(30, 30, 50, 0.92);
            backdrop-filter: blur(12px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.6);
            overflow: hidden;
        }

        .result-header {
            background: #d96c2c;
            padding: 25px;
            text-align: center;
            position: relative;
        }

        .result-header h2 {
            margin: 0;
            font-weight: 700;
            color: white;
        }

        .home-btn {
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.15);
            border: none;
            color: white;
            transition: all 0.3s;
        }

        .home-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }

        .result-body {
            padding: 30px 40px;
        }

        .status-card {
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            text-align: center;
        }

        .status-success {
            background: rgba(40, 167, 69, 0.2);
            border: 2px solid #28a745;
            color: #28a745;
        }

        .status-fail {
            background: rgba(220, 53, 69, 0.2);
            border: 2px solid #dc3545;
            color: #dc3545;
        }

        .status-invalid {
            background: rgba(255, 193, 7, 0.2);
            border: 2px solid #ffc107;
            color: #ffc107;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 1.1rem;
        }

        .info-label {
            font-weight: 600;
            color: #ddd;
        }

        .info-value {
            font-weight: 500;
        }

        footer {
            text-align: center;
            padding: 20px;
            color: #aaa;
            font-size: 0.95rem;
        }
    </style>
</head>
<body>

<div class="result-container">
    <!-- Header -->
    <div class="result-header">
        <h2>KẾT QUẢ THANH TOÁN</h2>
    </div>

    <div class="result-body">
        <%
            // Xử lý params từ VNPAY
            Map fields = new HashMap();
            for (Enumeration params = request.getParameterNames(); params.hasMoreElements(); ) {
                String fieldName = URLEncoder.encode((String) params.nextElement(), StandardCharsets.US_ASCII.toString());
                String fieldValue = URLEncoder.encode(request.getParameter(fieldName), StandardCharsets.US_ASCII.toString());
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    fields.put(fieldName, fieldValue);
                }
            }
            String vnp_SecureHash = request.getParameter("vnp_SecureHash");
            if (fields.containsKey("vnp_SecureHashType")) fields.remove("vnp_SecureHashType");
            if (fields.containsKey("vnp_SecureHash")) fields.remove("vnp_SecureHash");
            String signValue = VNPay.hashAllFields(fields);

            String status = "invalid signature";
            String statusClass = "status-invalid";
            String statusText = "Chữ ký không hợp lệ";

            if (signValue.equals(vnp_SecureHash)) {
                if ("00".equals(request.getParameter("vnp_TransactionStatus"))) {
                    status = "success";
                    statusClass = "status-success";
                    statusText = "Thành công";
                } else {
                    status = "fail";
                    statusClass = "status-fail";
                    statusText = "Không thành công";
                }
            }
        %>

        <!-- Trạng thái giao dịch -->
        <div class="status-card <%= statusClass %>">
            <h3 class="mb-3">
                <i class="bi <%= status.equals("success") ? "bi-check-circle-fill" : status.equals("fail") ? "bi-x-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i>
                <%= statusText %>
            </h3>
            <p class="mb-0">Mã giao
                dịch: <%= request.getParameter("vnp_TxnRef") != null ? request.getParameter("vnp_TxnRef") : "N/A" %>
            </p>
        </div>

        <!-- Thông tin chi tiết -->
        <div class="bg-dark bg-opacity-50 p-4 rounded-3">
            <div class="info-item">
                <span class="info-label">Mã giao dịch thanh toán:</span>
                <span class="info-value"><%= request.getParameter("vnp_TxnRef") != null ? request.getParameter("vnp_TxnRef") : "N/A" %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Số tiền:</span>
                <span class="info-value">
                        <%= request.getParameter("vnp_Amount") != null ?
                                String.format("%,.0f", Double.parseDouble(request.getParameter("vnp_Amount")) / 100) + " ₫" :
                                "N/A" %>
                    </span>
            </div>
            <div class="info-item">
                <span class="info-label">Mô tả giao dịch:</span>
                <span class="info-value"><%= request.getParameter("vnp_OrderInfo") != null ? request.getParameter("vnp_OrderInfo") : "N/A" %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Mã lỗi thanh toán:</span>
                <span class="info-value"><%= request.getParameter("vnp_ResponseCode") != null ? request.getParameter("vnp_ResponseCode") : "N/A" %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Mã giao dịch VNPAY:</span>
                <span class="info-value"><%= request.getParameter("vnp_TransactionNo") != null ? request.getParameter("vnp_TransactionNo") : "N/A" %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Ngân hàng thanh toán:</span>
                <span class="info-value"><%= request.getParameter("vnp_BankCode") != null ? request.getParameter("vnp_BankCode") : "N/A" %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Thời gian thanh toán:</span>
                <span class="info-value"><%= request.getParameter("vnp_PayDate") != null ? request.getParameter("vnp_PayDate") : "N/A" %></span>
            </div>
        </div>

        <!-- Nút về trang chủ dưới cùng -->
        <div class="text-center mt-5">
            <button type="button" class="btn btn-lg btn-primary px-5"
                    onclick="window.location.href='../..'">
                <i class="bi bi-house-door-fill me-2"></i> Về Trang Chủ
            </button>
        </div>
    </div>
</div>

<body onload="checkAndSaveBooking()">
<footer>
    <p>© 2025 VNPAY - Hệ thống thanh toán vé xem phim</p>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function checkAndSaveBooking() {
        console.log("Calling FinalizeBooking servlet...");

        const params = new URLSearchParams(window.location.search);

        const txnRef = params.get("vnp_TxnRef");
        const transactionStatus = params.get("vnp_TransactionStatus");
        const amount = params.get("vnp_Amount");

        fetch("<%=request.getContextPath()%>/FinalizeBooking", {

            method: "POST",

            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },

            body:
                "vnp_TxnRef=" + txnRef +
                "&vnp_TransactionStatus=" + transactionStatus +
                "&vnp_Amount=" + amount

        })
            .then(res => res.text())
            .then(data => {
                console.log("FinalizeBooking response:", data);
            })
            .catch(err => {
                console.error("FinalizeBooking error:", err);
            });
    }
</script>
</body>
</body>
</html>