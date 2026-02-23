CREATE DATABASE MBCMS;
GO

USE MBCMS;
GO

CREATE TABLE roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fullName NVARCHAR(255),
    birthday DATETIME2,
    phone VARCHAR(20),
    avatarURL VARCHAR(255),
    status VARCHAR(10) DEFAULT 'ACTIVE',
    points INT DEFAULT 0,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    last_login DATETIME2,
    CONSTRAINT FK_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE','LOCKED','INACTIVE'))
);
GO

CREATE TABLE cinema_branches (
    branch_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_name NVARCHAR(100) NOT NULL,
    address NVARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_id INT,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_branch_manager FOREIGN KEY (manager_id) REFERENCES users(user_id)
);
GO

CREATE TABLE screening_rooms (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_id INT NOT NULL,
    room_name VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL DEFAULT 0,
    status VARCHAR(15) DEFAULT 'ACTIVE',
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_rooms_branch FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id),
    CONSTRAINT CK_room_status CHECK (status IN ('ACTIVE','MAINTENANCE','CLOSED'))
);
GO

CREATE TABLE seats (
    seat_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    seat_code VARCHAR(10) NOT NULL,
    seat_type VARCHAR(10) DEFAULT 'NORMAL',
    row_number VARCHAR(5),
    seat_number INT,
    status VARCHAR(15) DEFAULT 'AVAILABLE',
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_seats_room FOREIGN KEY (room_id) REFERENCES screening_rooms(room_id),
    CONSTRAINT CK_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),
    CONSTRAINT CK_seat_status CHECK (status IN ('AVAILABLE','BROKEN','MAINTENANCE'))
);
GO

CREATE TABLE movies (
    movie_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX),
    genre NVARCHAR(100) NOT NULL,
    duration INT NOT NULL, -- Minutes
    release_date DATE,
    end_date DATE,
    rating DECIMAL(2,1) DEFAULT 0,
    age_rating VARCHAR(10), -- G, PG, PG-13, R, NC-17
    director NVARCHAR(100),
    cast NVARCHAR(500),
    poster_url VARCHAR(255),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT CK_movie_rating CHECK (rating BETWEEN 0 AND 5)
);
GO

CREATE TABLE showtimes (
    showtime_id INT IDENTITY(1,1) PRIMARY KEY,
    movie_id INT NOT NULL,
    room_id INT NOT NULL,
    show_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    base_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(15) DEFAULT 'SCHEDULED',
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_showtime_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    CONSTRAINT FK_showtime_room FOREIGN KEY (room_id) REFERENCES screening_rooms(room_id),
    CONSTRAINT CK_showtime_status CHECK (status IN ('SCHEDULED','ONGOING','COMPLETED','CANCELLED'))
);
GO

CREATE TABLE ticket_prices (
    price_id INT IDENTITY(1,1) PRIMARY KEY,
    seat_type VARCHAR(10) NOT NULL,
    ticket_type VARCHAR(10) NOT NULL,
    day_type VARCHAR(10) NOT NULL, -- WEEKDAY/WEEKEND/HOLIDAY
    time_slot VARCHAR(10) NOT NULL, -- MORNING/AFTERNOON/EVENING
    price DECIMAL(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT CK_price_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),
    CONSTRAINT CK_price_ticket_type CHECK (ticket_type IN ('ADULT','CHILD')),
    CONSTRAINT CK_price_day_type CHECK (day_type IN ('WEEKDAY','WEEKEND','HOLIDAY')),
CONSTRAINT CK_effective_dates 
CHECK (effective_to IS NULL OR effective_to >= effective_from),
CONSTRAINT CK_price_positive 
CHECK (price > 0),
    CONSTRAINT CK_price_time_slot CHECK (time_slot IN ('MORNING','AFTERNOON','EVENING','NIGHT'))
);
GO

CREATE TABLE bookings (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    showtime_id INT NOT NULL,
    booking_code VARCHAR(20) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(20),
    payment_status VARCHAR(15) DEFAULT 'PENDING',
    booking_time DATETIME2 DEFAULT SYSDATETIME(),
    payment_time DATETIME2,
    status VARCHAR(15) DEFAULT 'PENDING',
    cancellation_reason NVARCHAR(500),
    cancelled_at DATETIME2,
    CONSTRAINT FK_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT FK_booking_showtime FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id),
    CONSTRAINT CK_booking_status CHECK (status IN ('PENDING','CONFIRMED','CANCELLED','EXPIRED')),
    CONSTRAINT CK_payment_status CHECK (payment_status IN ('PENDING','PAID','REFUNDED','FAILED')),
    CONSTRAINT CK_payment_method CHECK (payment_method IN ('ZALOPAY','CREDIT_CARD','BANKING')),
    CONSTRAINT CK_booking_amounts CHECK (
        total_amount >= 0 AND 
        discount_amount >= 0 AND 
        final_amount >= 0 AND
        final_amount = total_amount - discount_amount
    ),
    CONSTRAINT CK_payment_time CHECK (payment_time IS NULL OR payment_time >= booking_time)
);
GO

