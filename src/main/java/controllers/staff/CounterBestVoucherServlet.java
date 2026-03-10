package controllers.staff;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.User;
import models.UserVoucher;
import models.Voucher;
import repositories.UserVouchers;
import repositories.Users;
import repositories.Vouchers;

/**
 * API cho quầy (counter) dùng để:
 * - Lấy danh sách voucher còn hiệu lực của khách (qua số điện thoại).
 * - Tự động chọn voucher "hời nhất" dựa trên tổng bill.
 */
@WebServlet(name = "counterBestVoucher", urlPatterns = {"/staff/counter-best-voucher"})
public class CounterBestVoucherServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CounterBestVoucherServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Not authenticated\"}");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\":false,\"message\":\"Access denied\"}");
            return;
        }

        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }

        Gson gson = new Gson();
        JsonObject requestData = gson.fromJson(jsonBuilder.toString(), JsonObject.class);

        Users usersRepo = null;
        UserVouchers userVouchersRepo = null;
        Vouchers vouchersRepo = null;

        try {
            usersRepo = new Users();
            userVouchersRepo = new UserVouchers();
            vouchersRepo = new Vouchers();

            String customerPhone = getStringOrNull(requestData, "customerPhone");
            String totalAmountStr = getStringOrNull(requestData, "totalAmount");

            if (customerPhone == null || customerPhone.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Customer phone is required to lookup vouchers\"}");
                return;
            }

            BigDecimal totalAmount = BigDecimal.ZERO;
            if (totalAmountStr != null && !totalAmountStr.trim().isEmpty()) {
                totalAmount = new BigDecimal(totalAmountStr.trim());
            }

            if (totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
                response.getWriter().write("{\"success\":false,\"message\":\"Total amount must be greater than 0\"}");
                return;
            }

            User customer = usersRepo.findByPhone(customerPhone.trim());
            if (customer == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No customer found with this phone number\"}");
                return;
            }

            List<UserVoucher> available = userVouchersRepo.getAvailableVouchersByUserId(customer.getUserId());
            if (available.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Customer has no available vouchers\"}");
                return;
            }

            JsonArray vouchersJson = new JsonArray();
            Voucher bestVoucher = null;
            UserVoucher bestUserVoucher = null;
            BigDecimal bestEffectiveDiscount = BigDecimal.ZERO;

            LocalDateTime now = LocalDateTime.now();

            for (UserVoucher uv : available) {
                Voucher v = vouchersRepo.getVoucherById(uv.getVoucherId());
                if (v == null || Boolean.FALSE.equals(v.getIsActive())) {
                    continue;
                }

                BigDecimal baseDiscount = v.getDiscountAmount() != null ? v.getDiscountAmount() : BigDecimal.ZERO;
                if (baseDiscount.compareTo(BigDecimal.ZERO) <= 0) {
                    continue;
                }

                // Không cho giảm quá tổng tiền
                BigDecimal effectiveDiscount = baseDiscount;
                if (effectiveDiscount.compareTo(totalAmount) > 0) {
                    effectiveDiscount = totalAmount;
                }

                JsonObject vJson = new JsonObject();
                vJson.addProperty("voucherCode", uv.getVoucherCode());
                vJson.addProperty("voucherName", v.getVoucherName());
                vJson.addProperty("voucherType", v.getVoucherType());
                vJson.addProperty("baseDiscount", baseDiscount.toPlainString());
                vJson.addProperty("effectiveDiscount", effectiveDiscount.toPlainString());
                vJson.addProperty("status", uv.getStatus());
                if (uv.getExpiresAt() != null) {
                    vJson.addProperty("expiresAt", uv.getExpiresAt().toString());
                }
                vouchersJson.add(vJson);

                // Chọn voucher "hời nhất": discount cao nhất, nếu bằng nhau thì ưu tiên sắp hết hạn trước
                if (effectiveDiscount.compareTo(bestEffectiveDiscount) > 0) {
                    bestEffectiveDiscount = effectiveDiscount;
                    bestVoucher = v;
                    bestUserVoucher = uv;
                } else if (effectiveDiscount.compareTo(bestEffectiveDiscount) == 0
                        && bestUserVoucher != null
                        && uv.getExpiresAt() != null
                        && (bestUserVoucher.getExpiresAt() == null || uv.getExpiresAt().isBefore(bestUserVoucher.getExpiresAt()))) {
                    bestVoucher = v;
                    bestUserVoucher = uv;
                }
            }

            JsonObject resp = new JsonObject();
            resp.addProperty("success", true);
            resp.add("vouchers", vouchersJson);

            if (bestVoucher != null && bestUserVoucher != null && bestEffectiveDiscount.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal finalAmount = totalAmount.subtract(bestEffectiveDiscount);
                if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                    finalAmount = BigDecimal.ZERO;
                }
                resp.addProperty("bestVoucherCode", bestUserVoucher.getVoucherCode());
                resp.addProperty("bestVoucherName", bestVoucher.getVoucherName());
                resp.addProperty("bestDiscount", bestEffectiveDiscount.toPlainString());
                resp.addProperty("finalAmount", finalAmount.toPlainString());
            }

            response.getWriter().write(gson.toJson(resp));

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[CounterBestVoucher] Error selecting best voucher", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Error selecting vouchers: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            if (usersRepo != null) {
                usersRepo.closeConnection();
            }
            if (userVouchersRepo != null) {
                userVouchersRepo.closeConnection();
            }
            if (vouchersRepo != null) {
                vouchersRepo.closeConnection();
            }
        }
    }

    private static String getStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) {
            return null;
        }
        return obj.get(key).getAsString();
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

