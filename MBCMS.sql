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
CONSTRAINT CK_booking_amounts 
CHECK (
    total_amount >= 0 AND 
    discount_amount >= 0 AND 
    final_amount >= 0 AND
    final_amount = total_amount - discount_amount
),
CONSTRAINT CK_payment_time 
CHECK (payment_time IS NULL OR payment_time >= booking_time)
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
    created_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_online_ticket_booking 
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),

    CONSTRAINT FK_online_ticket_showtime 
        FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id),

    CONSTRAINT FK_online_ticket_seat 
        FOREIGN KEY (seat_id) REFERENCES seats(seat_id),

    CONSTRAINT CK_online_ticket_type 
        CHECK (ticket_type IN ('ADULT','CHILD')),

    CONSTRAINT CK_online_seat_type 
        CHECK (seat_type IN ('NORMAL','VIP','COUPLE'))
);
GO

CREATE TABLE counter_tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    showtime_id INT NOT NULL,
    seat_id INT NOT NULL,
    ticket_type VARCHAR(10) NOT NULL,
    seat_type VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    sold_by INT NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    customer_name NVARCHAR(100),
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100),
    notes NVARCHAR(500),
    sold_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_counter_ticket_showtime 
        FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id),

    CONSTRAINT FK_counter_ticket_seat 
        FOREIGN KEY (seat_id) REFERENCES seats(seat_id),

    CONSTRAINT FK_counter_ticket_sold_by 
        FOREIGN KEY (sold_by) REFERENCES users(user_id),

    CONSTRAINT CK_counter_ticket_type 
        CHECK (ticket_type IN ('ADULT','CHILD')),

    CONSTRAINT CK_counter_seat_type 
        CHECK (seat_type IN ('NORMAL','VIP','COUPLE')),

    CONSTRAINT CK_counter_payment_method 
        CHECK (payment_method IN ('CASH','BANKING'))
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
    CONSTRAINT CK_invoice_payment_method CHECK (payment_method IN ('ZALOPA','BANKING','CASH')),
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

CREATE TABLE concessions (
    concession_id INT IDENTITY(1,1) PRIMARY KEY,
    concession_type VARCHAR(20) UNIQUE NOT NULL,
    quantity INT DEFAULT 0,
    price_base DECIMAL(3,1) NOT NULL ,
    added_by int,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT CK_concession_type CHECK (concession_type IN ('BEVERAGE','FOOD')),
    CONSTRAINT FK_concessions_users FOREIGN KEY (added_by) REFERENCES users(user_id)
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

-- Online tickets
CREATE INDEX idx_online_ticket_booking ON online_tickets(booking_id);
CREATE INDEX idx_online_ticket_showtime ON online_tickets(showtime_id);
CREATE INDEX idx_online_ticket_seat ON online_tickets(seat_id);
CREATE UNIQUE INDEX ux_online_ticket_showtime_seat 
    ON online_tickets(showtime_id, seat_id);

-- Counter tickets
CREATE INDEX idx_counter_ticket_showtime ON counter_tickets(showtime_id);
CREATE INDEX idx_counter_ticket_seat ON counter_tickets(seat_id);
CREATE INDEX idx_counter_ticket_sold_by ON counter_tickets(sold_by);
CREATE INDEX idx_counter_ticket_sold_at ON counter_tickets(sold_at);
CREATE UNIQUE INDEX ux_counter_ticket_showtime_seat 
    ON counter_tickets(showtime_id, seat_id);
GO

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
GO

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

CREATE TRIGGER trg_prevent_double_booking_online
ON online_tickets
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN counter_tickets ct
            ON i.showtime_id = ct.showtime_id
           AND i.seat_id = ct.seat_id
    )
    BEGIN
        RAISERROR(N'Seat already sold at counter', 16, 1);
        RETURN;
    END

    INSERT INTO online_tickets (
        booking_id, showtime_id, seat_id,
        ticket_type, seat_type, price
    )
    SELECT
        booking_id, showtime_id, seat_id,
        ticket_type, seat_type, price
    FROM inserted;
END;
GO


CREATE TRIGGER trg_prevent_double_booking_counter
ON counter_tickets
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN online_tickets ot
            ON i.showtime_id = ot.showtime_id
           AND i.seat_id = ot.seat_id
    )
    BEGIN
        RAISERROR(N'Seat already sold online', 16, 1);
        RETURN;
    END

    INSERT INTO counter_tickets (
        showtime_id, seat_id,
        ticket_type, seat_type,
        price, sold_by, payment_method,
        customer_name, customer_phone,
        customer_email, notes, sold_at
    )
    SELECT
        showtime_id, seat_id,
        ticket_type, seat_type,
        price, sold_by, payment_method,
        customer_name, customer_phone,
        customer_email, notes, SYSDATETIME()
    FROM inserted;
END;
GO



-- Updated 25/01/2026

INSERT INTO roles (role_name) VALUES ('GUEST');
INSERT INTO roles (role_name) VALUES ('CUSTOMER');
INSERT INTO roles (role_name) VALUES ('CINEMA_STAFF');
INSERT INTO roles (role_name) VALUES ('BRANCH_MANAGER');
INSERT INTO roles (role_name) VALUES ('ADMIN');
GO

-- Updated 04/02/2025
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






-- Updated 22/02/2026
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


-- Updated 01/03/2026
ALTER TABLE showtimes
    ADD cancellation_reason NVARCHAR(500) NULL,
        cancelled_at DATETIME2 NULL;

-- Updated 9/3/2026
ALTER TABLE ticket_prices
ADD branch_id int;

ALTER TABLE ticket_prices
ADD branch_id int;


ALTER TABLE ticket_prices
ADD CONSTRAINT FK_ticket_prices_branch
FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id);