CREATE TABLE online_tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    showtime_id INT NOT NULL,
    seat_id INT NOT NULL,
    ticket_type VARCHAR(10) NOT NULL,
    seat_type VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    e_ticket_code VARCHAR(100) UNIQUE NOT NULL,
    is_checked_in BIT DEFAULT 0,
    checked_in_at DATETIME2,
    checked_in_by INT, -- Staff user_id
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_online_ticket_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_online_ticket_showtime FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id),
    CONSTRAINT FK_online_ticket_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
    CONSTRAINT FK_online_ticket_checkin_by FOREIGN KEY (checked_in_by) REFERENCES users(user_id),
    CONSTRAINT CK_online_ticket_type CHECK (ticket_type IN ('ADULT','CHILD')),
    CONSTRAINT CK_online_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE'))
);
GO

CREATE TABLE counter_tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    showtime_id INT NOT NULL,
    seat_id INT NOT NULL,
    ticket_type VARCHAR(10) NOT NULL,
    seat_type VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    ticket_code VARCHAR(100) UNIQUE NOT NULL,
    sold_by INT NOT NULL, -- Staff user_id
    payment_method VARCHAR(20) NOT NULL,
    customer_name NVARCHAR(100),
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100),
    notes NVARCHAR(500),
    sold_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_counter_ticket_showtime FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id),
    CONSTRAINT FK_counter_ticket_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
    CONSTRAINT FK_counter_ticket_sold_by FOREIGN KEY (sold_by) REFERENCES users(user_id),
    CONSTRAINT CK_counter_ticket_type CHECK (ticket_type IN ('ADULT','CHILD')),
    CONSTRAINT CK_counter_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),
    CONSTRAINT CK_counter_payment_method CHECK (payment_method IN ('CASH','BANKING'))
);
GO

CREATE TABLE revenue_reports (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_id INT,
    report_date DATE NOT NULL,
    sale_channel VARCHAR(10) NOT NULL,
    online_tickets_count INT DEFAULT 0,
    online_revenue DECIMAL(12,2) DEFAULT 0,
    counter_tickets_count INT DEFAULT 0,
    counter_revenue DECIMAL(12,2) DEFAULT 0,
    total_tickets_count INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    adult_tickets INT DEFAULT 0,
    child_tickets INT DEFAULT 0,
    normal_seats INT DEFAULT 0,
    vip_seats INT DEFAULT 0,
    couple_seats INT DEFAULT 0,
    generated_at DATETIME2 DEFAULT SYSDATETIME(),
    generated_by INT,
    CONSTRAINT FK_revenue_branch FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id),
    CONSTRAINT FK_revenue_generated_by FOREIGN KEY (generated_by) REFERENCES users(user_id),
    CONSTRAINT CK_sale_channel CHECK (sale_channel IN ('ONLINE','COUNTER','COMBINED'))
);
GO

CREATE TABLE reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    comment NVARCHAR(MAX),
    helpful_count INT DEFAULT 0,
    is_verified BIT DEFAULT 0, -- User đã xem phim chưa
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT FK_review_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    CONSTRAINT CK_review_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE TABLE reported_comments (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    review_id INT NOT NULL,
    reported_by INT NOT NULL,
    reason NVARCHAR(255) NOT NULL,
    status VARCHAR(15) DEFAULT 'PENDING',
    resolved_by INT,
    resolved_at DATETIME2,
    resolution_note NVARCHAR(500),
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_report_review FOREIGN KEY (review_id) REFERENCES reviews(review_id),
    CONSTRAINT FK_report_reported_by FOREIGN KEY (reported_by) REFERENCES users(user_id),
    CONSTRAINT FK_report_resolved_by FOREIGN KEY (resolved_by) REFERENCES users(user_id),
    CONSTRAINT CK_report_status CHECK (status IN ('PENDING','REVIEWED','RESOLVED','DISMISSED'))
);
GO

CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    title NVARCHAR(150) NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    notification_type VARCHAR(20) DEFAULT 'GENERAL',
    sent_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_notification_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT CK_notification_type CHECK (notification_type IN ('BOOKING','SYSTEM','GENERAL'))
);
GO

CREATE TABLE invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_code VARCHAR(30) UNIQUE NOT NULL, -- Mã hoá đơn: INV-20260115-000001
    invoice_date DATETIME2 DEFAULT SYSDATETIME(),
    
    -- Link to booking (NULL if counter sale)
    booking_id INT NULL,
    
    -- Sale channel
    sale_channel VARCHAR(10) NOT NULL, -- ONLINE / COUNTER
    
    -- Customer info (basic)
    customer_name NVARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100),
    
    -- Branch info
    branch_id INT NOT NULL,
    
    -- Financial info (simple - no tax breakdown)
    total_amount DECIMAL(10,2) NOT NULL, -- Tổng tiền
    discount_amount DECIMAL(10,2) DEFAULT 0, -- Giảm giá
    final_amount DECIMAL(10,2) NOT NULL, -- Thành tiền
    
    -- Payment info
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(15) DEFAULT 'PAID',
    
    -- Status
    status VARCHAR(15) DEFAULT 'ACTIVE', -- ACTIVE / CANCELLED
    
    -- Staff who created this invoice
    created_by INT NOT NULL,
    
    -- Notes
    notes NVARCHAR(500),
    
    -- Timestamps
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_invoice_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_invoice_branch FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id),
    CONSTRAINT FK_invoice_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT CK_invoice_sale_channel CHECK (sale_channel IN ('ONLINE','COUNTER')),
    CONSTRAINT CK_invoice_status CHECK (status IN ('ACTIVE','CANCELLED')),
    CONSTRAINT CK_invoice_payment_status CHECK (payment_status IN ('PAID','UNPAID','REFUNDED')),
    CONSTRAINT CK_invoice_payment_method CHECK (payment_method IN ('ZALOPAY','BANKING','CASH')),
    CONSTRAINT CK_invoice_amounts CHECK (
        total_amount >= 0 AND 
        discount_amount >= 0 AND 
        final_amount >= 0 AND
        final_amount = total_amount - discount_amount
    )
);
GO

