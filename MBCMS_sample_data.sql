-- =============================================
-- MBCMS - DỮ LIỆU MẪU (SAMPLE DATA)
-- Chạy SAU khi đã chạy MBCMS.sql (schema + triggers).
-- Nếu đã chạy script này trước đó (dù bị lỗi giữa chừng): chạy block
-- "XÓA DỮ LIỆU MẪU" bên dưới trước, rồi mới chạy phần INSERT.
-- =============================================
USE MBCMS;
GO

-- ========== XÓA DỮ LIỆU MẪU (chạy block này trước khi INSERT lại) ==========
-- Thứ tự xóa phải tôn trọng FK, và cần phá vòng FK users <-> cinema_branches <-> roles

-- 1) Phá vòng FK giữa users và cinema_branches
UPDATE cinema_branches SET manager_id = NULL;
UPDATE users SET branch_id = NULL;

-- 2) Xóa dữ liệu từ bảng con lên bảng cha theo FK
DELETE FROM staff_schedules;
DELETE FROM reported_comments;
DELETE FROM invoice_items;
DELETE FROM invoices;
DELETE FROM revenue_reports;
-- DELETE FROM notifications; -- table not in schema
DELETE FROM reviews;
DELETE FROM counter_tickets;
DELETE FROM online_tickets;
DELETE FROM bookings;
DELETE FROM showtimes;
DELETE FROM movie_genres;
DELETE FROM ticket_prices;
DELETE FROM seat_type_surcharges;
DELETE FROM seats;
DELETE FROM screening_rooms;
DELETE FROM cinema_branches;
DELETE FROM movies;
DELETE FROM genres;
DELETE FROM point_history;
DELETE FROM user_vouchers;
DELETE FROM vouchers;
DELETE FROM users;
DELETE FROM roles;
GO

-- Reset identity về 0 cho các bảng có IDENTITY
-- (sau khi DELETE xong, reseed = 0 => lần INSERT tiếp theo sẽ bắt đầu từ 1)
DBCC CHECKIDENT ('roles', RESEED, 0);
DBCC CHECKIDENT ('users', RESEED, 0);
DBCC CHECKIDENT ('cinema_branches', RESEED, 0);
DBCC CHECKIDENT ('screening_rooms', RESEED, 0);
DBCC CHECKIDENT ('seats', RESEED, 0);
DBCC CHECKIDENT ('genres', RESEED, 0);
DBCC CHECKIDENT ('movies', RESEED, 0);
DBCC CHECKIDENT ('showtimes', RESEED, 0);
DBCC CHECKIDENT ('bookings', RESEED, 0);
DBCC CHECKIDENT ('invoices', RESEED, 0);
DBCC CHECKIDENT ('online_tickets', RESEED, 0);
DBCC CHECKIDENT ('counter_tickets', RESEED, 0);
DBCC CHECKIDENT ('vouchers', RESEED, 0);
DBCC CHECKIDENT ('user_vouchers', RESEED, 0);
DBCC CHECKIDENT ('point_history', RESEED, 0);
DBCC CHECKIDENT ('reviews', RESEED, 0);
DBCC CHECKIDENT ('staff_schedules', RESEED, 0);
GO

-- Mật khẩu mẫu cho tất cả user: 123456 (bcrypt hash bên dưới)

-- ========== 1. ROLES ==========
-- Theo app: Login redirect và guard dùng CINEMA_STAFF, BRANCH_MANAGER
-- Đảm bảo role_id cố định 1..4 để không lỗi FK_users_role
SET IDENTITY_INSERT roles ON;

INSERT INTO roles (role_id, role_name) VALUES
(1, 'ADMIN'),
(2, 'BRANCH_MANAGER'),
(3, 'CINEMA_STAFF'),
(4, 'CUSTOMER');

SET IDENTITY_INSERT roles OFF;
GO

-- ========== 2. USERS ==========
-- role_id: 1=ADMIN, 2=BRANCH_MANAGER, 3=CINEMA_STAFF, 4=CUSTOMER
-- Mật khẩu: 123456 (BCrypt hash sinh bởi utils.Password.hashPassword)
-- Thêm branch_id: staff & manager thuộc chi nhánh 1, customer không gán chi nhánh
SET IDENTITY_INSERT users ON;

INSERT INTO users (
    user_id, role_id, username, email, password, fullName, birthday, phone,
    status, points, total_accumulated_points, tier_id, branch_id
) VALUES
(1, 1, 'admin',    'admin@mbcms.vn',   '123456', N'Quản trị viên',             '1990-01-15', '0901234567', 'ACTIVE', 0, 0, 1, NULL),
(2, 3, 'staff1',   'staff1@mbcms.vn',  '123456', N'Nguyễn Văn A',             '1995-03-20', '0912345678', 'ACTIVE', 0, 0, 1, NULL),
(3, 3, 'staff2',   'staff2@mbcms.vn',  '123456', N'Trần Thị B',               '1998-07-10', '0923456789', 'ACTIVE', 0, 0, 1, NULL),
(4, 2, 'manager1', 'manager@mbcms.vn', '123456', N'Lê Quản lý Chi nhánh',     '1988-11-05', '0934567890', 'ACTIVE', 0, 0, 1, NULL),
(5, 4, 'customer1','customer1@gmail.com','123456',N'Phạm Văn Khách',         '2000-05-22', '0945678901', 'ACTIVE',150,150,2, NULL),
(6, 4, 'customer2','customer2@gmail.com','123456',N'Hoàng Thị Lan',          '1999-12-01', '0956789012', 'ACTIVE', 80, 80,1, NULL),
(7, 4, 'customer3','customer3@gmail.com','123456',N'Võ Minh Tuấn',           '2001-08-14', '0967890123', 'ACTIVE', 0,  0, 1, NULL),
-- Branch 2 staff (để test isolation lịch làm việc theo chi nhánh)
(8, 2, 'manager2', 'manager2@mbcms.vn','123456', N'Đinh Quản lý Thủ Đức',    '1985-06-15', '0934567891', 'ACTIVE', 0, 0, 1, NULL),
(9, 3, 'staff3',   'staff3@mbcms.vn',  '123456', N'Nguyễn Thị C',            '1997-04-25', '0912345679', 'ACTIVE', 0, 0, 1, NULL);

SET IDENTITY_INSERT users OFF;
GO

-- ========== 3. CINEMA BRANCHES ==========
-- manager_id = 4 (manager1, user thứ 4 vừa insert)
SET IDENTITY_INSERT cinema_branches ON;

INSERT INTO cinema_branches (branch_id, branch_name, address, phone, email, manager_id, is_active) VALUES
(1, N'MB Cinema Quận 1', N'123 Nguyễn Huệ, Quận 1, TP.HCM', '028-38251234', 'q1@mbcinema.vn', 4, 1),
(2, N'MB Cinema Thủ Đức', N'456 Võ Văn Ngân, Thủ Đức, TP.HCM', '028-38901234', 'thuduc@mbcinema.vn', 8, 1);

SET IDENTITY_INSERT cinema_branches OFF;
GO

-- Cập nhật branch_id cho staff và manager sau khi cinema_branches đã được tạo
UPDATE users SET branch_id = 1 WHERE user_id IN (2, 3, 4); -- staff1, staff2, manager1 thuộc chi nhánh 1
UPDATE users SET branch_id = 2 WHERE user_id IN (8, 9);    -- manager2, staff3 thuộc chi nhánh 2
GO

-- ========== 4. SCREENING ROOMS ==========
SET IDENTITY_INSERT screening_rooms ON;

INSERT INTO screening_rooms (room_id, branch_id, room_name, total_seats, status) VALUES
(1, 1, N'Phòng 1', 0, 'ACTIVE'),
(2, 1, N'Phòng 2', 0, 'ACTIVE'),
(3, 1, N'Phòng 3', 0, 'ACTIVE'),
(4, 2, N'Phòng A', 0, 'ACTIVE'),
(5, 2, N'Phòng B', 0, 'ACTIVE');

SET IDENTITY_INSERT screening_rooms OFF;
GO

