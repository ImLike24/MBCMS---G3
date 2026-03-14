package services;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.CounterTicket;
import models.PointHistory;
import models.User;
import models.UserVoucher;
import models.Voucher;
import repositories.CounterTickets;
import repositories.PointHistories;
import repositories.Roles;
import repositories.Showtimes;
import repositories.UserVouchers;
import repositories.Users;
import repositories.Vouchers;

/**
 * Business logic for counter booking payment (quầy).
 * Handles ticket creation, voucher application and loyalty points.
 */
public class CounterBookingService {

    private static final Logger LOGGER = Logger.getLogger(CounterBookingService.class.getName());

    /**
     * Xử lý thanh toán cho quầy.
     *
     * @param requestData JSON đã parse từ body
     * @param staffId     user_id của staff đang thao tác
     * @return JsonObject chứa kết quả (success, message, ticketCode, totals, ...)
     */
    public JsonObject processPayment(JsonObject requestData, int staffId) {
        JsonObject resp = new JsonObject();

        CounterTickets counterTicketsRepo = null;
        Showtimes showtimesRepo = null;
        Vouchers vouchersRepo = null;
        UserVouchers userVouchersRepo = null;

        try {
            int showtimeId = requestData.get("showtimeId").getAsInt();
            String paymentMethod = requestData.get("paymentMethod").getAsString();
            String customerName = getStringOrNull(requestData, "customerName");
            String customerPhone = getStringOrNull(requestData, "customerPhone");
            String customerEmail = getStringOrNull(requestData, "customerEmail");
            String voucherCode = getStringOrNull(requestData, "voucherCode");

            int redeemPointsRequested = 0;
            if (requestData.has("redeemPoints") && !requestData.get("redeemPoints").isJsonNull()) {
                try {
                    redeemPointsRequested = Math.max(0, requestData.get("redeemPoints").getAsInt());
                } catch (Exception ignore) {
                    redeemPointsRequested = 0;
                }
            }

            JsonArray seatsArray = requestData.getAsJsonArray("seats");

            // Validate payment method
            if (!"CASH".equals(paymentMethod) && !"BANKING".equals(paymentMethod)) {
                resp.addProperty("success", false);
                resp.addProperty("message", "Invalid payment method");
                return resp;
            }

            counterTicketsRepo = new CounterTickets();
            showtimesRepo = new Showtimes();

            // Generate unique ticket code for this transaction
            String ticketCode = counterTicketsRepo.generateTicketCode();

            // Get showtime details for price calculation
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            BigDecimal basePrice = ((models.Showtime) showtimeDetails.get("showtime")).getBasePrice();

            // Prepare counter tickets in memory first (no DB writes yet)
            List<Integer> ticketIds = new ArrayList<>();
            List<CounterTicket> ticketsToCreate = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;
            BigDecimal discountAmount = BigDecimal.ZERO; // voucher discount
            BigDecimal pointDiscount = BigDecimal.ZERO;  // discount from loyalty points
            BigDecimal finalAmount = null;

            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seatObj = seatsArray.get(i).getAsJsonObject();

                int seatId = seatObj.get("seatId").getAsInt();
                String seatType = seatObj.get("seatType").getAsString();
                String ticketType = seatObj.get("ticketType").getAsString();

                // Verify seat is still available
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    resp.addProperty("success", false);
                    resp.addProperty("message",
                            "Seat " + seatObj.get("seatCode").getAsString() + " is no longer available");
                    return resp;
                }

                // Calculate price
                BigDecimal price = basePrice;

                // Adjust for seat type
                if ("VIP".equals(seatType)) {
                    price = price.multiply(new BigDecimal("1.5"));
                } else if ("COUPLE".equals(seatType)) {
                    price = price.multiply(new BigDecimal("2.0"));
                }

                // Adjust for ticket type
                if ("CHILD".equals(ticketType)) {
                    price = price.multiply(new BigDecimal("0.7"));
                }

                // Round to 2 decimal places
                price = price.setScale(2, RoundingMode.HALF_UP);

                totalAmount = totalAmount.add(price);

                // Prepare counter ticket object (will insert later after voucher validation)
                CounterTicket ticket = new CounterTicket();
                ticket.setShowtimeId(showtimeId);
                ticket.setSeatId(seatId);
                ticket.setTicketType(ticketType);
                ticket.setSeatType(seatType);
                ticket.setPrice(price);
                ticket.setSoldBy(staffId);
                ticket.setPaymentMethod(paymentMethod);
                ticket.setCustomerName(customerName);
                ticket.setCustomerPhone(customerPhone);
                ticket.setCustomerEmail(customerEmail);
                ticket.setTicketCode(ticketCode + "-" + (i + 1));

                ticketsToCreate.add(ticket);
            }

            // Apply voucher discount to total bill if voucher code is provided
            String appliedVoucherCode = null;
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                vouchersRepo = new Vouchers();
                userVouchersRepo = new UserVouchers();