-- Invoice items (details)
CREATE TABLE invoice_items (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT NOT NULL,
    
    -- Item type
    item_type VARCHAR(20) NOT NULL, -- ONLINE_TICKET / COUNTER_TICKET
    
    -- Reference to ticket
    online_ticket_id INT NULL,
    counter_ticket_id INT NULL,
    
    -- Description
    item_description NVARCHAR(500) NOT NULL, -- "Avengers: Endgame - VIP - A5"
    movie_title NVARCHAR(150),
    showtime_date DATE,
    showtime_time TIME,
    room_name VARCHAR(50),
    seat_code VARCHAR(10),
    ticket_type VARCHAR(10), -- ADULT / CHILD
    seat_type VARCHAR(10), -- NORMAL / VIP / COUPLE
    
    -- Price
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    amount DECIMAL(10,2) NOT NULL, -- quantity * unit_price
    
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    CONSTRAINT FK_invoice_item_online FOREIGN KEY (online_ticket_id) REFERENCES online_tickets(ticket_id),
    CONSTRAINT FK_invoice_item_counter FOREIGN KEY (counter_ticket_id) REFERENCES counter_tickets(ticket_id),
    CONSTRAINT CK_invoice_item_type CHECK (item_type IN ('ONLINE_TICKET','COUNTER_TICKET')),
    CONSTRAINT CK_invoice_item_ticket_type CHECK (ticket_type IN ('ADULT','CHILD')),
    CONSTRAINT CK_invoice_item_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),
    CONSTRAINT CK_invoice_item_amounts CHECK (
        quantity > 0 AND
        unit_price >= 0 AND
        amount = quantity * unit_price
    )
);
GO



-- Users indexes
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created ON users(created_at);

-- Cinema branches indexes
CREATE INDEX idx_branches_active ON cinema_branches(is_active);
CREATE INDEX idx_branches_manager ON cinema_branches(manager_id);

-- Screening rooms indexes
CREATE INDEX idx_rooms_branch ON screening_rooms(branch_id);
CREATE INDEX idx_rooms_status ON screening_rooms(status);

-- Seats indexes
CREATE INDEX idx_seats_room ON seats(room_id);
CREATE INDEX idx_seats_status ON seats(status);
CREATE INDEX idx_seats_type ON seats(seat_type);
CREATE UNIQUE INDEX ux_seat_room_code ON seats(room_id, seat_code);

-- Movies indexes
CREATE INDEX idx_movies_release ON movies(release_date);
CREATE INDEX idx_movies_active ON movies(is_active);
CREATE INDEX idx_movies_genre ON movies(genre);
CREATE INDEX idx_movies_rating ON movies(rating);

-- Showtimes indexes
CREATE INDEX idx_showtime_movie ON showtimes(movie_id);
CREATE INDEX idx_showtime_room ON showtimes(room_id);
CREATE INDEX idx_showtime_date ON showtimes(show_date);
CREATE INDEX idx_showtime_status ON showtimes(status);
CREATE UNIQUE INDEX ux_showtime_unique ON showtimes(room_id, show_date, start_time);

-- Bookings indexes
CREATE INDEX idx_booking_user ON bookings(user_id);
CREATE INDEX idx_booking_showtime ON bookings(showtime_id);
CREATE INDEX idx_booking_status ON bookings(status);
CREATE INDEX idx_booking_payment_status ON bookings(payment_status);
CREATE INDEX idx_booking_time ON bookings(booking_time);
CREATE UNIQUE INDEX ux_booking_code ON bookings(booking_code);

-- Ticket prices indexes
CREATE INDEX idx_ticket_prices_dates 
ON ticket_prices(effective_from, effective_to, is_active);

-- Online tickets indexes
CREATE INDEX idx_online_ticket_booking ON online_tickets(booking_id);
CREATE INDEX idx_online_ticket_showtime ON online_tickets(showtime_id);
CREATE INDEX idx_online_ticket_seat ON online_tickets(seat_id);
CREATE INDEX idx_online_ticket_checkin ON online_tickets(is_checked_in);
CREATE UNIQUE INDEX ux_online_ticket_showtime_seat ON online_tickets(showtime_id, seat_id);