-- ========== 5. SEATS ==========
-- Room 1: 4 rows x 6 (A1-A6, B1-B6, C1-C6, D1-D6). D1-D2 COUPLE, C5-C6 VIP
INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES
(1,'A1','NORMAL','A',1,'AVAILABLE'),(1,'A2','NORMAL','A',2,'AVAILABLE'),(1,'A3','NORMAL','A',3,'AVAILABLE'),(1,'A4','NORMAL','A',4,'AVAILABLE'),(1,'A5','NORMAL','A',5,'AVAILABLE'),(1,'A6','NORMAL','A',6,'AVAILABLE'),
(1,'B1','NORMAL','B',1,'AVAILABLE'),(1,'B2','NORMAL','B',2,'AVAILABLE'),(1,'B3','NORMAL','B',3,'AVAILABLE'),(1,'B4','NORMAL','B',4,'AVAILABLE'),(1,'B5','NORMAL','B',5,'AVAILABLE'),(1,'B6','NORMAL','B',6,'AVAILABLE'),
(1,'C1','NORMAL','C',1,'AVAILABLE'),(1,'C2','NORMAL','C',2,'AVAILABLE'),(1,'C3','NORMAL','C',3,'AVAILABLE'),(1,'C4','NORMAL','C',4,'AVAILABLE'),(1,'C5','VIP','C',5,'AVAILABLE'),(1,'C6','VIP','C',6,'AVAILABLE'),
(1,'D1','COUPLE','D',1,'AVAILABLE'),(1,'D2','COUPLE','D',2,'AVAILABLE'),(1,'D3','NORMAL','D',3,'AVAILABLE'),(1,'D4','NORMAL','D',4,'AVAILABLE'),(1,'D5','NORMAL','D',5,'AVAILABLE'),(1,'D6','NORMAL','D',6,'AVAILABLE');
-- Room 2: 3x5
INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES
(2,'A1','NORMAL','A',1,'AVAILABLE'),(2,'A2','NORMAL','A',2,'AVAILABLE'),(2,'A3','NORMAL','A',3,'AVAILABLE'),(2,'A4','NORMAL','A',4,'AVAILABLE'),(2,'A5','NORMAL','A',5,'AVAILABLE'),
(2,'B1','NORMAL','B',1,'AVAILABLE'),(2,'B2','NORMAL','B',2,'AVAILABLE'),(2,'B3','NORMAL','B',3,'AVAILABLE'),(2,'B4','NORMAL','B',4,'AVAILABLE'),(2,'B5','NORMAL','B',5,'AVAILABLE'),
(2,'C1','NORMAL','C',1,'AVAILABLE'),(2,'C2','NORMAL','C',2,'AVAILABLE'),(2,'C3','NORMAL','C',3,'AVAILABLE'),(2,'C4','NORMAL','C',4,'AVAILABLE'),(2,'C5','NORMAL','C',5,'AVAILABLE');
-- Room 3: 4x5
INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES
(3,'A1','NORMAL','A',1,'AVAILABLE'),(3,'A2','NORMAL','A',2,'AVAILABLE'),(3,'A3','NORMAL','A',3,'AVAILABLE'),(3,'A4','NORMAL','A',4,'AVAILABLE'),(3,'A5','NORMAL','A',5,'AVAILABLE'),
(3,'B1','NORMAL','B',1,'AVAILABLE'),(3,'B2','NORMAL','B',2,'AVAILABLE'),(3,'B3','NORMAL','B',3,'AVAILABLE'),(3,'B4','NORMAL','B',4,'AVAILABLE'),(3,'B5','NORMAL','B',5,'AVAILABLE'),
(3,'C1','NORMAL','C',1,'AVAILABLE'),(3,'C2','NORMAL','C',2,'AVAILABLE'),(3,'C3','NORMAL','C',3,'AVAILABLE'),(3,'C4','NORMAL','C',4,'AVAILABLE'),(3,'C5','NORMAL','C',5,'AVAILABLE'),
(3,'D1','NORMAL','D',1,'AVAILABLE'),(3,'D2','NORMAL','D',2,'AVAILABLE'),(3,'D3','NORMAL','D',3,'AVAILABLE'),(3,'D4','NORMAL','D',4,'AVAILABLE'),(3,'D5','NORMAL','D',5,'AVAILABLE');
-- Room 4 (branch 2): 3x6
INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES
(4,'A1','NORMAL','A',1,'AVAILABLE'),(4,'A2','NORMAL','A',2,'AVAILABLE'),(4,'A3','NORMAL','A',3,'AVAILABLE'),(4,'A4','NORMAL','A',4,'AVAILABLE'),(4,'A5','NORMAL','A',5,'AVAILABLE'),(4,'A6','NORMAL','A',6,'AVAILABLE'),
(4,'B1','NORMAL','B',1,'AVAILABLE'),(4,'B2','NORMAL','B',2,'AVAILABLE'),(4,'B3','NORMAL','B',3,'AVAILABLE'),(4,'B4','NORMAL','B',4,'AVAILABLE'),(4,'B5','NORMAL','B',5,'AVAILABLE'),(4,'B6','NORMAL','B',6,'AVAILABLE'),
(4,'C1','NORMAL','C',1,'AVAILABLE'),(4,'C2','NORMAL','C',2,'AVAILABLE'),(4,'C3','NORMAL','C',3,'AVAILABLE'),(4,'C4','NORMAL','C',4,'AVAILABLE'),(4,'C5','NORMAL','C',5,'AVAILABLE'),(4,'C6','NORMAL','C',6,'AVAILABLE');
-- Room 5: 3x5
INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status) VALUES
(5,'A1','NORMAL','A',1,'AVAILABLE'),(5,'A2','NORMAL','A',2,'AVAILABLE'),(5,'A3','NORMAL','A',3,'AVAILABLE'),(5,'A4','NORMAL','A',4,'AVAILABLE'),(5,'A5','NORMAL','A',5,'AVAILABLE'),
(5,'B1','NORMAL','B',1,'AVAILABLE'),(5,'B2','NORMAL','B',2,'AVAILABLE'),(5,'B3','NORMAL','B',3,'AVAILABLE'),(5,'B4','NORMAL','B',4,'AVAILABLE'),(5,'B5','NORMAL','B',5,'AVAILABLE'),
(5,'C1','NORMAL','C',1,'AVAILABLE'),(5,'C2','NORMAL','C',2,'AVAILABLE'),(5,'C3','NORMAL','C',3,'AVAILABLE'),(5,'C4','NORMAL','C',4,'AVAILABLE'),(5,'C5','NORMAL','C',5,'AVAILABLE');
GO

-- ========== 6. GENRES ==========
SET IDENTITY_INSERT genres ON;

INSERT INTO genres (genre_id, genre_name, description, is_active) VALUES
(1, N'Hành động', N'Phim hành động, phiêu lưu', 1),
(2, N'Tình cảm', N'Phim tình cảm, lãng mạn', 1),
(3, N'Hài', N'Phim hài kịch', 1),
(4, N'Kinh dị', N'Phim kinh dị, bí ẩn', 1),
(5, N'Khoa học viễn tưởng', N'Sci-Fi, viễn tưởng', 1),
(6, N'Hoạt hình', N'Phim hoạt hình', 1),
(7, N'Gia đình', N'Phim dành cho gia đình', 1);

SET IDENTITY_INSERT genres OFF;
GO

-- ========== 7. MOVIES ==========
SET IDENTITY_INSERT movies ON;

INSERT INTO movies (movie_id, title, description, duration, release_date, end_date, rating, age_rating, director, cast, poster_url, is_active) VALUES
(1, N'Làm Giàu Với Ma', N'Comedy horror về một nhóm bạn trẻ đụng độ ma và cố gắng kiếm tiền từ ma.', 110, '2025-01-10', '2025-03-31', 0, 'T16', N'Trấn Thành', N'Trấn Thành, Thu Trang, Tiến Luật', '/posters/lam-giau-voi-ma.jpg', 1),
(2, N'Làm Mẹ 4.0', N'Phim gia đình hài cảm động về hành trình làm mẹ thời hiện đại.', 120, '2025-02-01', '2025-04-15', 0, 'T13', N'Vũ Ngọc Đãng', N'Minh Hằng, Hồng Ánh, Lê Khánh', '/posters/lam-me-40.jpg', 1),
(3, N'Dune: Part Two', N'Paul Atreides hợp nhất với người Fremen để trả thù và bảo vệ vũ trụ.', 166, '2025-02-14', '2025-04-30', 0, 'T16', N'Denis Villeneuve', N'Timothée Chalamet, Zendaya', '/posters/dune2.jpg', 1),
(4, N'Mai', N'Cuộc đời của Mai - người phụ nữ trung niên với nhiều biến cố và sự hồi sinh.', 131, '2024-02-10', '2025-02-28', 0, 'T18', N'Trấn Thành', N'Phương Anh Đào, Thu Trang', '/posters/mai.jpg', 1),
(5, N'Inside Out 2', N'Riley lớn lên và những cảm xúc mới xuất hiện trong đầu cô.', 96, '2025-01-17', '2025-04-01', 0, 'T0', N'Kelsey Mann', N'(Lồng tiếng)', '/posters/inside-out-2.jpg', 1);

SET IDENTITY_INSERT movies OFF;
GO

-- ========== 8. MOVIE_GENRES ==========
INSERT INTO movie_genres (movie_id, genre_id) VALUES
(1, 1),(1, 3),(1, 4),   -- Làm Giàu Với Ma: Hành động, Hài, Kinh dị
(2, 2),(2, 3),(2, 7),   -- Làm Mẹ 4.0: Tình cảm, Hài, Gia đình
(3, 1),(3, 5),          -- Dune 2: Hành động, Sci-Fi
(4, 2),(4, 3),          -- Mai: Tình cảm, Hài
(5, 6),(5, 7);          -- Inside Out 2: Hoạt hình, Gia đình
GO

-- ========== 9. SHOWTIMES ==========
-- movie_id, room_id, show_date, start_time, end_time, base_price, status
SET IDENTITY_INSERT showtimes ON;