                String trimmedCode = voucherCode.trim();
                Voucher voucher = null;

                UserVoucher uv = userVouchersRepo.getVoucherByCode(trimmedCode);
                if (uv != null) {
                    if (!"AVAILABLE".equalsIgnoreCase(uv.getStatus())) {
                        JsonObject error = new JsonObject();
                        error.addProperty("success", false);
                        error.addProperty("message", "Voucher is not available for use");
                        return error;
                    }
                    if (uv.getExpiresAt() != null && uv.getExpiresAt().isBefore(LocalDateTime.now())) {
                        JsonObject error = new JsonObject();
                        error.addProperty("success", false);
                        error.addProperty("message", "Voucher has expired");
                        return error;
                    }

                    voucher = vouchersRepo.getVoucherById(uv.getVoucherId());
                } else {
                    voucher = vouchersRepo.getActiveVoucherByCode(trimmedCode);
                }

                if (voucher == null || Boolean.FALSE.equals(voucher.getIsActive())) {
                    JsonObject error = new JsonObject();
                    error.addProperty("success", false);
                    error.addProperty("message", "Invalid or inactive voucher code");
                    return error;
                }

                if (voucher.getDiscountAmount() != null) {
                    discountAmount = voucher.getDiscountAmount();
                    if (discountAmount.compareTo(BigDecimal.ZERO) < 0) {
                        discountAmount = BigDecimal.ZERO;
                    }
                    if (discountAmount.compareTo(totalAmount) > 0) {
                        discountAmount = totalAmount;
                    }
                }
                appliedVoucherCode = trimmedCode;
            }

            // Now actually create counter tickets in DB (only after all validations pass)
            for (CounterTicket ticket : ticketsToCreate) {
                int ticketId = counterTicketsRepo.createCounterTicket(ticket);

                if (ticketId > 0) {
                    ticketIds.add(ticketId);
                } else {
                    String dbError = counterTicketsRepo.getLastErrorMessage();
                    String msg = dbError != null ? "Failed to create ticket: " + dbError : "Failed to create ticket";
                    LOGGER.log(Level.SEVERE,
                            "[CounterBookingService] createCounterTicket failed for seatId={0}, ticketCode={1}, dbError={2}",
                            new Object[] { ticket.getSeatId(), ticket.getTicketCode(), dbError });
                    JsonObject error = new JsonObject();
                    error.addProperty("success", false);
                    error.addProperty("message", msg);
                    return error;
                }
            }

            // Loyalty: find/create user, redeem points, then earn new points
            try {
                String trimmedPhone = customerPhone != null ? customerPhone.trim() : null;
                if (trimmedPhone != null && !trimmedPhone.isEmpty()) {
                    Users usersRepo = null;
                    Roles rolesRepo = null;
                    PointHistories pointHistoriesRepo = null;
                    try {
                        usersRepo = new Users();
                        rolesRepo = new Roles();
                        pointHistoriesRepo = new PointHistories();

                        User loyaltyUser = usersRepo.findByPhone(trimmedPhone);

                        if (loyaltyUser == null) {
                            Integer customerRoleId = rolesRepo.getRoleIdByName("CUSTOMER");
                            if (customerRoleId != null) {
                                loyaltyUser = new User();
                                loyaltyUser.setRoleId(customerRoleId);
                                loyaltyUser.setUsername("guest_" + trimmedPhone);

                                String emailToUse = (customerEmail != null && !customerEmail.trim().isEmpty())
                                        ? customerEmail.trim()
                                        : "guest_" + trimmedPhone + "@guest.local";

                                if (usersRepo.checkEmailExists(emailToUse)) {
                                    emailToUse = "guest_" + trimmedPhone + "_" + UUID.randomUUID() + "@guest.local";
                                }

                                loyaltyUser.setEmail(emailToUse);
                                loyaltyUser.setPassword(UUID.randomUUID().toString());
                                loyaltyUser.setFullName(customerName);
                                loyaltyUser.setPhone(trimmedPhone);
                                loyaltyUser.setStatus("ACTIVE");
                                loyaltyUser.setPoints(0);
                                loyaltyUser.setTotalAccumulatedPoints(0);
                                loyaltyUser.setTierId(1);

                                if (usersRepo.insert(loyaltyUser)) {
                                    loyaltyUser = usersRepo.findByPhone(trimmedPhone);
                                } else {
                                    loyaltyUser = null;
                                }
                            }
                        }

                        if (loyaltyUser != null) {
                            int currentPoints = loyaltyUser.getPoints() != null ? loyaltyUser.getPoints() : 0;

                            // 1) Redeem points if requested
                            int redeemPointsToUse = 0;
                            if (redeemPointsRequested > 0 && currentPoints > 0) {
                                BigDecimal amountAfterVoucher = totalAmount.subtract(discountAmount);
                                if (amountAfterVoucher.compareTo(BigDecimal.ZERO) > 0) {
                                    int maxPointsFromAmount = amountAfterVoucher
                                            .divide(new BigDecimal("1000"), 0, RoundingMode.FLOOR)
                                            .intValue();
                                    redeemPointsToUse = Math.min(redeemPointsRequested,
                                            Math.min(currentPoints, maxPointsFromAmount));
                                }
                            }

                            if (redeemPointsToUse > 0
                                    && usersRepo.redeemPoints(loyaltyUser.getUserId(), redeemPointsToUse)) {
                                pointDiscount = new BigDecimal(redeemPointsToUse).multiply(new BigDecimal("1000"));

                                PointHistory redeemHistory = new PointHistory();
                                redeemHistory.setUserId(loyaltyUser.getUserId());
                                redeemHistory.setPointsChanged(-redeemPointsToUse);
                                redeemHistory.setTransactionType("REDEEM");
                                redeemHistory.setDescription("Redeem points for counter ticket " + ticketCode);
                                redeemHistory.setReferenceId(ticketIds.isEmpty() ? null : ticketIds.get(0));
                                pointHistoriesRepo.insert(redeemHistory);
                            }

                            // 2) Earn new points on the final payable amount (after voucher & points)
                            BigDecimal effectiveFinalAmount = totalAmount
                                    .subtract(discountAmount)
                                    .subtract(pointDiscount);
                            if (effectiveFinalAmount.compareTo(BigDecimal.ZERO) < 0) {
                                effectiveFinalAmount = BigDecimal.ZERO;
                            }

                            int earnedPoints = effectiveFinalAmount
                                    .divide(new BigDecimal("1000"), 0, RoundingMode.FLOOR)
                                    .intValue();

                            if (earnedPoints > 0
                                    && usersRepo.addPoints(loyaltyUser.getUserId(), earnedPoints)) {
                                PointHistory earnHistory = new PointHistory();
                                earnHistory.setUserId(loyaltyUser.getUserId());
                                earnHistory.setPointsChanged(earnedPoints);
                                earnHistory.setTransactionType("EARN");
                                earnHistory.setDescription("Earn points from counter ticket " + ticketCode);
                                earnHistory.setReferenceId(ticketIds.isEmpty() ? null : ticketIds.get(0));
                                pointHistoriesRepo.insert(earnHistory);
                            }

                            finalAmount = totalAmount.subtract(discountAmount).subtract(pointDiscount);
                            if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                                finalAmount = BigDecimal.ZERO;
                            }
                        } else {
                            finalAmount = totalAmount.subtract(discountAmount);
                            if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                                finalAmount = BigDecimal.ZERO;
                            }
                        }
                    } finally {
                        if (usersRepo != null) {
                            usersRepo.closeConnection();
                        }
                        if (rolesRepo != null) {
                            rolesRepo.closeConnection();
                        }
                        if (pointHistoriesRepo != null) {
                            pointHistoriesRepo.closeConnection();
                        }
                    }
                }
            } catch (Exception loyaltyEx) {
                LOGGER.log(Level.WARNING, "[CounterBookingService] Loyalty point processing failed", loyaltyEx);
                if (finalAmount == null) {
                    finalAmount = totalAmount.subtract(discountAmount);
                    if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                        finalAmount = BigDecimal.ZERO;
                    }
                }
            }

            if (finalAmount == null) {
                finalAmount = totalAmount.subtract(discountAmount).subtract(pointDiscount);
                if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                    finalAmount = BigDecimal.ZERO;
                }
            }

            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("message", "Booking completed successfully");
            successResponse.addProperty("ticketCode", ticketCode);
            successResponse.addProperty("totalAmount", totalAmount.toString());
            BigDecimal totalDiscountForResponse = discountAmount.add(pointDiscount);
            successResponse.addProperty("discountAmount", totalDiscountForResponse.toString());
            successResponse.addProperty("finalAmount", finalAmount.toString());
            if (appliedVoucherCode != null) {
                successResponse.addProperty("appliedVoucherCode", appliedVoucherCode);
            }
            successResponse.addProperty("ticketCount", ticketIds.size());

            JsonArray ticketIdsArray = new JsonArray();
            for (Integer id : ticketIds) {
                ticketIdsArray.add(id);
            }
            successResponse.add("ticketIds", ticketIdsArray);

            return successResponse;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[CounterBookingService] Payment error", e);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", e.getMessage());
            return error;
        } finally {
            if (counterTicketsRepo != null) {
                counterTicketsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
            if (vouchersRepo != null) {
                vouchersRepo.closeConnection();
            }
            if (userVouchersRepo != null) {
                userVouchersRepo.closeConnection();
            }
        }
    }

    private static String getStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) {
            return null;
        }
        return obj.get(key).getAsString();
    }
}

