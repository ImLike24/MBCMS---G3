/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers.customer;

import java.io.IOException;
import java.io.PrintWriter;

import models.User;
import models.Showtime;
import models.OnlineTicket;

// repositories
import repositories.Showtimes;
import repositories.OnlineTickets;
import repositories.Bookings;

import com.google.gson.JsonObject;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import jakarta.servlet.RequestDispatcher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author ducanhtran
 */
@WebServlet(name = "BookingPayment", urlPatterns = {"/customer/booking-payment"})
public class BookingPayment extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(BookingPayment.class.getName());
    
    @Override
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("user") == null){
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if(!"CUSTOMER".equals(role)){
            response.sendRedirect(request.getContextPath() + "/access-denied");
            return;
        }
        
        String showtimeIdParam = request.getParameter("showtimeId");
        if(showtimeIdParam == null || showtimeIdParam.isEmpty()){
            response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
            return;
        }
        
        Showtimes showtimesRepo = null;
        
        try {
            int showtimeId = Integer.parseInt(showtimeIdParam);
            showtimesRepo = new Showtimes();
            
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            
            if(showtimeDetails.isEmpty()) {
                request.setAttribute("error", "Showtime not found");
                response.sendRedirect(request.getContextPath() + "/customer/booking-tickets");
                return;
            }
            
            request.setAttribute("showtimeDetails", showtimeDetails);
            request.setAttribute("showtimeId", showtimeId);
            request.setAttribute("movieTitle", showtimeDetails.get("movieTitle"));
            request.setAttribute("branchName", showtimeDetails.get("branchName"));
            Showtime st = (Showtime) showtimeDetails.get("showtime");
            if (st != null) {
                if (st.getShowDate() != null) {
                    request.setAttribute("showDateFormatted", st.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                }
                if (st.getStartTime() != null) {
                    request.setAttribute("showTimeFormatted", st.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")));
                }
            }
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading payment page: " + e.getMessage());
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
        } finally {
            if(showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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

        User currentUser = (User) session.getAttribute("user");
        int customerId = currentUser.getUserId();

        // Đọc JSON body
        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }

        Gson gson = new Gson();
<<<<<<< Updated upstream
        JsonObject requestData = gson.fromJson(jsonBuilder.toString(), JsonObject.class);
        
=======
        String jsonBody = jsonBuilder.toString();
        if (jsonBody.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Thiếu dữ liệu đặt vé.");
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
            return;
        }

        JsonObject requestData = gson.fromJson(jsonBody, JsonObject.class);
        if (requestData == null) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
            return;
        }

>>>>>>> Stashed changes
        Showtimes showtimesRepo = null;
        OnlineTickets onlineTicketsRepo = null;
        Bookings bookingsRepo = null;

        try {
            int showtimeId = requestData.get("showtimeId").getAsInt();
            JsonArray seatsArray = requestData.has("seats") ? requestData.getAsJsonArray("seats") : new JsonArray();
            BigDecimal totalAmount = requestData.has("totalAmount")
                    ? new BigDecimal(requestData.get("totalAmount").getAsString())
                    : BigDecimal.ZERO;

            if (seatsArray.size() == 0) {
                request.setAttribute("errorMessage", "Chưa chọn ghế.");
                request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
                return;
            }

            showtimesRepo = new Showtimes();
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(showtimeId);
            if (showtimeDetails == null || showtimeDetails.isEmpty()) {
                request.setAttribute("errorMessage", "Suất chiếu không tồn tại.");
                request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
                return;
            }

            // Kiểm tra ghế còn trống
            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seatObj = seatsArray.get(i).getAsJsonObject();
                int seatId = seatObj.get("seatId").getAsInt();
                if (!showtimesRepo.isSeatAvailable(showtimeId, seatId)) {
                    String seatCode = seatObj.has("seatCode") ? seatObj.get("seatCode").getAsString() : "unknown";
                    request.setAttribute("errorMessage", "Ghế " + seatCode + " đã được đặt trước.");
                    request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
                    return;
                }
            }

            // Tạo booking tạm thời (PENDING)
            bookingsRepo = new Bookings();
            String bookingCode = bookingsRepo.generateBookingCode();
            String paymentMethod = "VNPAY_PENDING";
            int bookingId = bookingsRepo.createOnlineBooking(customerId, showtimeId, paymentMethod, bookingCode);

            if (bookingId <= 0) {
                request.setAttribute("errorMessage", "Không thể tạo đơn đặt chỗ tạm thời.");
                request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
                return;
            }

            // Lưu vé tạm thời
            onlineTicketsRepo = new OnlineTickets();
            for (int i = 0; i < seatsArray.size(); i++) {
                JsonObject seatObj = seatsArray.get(i).getAsJsonObject();
                int seatId = seatObj.get("seatId").getAsInt();
                String seatType = seatObj.get("seatType").getAsString();
                String ticketType = seatObj.get("ticketType").getAsString();
                BigDecimal price = seatObj.has("price")
                        ? new BigDecimal(seatObj.get("price").getAsString())
                        : BigDecimal.ZERO;

                onlineTicketsRepo.insertOnlineTicket(bookingId, showtimeId, seatId, ticketType, seatType, price);
            }

<<<<<<< Updated upstream
            JsonObject respJson = new JsonObject();
            respJson.addProperty("success", true);
            respJson.addProperty("message", "Thanh toán thành công.");
            respJson.addProperty("eTicketCode", bookingCode);
            respJson.addProperty("totalAmount", totalAmount.toPlainString());
=======
            // Lưu thông tin cần cho trang VNPAY
            request.setAttribute("vnpay_total_amount", totalAmount);
            request.setAttribute("vnpay_booking_code", bookingCode);
            // Nếu cần truyền thêm: phim, rạp, giờ chiếu... thì set thêm attribute
>>>>>>> Stashed changes

            // Forward thẳng đến trang VNPAY
            RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/payment/vnpay_create_order.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/pages/customer/booking-payment.jsp").forward(request, response);
        } finally {
            if (onlineTicketsRepo != null) onlineTicketsRepo.closeConnection();
            if (bookingsRepo != null) bookingsRepo.closeConnection();
            if (showtimesRepo != null) showtimesRepo.closeConnection();
        }
    }
    
}