-- Counter tickets indexes
CREATE INDEX idx_counter_ticket_showtime ON counter_tickets(showtime_id);
CREATE INDEX idx_counter_ticket_seat ON counter_tickets(seat_id);
CREATE INDEX idx_counter_ticket_sold_by ON counter_tickets(sold_by);
CREATE INDEX idx_counter_ticket_sold_at ON counter_tickets(sold_at);
CREATE UNIQUE INDEX ux_counter_ticket_showtime_seat ON counter_tickets(showtime_id, seat_id);

-- Revenue reports indexes
CREATE INDEX idx_revenue_branch ON revenue_reports(branch_id);
CREATE INDEX idx_revenue_date ON revenue_reports(report_date);
CREATE INDEX idx_revenue_channel ON revenue_reports(sale_channel);
CREATE INDEX idx_revenue_generated ON revenue_reports(generated_at);

-- Reviews indexes
CREATE INDEX idx_review_movie ON reviews(movie_id);
CREATE INDEX idx_review_user ON reviews(user_id);
CREATE INDEX idx_review_rating ON reviews(rating);
CREATE INDEX idx_review_created ON reviews(created_at);

-- Reported comments indexes
CREATE INDEX idx_report_review ON reported_comments(review_id);
CREATE INDEX idx_report_status ON reported_comments(status);
CREATE INDEX idx_report_reported_by ON reported_comments(reported_by);

-- Notifications indexes
CREATE INDEX idx_notification_user ON notifications(user_id);
CREATE INDEX idx_notification_type ON notifications(notification_type);
CREATE INDEX idx_notification_sent ON notifications(sent_at);


CREATE INDEX idx_invoice_code ON invoices(invoice_code);
CREATE INDEX idx_invoice_booking ON invoices(booking_id);
CREATE INDEX idx_invoice_date ON invoices(invoice_date);
CREATE INDEX idx_invoice_status ON invoices(status);
CREATE INDEX idx_invoice_branch ON invoices(branch_id);
CREATE INDEX idx_invoice_channel ON invoices(sale_channel);
CREATE INDEX idx_invoice_customer ON invoices(customer_phone, customer_email);

CREATE INDEX idx_invoice_item_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_item_online ON invoice_items(online_ticket_id);
CREATE INDEX idx_invoice_item_counter ON invoice_items(counter_ticket_id);
Go

-- Auto update timestamp
CREATE TRIGGER trg_invoice_updated ON invoices
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE i SET updated_at = SYSDATETIME()
    FROM invoices i
    INNER JOIN inserted ins ON i.invoice_id = ins.invoice_id;
END;
GO

CREATE TRIGGER trg_users_updated ON users
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE u SET updated_at = SYSDATETIME()
    FROM users u
    INNER JOIN inserted i ON u.user_id = i.user_id;
END;
GO

-- Trigger: Auto update movies.updated_at
CREATE TRIGGER trg_movies_updated ON movies
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE m SET updated_at = SYSDATETIME()
    FROM movies m
    INNER JOIN inserted i ON m.movie_id = i.movie_id;
END;
GO

-- Trigger: Auto update cinema_branches.updated_at
CREATE TRIGGER trg_branches_updated ON cinema_branches
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b SET updated_at = SYSDATETIME()
    FROM cinema_branches b
    INNER JOIN inserted i ON b.branch_id = i.branch_id;
END;
GO

-- Trigger: Auto update roles.updated_at
CREATE TRIGGER trg_roles_updated ON roles
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r SET updated_at = SYSDATETIME()
    FROM roles r
    INNER JOIN inserted i ON r.role_id = i.role_id;
END;
GO

-- Trigger: Auto update reviews.updated_at
CREATE TRIGGER trg_reviews_updated ON reviews
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r SET updated_at = SYSDATETIME()
    FROM reviews r
    INNER JOIN inserted i ON r.review_id = i.review_id;
END;
GO

CREATE TRIGGER trg_update_total_seats ON seats
AFTER INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r
    SET total_seats = (
        SELECT COUNT(*)
        FROM seats s
        WHERE s.room_id = r.room_id AND s.status != 'BROKEN'
    )
    FROM screening_rooms r
    WHERE r.room_id IN (
        SELECT room_id FROM inserted
        UNION
        SELECT room_id FROM deleted
    );
END;
GO

CREATE TRIGGER trg_calculate_booking_amount ON online_tickets
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b
    SET total_amount = (
        SELECT ISNULL(SUM(price), 0)
        FROM online_tickets
        WHERE booking_id = b.booking_id
    ),
    final_amount = (
        SELECT ISNULL(SUM(price), 0)
        FROM online_tickets
        WHERE booking_id = b.booking_id
    ) - ISNULL(b.discount_amount, 0)
    FROM bookings b
    WHERE b.booking_id IN (SELECT DISTINCT booking_id FROM inserted);
END;
GO

-- Trigger: Update movie rating when review is added/updated
CREATE TRIGGER trg_update_movie_rating ON reviews
AFTER INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE m
    SET rating = (
        SELECT ROUND(AVG(CAST(rating AS DECIMAL(3,2))), 1)
        FROM reviews
        WHERE movie_id = m.movie_id
    )
    FROM movies m
    WHERE m.movie_id IN (SELECT DISTINCT movie_id FROM inserted);