-- Cập nhật lại index cho tối ưu
CREATE INDEX idx_ticket_prices_branch
ON ticket_prices (branch_id, is_active);


-- Xóa constraint check của cột seat_type
ALTER TABLE ticket_prices DROP CONSTRAINT CK_price_seat_type;


-- Xóa cột seat_type khỏi bảng ticket_prices
ALTER TABLE ticket_prices DROP COLUMN seat_type;

ALTER TABLE screening_rooms ALTER COLUMN room_name NVARCHAR(100) NOT NULL;

ALTER TABLE ticket_prices
ADD CONSTRAINT FK_ticket_prices_branch
FOREIGN KEY (branch_id) REFERENCES cinema_branches(branch_id);


-- Cập nhật lại index cho tối ưu
CREATE INDEX idx_ticket_prices_branch
ON ticket_prices (branch_id, is_active);


-- Xóa constraint check của cột seat_type
ALTER TABLE ticket_prices DROP CONSTRAINT CK_price_seat_type;


-- Xóa cột seat_type khỏi bảng ticket_prices
ALTER TABLE ticket_prices DROP COLUMN seat_type;

ALTER TABLE screening_rooms ALTER COLUMN room_name NVARCHAR(100) NOT NULL;


-- ==========================================
-- UPDATE 09/03/2026
-- ==========================================
-- 1. BẢNG CẤP BẬC THÀNH VIÊN (MEMBERSHIP TIERS)
CREATE TABLE membership_tiers (
    tier_id INT IDENTITY(1,1) PRIMARY KEY,
    tier_name NVARCHAR(50) NOT NULL UNIQUE,
    min_points_required INT NOT NULL DEFAULT 0,
    point_multiplier DECIMAL(3,2) DEFAULT 1.0, -- Hệ số nhân điểm (VD: VIP x1.2)
    created_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

INSERT INTO membership_tiers (tier_name, min_points_required, point_multiplier) VALUES
('MEMBER', 0, 1.0),
('BRONZE', 100, 1.1),
('SILVER', 200, 1.2),
('GOLD', 300, 1.3),
('DIAMOND', 500, 1.5);
GO

-- 2. CẬP NHẬT BẢNG USERS

ALTER TABLE users 
ADD total_accumulated_points INT DEFAULT 0,
    tier_id INT DEFAULT 1;
GO

ALTER TABLE users
ADD CONSTRAINT FK_users_tier FOREIGN KEY (tier_id) REFERENCES membership_tiers(tier_id);
GO

-- 3. BẢNG LỊCH SỬ ĐIỂM (POINT HISTORY)
CREATE TABLE point_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    points_changed INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, 
    description NVARCHAR(255),
    reference_id INT,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_point_history_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT CK_point_transaction_type CHECK (transaction_type IN ('EARN', 'REDEEM', 'REFUND', 'EXPIRE', 'ADJUSTMENT'))
);
GO

-- 4. BẢNG DANH MỤC QUÀ TẶNG & PROMO (REWARD VOUCHERS)
-- Lưu các Voucher do Admin tạo ra
CREATE TABLE vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_name NVARCHAR(100) NOT NULL,          
    voucher_type VARCHAR(20) DEFAULT 'LOYALTY',   
    voucher_code VARCHAR(50) NULL,                
    points_cost INT NOT NULL DEFAULT 0,           
    discount_amount DECIMAL(10,2) NOT NULL,
    max_usage_limit INT DEFAULT 0,                
    valid_days INT DEFAULT 30,                    
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT CK_voucher_type CHECK (voucher_type IN ('LOYALTY', 'PUBLIC'))
);
GO

-- 5. BẢNG VOUCHER CỦA KHÁCH HÀNG (USER VOUCHERS)
-- Lưu mã voucher cá nhân của từng khách
CREATE TABLE user_vouchers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    voucher_id INT NOT NULL,
    voucher_code VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(15) DEFAULT 'AVAILABLE', 
    redeemed_at DATETIME2 DEFAULT SYSDATETIME(),
    expires_at DATETIME2 NOT NULL,
    used_at DATETIME2,
    CONSTRAINT FK_uv_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT FK_uv_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id),
    CONSTRAINT CK_uv_status CHECK (status IN ('AVAILABLE', 'USED', 'EXPIRED'))
);
GO

-- 6. CẬP NHẬT BẢNG BOOKINGS
ALTER TABLE bookings
ADD applied_voucher_id INT NULL;
GO

ALTER TABLE bookings
ADD CONSTRAINT FK_booking_voucher FOREIGN KEY (applied_voucher_id) REFERENCES user_vouchers(id);
GO

-- 7. BẢNG CẤU HÌNH TÍCH ĐIỂM
CREATE TABLE loyalty_configs (
    config_id INT PRIMARY KEY CHECK (config_id = 1),
    earn_rate_amount DECIMAL(10,2) NOT NULL DEFAULT 10000,
    earn_points INT NOT NULL DEFAULT 1,          
    min_redeem_points INT NOT NULL DEFAULT 100,
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_by INT NULL,
    CONSTRAINT FK_loyalty_config_admin FOREIGN KEY (updated_by) REFERENCES users(user_id)
);
GO

INSERT INTO loyalty_configs (config_id, earn_rate_amount, earn_points, min_redeem_points) 
VALUES (1, 10000, 1, 100);
GO

-- 11/03/2026
ALTER TABLE [MBCMS].[dbo].[concessions]
<<<<<<< HEAD
ADD concession_name NVARCHAR(255);
=======
ADD concession_name NVARCHAR(255);

-- 14/03/2026
ALTER TABLE vouchers
Update current_usage INT DEFAULT 0;
>>>>>>> cad9b9da817621b1a64709567129f2934fdc5c8d
