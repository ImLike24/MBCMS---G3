package services;

import com.google.gson.JsonObject;
import config.VNPayConfig;
import utils.VNPay;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;

public class VNPayService {

    // =========================================================================
    // HÀM 1: TRUY VẤN TRẠNG THÁI GIAO DỊCH (QUERY)
    // =========================================================================
    public String queryTransaction(String orderId, String transDate, String ipAddr) {
        try {
            String vnp_RequestId = VNPay.getRandomNumber(8);
            String vnp_Version = "2.1.0";
            String vnp_Command = "querydr";
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;
            String vnp_OrderInfo = "Kiem tra ket qua GD OrderId:" + orderId;

            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnp_CreateDate = formatter.format(cld.getTime());

            JsonObject vnp_Params = new JsonObject();
            vnp_Params.addProperty("vnp_RequestId", vnp_RequestId);
            vnp_Params.addProperty("vnp_Version", vnp_Version);
            vnp_Params.addProperty("vnp_Command", vnp_Command);
            vnp_Params.addProperty("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.addProperty("vnp_TxnRef", orderId);
            vnp_Params.addProperty("vnp_OrderInfo", vnp_OrderInfo);
            vnp_Params.addProperty("vnp_TransactionDate", transDate);
            vnp_Params.addProperty("vnp_CreateDate", vnp_CreateDate);
            vnp_Params.addProperty("vnp_IpAddr", ipAddr);

            String hash_Data = String.join("|", vnp_RequestId, vnp_Version, vnp_Command, vnp_TmnCode,
                    orderId, transDate, vnp_CreateDate, ipAddr, vnp_OrderInfo);
            String vnp_SecureHash = VNPay.hmacSHA512(VNPayConfig.secretKey, hash_Data);

            vnp_Params.addProperty("vnp_SecureHash", vnp_SecureHash);

            return sendPostRequest(VNPayConfig.vnp_ApiUrl, vnp_Params.toString());
        } catch (Exception e) {
            e.printStackTrace();
            return "{\"RspCode\":\"99\",\"Message\":\"Unknown Error\"}";
        }
    }

    // =========================================================================
    // HÀM 2: YÊU CẦU HOÀN TIỀN (REFUND)
    // =========================================================================
    public String refundTransaction(String orderId, String transType, long amount, String transDate, String user, String ipAddr) {
        try {
            String vnp_RequestId = VNPay.getRandomNumber(8);
            String vnp_Version = "2.1.0";
            String vnp_Command = "refund";
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;
            String vnp_Amount = String.valueOf(amount * 100); // VNPay yêu cầu nhân 100
            String vnp_OrderInfo = "Hoan tien GD OrderId:" + orderId;
            String vnp_TransactionNo = ""; // Có thể để trống nếu hệ thống không lưu

            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnp_CreateDate = formatter.format(cld.getTime());

            JsonObject vnp_Params = new JsonObject();
            vnp_Params.addProperty("vnp_RequestId", vnp_RequestId);
            vnp_Params.addProperty("vnp_Version", vnp_Version);
            vnp_Params.addProperty("vnp_Command", vnp_Command);
            vnp_Params.addProperty("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.addProperty("vnp_TransactionType", transType);
            vnp_Params.addProperty("vnp_TxnRef", orderId);
            vnp_Params.addProperty("vnp_Amount", vnp_Amount);
            vnp_Params.addProperty("vnp_OrderInfo", vnp_OrderInfo);
            vnp_Params.addProperty("vnp_TransactionDate", transDate);
            vnp_Params.addProperty("vnp_CreateBy", user);
            vnp_Params.addProperty("vnp_CreateDate", vnp_CreateDate);
            vnp_Params.addProperty("vnp_IpAddr", ipAddr);

            String hash_Data = String.join("|", vnp_RequestId, vnp_Version, vnp_Command, vnp_TmnCode,
                    transType, orderId, vnp_Amount, vnp_TransactionNo, transDate,
                    user, vnp_CreateDate, ipAddr, vnp_OrderInfo);

            String vnp_SecureHash = VNPay.hmacSHA512(VNPayConfig.secretKey, hash_Data);
            vnp_Params.addProperty("vnp_SecureHash", vnp_SecureHash);

            return sendPostRequest(VNPayConfig.vnp_ApiUrl, vnp_Params.toString());
        } catch (Exception e) {
            e.printStackTrace();
            return "{\"RspCode\":\"99\",\"Message\":\"Unknown Error\"}";
        }
    }

    // =========================================================================
    // HÀM TIỆN ÍCH DÙNG CHUNG: GỬI HTTP POST (KHÔNG PUBLIC)
    // =========================================================================
    private String sendPostRequest(String apiUrl, String jsonPayload) throws Exception {
        URL url = new URL(apiUrl);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json");
        con.setDoOutput(true);

        try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
            wr.writeBytes(jsonPayload);
            wr.flush();
        }

        // Đọc dữ liệu VNPay trả về
        try (BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()))) {
            String output;
            StringBuilder response = new StringBuilder();
            while ((output = in.readLine()) != null) {
                response.append(output);
            }
            return response.toString();
        }
    }
}