END;
GO

-- Trigger: Prevent duplicate seat at online booking
CREATE TRIGGER trg_prevent_double_booking_online
ON online_tickets
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if seat already sold at counter
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN counter_tickets ct 
            ON i.showtime_id = ct.showtime_id 
            AND i.seat_id = ct.seat_id
    )
    BEGIN
        RAISERROR('Seat already sold at counter', 16, 1);
        RETURN;
    END
    
    -- Insert if OK
    INSERT INTO online_tickets (
        booking_id, showtime_id, seat_id, ticket_type, 
        seat_type, price, e_ticket_code, created_at
    )
    SELECT 
        booking_id, showtime_id, seat_id, ticket_type,
        seat_type, price, e_ticket_code, SYSDATETIME()
    FROM inserted;
END;
GO

-- Trigger: Prevent duplicate seat at counter booking
CREATE TRIGGER trg_prevent_double_booking_counter
ON counter_tickets
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if seat already sold online
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN online_tickets ot 
            ON i.showtime_id = ot.showtime_id 
            AND i.seat_id = ot.seat_id
    )
    BEGIN
        RAISERROR('Seat already sold online', 16, 1);
        RETURN;
    END
    
    -- Insert if OK
    INSERT INTO counter_tickets (
        showtime_id, seat_id, ticket_type, seat_type, 
        price, ticket_code, sold_by, payment_method,
        customer_name, customer_phone, customer_email, 
        notes, sold_at
    )
    SELECT 
        showtime_id, seat_id, ticket_type, seat_type,
        price, ticket_code, sold_by, payment_method,
        customer_name, customer_phone, customer_email,
        notes, SYSDATETIME()
    FROM inserted;
END;
GO

-- =============================================
-- SAMPLE DATA: 22 Movies
-- =============================================

-- Insert 22 sample movies with diverse genres, ratings, and age ratings
INSERT INTO movies (title, description, genre, duration, release_date, end_date, rating, age_rating, director, cast, poster_url, is_active) VALUES
-- Action Movies
(N'The Last Guardian', N'A former special forces operative must protect a young witness from ruthless assassins across dangerous terrain.', N'Action', 142, '2025-01-15', '2025-03-15', 4.5, 'R', N'Michael Bay', N'Chris Hemsworth, Zoe Saldana, Idris Elba', 'https://image.tmdb.org/t/p/w500/sample1.jpg', 1),
(N'Speed Racer Returns', N'An underground street racer enters a high-stakes international racing competition to save his family business.', N'Action', 128, '2025-01-20', '2025-03-20', 4.2, 'PG-13', N'Justin Lin', N'Tom Hardy, Michelle Rodriguez, Sung Kang', 'https://image.tmdb.org/t/p/w500/sample2.jpg', 1),

-- Comedy Movies
(N'Wedding Disaster', N'A wedding planner must save a celebrity wedding when everything goes hilariously wrong in 48 hours.', N'Comedy', 105, '2025-01-10', '2025-03-10', 3.8, 'PG-13', N'Paul Feig', N'Melissa McCarthy, Ryan Reynolds, Awkwafina', 'https://image.tmdb.org/t/p/w500/sample3.jpg', 1),
(N'The Roommate From Hell', N'Two polar opposite college roommates must learn to live together or face expulsion.', N'Comedy', 98, '2025-02-01', '2025-04-01', 3.5, 'PG-13', N'Judd Apatow', N'Jack Black, Emma Stone, Kevin Hart', 'https://image.tmdb.org/t/p/w500/sample4.jpg', 1),

-- Horror Movies
(N'The Haunting of Blackwood Manor', N'A family moves into an old mansion only to discover its dark and deadly secrets.', N'Horror', 115, '2025-01-25', '2025-03-25', 4.0, 'R', N'James Wan', N'Vera Farmiga, Patrick Wilson, Taissa Farmiga', 'https://image.tmdb.org/t/p/w500/sample5.jpg', 1),
(N'Silent Scream', N'A deaf woman must survive a home invasion by using her other heightened senses.', N'Horror', 92, '2025-02-05', '2025-04-05', 4.3, 'R', N'Mike Flanagan', N'Emily Blunt, John Krasinski, Millicent Simmonds', 'https://image.tmdb.org/t/p/w500/sample6.jpg', 1),

-- Drama Movies
(N'The Forgotten Soldier', N'A war veteran struggles to reintegrate into society while battling PTSD and searching for meaning.', N'Drama', 135, '2025-01-12', '2025-03-12', 4.7, 'R', N'Clint Eastwood', N'Bradley Cooper, Sienna Miller, Kyle Gallner', 'https://image.tmdb.org/t/p/w500/sample7.jpg', 1),
(N'Letters to My Daughter', N'A mother writes letters to her daughter over 20 years, chronicling life, love, and loss.', N'Drama', 122, '2025-02-10', '2025-04-10', 4.6, 'PG-13', N'Greta Gerwig', N'Saoirse Ronan, Meryl Streep, Timothée Chalamet', 'https://image.tmdb.org/t/p/w500/sample8.jpg', 1),