INSERT INTO showtimes (showtime_id, movie_id, room_id, show_date, start_time, end_time, base_price, status) VALUES
(1, 1, 1, '2025-02-25', '09:00', '10:50', 75000, 'SCHEDULED'),
(2, 1, 1, '2025-02-25', '14:00', '15:50', 85000, 'SCHEDULED'),
(3, 1, 2, '2025-02-25', '19:00', '20:50', 95000, 'SCHEDULED'),
(4, 2, 1, '2025-02-25', '11:00', '13:00', 75000, 'SCHEDULED'),
(5, 3, 2, '2025-02-25', '21:00', '23:46', 95000, 'SCHEDULED'),
(6, 4, 3, '2025-02-24', '18:30', '20:41', 85000, 'SCHEDULED'),
(7, 5, 4, '2025-02-26', '10:00', '11:36', 65000, 'SCHEDULED'),
(8, 1, 4, '2025-02-26', '14:00', '15:50', 75000, 'SCHEDULED');

SET IDENTITY_INSERT showtimes OFF;
GO

-- ========== 10. TICKET PRICES ==========
-- Schema mới: ticket_type, day_type, time_slot, price, effective_from, effective_to, is_active, branch_id
-- Giá mẫu cho chi nhánh 1 (MB Cinema Quận 1)
INSERT INTO ticket_prices (ticket_type, day_type, time_slot, price, effective_from, effective_to, is_active, branch_id) VALUES
('ADULT','WEEKDAY','MORNING',   65000,'2025-01-01',NULL,1, 1),
('ADULT','WEEKDAY','AFTERNOON', 75000,'2025-01-01',NULL,1, 1),
('ADULT','WEEKDAY','EVENING',   85000,'2025-01-01',NULL,1, 1),
('ADULT','WEEKDAY','NIGHT',     95000,'2025-01-01',NULL,1, 1),

('CHILD','WEEKDAY','MORNING',   45000,'2025-01-01',NULL,1, 1),
('CHILD','WEEKDAY','AFTERNOON', 55000,'2025-01-01',NULL,1, 1),
('CHILD','WEEKDAY','EVENING',   65000,'2025-01-01',NULL,1, 1),

('ADULT','WEEKEND','MORNING',   75000,'2025-01-01',NULL,1, 1),
('ADULT','WEEKEND','AFTERNOON', 85000,'2025-01-01',NULL,1, 1),
('ADULT','WEEKEND','EVENING',   95000,'2025-01-01',NULL,1, 1);
GO

-- ========== 11. BOOKINGS ==========
-- user_id 5,6,7 = customers. Showtime 1 = 2025-02-25 09:00 room 1.
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings (booking_id, user_id, showtime_id, booking_code, total_amount, discount_amount, final_amount, payment_method, payment_status, booking_time, payment_time, status) VALUES
(1, 5, 1, 'MB20250225001', 0, 0, 0, 'ZALOPAY', 'PAID', '2025-02-22 10:00:00', '2025-02-22 10:01:00', 'CONFIRMED'),
(2, 6, 2, 'MB20250225002', 0, 0, 0, 'BANKING', 'PAID', '2025-02-22 11:30:00', '2025-02-22 11:31:00', 'CONFIRMED'),
(3, 5, 4, 'MB20250225003', 0, 0, 0, 'ZALOPAY', 'PENDING', '2025-02-22 14:00:00', NULL, 'PENDING');

SET IDENTITY_INSERT bookings OFF;
GO

-- ========== 12. ONLINE TICKETS ==========
-- Trigger will update booking total_amount & final_amount. Seat: room 1 -> seat_id 1-24 (A1=1..D6=24).
-- Booking 1: showtime 1, seats 1,2 (A1,A2). Booking 2: showtime 2 (cũng room 1), seat 5 (A5). Booking 3: chưa có vé.
INSERT INTO online_tickets (booking_id, showtime_id, seat_id, ticket_type, seat_type, price) VALUES
(1, 1, 1, 'ADULT', 'NORMAL', 75000),
(1, 1, 2, 'ADULT', 'NORMAL', 75000),
(2, 2, 5, 'ADULT', 'NORMAL', 85000);
GO

-- ========== 13. COUNTER TICKETS ==========
-- Showtime 1: room 1. Use seats 3,4 (A3,A4) - not sold online. Sold by staff user_id 2.
INSERT INTO counter_tickets (showtime_id, seat_id, ticket_type, seat_type, price, sold_by, payment_method, customer_name, customer_phone, sold_at) VALUES
(1, 3, 'ADULT', 'NORMAL', 75000, 2, 'CASH', N'Nguyễn Văn X', '0978123456', '2025-02-22 08:30:00'),
(1, 4, 'CHILD', 'NORMAL', 55000, 2, 'CASH', N'Trần Thị Y', '0987654321', '2025-02-22 08:35:00');
GO

-- ========== 14. SEAT TYPE SURCHARGES (per branch) ==========
-- Theo MBCMS.sql: "Default rows (0% surcharge for all types per existing branch)" - dùng surcharge_rate = 0
INSERT INTO seat_type_surcharges (branch_id, seat_type, surcharge_rate)
SELECT b.branch_id, t.seat_type, 0
FROM cinema_branches b
CROSS JOIN (VALUES ('NORMAL'),('VIP'),('COUPLE')) AS t(seat_type)
WHERE NOT EXISTS (
    SELECT 1 FROM seat_type_surcharges s
    WHERE s.branch_id = b.branch_id AND s.seat_type = t.seat_type
);
GO

-- ========== 15. REVIEWS ==========
SET IDENTITY_INSERT reviews ON;

INSERT INTO reviews (review_id, user_id, movie_id, rating, comment, helpful_count, is_verified) VALUES
(1, 5, 1, 4.5, N'Phim vui, diễn viên đạt. Đáng xem cuối tuần.', 3, 1),
(2, 6, 1, 4, N'Hài nhưng vẫn có cảm xúc.', 1, 1),
(3, 5, 4, 5, N'Mai hay và sâu sắc, khuyên xem.', 5, 1),
(4, 7, 2, 3.5, N'Phim gia đình ổn.', 0, 0);

SET IDENTITY_INSERT reviews OFF;
GO

-- ========== 16. NOTIFICATIONS ==========
-- notifications table is not in schema; skipped
GO

-- ========== 17. REVENUE REPORTS ==========
INSERT INTO revenue_reports (branch_id, report_date, sale_channel, online_tickets_count, online_revenue, counter_tickets_count, counter_revenue, total_tickets_count, total_revenue, adult_tickets, child_tickets, normal_seats, vip_seats, couple_seats, generated_by) VALUES
(1, '2025-02-22', 'COMBINED', 3, 235000, 2, 130000, 5, 365000, 4, 1, 5, 0, 0, 1),
(1, '2025-02-21', 'ONLINE', 4, 320000, 0, 0, 4, 320000, 4, 0, 4, 0, 0, 1);
GO

-- Fix ZALOPA typo in constraint (safe to run on existing DB)
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_invoice_payment_method' AND parent_object_id = OBJECT_ID('invoices'))
BEGIN
    ALTER TABLE invoices DROP CONSTRAINT CK_invoice_payment_method;
    ALTER TABLE invoices ADD CONSTRAINT CK_invoice_payment_method CHECK (payment_method IN ('ZALOPAY','BANKING','CASH'));
END;
GO

-- ========== 18. INVOICES ==========
-- Invoice for online booking 1 (customer Phạm Văn Khách), branch 1, created_by staff 2.
SET IDENTITY_INSERT invoices ON;

INSERT INTO invoices (invoice_id, invoice_code, booking_id, sale_channel, customer_name, customer_phone, customer_email, branch_id, total_amount, discount_amount, final_amount, payment_method, payment_status, status, created_by, notes) VALUES
(1, 'INV-20250222-0001', 1, 'ONLINE', N'Phạm Văn Khách', '0945678901', 'customer1@gmail.com', 1, 150000, 0, 150000, 'ZALOPAY', 'PAID', 'ACTIVE', 2, NULL),
(2, 'INV-20250222-0002', NULL, 'COUNTER', N'Nguyễn Văn X', '0978123456', NULL, 1, 75000, 0, 75000, 'CASH', 'PAID', 'ACTIVE', 2, N'Vé quầy');

SET IDENTITY_INSERT invoices OFF;
GO

-- ========== 19. INVOICE ITEMS ==========
-- Invoice 1: 2 items from online_tickets (ticket_id 1, 2). Invoice 2: 1 item from counter_ticket (ticket_id 1).
INSERT INTO invoice_items (invoice_id, item_type, online_ticket_id, counter_ticket_id, item_description, movie_title, showtime_date, showtime_time, room_name, seat_code, ticket_type, seat_type, quantity, unit_price, amount) VALUES
(1, 'ONLINE_TICKET', 1, NULL, N'Làm Giàu Với Ma - A1', N'Làm Giàu Với Ma', '2025-02-25', '09:00', 'Phòng 1', 'A1', 'ADULT', 'NORMAL', 1, 75000, 75000),
(1, 'ONLINE_TICKET', 2, NULL, N'Làm Giàu Với Ma - A2', N'Làm Giàu Với Ma', '2025-02-25', '09:00', 'Phòng 1', 'A2', 'ADULT', 'NORMAL', 1, 75000, 75000),
(2, 'COUNTER_TICKET', NULL, 1, N'Làm Giàu Với Ma - A3', N'Làm Giàu Với Ma', '2025-02-25', '09:00', 'Phòng 1', 'A3', 'ADULT', 'NORMAL', 1, 75000, 75000);
GO

