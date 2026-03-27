package services;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import models.User;
import models.UserVoucher;
import models.Voucher;
import repositories.UserVouchers;
import repositories.Users;
import repositories.Vouchers;

/**
 * Business logic for suggesting the best voucher for counter booking.
 * Servlet should delegate to this service and only handle HTTP concerns.
 */
public class CounterVoucherService {

    /**
     * Validate a voucher code for counter booking.
     * Checks PUBLIC vouchers first, then personal vouchers by phone.
     *
     * @param voucherCode   the code staff entered
     * @param customerPhone optional phone number of the customer
     * @param totalAmount   current bill total
     * @return JsonObject with success, discount, voucherName, message
     */
    public JsonObject validateVoucherCode(String voucherCode, String customerPhone, BigDecimal totalAmount) {
        JsonObject resp = new JsonObject();

        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            resp.addProperty("success", false);
            resp.addProperty("message", "Vui lòng nhập mã voucher");
            return resp;
        }

        Vouchers vouchersRepo = null;
        UserVouchers userVouchersRepo = null;
        Users usersRepo = null;

        try {
            vouchersRepo = new Vouchers();
            userVouchersRepo = new UserVouchers();

            // 1. Check PUBLIC voucher (matches voucher_code directly)
            Voucher publicV = vouchersRepo.getActiveVoucherByCode(voucherCode.trim());
            if (publicV != null && "PUBLIC".equalsIgnoreCase(publicV.getVoucherType())) {
                BigDecimal discount = publicV.getDiscountAmount() != null ? publicV.getDiscountAmount() : BigDecimal.ZERO;
                if (totalAmount != null && discount.compareTo(totalAmount) > 0) {
                    discount = totalAmount;
                }
                resp.addProperty("success", true);
                resp.addProperty("voucherType", "PUBLIC");
                resp.addProperty("voucherName", publicV.getVoucherName() != null ? publicV.getVoucherName() : voucherCode.trim());
                resp.addProperty("discount", discount.toPlainString());
                return resp;
            }

            // 2. Check personal voucher in user_vouchers by code
            UserVoucher uv = userVouchersRepo.getVoucherByCode(voucherCode.trim());
            if (uv != null && "AVAILABLE".equalsIgnoreCase(uv.getStatus())) {
                // If phone provided, verify it belongs to that customer
                if (customerPhone != null && !customerPhone.trim().isEmpty()) {
                    usersRepo = new Users();
                    User customer = usersRepo.findByPhone(customerPhone.trim());
                    if (customer == null || customer.getUserId() != uv.getUserId()) {
                        resp.addProperty("success", false);
                        resp.addProperty("message", "Voucher này không thuộc về khách hàng với số điện thoại đã nhập");
                        return resp;
                    }
                }
                Voucher v = vouchersRepo.getVoucherById(uv.getVoucherId());
                if (v != null && Boolean.TRUE.equals(v.getIsActive())) {
                    BigDecimal discount = v.getDiscountAmount() != null ? v.getDiscountAmount() : BigDecimal.ZERO;
                    if (totalAmount != null && discount.compareTo(totalAmount) > 0) {
                        discount = totalAmount;
                    }
                    resp.addProperty("success", true);
                    resp.addProperty("voucherType", "PERSONAL");
                    resp.addProperty("voucherName", v.getVoucherName() != null ? v.getVoucherName() : voucherCode.trim());
                    resp.addProperty("discount", discount.toPlainString());
                    return resp;
                }
            }

            resp.addProperty("success", false);
            resp.addProperty("message", "Không tìm thấy voucher này, vui lòng chọn voucher khác hoặc bỏ nhập voucher");
            return resp;

        } catch (Exception e) {
            resp.addProperty("success", false);
            resp.addProperty("message", "Lỗi khi kiểm tra voucher: " + e.getMessage());
            return resp;
        } finally {
            if (vouchersRepo != null) vouchersRepo.closeConnection();
            if (userVouchersRepo != null) userVouchersRepo.closeConnection();
            if (usersRepo != null) usersRepo.closeConnection();
        }
    }



    /**
     * Find all usable vouchers for a customer (by phone) and determine the best
     * one for a given bill total.
     *
     * @param customerPhone phone number of customer
     * @param totalAmount   current bill total (must be > 0)
     * @return JsonObject response payload (success, message, vouchers, bestVoucherCode, ...)
     */
    public JsonObject findBestVoucher(String customerPhone, BigDecimal totalAmount) {
        JsonObject resp = new JsonObject();

        if (customerPhone == null || customerPhone.trim().isEmpty()) {
            resp.addProperty("success", false);
            resp.addProperty("message", "Customer phone is required to lookup vouchers");
            return resp;
        }

        if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            resp.addProperty("success", false);
            resp.addProperty("message", "Total amount must be greater than 0");
            return resp;
        }

        Users usersRepo = null;
        UserVouchers userVouchersRepo = null;
        Vouchers vouchersRepo = null;

        try {
            usersRepo = new Users();
            userVouchersRepo = new UserVouchers();
            vouchersRepo = new Vouchers();

            User customer = usersRepo.findByPhone(customerPhone.trim());
            if (customer == null) {
                resp.addProperty("success", false);
                resp.addProperty("message", "No customer found with this phone number");
                return resp;
            }

            List<UserVoucher> available = userVouchersRepo.getAvailableVouchersByUserId(customer.getUserId());
            if (available.isEmpty()) {
                resp.addProperty("success", false);
                resp.addProperty("message", "Customer has no available vouchers");
                return resp;
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

                // Clamp discount to total amount
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

                // Pick best voucher: highest discount, tie-breaker by earliest expiry
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

            return resp;
        } catch (Exception e) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", "Error selecting vouchers: " + e.getMessage());
            return error;
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
}

