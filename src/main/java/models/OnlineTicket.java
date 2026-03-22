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
    private LocalDateTime createdAt; // thoi gian tao ve
}