-- Sci-Fi Movies
(N'Beyond the Void', N'Astronauts on a deep space mission discover an ancient alien civilization that changes everything.', N'Sci-Fi', 148, '2025-01-18', '2025-03-18', 4.4, 'PG-13', N'Denis Villeneuve', N'Matthew McConaughey, Anne Hathaway, Jessica Chastain', 'https://image.tmdb.org/t/p/w500/sample9.jpg', 1),
(N'Neural Link', N'In the near future, a hacker discovers a conspiracy within a virtual reality network.', N'Sci-Fi', 118, '2025-02-15', '2025-04-15', 4.1, 'PG-13', N'Wachowski Sisters', N'Keanu Reeves, Carrie-Anne Moss, Yahya Abdul-Mateen II', 'https://image.tmdb.org/t/p/w500/sample10.jpg', 1),

-- Romance Movies
(N'Love in Paris', N'Two strangers meet on a train to Paris and spend one magical night exploring the city together.', N'Romance', 108, '2025-01-22', '2025-03-22', 3.9, 'PG-13', N'Richard Linklater', N'Emma Watson, Eddie Redmayne, Marion Cotillard', 'https://image.tmdb.org/t/p/w500/sample11.jpg', 1),
(N'Second Chances', N'A divorced couple reunites at their daughter wedding and rekindles their romance.', N'Romance', 112, '2025-02-08', '2025-04-08', 4.0, 'PG', N'Nancy Meyers', N'Meryl Streep, Alec Baldwin, Steve Martin', 'https://image.tmdb.org/t/p/w500/sample12.jpg', 1),

-- Animation Movies
(N'Dragon Kingdom', N'A young farm boy discovers he is the last dragon rider and must save the kingdom from darkness.', N'Animation', 102, '2025-01-28', '2025-03-28', 4.5, 'PG', N'Dean DeBlois', N'Jay Baruchel, America Ferrera, Cate Blanchett', 'https://image.tmdb.org/t/p/w500/sample13.jpg', 1),
(N'Tiny Heroes', N'A group of miniature toys come to life and embark on an epic adventure to return home.', N'Animation', 95, '2025-02-12', '2025-04-12', 4.3, 'G', N'Pete Docter', N'Tom Hanks, Tim Allen, Joan Cusack', 'https://image.tmdb.org/t/p/w500/sample14.jpg', 1),

-- Thriller Movies
(N'The Perfect Alibi', N'A detective hunts a serial killer who always has an ironclad alibi for each murder.', N'Thriller', 125, '2025-01-30', '2025-03-30', 4.2, 'R', N'David Fincher', N'Jake Gyllenhaal, Mark Ruffalo, Robert Downey Jr.', 'https://image.tmdb.org/t/p/w500/sample15.jpg', 1),
(N'Trust No One', N'A woman discovers her entire life is an elaborate lie created by those closest to her.', N'Thriller', 110, '2025-02-18', '2025-04-18', 4.1, 'R', N'Ben Affleck', N'Rosamund Pike, Ben Affleck, Neil Patrick Harris', 'https://image.tmdb.org/t/p/w500/sample16.jpg', 1),

-- Fantasy Movies
(N'The Enchanted Forest', N'A young witch must master her powers to save her magical realm from eternal darkness.', N'Fantasy', 138, '2025-01-16', '2025-03-16', 4.4, 'PG-13', N'Guillermo del Toro', N'Anya Taylor-Joy, Ralph Fiennes, Helena Bonham Carter', 'https://image.tmdb.org/t/p/w500/sample17.jpg', 1),
(N'Legend of the Silver Sword', N'An unlikely hero discovers an ancient sword and must unite warring kingdoms against a dark lord.', N'Fantasy', 155, '2025-02-20', '2025-04-20', 4.6, 'PG-13', N'Peter Jackson', N'Elijah Wood, Viggo Mortensen, Ian McKellen', 'https://image.tmdb.org/t/p/w500/sample18.jpg', 1),

-- Mystery Movies
(N'The Missing Hour', N'A man wakes up with no memory of the last hour, which holds the key to solving a murder.', N'Mystery', 108, '2025-01-24', '2025-03-24', 3.9, 'PG-13', N'Christopher Nolan', N'Guy Pearce, Carrie-Anne Moss, Joe Pantoliano', 'https://image.tmdb.org/t/p/w500/sample19.jpg', 1),
(N'Whispers in the Dark', N'A psychiatrist becomes entangled in a web of secrets when treating a mysterious patient.', N'Mystery', 118, '2025-02-14', '2025-04-14', 4.0, 'R', N'Martin Scorsese', N'Leonardo DiCaprio, Mark Ruffalo, Ben Kingsley', 'https://image.tmdb.org/t/p/w500/sample20.jpg', 1),

