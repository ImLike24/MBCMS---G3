package models;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OnlineTicket {
    private Integer ticketId; // moi seat tao thanh cong = 1  record rieng
    private Integer bookingId; // 1 booking = n ticket (1 hay nhieu seat)
    private Integer showtimeId; // showtimeId de lay thong tin ve phim, rap, thoi gian chieu
    private Integer seatId; // ma so ghe
    private String ticketType; // loai ve (adult, child)
    private String seatType; // normal, vip, couple
    private BigDecimal price; // gia ve sau khi tinh giam gia
    private String eTicketCode; // ma ve dien tu (unique) de check-in
    private boolean isCheckedIn = false; // trang thai da vao rap hay chua
    private LocalDateTime checkedInAt; // thoi gian check-in
    private Integer checkedInBy; // ma nhan vien check-in (neu co), de phan biet check-in tu app hay tu counter
    private LocalDateTime createdAt; // thoi gian tao ve
}