-- ========== 20. REPORTED COMMENTS (optional) ==========
INSERT INTO reported_comments (review_id, reported_by, reason, status) VALUES
(2, 7, N'Nghi ngờ bình luận spam', 'PENDING');
GO

-- ========== 21. VOUCHERS & USER_VOUCHERS (LOYALTY SAMPLE) ==========
-- Vouchers (tham chiếu theo schema mới trong MBCMS.sql)
SET IDENTITY_INSERT vouchers ON;

INSERT INTO vouchers (voucher_id, voucher_name, voucher_type, voucher_code, points_cost, discount_amount, max_usage_limit, valid_days, is_active) VALUES
(1, N'GIẢM 50K VÉ ONLINE', 'PUBLIC', 'SALE50K', 0, 50000, 0, 30, 1),
(2, N'VOUCHER THÀNH VIÊN 30K', 'LOYALTY', NULL, 100, 30000, 1, 60, 1);

SET IDENTITY_INSERT vouchers OFF;
GO

-- User vouchers (gán cho customer1 và customer2)
DECLARE @now DATETIME2 = SYSDATETIME();

INSERT INTO user_vouchers (user_id, voucher_id, voucher_code, status, redeemed_at, expires_at, used_at) VALUES
(5, 1, 'SALE50K-USER1', 'AVAILABLE', @now, DATEADD(DAY, 30, @now), NULL),
(6, 2, 'LOYAL30K-USER2', 'AVAILABLE', @now, DATEADD(DAY, 60, @now), NULL);
GO

-- ========== 22. POINT HISTORY (LOYALTY SAMPLE) ==========
INSERT INTO point_history (user_id, points_changed, transaction_type, description, reference_id) VALUES
(5, 150, 'EARN', N'Tích lũy từ các đơn hàng trước', NULL),
(5, -100, 'REDEEM', N'Đổi voucher thành viên 30K', NULL),
(6, 80, 'EARN', N'Tích lũy từ đơn hàng trước', NULL);
GO




-- ========== SHOWTIMES TUẦN 16-22/3/2026 (để test với ngày hiện tại) ==========
-- Branch 1 (rooms 1,2,3) và Branch 2 (rooms 4,5) đều có suất chiếu trong tuần này
-- staff1/staff2 (branch 1) chỉ thấy showtime_id 9-13
-- staff3 (branch 2) chỉ thấy showtime_id 14-18
SET IDENTITY_INSERT showtimes ON;

INSERT INTO showtimes (showtime_id, movie_id, room_id, show_date, start_time, end_time, base_price, status) VALUES
-- Branch 1: Phòng 1,2,3
(9,  1, 1, '2026-03-17', '18:00', '19:50', 75000, 'SCHEDULED'),
(10, 3, 2, '2026-03-17', '19:00', '21:46', 95000, 'SCHEDULED'),
(11, 5, 3, '2026-03-17', '20:00', '21:36', 65000, 'SCHEDULED'),
(12, 2, 1, '2026-03-18', '11:00', '13:00', 75000, 'SCHEDULED'),
(13, 4, 2, '2026-03-19', '19:00', '21:11', 85000, 'SCHEDULED'),
-- Branch 2: Phòng A,B
(14, 3, 4, '2026-03-17', '18:00', '20:46', 85000, 'SCHEDULED'),
(15, 5, 5, '2026-03-17', '19:00', '20:36', 65000, 'SCHEDULED'),
(16, 1, 4, '2026-03-17', '20:00', '21:50', 85000, 'SCHEDULED'),
(17, 4, 5, '2026-03-18', '19:00', '21:11', 95000, 'SCHEDULED'),
(18, 3, 4, '2026-03-19', '11:00', '13:46', 85000, 'SCHEDULED');

SET IDENTITY_INSERT showtimes OFF;
GO

-- =============================================
-- DỮ LIỆU MẪU: 18/03/2026 → 01/04/2026
-- Bao gồm: Showtimes, Counter Tickets, Invoices, Staff Schedules
-- =============================================

-- =============================================
-- A. SHOWTIMES: 18/03 → 01/04/2026
-- Branch 1 (rooms 1,2,3) và Branch 2 (rooms 4,5)
-- Mỗi ngày 2–3 suất mỗi branch, đa dạng phim và giờ
-- showtime_id bắt đầu từ 19
-- =============================================
SET IDENTITY_INSERT showtimes ON;

INSERT INTO showtimes (showtime_id, movie_id, room_id, show_date, start_time, end_time, base_price, status) VALUES
-- ===== BRANCH 1 =====
-- 18/03 (Thứ 4 - WEEKDAY)
(19, 1, 1, '2026-03-18', '08:30', '10:20', 65000, 'COMPLETED'),
(20, 3, 2, '2026-03-18', '14:00', '16:46', 75000, 'COMPLETED'),
(21, 5, 3, '2026-03-18', '19:00', '20:36', 85000, 'COMPLETED'),
-- 19/03 (Thứ 5 - WEEKDAY)
(22, 2, 1, '2026-03-19', '09:00', '11:00', 65000, 'COMPLETED'),
(23, 4, 2, '2026-03-19', '14:30', '16:41', 75000, 'COMPLETED'),
(24, 1, 3, '2026-03-19', '20:00', '21:50', 85000, 'COMPLETED'),
-- 20/03 (Thứ 6 - WEEKDAY)
(25, 3, 1, '2026-03-20', '10:00', '12:46', 65000, 'COMPLETED'),
(26, 5, 2, '2026-03-20', '15:00', '16:36', 75000, 'COMPLETED'),
(27, 2, 3, '2026-03-20', '19:30', '21:30', 85000, 'COMPLETED'),
-- 21/03 (Thứ 7 - WEEKEND)
(28, 1, 1, '2026-03-21', '09:00', '10:50', 75000, 'COMPLETED'),
(29, 3, 2, '2026-03-21', '13:00', '15:46', 85000, 'COMPLETED'),
(30, 4, 3, '2026-03-21', '18:00', '20:11', 95000, 'COMPLETED'),
-- 22/03 (Chủ nhật - WEEKEND)
(31, 5, 1, '2026-03-22', '10:00', '11:36', 75000, 'COMPLETED'),
(32, 2, 2, '2026-03-22', '14:00', '16:00', 85000, 'COMPLETED'),
(33, 1, 3, '2026-03-22', '19:00', '20:50', 95000, 'COMPLETED'),
-- 23/03 (Thứ 2 - WEEKDAY)
(34, 4, 1, '2026-03-23', '09:00', '11:11', 65000, 'COMPLETED'),
(35, 3, 2, '2026-03-23', '15:00', '17:46', 75000, 'COMPLETED'),
(36, 5, 3, '2026-03-23', '19:00', '20:36', 85000, 'COMPLETED'),
-- 24/03 (Thứ 3 - WEEKDAY)
(37, 1, 1, '2026-03-24', '08:30', '10:20', 65000, 'COMPLETED'),
(38, 2, 2, '2026-03-24', '14:00', '16:00', 75000, 'COMPLETED'),
(39, 3, 3, '2026-03-24', '20:00', '22:46', 85000, 'COMPLETED'),
-- 25/03 (Thứ 4 - WEEKDAY)
(40, 5, 1, '2026-03-25', '09:00', '10:36', 65000, 'COMPLETED'),
(41, 4, 2, '2026-03-25', '14:30', '16:41', 75000, 'COMPLETED'),
(42, 1, 3, '2026-03-25', '19:00', '20:50', 85000, 'COMPLETED'),
-- 26/03 (Thứ 5 - WEEKDAY)
(43, 2, 1, '2026-03-26', '10:00', '12:00', 65000, 'COMPLETED'),
(44, 3, 2, '2026-03-26', '15:00', '17:46', 75000, 'COMPLETED'),
(45, 5, 3, '2026-03-26', '19:30', '21:06', 85000, 'COMPLETED'),
-- 27/03 (Thứ 6 - WEEKDAY)
(46, 4, 1, '2026-03-27', '09:00', '11:11', 65000, 'COMPLETED'),
(47, 1, 2, '2026-03-27', '14:00', '15:50', 75000, 'COMPLETED'),
(48, 2, 3, '2026-03-27', '20:00', '22:00', 85000, 'COMPLETED'),
-- 28/03 (Thứ 7 - WEEKEND)
(49, 3, 1, '2026-03-28', '09:30', '12:16', 75000, 'COMPLETED'),
(50, 5, 2, '2026-03-28', '13:00', '14:36', 85000, 'COMPLETED'),
(51, 1, 3, '2026-03-28', '18:30', '20:20', 95000, 'COMPLETED'),
-- 29/03 (Chủ nhật - WEEKEND)
(52, 2, 1, '2026-03-29', '10:00', '12:00', 75000, 'COMPLETED'),
(53, 4, 2, '2026-03-29', '14:00', '16:11', 85000, 'COMPLETED'),
(54, 3, 3, '2026-03-29', '19:00', '21:46', 95000, 'COMPLETED'),
-- 30/03 (Thứ 2 - WEEKDAY)
(55, 5, 1, '2026-03-30', '09:00', '10:36', 65000, 'COMPLETED'),
(56, 1, 2, '2026-03-30', '14:00', '15:50', 75000, 'COMPLETED'),
(57, 2, 3, '2026-03-30', '19:00', '21:00', 85000, 'COMPLETED'),
-- 31/03 (Thứ 3 - WEEKDAY)
(58, 4, 1, '2026-03-31', '10:00', '12:11', 65000, 'SCHEDULED'),
(59, 3, 2, '2026-03-31', '15:00', '17:46', 75000, 'SCHEDULED'),
(60, 5, 3, '2026-03-31', '19:00', '20:36', 85000, 'SCHEDULED'),
-- 01/04 (Thứ 4 - WEEKDAY)
(61, 1, 1, '2026-04-01', '09:00', '10:50', 65000, 'SCHEDULED'),
(62, 2, 2, '2026-04-01', '14:00', '16:00', 75000, 'SCHEDULED'),
(63, 3, 3, '2026-04-01', '19:30', '22:16', 85000, 'SCHEDULED'),