-- Adventure Movies
(N'Quest for the Lost Temple', N'An archaeologist races against mercenaries to find an ancient temple holding unimaginable power.', N'Adventure', 132, '2025-01-26', '2025-03-26', 4.3, 'PG-13', N'Steven Spielberg', N'Harrison Ford, Karen Allen, Shia LaBeouf', 'https://image.tmdb.org/t/p/w500/sample21.jpg', 1),
(N'Ocean Deep', N'A marine biologist and her team explore the deepest parts of the ocean and discover new life forms.', N'Adventure', 126, '2025-02-22', '2025-04-22', 4.2, 'PG', N'James Cameron', N'Sigourney Weaver, Sam Worthington, Zoe Saldana', 'https://image.tmdb.org/t/p/w500/sample22.jpg', 1);

GO

-- =============================================
-- SAMPLE DATA: Cinema branch, room, seats (cần cho showtimes)
-- Counter Booking chỉ hiện phim có suất chiếu (showtimes) trong ngày chọn.
-- =============================================
-- Nếu đã có chi nhánh/phòng, bỏ qua 2 lệnh INSERT dưới và chạy riêng phần showtimes với room_id của bạn.
INSERT INTO cinema_branches (branch_name, address, phone, email, is_active)
VALUES (N'MBCMS Chi nhánh 1', N'123 Đường Mẫu, Quận 1', '0281234567', 'branch1@mbcms.com', 1);

INSERT INTO screening_rooms (branch_id, room_name, total_seats, status)
VALUES (1, N'Phòng 1', 50, 'ACTIVE');

-- 50 ghế cho phòng 1 (5 hàng x 10 ghế) với đa dạng loại ghế
-- Row 1-2: NORMAL seats (20 seats)
-- Row 3: VIP seats (10 seats - best viewing angle)
-- Row 4: Mix of VIP center + NORMAL sides (4 VIP + 6 NORMAL)
-- Row 5: COUPLE at ends + NORMAL middle (4 COUPLE + 6 NORMAL)

DECLARE @roomId INT = 1;
DECLARE @rowNum INT = 1;
DECLARE @seatNum INT;
DECLARE @seatCode VARCHAR(10);
DECLARE @seatType VARCHAR(10);

-- Loop through 5 rows
WHILE @rowNum <= 5
BEGIN
    -- Loop through 10 seats per row (A-J where A=1, B=2, ..., J=10)
    SET @seatNum = 1;
    WHILE @seatNum <= 10
    BEGIN
        -- Create seat code: Row + Letter (e.g., "1A", "1B", ..., "1J")
        SET @seatCode = CAST(@rowNum AS VARCHAR) + CHAR(64 + @seatNum);
        
        -- Determine seat type based on row and position
        IF @rowNum = 1 OR @rowNum = 2
        BEGIN
            -- Rows 1-2: All NORMAL
            SET @seatType = 'NORMAL';
        END
        ELSE IF @rowNum = 3
        BEGIN
            -- Row 3: All VIP (premium middle row with best view)
            SET @seatType = 'VIP';
        END
        ELSE IF @rowNum = 4
        BEGIN
            -- Row 4: VIP in center (seats D-G = 4-7), NORMAL at sides
            IF @seatNum >= 4 AND @seatNum <= 7
                SET @seatType = 'VIP';
            ELSE
                SET @seatType = 'NORMAL';
        END
        ELSE IF @rowNum = 5
        BEGIN
            -- Row 5: COUPLE at ends (A-B = 1-2 and I-J = 9-10), NORMAL in middle
            IF @seatNum <= 2 OR @seatNum >= 9
                SET @seatType = 'COUPLE';
            ELSE
                SET @seatType = 'NORMAL';
        END
        
        -- Insert seat
        INSERT INTO seats (room_id, seat_code, seat_type, row_number, seat_number, status)
        VALUES (@roomId, @seatCode, @seatType, CAST(@rowNum AS VARCHAR), @seatNum, 'AVAILABLE');
        
        SET @seatNum = @seatNum + 1;
    END
    
    SET @rowNum = @rowNum + 1;
END;

GO

-- =============================================
-- SAMPLE DATA: Showtimes (phim có suất chiếu mới hiện trên Counter Booking)
-- =============================================
-- Suất chiếu ngày 2026-02-01 và 2026-02-02 cho 22 phim (status SCHEDULED/ONGOING)
INSERT INTO showtimes (movie_id, room_id, show_date, start_time, base_price, status) VALUES
(1, 1, '2026-02-01', '09:00', 65000, 'SCHEDULED'),
(2, 1, '2026-02-01', '11:30', 65000, 'SCHEDULED'),
(3, 1, '2026-02-01', '14:00', 65000, 'SCHEDULED'),
(4, 1, '2026-02-01', '16:00', 65000, 'SCHEDULED'),
(5, 1, '2026-02-01', '18:00', 65000, 'SCHEDULED'),
(6, 1, '2026-02-01', '20:00', 65000, 'SCHEDULED'),
(7, 1, '2026-02-01', '21:30', 65000, 'SCHEDULED'),
(8, 1, '2026-02-02', '09:00', 65000, 'SCHEDULED'),
(9, 1, '2026-02-02', '11:30', 65000, 'SCHEDULED'),
(10, 1, '2026-02-02', '14:00', 65000, 'SCHEDULED'),
(11, 1, '2026-02-02', '16:30', 65000, 'SCHEDULED'),
(12, 1, '2026-02-02', '18:30', 65000, 'SCHEDULED'),
(13, 1, '2026-02-02', '20:30', 65000, 'SCHEDULED'),
(14, 1, '2026-02-01', '10:00', 65000, 'SCHEDULED'),
(15, 1, '2026-02-01', '12:30', 65000, 'SCHEDULED'),
(16, 1, '2026-02-01', '15:00', 65000, 'SCHEDULED'),
(17, 1, '2026-02-02', '10:00', 65000, 'SCHEDULED'),
(18, 1, '2026-02-02', '12:00', 65000, 'SCHEDULED'),
(19, 1, '2026-02-02', '15:00', 65000, 'SCHEDULED'),
(20, 1, '2026-02-02', '17:00', 65000, 'SCHEDULED'),
(21, 1, '2026-02-01', '13:00', 65000, 'SCHEDULED'),
(22, 1, '2026-02-02', '19:00', 65000, 'SCHEDULED');

