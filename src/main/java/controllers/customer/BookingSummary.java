package controllers.customer;

import java.io.IOException;

import models.PointHistory;
import models.User;
import models.Showtime;
import repositories.Showtimes;
import repositories.OnlineTickets;
import repositories.Bookings;
import repositories.Invoices;
import repositories.LoyaltyConfigs;
import repositories.PointHistories;
import repositories.Users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.User;
import repositories.Bookings;

@WebServlet(name = "BookingSummary", urlPatterns = { "/customer/booking-summary" })
public class BookingSummary extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingSummary.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        String showtimeIdParam = request.getParameter("showtimeId");

        if (showtimeIdParam == null || showtimeIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }

        String successParam = request.getParameter("success");
        boolean isSuccessRedirect = "1".equals(successParam);

        // Hiển thị lỗi từ session (khi redirect từ doPost)
        if (session.getAttribute("paymentError") != null) {
            request.setAttribute("error", session.getAttribute("paymentError"));
            session.removeAttribute("paymentError");
        }

        // Khi success=1: hiển thị hóa đơn (dữ liệu từ session receipt)
        // Khi không success: cần customerBookingData từ booking-tickets
        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        List<Map<String, Object>> selectedSeats = new ArrayList<>();
        java.math.BigDecimal totalAmount = java.math.BigDecimal.ZERO;

        if (!isSuccessRedirect) {
            if (bookingData == null || !Integer.valueOf(showtimeIdParam).equals(bookingData.get("showtimeId"))) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeIdParam);
                return;
            }
            selectedSeats = (List<Map<String, Object>>) bookingData.get("seats");
            totalAmount = (java.math.BigDecimal) bookingData.get("totalAmount");
            if (selectedSeats == null) selectedSeats = new ArrayList<>();
            if (totalAmount == null) totalAmount = java.math.BigDecimal.ZERO;
        }

        Showtimes showtimesRepo = null;

        try {

            int showtimeId = Integer.parseInt(showtimeIdParam);

            showtimesRepo = new Showtimes();

            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);

            if(showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            User user = (User) session.getAttribute("user");
            request.setAttribute("customerName", user != null && user.getFullName() != null ? user.getFullName() : "");
            request.setAttribute("customerEmail", user != null && user.getEmail() != null ? user.getEmail() : "");

            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));
            request.setAttribute("selectedSeats", selectedSeats != null ? selectedSeats : new ArrayList<>());
            request.setAttribute("totalAmount", totalAmount != null ? totalAmount : java.math.BigDecimal.ZERO);
            List<Map<String, Object>> concessions = (List<Map<String, Object>>) (bookingData != null ? bookingData.get("concessions") : null);
            request.setAttribute("selectedConcessions", concessions != null ? concessions : new ArrayList<>());
            java.math.BigDecimal ticketTotalAttr = bookingData != null ? (java.math.BigDecimal) bookingData.get("ticketTotal") : null;
            java.math.BigDecimal concessionTotalAttr = bookingData != null ? (java.math.BigDecimal) bookingData.get("concessionTotal") : null;
            if (ticketTotalAttr == null) ticketTotalAttr = totalAmount;
            if (concessionTotalAttr == null) concessionTotalAttr = java.math.BigDecimal.ZERO;
            request.setAttribute("ticketTotal", ticketTotalAttr);
            request.setAttribute("concessionTotal", concessionTotalAttr);

            Showtime st = (Showtime) showtimeDetails.get("showtime");

            if (st != null) {

                if (st.getShowDate() != null) {
                    request.setAttribute("showDateFormatted",
                            st.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }

                if (st.getStartTime() != null) {
                    request.setAttribute("showTimeFormatted",
                            st.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
            }

            // Hiển thị hóa đơn sau thanh toán thành công (redirect với success=1)
            if (isSuccessRedirect) {
                request.setAttribute("paymentSuccess", true);
                request.setAttribute("receiptBookingCode", session.getAttribute("receiptBookingCode"));
                request.setAttribute("receiptInvoiceCode", session.getAttribute("receiptInvoiceCode"));
                request.setAttribute("receiptSeats", session.getAttribute("receiptSeats"));
                request.setAttribute("receiptTotal", session.getAttribute("receiptTotal"));
                session.removeAttribute("receiptBookingCode");
                session.removeAttribute("receiptInvoiceCode");
                session.removeAttribute("receiptSeats");
                session.removeAttribute("receiptTotal");
            }

            request.getRequestDispatcher("/pages/customer/booking-summary.jsp").forward(request, response);
        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("error", e.getMessage());

            request.getRequestDispatcher("/pages/customer/booking-summary.jsp")
                    .forward(request, response);

        } finally {

            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("user") == null){
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if(!"CUSTOMER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int customerId = currentUser.getUserId();

        // Lấy dữ liệu từ form (không dùng JSON/JavaScript)
        String customerName = request.getParameter("customerName");
        String customerEmail = request.getParameter("customerEmail");
        if (customerName == null || customerName.isBlank()) {
            customerName = currentUser.getFullName() != null ? currentUser.getFullName() : "";
        }
        if (customerEmail == null || customerEmail.isBlank()) {
            customerEmail = currentUser.getEmail() != null ? currentUser.getEmail() : "";
        }

        // Lấy dữ liệu đặt vé từ session (do booking-tickets lưu)
        @SuppressWarnings("unchecked")
        Map<String, Object> bookingData = (Map<String, Object>) session.getAttribute("customerBookingData");
        if (bookingData == null) {
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        int showtimeId = (Integer) bookingData.get("showtimeId");
        BigDecimal totalAmount = (BigDecimal) bookingData.get("totalAmount");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> seatsList = (List<Map<String, Object>>) bookingData.get("seats");

        if (seatsList == null || seatsList.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
            return;
        }

        // Disable DB insert/payment side effects for online booking.
        // Keep the selected seats in session and return to summary page.
        session.setAttribute("paymentError", "Chức năng xử lý thanh toán online đang tạm thời bị tắt.");
        response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);
        return;

        Showtimes showtimesRepo = null;
        OnlineTickets onlineTicketsRepo = null;
        Bookings bookingsRepo = null;
        Invoices invoicesRepo = null;
        try {
            showtimesRepo = new Showtimes();
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets?showtimeId=" + showtimeId);
                return;
            }

            String paymentMethod = "BANKING";

            bookingsRepo = new Bookings();
            String bookingCode = bookingsRepo.generateBookingCode();
                int bookingId = bookingsRepo.createOnlineBooking(customerId, showtimeId, paymentMethod, bookingCode);
            if (bookingId <= 0) {
                session.setAttribute("paymentError", "Không thể tạo đơn đặt vé.");
                response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);
                return;
            }

            onlineTicketsRepo = new OnlineTickets();
            List<Map<String, Object>> insertedTickets = new ArrayList<>();

            Showtime st = (Showtime) showtimeDetails.get("showtime");
            String movieTitle = (String) showtimeDetails.get("movieTitle");
            String roomName = (String) showtimeDetails.get("roomName");
            Integer branchId = (Integer) showtimeDetails.get("branchId");
            LocalDate showDate = st != null ? st.getShowDate() : null;
            LocalTime startTime = st != null ? st.getStartTime() : null;

            StringBuilder receiptSeatsStr = new StringBuilder();
            for (int i = 0; i < seatsList.size(); i++) {
                Map<String, Object> seatData = seatsList.get(i);
                int seatId = ((Number) seatData.get("seatId")).intValue();
                String seatType = (String) seatData.get("seatType");
                String ticketType = (String) seatData.get("ticketType");
                String seatCode = (String) seatData.get("seatCode");
                BigDecimal price = (BigDecimal) seatData.get("price");

                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    session.setAttribute("paymentError", "Ghế " + (seatCode != null ? seatCode : seatId) + " đã được đặt trước.");
                    response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);
                    return;
                }

                int ticketId = onlineTicketsRepo.insertOnlineTicket(bookingId, showtimeId, seatId, ticketType, seatType, price);
                if (ticketId > 0) {
                    Map<String, Object> row = new java.util.HashMap<>();
                    row.put("ticketId", ticketId);
                    row.put("seatCode", seatCode != null ? seatCode : "S" + seatId);
                    row.put("seatType", seatType);
                    row.put("ticketType", ticketType);
                    row.put("price", price);
                    insertedTickets.add(row);
                }
                String ticketLabel = "CHILD".equals(ticketType) ? "Trẻ em" : "Người lớn";
                if (i > 0) receiptSeatsStr.append(", ");
                receiptSeatsStr.append(seatCode).append(" (").append(ticketLabel).append(")");
            }

            String invoiceCode = "";
            if (branchId != null && branchId > 0) {
                invoicesRepo = new Invoices();
                invoiceCode = invoicesRepo.generateInvoiceCode();
                BigDecimal discountAmount = BigDecimal.ZERO;
                BigDecimal finalAmount = totalAmount;

                int invoiceId = invoicesRepo.insertInvoice(
                        bookingId, invoiceCode, "ONLINE",
                        customerName, currentUser.getPhone(), customerEmail,
                        branchId, totalAmount, discountAmount, finalAmount,
                        paymentMethod, customerId, null
                );

                if (invoiceId > 0) {
                    for (Map<String, Object> ticket : insertedTickets) {
                        int ticketId = (int) ticket.get("ticketId");
                        String seatCode = (String) ticket.get("seatCode");
                        String seatType = (String) ticket.get("seatType");
                        String ticketType = (String) ticket.get("ticketType");
                        BigDecimal price = (BigDecimal) ticket.get("price");
                        if (price == null) price = BigDecimal.ZERO;

                        String itemDesc = (movieTitle != null ? movieTitle : "") + " - " + (seatType != null ? seatType : "") + " - " + (seatCode != null ? seatCode : "");
                        try {
                            invoicesRepo.insertInvoiceItem(
                                    invoiceId, ticketId, itemDesc,
                                    movieTitle, showDate, startTime,
                                    roomName, seatCode, ticketType, seatType,
                                    price, price
                            );
                        } catch (Exception ex) {
                            LOGGER.log(Level.WARNING, "insertInvoiceItem failed for ticketId=" + ticketId + ", invoiceId=" + invoiceId, ex);
                        }
                    }
                }

                // Tích điểm thành viên từ hóa đơn (theo cấu hình admin)
                if (invoiceId > 0 && totalAmount != null && totalAmount.compareTo(BigDecimal.ZERO) > 0) {
                    LoyaltyConfigs loyaltyConfigs = null;
                    Users usersRepoLoyalty = null;
                    PointHistories pointHistoriesRepo = null;
                    try {
                        loyaltyConfigs = new LoyaltyConfigs();
                        var config = loyaltyConfigs.getConfig();
                        if (config != null && config.getEarnRateAmount() != null
                                && config.getEarnRateAmount().compareTo(BigDecimal.ZERO) > 0
                                && config.getEarnPoints() != null && config.getEarnPoints() > 0) {
                            BigDecimal rate = config.getEarnRateAmount();
                            int earnPointsPerRate = config.getEarnPoints();
                            int earnedPoints = totalAmount.divide(rate, 0, RoundingMode.FLOOR).intValue() * earnPointsPerRate;
                            if (earnedPoints > 0) {
                                usersRepoLoyalty = new Users();
                                if (usersRepoLoyalty.addPoints(customerId, earnedPoints)) {
                                    pointHistoriesRepo = new PointHistories();
                                    PointHistory ph = new PointHistory();
                                    ph.setUserId(customerId);
                                    ph.setPointsChanged(earnedPoints);
                                    ph.setTransactionType("EARN");
                                    ph.setDescription("Tích điểm từ hóa đơn #" + invoiceCode);
                                    ph.setReferenceId(invoiceId);
                                    pointHistoriesRepo.insert(ph);
                                }
                            }
                        }
                    } catch (Exception ex) {
                        LOGGER.log(Level.WARNING, "[BookingSummary] Loyalty points failed", ex);
                    } finally {
                        if (pointHistoriesRepo != null) pointHistoriesRepo.closeConnection();
                        if (usersRepoLoyalty != null) usersRepoLoyalty.closeConnection();
                        if (loyaltyConfigs != null) loyaltyConfigs.closeConnection();
                    }
                }
            }

            // Xóa dữ liệu đặt vé khỏi session, lưu thông tin hóa đơn để hiển thị
            session.removeAttribute("customerBookingData");
            session.setAttribute("receiptBookingCode", bookingCode);
            session.setAttribute("receiptInvoiceCode", invoiceCode);
            session.setAttribute("receiptSeats", receiptSeatsStr.toString());
            session.setAttribute("receiptTotal", totalAmount);

            response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId + "&success=1");

        } catch (Exception e) {

            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "[OnlineBookingPayment] Payment error", e);
            session.setAttribute("paymentError", "Lỗi thanh toán: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/customer/booking-summary?showtimeId=" + showtimeId);
        } finally {
            if (invoicesRepo != null) {
                invoicesRepo.closeConnection();
            }
            if (onlineTicketsRepo != null) {
                onlineTicketsRepo.closeConnection();
            }
            if (bookingsRepo != null) {
                bookingsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
}