-- ===== BRANCH 2 (rooms 4,5) =====
-- 18/03
(64, 1, 4, '2026-03-18', '09:00', '10:50', 65000, 'COMPLETED'),
(65, 5, 5, '2026-03-18', '14:00', '15:36', 75000, 'COMPLETED'),
(66, 2, 4, '2026-03-18', '19:00', '21:00', 85000, 'COMPLETED'),
-- 19/03
(67, 3, 4, '2026-03-19', '10:00', '12:46', 65000, 'COMPLETED'),
(68, 4, 5, '2026-03-19', '15:00', '17:11', 75000, 'COMPLETED'),
-- 20/03
(69, 5, 4, '2026-03-20', '09:30', '11:06', 65000, 'COMPLETED'),
(70, 1, 5, '2026-03-20', '19:00', '20:50', 85000, 'COMPLETED'),
-- 21/03 (WEEKEND)
(71, 2, 4, '2026-03-21', '10:00', '12:00', 75000, 'COMPLETED'),
(72, 3, 5, '2026-03-21', '14:00', '16:46', 85000, 'COMPLETED'),
(73, 4, 4, '2026-03-21', '19:00', '21:11', 95000, 'COMPLETED'),
-- 22/03 (WEEKEND)
(74, 5, 5, '2026-03-22', '09:00', '10:36', 75000, 'COMPLETED'),
(75, 1, 4, '2026-03-22', '15:00', '16:50', 85000, 'COMPLETED'),
-- 23/03–27/03 (WEEKDAY)
(76, 2, 4, '2026-03-23', '14:00', '16:00', 75000, 'COMPLETED'),
(77, 4, 5, '2026-03-24', '19:00', '21:11', 85000, 'COMPLETED'),
(78, 3, 4, '2026-03-25', '10:00', '12:46', 65000, 'COMPLETED'),
(79, 5, 5, '2026-03-26', '14:00', '15:36', 75000, 'COMPLETED'),
(80, 1, 4, '2026-03-27', '19:00', '20:50', 85000, 'COMPLETED'),
-- 28/03–29/03 (WEEKEND)
(81, 2, 4, '2026-03-28', '11:00', '13:00', 75000, 'COMPLETED'),
(82, 3, 5, '2026-03-28', '18:00', '20:46', 95000, 'COMPLETED'),
(83, 4, 4, '2026-03-29', '10:00', '12:11', 75000, 'COMPLETED'),
(84, 5, 5, '2026-03-29', '19:00', '20:36', 95000, 'COMPLETED'),
-- 30/03–01/04
(85, 1, 4, '2026-03-30', '14:00', '15:50', 75000, 'COMPLETED'),
(86, 2, 5, '2026-03-31', '19:00', '21:00', 85000, 'SCHEDULED'),
(87, 3, 4, '2026-04-01', '10:00', '12:46', 65000, 'SCHEDULED');

SET IDENTITY_INSERT showtimes OFF;
GO

-- Cập nhật total_seats cho các phòng
UPDATE screening_rooms SET total_seats = (SELECT COUNT(*) FROM seats WHERE seats.room_id = screening_rooms.room_id);
GO

