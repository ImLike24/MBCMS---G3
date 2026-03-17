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

