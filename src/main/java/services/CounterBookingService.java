package services;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.CounterTicket;
import models.PointHistory;
import models.SeatTypeSurcharge;
import models.Showtime;
import models.User;
import models.UserVoucher;
import models.Voucher;
import repositories.CounterTickets;
import repositories.PointHistories;
import repositories.Roles;
import repositories.SeatTypeSurcharges;
import repositories.Showtimes;
import repositories.TicketPrices;
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
        TicketPrices ticketPricesRepo = null;
        SeatTypeSurcharges seatTypeSurchargesRepo = null;

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

            // Parse concessions from request
            JsonArray concessionsArray = requestData.has("concessions") && !requestData.get("concessions").isJsonNull()
                    ? requestData.getAsJsonArray("concessions")
                    : new JsonArray();

            // Validate payment method (counter booking: cash only)
            if (!"CASH".equals(paymentMethod)) {
                resp.addProperty("success", false);
                resp.addProperty("message", "Invalid payment method (counter supports CASH only)");
                return resp;
            }

            counterTicketsRepo = new CounterTickets();
            showtimesRepo = new Showtimes();

            // Generate a reference code for this transaction (used in descriptions only, not stored in DB column)
            String ticketCode = counterTicketsRepo.generateTicketCode();

            // Get showtime details and branch info for price calculation
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            Integer branchId = (Integer) showtimeDetails.get("branchId");

            BigDecimal basePriceFromShowtime = (showtime != null && showtime.getBasePrice() != null)
                    ? showtime.getBasePrice()
                    : BigDecimal.ZERO;

            // Prepare dynamic ticket prices from configuration (ticket_prices) if possible
            BigDecimal adultPrice = null;
            BigDecimal childPrice = null;
            Map<String, Double> surchargeRates = new HashMap<>();

            if (showtime != null && branchId != null
                    && showtime.getShowDate() != null && showtime.getStartTime() != null) {

                DayOfWeek dayOfWeek = showtime.getShowDate().getDayOfWeek();
                String dayType = (dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY)
                        ? "WEEKEND"
                        : "WEEKDAY";

                int hour = showtime.getStartTime().getHour();
                String timeSlot;
                if (hour >= 6 && hour < 12) timeSlot = "MORNING";
                else if (hour >= 12 && hour < 17) timeSlot = "AFTERNOON";
                else if (hour >= 17 && hour < 22) timeSlot = "EVENING";
                else timeSlot = "NIGHT";

                ticketPricesRepo = new TicketPrices();
                adultPrice = ticketPricesRepo.getTicketPrice(branchId, "ADULT", dayType, timeSlot,
                        showtime.getShowDate());
                childPrice = ticketPricesRepo.getTicketPrice(branchId, "CHILD", dayType, timeSlot,
                        showtime.getShowDate());

                // Load seat-type surcharge rates for this branch
                seatTypeSurchargesRepo = new SeatTypeSurcharges();
                List<SeatTypeSurcharge> surchargeList = seatTypeSurchargesRepo.getSurchargesByBranch(branchId);
                if (surchargeList != null) {
                    for (SeatTypeSurcharge s : surchargeList) {
                        surchargeRates.put(s.getSeatType(), s.getSurchargeRate());
                    }
                }
            }

            // Fallbacks if config is missing
            if (adultPrice == null || adultPrice.compareTo(BigDecimal.ZERO) <= 0) {
                adultPrice = basePriceFromShowtime;
            }
            if (childPrice == null || childPrice.compareTo(BigDecimal.ZERO) <= 0) {
                childPrice = adultPrice;
            }

            // Prepare counter tickets in memory first (no DB writes yet)
            List<Integer> ticketIds = new ArrayList<>();
            List<CounterTicket> ticketsToCreate = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;
            BigDecimal discountAmount = BigDecimal.ZERO; // voucher discount
            BigDecimal pointDiscount = BigDecimal.ZERO;  // discount from loyalty points
            BigDecimal finalAmount = null;
            int pointsRedeemed = 0;

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

                // Calculate price using configured ticket_prices and seat_type_surcharges
                BigDecimal price = "CHILD".equals(ticketType) ? childPrice : adultPrice;

                // Adjust for seat type via surcharge rate (percent)
                Double rate = surchargeRates.get(seatType);
                if (rate != null && rate > 0) {
                    BigDecimal multiplier = BigDecimal.ONE.add(
                            BigDecimal.valueOf(rate).divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP));
                    price = price.multiply(multiplier);
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
                // ticket_code is not a DB column; omit setting it here

                ticketsToCreate.add(ticket);
            }

            // Add concession total to bill
            BigDecimal concessionTotal = BigDecimal.ZERO;
            for (int i = 0; i < concessionsArray.size(); i++) {
                JsonObject cObj = concessionsArray.get(i).getAsJsonObject();
                int qty = cObj.has("quantity") ? cObj.get("quantity").getAsInt() : 0;
                double priceBase = cObj.has("priceBase") ? cObj.get("priceBase").getAsDouble() : 0.0;
                if (qty > 0 && priceBase > 0) {
                    concessionTotal = concessionTotal.add(BigDecimal.valueOf(priceBase * qty));
                }
            }
            totalAmount = totalAmount.add(concessionTotal);

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
                                pointsRedeemed = redeemPointsToUse;
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

            // Persist discount info into notes so receipt can display them
            StringBuilder notesBuilder = new StringBuilder();
            notesBuilder.append("TOTAL:").append(totalAmount.toPlainString());
            if (appliedVoucherCode != null) {
                notesBuilder.append("|VOUCHER:").append(appliedVoucherCode)
                            .append(":").append(discountAmount.toPlainString());
            }
            if (pointsRedeemed > 0) {
                notesBuilder.append("|POINTS:").append(pointsRedeemed)
                            .append(":").append(pointDiscount.toPlainString());
            }
            notesBuilder.append("|FINAL:").append(finalAmount.toPlainString());
            // Persist concessions into notes
            for (int i = 0; i < concessionsArray.size(); i++) {
                JsonObject cObj = concessionsArray.get(i).getAsJsonObject();
                int qty = cObj.has("quantity") ? cObj.get("quantity").getAsInt() : 0;
                if (qty > 0) {
                    String cName = cObj.has("concessionName") ? cObj.get("concessionName").getAsString() : "";
                    double priceBase = cObj.has("priceBase") ? cObj.get("priceBase").getAsDouble() : 0.0;
                    notesBuilder.append("|ITEM:").append(cName)
                                .append(":").append(qty)
                                .append(":").append(priceBase);
                }
            }
            counterTicketsRepo.updateNotesByTicketIds(ticketIds, notesBuilder.toString());

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
            if (ticketPricesRepo != null) {
                ticketPricesRepo.closeConnection();
            }
            if (seatTypeSurchargesRepo != null) {
                seatTypeSurchargesRepo.closeConnection();
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