-- =============================================
-- B. COUNTER TICKETS: 18/03 → 30/03/2026
-- Branch 1: sold_by staff1 (user_id=2) và staff2 (user_id=3)
-- Branch 2: sold_by staff3 (user_id=9)
-- Seat IDs: Room 1 (1-24), Room 2 (25-39), Room 3 (40-59), Room 4 (60-77), Room 5 (78-92)
-- =============================================
INSERT INTO counter_tickets (showtime_id, seat_id, ticket_type, seat_type, price, sold_by, payment_method, customer_name, customer_phone, sold_at) VALUES
-- 18/03 branch 1, showtime 19 (room 1, 08:30)
(19, 3,  'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Trần Văn Nam',      '0901111001', '2026-03-18 08:15:00'),
(19, 4,  'CHILD',  'NORMAL', 45000, 2, 'CASH',    N'Trần Văn Nam',      '0901111001', '2026-03-18 08:15:00'),
(19, 7,  'ADULT',  'NORMAL', 65000, 2, 'BANKING', N'Lê Thị Hoa',        '0902222002', '2026-03-18 08:20:00'),
-- 18/03 branch 1, showtime 21 (room 3, 19:00)
(21, 41, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Phạm Minh Đức',     '0903333003', '2026-03-18 18:45:00'),
(21, 42, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Phạm Minh Đức',     '0903333003', '2026-03-18 18:45:00'),
(21, 50, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Ngô Thị Bích',      '0904444004', '2026-03-18 18:50:00'),
-- 18/03 branch 2, showtime 64 (room 4, 09:00)
(64, 60, 'ADULT',  'NORMAL', 65000, 9, 'CASH',    N'Huỳnh Văn Tài',     '0905555005', '2026-03-18 08:50:00'),
(64, 61, 'CHILD',  'NORMAL', 45000, 9, 'CASH',    N'Huỳnh Văn Tài',     '0905555005', '2026-03-18 08:50:00'),
-- 18/03 branch 2, showtime 66 (room 4, 19:00)
(66, 63, 'ADULT',  'NORMAL', 85000, 9, 'BANKING', N'Võ Thị Kim',        '0906666006', '2026-03-18 18:40:00'),
(66, 64, 'ADULT',  'NORMAL', 85000, 9, 'CASH',    N'Bùi Văn Hùng',      '0907777007', '2026-03-18 18:55:00'),

-- 19/03 branch 1, showtime 22 (room 1, 09:00)
(22, 5,  'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Đặng Thị Lan',      '0908888008', '2026-03-19 08:45:00'),
(22, 8,  'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Đặng Thị Lan',      '0908888008', '2026-03-19 08:45:00'),
-- 19/03 branch 1, showtime 24 (room 3, 20:00)
(24, 40, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Trương Quốc Bảo',   '0909999009', '2026-03-19 19:45:00'),
(24, 52, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Lý Thị Mai',        '0910000010', '2026-03-19 19:50:00'),

-- 20/03 branch 1, showtime 25 (room 1, 10:00)
(25, 9,  'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Phan Văn Khoa',     '0911111011', '2026-03-20 09:50:00'),
(25, 10, 'CHILD',  'NORMAL', 45000, 2, 'CASH',    N'Phan Văn Khoa',     '0911111011', '2026-03-20 09:50:00'),
(25, 17, 'ADULT',  'VIP',    75000, 2, 'BANKING', N'Đinh Thị Thu',      '0912222012', '2026-03-20 09:55:00'),
-- 20/03 branch 1, showtime 27 (room 3, 19:30)
(27, 43, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Nguyễn Bá Thắng',   '0913333013', '2026-03-20 19:20:00'),
(27, 55, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Trần Mỹ Linh',      '0914444014', '2026-03-20 19:25:00'),

-- 21/03 (WEEKEND) branch 1, showtime 28 (room 1, 09:00)
(28, 11, 'ADULT',  'NORMAL', 75000, 2, 'CASH',    N'Vũ Đức Thịnh',      '0915555015', '2026-03-21 08:50:00'),
(28, 12, 'ADULT',  'NORMAL', 75000, 2, 'CASH',    N'Vũ Đức Thịnh',      '0915555015', '2026-03-21 08:50:00'),
(28, 19, 'ADULT',  'COUPLE', 95000, 2, 'BANKING', N'Hoàng Văn Phúc',    '0916666016', '2026-03-21 08:55:00'),
(28, 20, 'ADULT',  'COUPLE', 95000, 2, 'BANKING', N'Hoàng Văn Phúc',    '0916666016', '2026-03-21 08:55:00'),
-- 21/03 branch 1, showtime 30 (room 3, 18:00)
(30, 44, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Lê Phương Thảo',    '0917777017', '2026-03-21 17:50:00'),
(30, 56, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Dương Văn Long',    '0918888018', '2026-03-21 17:55:00'),
(30, 57, 'CHILD',  'NORMAL', 65000, 3, 'BANKING', N'Dương Văn Long',    '0918888018', '2026-03-21 17:55:00'),

-- 22/03 (WEEKEND) branch 1, showtime 31 (room 1, 10:00)
(31, 13, 'ADULT',  'NORMAL', 75000, 2, 'CASH',    N'Mai Quốc Hưng',     '0919999019', '2026-03-22 09:50:00'),
(31, 14, 'CHILD',  'NORMAL', 55000, 2, 'CASH',    N'Mai Quốc Hưng',     '0919999019', '2026-03-22 09:50:00'),
-- 22/03 branch 1, showtime 33 (room 3, 19:00)
(33, 45, 'ADULT',  'NORMAL', 95000, 3, 'BANKING', N'Cao Thị Ngọc',      '0920000020', '2026-03-22 18:45:00'),
(33, 46, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Tăng Văn Bình',     '0921111021', '2026-03-22 18:50:00'),

-- 23/03 branch 1, showtime 34 (room 1, 09:00)
(34, 15, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Quách Minh Tuấn',   '0922222022', '2026-03-23 08:50:00'),
(34, 16, 'ADULT',  'NORMAL', 65000, 2, 'BANKING', N'Trịnh Thị Hạnh',    '0923333023', '2026-03-23 08:55:00'),
-- 23/03 branch 1, showtime 36 (room 3, 19:00)
(36, 47, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Đỗ Văn Tiến',       '0924444024', '2026-03-23 18:48:00'),

-- 24/03 branch 1, showtime 37 (room 1, 08:30)
(37, 21, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Phùng Thị Yến',     '0925555025', '2026-03-24 08:20:00'),
(37, 22, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Lâm Quốc Khánh',    '0926666026', '2026-03-24 08:25:00'),
-- 24/03 branch 1, showtime 39 (room 3, 20:00)
(39, 48, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Hà Thị Bảo Châu',   '0927777027', '2026-03-24 19:50:00'),
(39, 49, 'CHILD',  'NORMAL', 55000, 3, 'CASH',    N'Nguyễn Thành Đạt',  '0928888028', '2026-03-24 19:55:00'),

-- 25/03 branch 1, showtime 40 (room 1, 09:00)
(40, 23, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Dương Thị Kim Anh', '0929999029', '2026-03-25 08:50:00'),
(40, 24, 'ADULT',  'NORMAL', 65000, 2, 'BANKING', N'Tô Văn Hải',        '0930000030', '2026-03-25 08:55:00'),
-- 25/03 branch 1, showtime 42 (room 3, 19:00)
(42, 51, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Lưu Thị Diệu',      '0931111031', '2026-03-25 18:48:00'),
(42, 53, 'ADULT',  'VIP',    95000, 3, 'BANKING', N'Phan Tuấn Anh',     '0932222032', '2026-03-25 18:52:00'),

-- 26/03 branch 1, showtime 43 (room 1, 10:00)
(43, 25, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Từ Minh Châu',      '0933333033', '2026-03-26 09:50:00'),
(43, 26, 'CHILD',  'NORMAL', 45000, 2, 'CASH',    N'Từ Minh Châu',      '0933333033', '2026-03-26 09:50:00'),
-- 26/03 branch 1, showtime 45 (room 3, 19:30)
(45, 54, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Vương Văn Đức',     '0934444034', '2026-03-26 19:20:00'),

-- 27/03 branch 1, showtime 46 (room 1, 09:00)
(46, 27, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Hồ Thị Bảo Trân',   '0935555035', '2026-03-27 08:50:00'),
(46, 28, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Bùi Đình Toàn',     '0936666036', '2026-03-27 08:55:00'),
-- 27/03 branch 1, showtime 48 (room 3, 20:00)
(48, 58, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Kiều Thị Thanh',    '0937777037', '2026-03-27 19:50:00'),
(48, 59, 'ADULT',  'NORMAL', 85000, 3, 'BANKING', N'Nghiêm Xuân Hùng',  '0938888038', '2026-03-27 19:55:00'),

-- 28/03 (WEEKEND) branch 1, showtime 49 (room 1, 09:30)
(49, 29, 'ADULT',  'NORMAL', 75000, 2, 'CASH',    N'Chu Văn Tùng',      '0939999039', '2026-03-28 09:20:00'),
(49, 30, 'ADULT',  'NORMAL', 75000, 2, 'BANKING', N'Trần Ngọc Hiếu',    '0940000040', '2026-03-28 09:25:00'),
(49, 18, 'ADULT',  'VIP',    95000, 2, 'BANKING', N'Phạm Bảo Ngọc',     '0941111041', '2026-03-28 09:28:00'),
-- 28/03 branch 1, showtime 51 (room 3, 18:30)
(51, 40, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Lưu Ngọc Quỳnh',    '0942222042', '2026-03-28 18:20:00'),
(51, 41, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Đoàn Văn Phong',    '0943333043', '2026-03-28 18:25:00'),
(51, 42, 'CHILD',  'NORMAL', 65000, 3, 'BANKING', N'Đoàn Văn Phong',    '0943333043', '2026-03-28 18:25:00'),

-- 29/03 (WEEKEND) branch 1, showtime 52 (room 1, 10:00)
(52, 31, 'ADULT',  'NORMAL', 75000, 2, 'CASH',    N'Lý Minh Phúc',      '0944444044', '2026-03-29 09:50:00'),
(52, 32, 'CHILD',  'NORMAL', 55000, 2, 'CASH',    N'Lý Minh Phúc',      '0944444044', '2026-03-29 09:50:00'),
-- 29/03 branch 1, showtime 54 (room 3, 19:00)
(54, 43, 'ADULT',  'NORMAL', 95000, 3, 'BANKING', N'Cao Văn Tuấn',      '0945555045', '2026-03-29 18:50:00'),
(54, 44, 'ADULT',  'NORMAL', 95000, 3, 'CASH',    N'Ninh Thị Thu Hà',   '0946666046', '2026-03-29 18:55:00'),

-- 30/03 branch 1, showtime 55 (room 1, 09:00)
(55, 33, 'ADULT',  'NORMAL', 65000, 2, 'CASH',    N'Triệu Văn An',      '0947777047', '2026-03-30 08:50:00'),
(55, 34, 'ADULT',  'NORMAL', 65000, 2, 'BANKING', N'Phùng Ngọc Lan',    '0948888048', '2026-03-30 08:55:00'),
-- 30/03 branch 1, showtime 57 (room 3, 19:00)
(57, 45, 'ADULT',  'NORMAL', 85000, 3, 'CASH',    N'Diệp Hữu Nghĩa',    '0949999049', '2026-03-30 18:48:00'),
(57, 46, 'CHILD',  'NORMAL', 55000, 3, 'CASH',    N'Diệp Hữu Nghĩa',    '0949999049', '2026-03-30 18:48:00'),

-- Branch 2 counter tickets
(67, 62, 'ADULT',  'NORMAL', 65000, 9, 'CASH',    N'Ngô Thanh Bình',    '0951111051', '2026-03-19 09:50:00'),
(67, 63, 'ADULT',  'NORMAL', 65000, 9, 'BANKING', N'Lưu Thị Ngọc',      '0952222052', '2026-03-19 09:55:00'),
(71, 65, 'ADULT',  'NORMAL', 75000, 9, 'CASH',    N'Trương Văn Hào',    '0953333053', '2026-03-21 09:50:00'),
(71, 66, 'CHILD',  'NORMAL', 55000, 9, 'CASH',    N'Trương Văn Hào',    '0953333053', '2026-03-21 09:50:00'),
(73, 68, 'ADULT',  'NORMAL', 95000, 9, 'BANKING', N'Mạc Thị Tuyết',     '0954444054', '2026-03-21 18:50:00'),
(73, 69, 'ADULT',  'NORMAL', 95000, 9, 'CASH',    N'Phan Đình Minh',    '0955555055', '2026-03-21 18:55:00'),
(75, 71, 'ADULT',  'NORMAL', 85000, 9, 'CASH',    N'Giang Văn Tú',      '0956666056', '2026-03-22 14:50:00'),
(78, 73, 'ADULT',  'NORMAL', 65000, 9, 'BANKING', N'Điền Thị Hương',    '0957777057', '2026-03-25 09:50:00'),
(78, 74, 'ADULT',  'NORMAL', 65000, 9, 'CASH',    N'Sơn Văn Dũng',      '0958888058', '2026-03-25 09:55:00'),
(80, 75, 'ADULT',  'NORMAL', 85000, 9, 'CASH',    N'Lê Ngọc Sơn',       '0959999059', '2026-03-27 18:50:00'),
(80, 76, 'CHILD',  'NORMAL', 55000, 9, 'BANKING', N'Lê Ngọc Sơn',       '0959999059', '2026-03-27 18:50:00'),
(82, 78, 'ADULT',  'NORMAL', 95000, 9, 'CASH',    N'Trần Bảo Châu',     '0960000060', '2026-03-28 17:50:00'),
(82, 79, 'ADULT',  'NORMAL', 95000, 9, 'BANKING', N'Hoàng Đức Duy',     '0961111061', '2026-03-28 17:55:00'),
(83, 80, 'ADULT',  'NORMAL', 75000, 9, 'CASH',    N'Dư Thị Nga',        '0962222062', '2026-03-29 09:50:00'),
(84, 81, 'ADULT',  'NORMAL', 95000, 9, 'BANKING', N'Võ Bá Huy',         '0963333063', '2026-03-29 18:50:00'),
(85, 82, 'ADULT',  'NORMAL', 75000, 9, 'CASH',    N'Dương Quang Minh',  '0964444064', '2026-03-30 13:50:00'),
(85, 83, 'CHILD',  'NORMAL', 55000, 9, 'CASH',    N'Dương Quang Minh',  '0964444064', '2026-03-30 13:50:00');
GO

-- =============================================
-- C. INVOICES cho counter tickets trên (mẫu đại diện)
-- =============================================
SET IDENTITY_INSERT invoices ON;

INSERT INTO invoices (invoice_id, invoice_code, booking_id, sale_channel, customer_name, customer_phone, customer_email, branch_id, total_amount, discount_amount, final_amount, payment_method, payment_status, status, created_by, notes) VALUES
(3,  'INV-20260318-0001', NULL, 'COUNTER', N'Trần Văn Nam',      '0901111001', NULL, 1, 110000, 0, 110000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(4,  'INV-20260318-0002', NULL, 'COUNTER', N'Lê Thị Hoa',        '0902222002', NULL, 1,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(5,  'INV-20260318-0003', NULL, 'COUNTER', N'Phạm Minh Đức',     '0903333003', NULL, 1, 170000, 0, 170000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(6,  'INV-20260318-0004', NULL, 'COUNTER', N'Ngô Thị Bích',      '0904444004', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(7,  'INV-20260318-0005', NULL, 'COUNTER', N'Huỳnh Văn Tài',     '0905555005', NULL, 2, 110000, 0, 110000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(8,  'INV-20260318-0006', NULL, 'COUNTER', N'Võ Thị Kim',        '0906666006', NULL, 2,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(9,  'INV-20260318-0007', NULL, 'COUNTER', N'Bùi Văn Hùng',      '0907777007', NULL, 2,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(10, 'INV-20260319-0001', NULL, 'COUNTER', N'Đặng Thị Lan',      '0908888008', NULL, 1, 130000, 0, 130000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(11, 'INV-20260319-0002', NULL, 'COUNTER', N'Trương Quốc Bảo',   '0909999009', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(12, 'INV-20260319-0003', NULL, 'COUNTER', N'Lý Thị Mai',        '0910000010', NULL, 1,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(13, 'INV-20260319-0004', NULL, 'COUNTER', N'Ngô Thanh Bình',    '0951111051', NULL, 2,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(14, 'INV-20260319-0005', NULL, 'COUNTER', N'Lưu Thị Ngọc',      '0952222052', NULL, 2,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(15, 'INV-20260320-0001', NULL, 'COUNTER', N'Phan Văn Khoa',     '0911111011', NULL, 1, 110000, 0, 110000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(16, 'INV-20260320-0002', NULL, 'COUNTER', N'Đinh Thị Thu',      '0912222012', NULL, 1,  75000, 0,  75000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(17, 'INV-20260320-0003', NULL, 'COUNTER', N'Nguyễn Bá Thắng',   '0913333013', NULL, 1,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(18, 'INV-20260320-0004', NULL, 'COUNTER', N'Trần Mỹ Linh',      '0914444014', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(19, 'INV-20260321-0001', NULL, 'COUNTER', N'Vũ Đức Thịnh',      '0915555015', NULL, 1, 150000, 0, 150000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(20, 'INV-20260321-0002', NULL, 'COUNTER', N'Hoàng Văn Phúc',    '0916666016', NULL, 1, 190000, 0, 190000, 'BANKING', 'PAID', 'ACTIVE', 2, N'Cặp đôi'),
(21, 'INV-20260321-0003', NULL, 'COUNTER', N'Lê Phương Thảo',    '0917777017', NULL, 1,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(22, 'INV-20260321-0004', NULL, 'COUNTER', N'Dương Văn Long',    '0918888018', NULL, 1, 160000, 0, 160000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(23, 'INV-20260321-0005', NULL, 'COUNTER', N'Trương Văn Hào',    '0953333053', NULL, 2, 130000, 0, 130000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(24, 'INV-20260321-0006', NULL, 'COUNTER', N'Mạc Thị Tuyết',     '0954444054', NULL, 2,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(25, 'INV-20260321-0007', NULL, 'COUNTER', N'Phan Đình Minh',    '0955555055', NULL, 2,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(26, 'INV-20260322-0001', NULL, 'COUNTER', N'Mai Quốc Hưng',     '0919999019', NULL, 1, 130000, 0, 130000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(27, 'INV-20260322-0002', NULL, 'COUNTER', N'Cao Thị Ngọc',      '0920000020', NULL, 1,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(28, 'INV-20260322-0003', NULL, 'COUNTER', N'Tăng Văn Bình',     '0921111021', NULL, 1,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(29, 'INV-20260322-0004', NULL, 'COUNTER', N'Giang Văn Tú',      '0956666056', NULL, 2,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(30, 'INV-20260323-0001', NULL, 'COUNTER', N'Quách Minh Tuấn',   '0922222022', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(31, 'INV-20260323-0002', NULL, 'COUNTER', N'Trịnh Thị Hạnh',    '0923333023', NULL, 1,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(32, 'INV-20260323-0003', NULL, 'COUNTER', N'Đỗ Văn Tiến',       '0924444024', NULL, 1,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(33, 'INV-20260324-0001', NULL, 'COUNTER', N'Phùng Thị Yến',     '0925555025', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(34, 'INV-20260324-0002', NULL, 'COUNTER', N'Lâm Quốc Khánh',    '0926666026', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(35, 'INV-20260324-0003', NULL, 'COUNTER', N'Hà Thị Bảo Châu',   '0927777027', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(36, 'INV-20260324-0004', NULL, 'COUNTER', N'Nguyễn Thành Đạt',  '0928888028', NULL, 1,  55000, 0,  55000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(37, 'INV-20260325-0001', NULL, 'COUNTER', N'Dương Thị Kim Anh', '0929999029', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(38, 'INV-20260325-0002', NULL, 'COUNTER', N'Tô Văn Hải',        '0930000030', NULL, 1,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(39, 'INV-20260325-0003', NULL, 'COUNTER', N'Lưu Thị Diệu',      '0931111031', NULL, 1,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(40, 'INV-20260325-0004', NULL, 'COUNTER', N'Phan Tuấn Anh',     '0932222032', NULL, 1,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(41, 'INV-20260325-0005', NULL, 'COUNTER', N'Điền Thị Hương',    '0957777057', NULL, 2,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(42, 'INV-20260325-0006', NULL, 'COUNTER', N'Sơn Văn Dũng',      '0958888058', NULL, 2,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(43, 'INV-20260326-0001', NULL, 'COUNTER', N'Từ Minh Châu',      '0933333033', NULL, 1, 110000, 0, 110000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(44, 'INV-20260326-0002', NULL, 'COUNTER', N'Vương Văn Đức',     '0934444034', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(45, 'INV-20260327-0001', NULL, 'COUNTER', N'Hồ Thị Bảo Trân',   '0935555035', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(46, 'INV-20260327-0002', NULL, 'COUNTER', N'Bùi Đình Toàn',     '0936666036', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(47, 'INV-20260327-0003', NULL, 'COUNTER', N'Kiều Thị Thanh',    '0937777037', NULL, 1,  85000, 0,  85000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(48, 'INV-20260327-0004', NULL, 'COUNTER', N'Nghiêm Xuân Hùng',  '0938888038', NULL, 1,  85000, 0,  85000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(49, 'INV-20260327-0005', NULL, 'COUNTER', N'Lê Ngọc Sơn',       '0959999059', NULL, 2, 140000, 0, 140000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(50, 'INV-20260328-0001', NULL, 'COUNTER', N'Chu Văn Tùng',      '0939999039', NULL, 1,  75000, 0,  75000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(51, 'INV-20260328-0002', NULL, 'COUNTER', N'Trần Ngọc Hiếu',    '0940000040', NULL, 1,  75000, 0,  75000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(52, 'INV-20260328-0003', NULL, 'COUNTER', N'Phạm Bảo Ngọc',     '0941111041', NULL, 1,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 2, N'VIP'),
(53, 'INV-20260328-0004', NULL, 'COUNTER', N'Lưu Ngọc Quỳnh',    '0942222042', NULL, 1,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(54, 'INV-20260328-0005', NULL, 'COUNTER', N'Đoàn Văn Phong',    '0943333043', NULL, 1, 160000, 0, 160000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(55, 'INV-20260328-0006', NULL, 'COUNTER', N'Trần Bảo Châu',     '0960000060', NULL, 2,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(56, 'INV-20260328-0007', NULL, 'COUNTER', N'Hoàng Đức Duy',     '0961111061', NULL, 2,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(57, 'INV-20260329-0001', NULL, 'COUNTER', N'Lý Minh Phúc',      '0944444044', NULL, 1, 130000, 0, 130000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(58, 'INV-20260329-0002', NULL, 'COUNTER', N'Cao Văn Tuấn',      '0945555045', NULL, 1,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 3, NULL),
(59, 'INV-20260329-0003', NULL, 'COUNTER', N'Ninh Thị Thu Hà',   '0946666046', NULL, 1,  95000, 0,  95000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(60, 'INV-20260329-0004', NULL, 'COUNTER', N'Dư Thị Nga',        '0962222062', NULL, 2,  75000, 0,  75000, 'CASH',    'PAID', 'ACTIVE', 9, NULL),
(61, 'INV-20260329-0005', NULL, 'COUNTER', N'Võ Bá Huy',         '0963333063', NULL, 2,  95000, 0,  95000, 'BANKING', 'PAID', 'ACTIVE', 9, NULL),
(62, 'INV-20260330-0001', NULL, 'COUNTER', N'Triệu Văn An',      '0947777047', NULL, 1,  65000, 0,  65000, 'CASH',    'PAID', 'ACTIVE', 2, NULL),
(63, 'INV-20260330-0002', NULL, 'COUNTER', N'Phùng Ngọc Lan',    '0948888048', NULL, 1,  65000, 0,  65000, 'BANKING', 'PAID', 'ACTIVE', 2, NULL),
(64, 'INV-20260330-0003', NULL, 'COUNTER', N'Diệp Hữu Nghĩa',    '0949999049', NULL, 1, 140000, 0, 140000, 'CASH',    'PAID', 'ACTIVE', 3, NULL),
(65, 'INV-20260330-0004', NULL, 'COUNTER', N'Dương Quang Minh',  '0964444064', NULL, 2, 130000, 0, 130000, 'CASH',    'PAID', 'ACTIVE', 9, NULL);

SET IDENTITY_INSERT invoices OFF;
GO

-- =============================================
-- D. STAFF SCHEDULES: 18/03 → 01/04/2026
-- Branch 1: staff1 (user_id=2), staff2 (user_id=3) - created_by manager1 (user_id=4)
-- Branch 2: staff3 (user_id=9) - created_by manager2 (user_id=8)
-- Ca: MORNING(06-12), AFTERNOON(12-17), EVENING(17-22), NIGHT(22-06)
-- =============================================
INSERT INTO staff_schedules (staff_id, branch_id, work_date, shift, status, note, created_by) VALUES
-- ===== BRANCH 1 STAFF1 (user_id=2) =====
(2, 1, '2026-03-18', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-19', 'AFTERNOON', 'SCHEDULED', NULL, 4),
(2, 1, '2026-03-20', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-21', 'MORNING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(2, 1, '2026-03-22', 'MORNING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(2, 1, '2026-03-23', 'AFTERNOON', 'SCHEDULED', NULL, 4),
(2, 1, '2026-03-24', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-25', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-26', 'AFTERNOON', 'SCHEDULED', NULL, 4),
(2, 1, '2026-03-27', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-28', 'MORNING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(2, 1, '2026-03-29', 'MORNING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(2, 1, '2026-03-30', 'MORNING',   'SCHEDULED', NULL, 4),
(2, 1, '2026-03-31', 'AFTERNOON', 'SCHEDULED', NULL, 4),
(2, 1, '2026-04-01', 'MORNING',   'SCHEDULED', NULL, 4),
-- ===== BRANCH 1 STAFF2 (user_id=3) =====
(3, 1, '2026-03-18', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-19', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-20', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-21', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(3, 1, '2026-03-22', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(3, 1, '2026-03-23', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-24', 'AFTERNOON', 'SCHEDULED', NULL, 4),
(3, 1, '2026-03-25', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-26', 'EVENING',   'CANCELLED', N'Nghỉ phép', 4),
(3, 1, '2026-03-27', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-28', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(3, 1, '2026-03-29', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 4),
(3, 1, '2026-03-30', 'EVENING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-03-31', 'MORNING',   'SCHEDULED', NULL, 4),
(3, 1, '2026-04-01', 'EVENING',   'SCHEDULED', NULL, 4),
-- ===== BRANCH 2 STAFF3 (user_id=9) =====
(9, 2, '2026-03-18', 'MORNING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-18', 'EVENING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-19', 'MORNING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-20', 'MORNING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-21', 'MORNING',   'SCHEDULED', N'Cuối tuần', 8),
(9, 2, '2026-03-21', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 8),
(9, 2, '2026-03-22', 'AFTERNOON', 'SCHEDULED', N'Cuối tuần', 8),
(9, 2, '2026-03-23', 'AFTERNOON', 'SCHEDULED', NULL, 8),
(9, 2, '2026-03-24', 'EVENING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-25', 'MORNING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-26', 'AFTERNOON', 'SCHEDULED', NULL, 8),
(9, 2, '2026-03-27', 'EVENING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-03-28', 'MORNING',   'SCHEDULED', N'Cuối tuần', 8),
(9, 2, '2026-03-28', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 8),
(9, 2, '2026-03-29', 'MORNING',   'SCHEDULED', N'Cuối tuần', 8),
(9, 2, '2026-03-29', 'EVENING',   'SCHEDULED', N'Cuối tuần tăng ca', 8),
(9, 2, '2026-03-30', 'AFTERNOON', 'SCHEDULED', NULL, 8),
(9, 2, '2026-03-31', 'EVENING',   'SCHEDULED', NULL, 8),
(9, 2, '2026-04-01', 'MORNING',   'SCHEDULED', NULL, 8);
GO

-- =============================================
-- E. REVENUE REPORTS: 18/03 → 30/03/2026
-- =============================================
INSERT INTO revenue_reports (branch_id, report_date, sale_channel, online_tickets_count, online_revenue, counter_tickets_count, counter_revenue, total_tickets_count, total_revenue, adult_tickets, child_tickets, normal_seats, vip_seats, couple_seats, generated_by) VALUES
(1, '2026-03-18', 'COUNTER',  0,      0, 6, 480000,  6, 480000,  5, 1, 6, 0, 0, 4),
(2, '2026-03-18', 'COUNTER',  0,      0, 4, 345000,  4, 345000,  4, 0, 4, 0, 0, 8),
(1, '2026-03-19', 'COUNTER',  0,      0, 4, 330000,  4, 330000,  4, 0, 4, 0, 0, 4),
(2, '2026-03-19', 'COUNTER',  0,      0, 2, 130000,  2, 130000,  2, 0, 2, 0, 0, 8),
(1, '2026-03-20', 'COUNTER',  0,      0, 5, 405000,  5, 405000,  4, 1, 4, 1, 0, 4),
(1, '2026-03-21', 'COUNTER',  0,      0, 7, 680000,  7, 680000,  6, 1, 5, 0, 2, 4),
(2, '2026-03-21', 'COUNTER',  0,      0, 4, 380000,  4, 380000,  4, 0, 4, 0, 0, 8),
(1, '2026-03-22', 'COUNTER',  0,      0, 4, 385000,  4, 385000,  3, 1, 4, 0, 0, 4),
(2, '2026-03-22', 'COUNTER',  0,      0, 1,  85000,  1,  85000,  1, 0, 1, 0, 0, 8),
(1, '2026-03-23', 'COUNTER',  0,      0, 3, 215000,  3, 215000,  3, 0, 3, 0, 0, 4),
(1, '2026-03-24', 'COUNTER',  0,      0, 4, 270000,  4, 270000,  3, 1, 4, 0, 0, 4),
(1, '2026-03-25', 'COUNTER',  0,      0, 4, 310000,  4, 310000,  3, 1, 3, 1, 0, 4),
(2, '2026-03-25', 'COUNTER',  0,      0, 2, 130000,  2, 130000,  2, 0, 2, 0, 0, 8),
(1, '2026-03-26', 'COUNTER',  0,      0, 3, 195000,  3, 195000,  2, 1, 3, 0, 0, 4),
(1, '2026-03-27', 'COUNTER',  0,      0, 4, 300000,  4, 300000,  4, 0, 4, 0, 0, 4),
(2, '2026-03-27', 'COUNTER',  0,      0, 2, 140000,  2, 140000,  1, 1, 2, 0, 0, 8),
(1, '2026-03-28', 'COUNTER',  0,      0, 6, 530000,  6, 530000,  5, 1, 5, 1, 0, 4),
(2, '2026-03-28', 'COUNTER',  0,      0, 2, 190000,  2, 190000,  2, 0, 2, 0, 0, 8),
(1, '2026-03-29', 'COUNTER',  0,      0, 4, 380000,  4, 380000,  3, 1, 4, 0, 0, 4),
(2, '2026-03-29', 'COUNTER',  0,      0, 2, 170000,  2, 170000,  2, 0, 2, 0, 0, 8),
(1, '2026-03-30', 'COUNTER',  0,      0, 4, 275000,  4, 275000,  3, 1, 4, 0, 0, 4),
(2, '2026-03-30', 'COUNTER',  0,      0, 2, 130000,  2, 130000,  1, 1, 2, 0, 0, 8);
GO

-- =============================================
-- Thêm vào block XÓA DỮ LIỆU MẪU ở đầu file khi chạy lại:
-- DELETE FROM staff_schedules;
-- DBCC CHECKIDENT ('staff_schedules', RESEED, 0);
-- =============================================