GO

-- =============================================
-- SAMPLE DATA: Roles (cần có trước khi insert users)
-- =============================================
-- Chỉ insert role nếu chưa tồn tại (an toàn khi chạy lại script)
INSERT INTO roles (role_name)
SELECT x.role_name
FROM (VALUES ('ADMIN'), ('CUSTOMER'), ('CINEMA_STAFF'), ('STAFF'), ('BRANCH_MANAGER')) AS x(role_name)
WHERE NOT EXISTS (SELECT 1 FROM roles r WHERE r.role_name = x.role_name);

GO

-- =============================================
-- SAMPLE DATA: 1 additional Staff account (CINEMA_STAFF)
-- =============================================
-- Login: username = staff2, password = password (hash do jBCrypt của project sinh ra)
INSERT INTO users (role_id, username, email, password, fullName, phone, status, points)
SELECT r.role_id, 'staff2', 'staff2@mbcms.com', '$2a$10$BsDOyk3.dFIxPtGshxvTnubWVZ0gX6O9m3J/WZxPhIFG8v31THOke', N'Nguyễn Văn Staff 2', '0901234567', 'ACTIVE', 0
FROM roles r
WHERE r.role_name = 'CINEMA_STAFF';

GO

-- Nếu staff2 đã tồn tại nhưng đăng nhập không được, chạy lệnh sau để sửa mật khẩu (password = password):
-- UPDATE users SET password = '$2a$10$BsDOyk3.dFIxPtGshxvTnubWVZ0gX6O9m3J/WZxPhIFG8v31THOke' WHERE username = 'staff2';

create table genres
(
    genre_id    int identity
        primary key,
    genre_name  nvarchar(100) not null
        unique,
    description nvarchar(255),
    is_active   bit       default 1,
    created_at  datetime2 default sysdatetime(),
    updated_at  datetime2 default sysdatetime()
)
go

create index idx_genres_active
    on genres (is_active)
go


-- Trigger: Auto update genres.updated_at
CREATE TRIGGER trg_genres_updated ON genres
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE g SET updated_at = SYSDATETIME()
    FROM genres g
    INNER JOIN inserted i ON g.genre_id = i.genre_id;
END;
go

create table movie_genres
(
    movie_id int not null
        constraint FK_movie_genres_movie
            references movies(movie_id)
            on delete cascade,

    genre_id int not null
        constraint FK_movie_genres_genre
            references genres(genre_id)
            on delete cascade,

    created_at datetime2 default sysdatetime(),

    constraint PK_movie_genres
        primary key (movie_id, genre_id)
)
go

create index idx_movie_genres_movie
    on movie_genres (movie_id)
go

create index idx_movie_genres_genre
    on movie_genres (genre_id)
go

drop index idx_movies_genre on movies
go

alter table movies
drop column genre
go

-- =============================================
-- Seat Type Surcharge Config (per branch)
-- Run this on existing DB to add surcharge support
-- =============================================
CREATE TABLE seat_type_surcharges (
    surcharge_id   INT IDENTITY(1,1) PRIMARY KEY,
    branch_id      INT NOT NULL,
    seat_type      VARCHAR(10) NOT NULL,
    surcharge_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
    updated_at     DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_surcharge_branch    FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id),
    CONSTRAINT CK_surcharge_seat_type CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),
    CONSTRAINT CK_surcharge_rate      CHECK (surcharge_rate >= 0),
    CONSTRAINT UQ_surcharge_branch_type UNIQUE (branch_id, seat_type)
);
GO

-- Default rows (0% surcharge for all types per existing branch)
INSERT INTO seat_type_surcharges (branch_id, seat_type, surcharge_rate)
SELECT b.branch_id, t.seat_type, 0
FROM cinema_branches b
CROSS JOIN (VALUES ('NORMAL'),('VIP'),('COUPLE')) AS t(seat_type)
WHERE NOT EXISTS (
    SELECT 1 FROM seat_type_surcharges s
    WHERE s.branch_id = b.branch_id AND s.seat_type = t.seat_type
);
GO