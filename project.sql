-- Library Management System Database.

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Table for book categories/genres
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for publishers
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY author_name_unique (first_name, last_name)
);

-- Table for books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    category_id INT,
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(20),
    pages INT,
    language VARCHAR(30) DEFAULT 'English',
    summary TEXT,
    shelf_location VARCHAR(50),
    cover_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    INDEX idx_book_title (title)
);

-- Many-to-Many relationship between books and authors
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    is_primary_author BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Table for physical book copies/inventory
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(30) UNIQUE,
    acquisition_date DATE,
    price DECIMAL(10,2),
    status ENUM('Available', 'Borrowed', 'Reserved', 'Lost', 'Damaged', 'Under Repair') DEFAULT 'Available',
    condition ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'Good',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Table for library members/patrons
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_expiry DATE,
    membership_status ENUM('Active', 'Expired', 'Suspended', 'Cancelled') DEFAULT 'Active',
    membership_type ENUM('Standard', 'Premium', 'Student', 'Senior', 'Staff') DEFAULT 'Standard',
    photo_url VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_member_name (last_name, first_name)
);

-- Table for library staff
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('Librarian', 'Assistant Librarian', 'Admin', 'IT Support', 'Clerk') NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for membership fees
CREATE TABLE membership_fees (
    fee_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online Payment') NOT NULL,
    reference_number VARCHAR(50),
    receipt_number VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Table for book borrowing transactions
CREATE TABLE book_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id_checkout INT NOT NULL,
    staff_id_return INT,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    renewal_count TINYINT DEFAULT 0,
    status ENUM('Borrowed', 'Returned', 'Overdue', 'Lost', 'Damaged') DEFAULT 'Borrowed',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id_checkout) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id_return) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    INDEX idx_loan_dates (borrow_date, due_date, return_date)
);

-- Table for fines
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason ENUM('Late Return', 'Damaged Book', 'Lost Book') NOT NULL,
    issue_date DATE NOT NULL,
    payment_date DATE,
    payment_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online Payment'),
    staff_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES book_loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Table for book reservations
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Table for events (like book clubs, reading sessions, etc.)
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    location VARCHAR(100),
    max_attendees INT,
    event_type ENUM('Book Club', 'Reading Session', 'Author Visit', 'Workshop', 'Other') NOT NULL,
    host_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Many-to-Many relationship between events and members
CREATE TABLE event_attendees (
    event_id INT,
    member_id INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No-Show', 'Cancelled') DEFAULT 'Registered',
    notes TEXT,
    PRIMARY KEY (event_id, member_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Insert Categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Literary works created from the imagination'),
('Science Fiction', 'Fiction dealing with imagined scientific advancements in the future'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Romance', 'Fiction that focuses on romantic relationships'),
('Biography', 'Non-fiction account of a person''s life'),
('History', 'Non-fiction about past events'),
('Self-Help', 'Books that provide advice for personal improvement'),
('Science', 'Non-fiction works about scientific topics'),
('Technology', 'Books about technological subjects and innovations'),
('Children', 'Books intended for children');

-- Insert Publishers
INSERT INTO publishers (publisher_name, address, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com'),
('Oxford University Press', 'Great Clarendon Street, Oxford OX2 6DP, UK', '+44-1865-353456', 'info@oup.com', 'www.oup.com');

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_date, biography) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British author best known for the Harry Potter series'),
('Stephen', 'King', '1947-09-21', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('Agatha', 'Christie', '1890-09-15', 'English writer known for her 66 detective novels'),
('Jane', 'Austen', '1775-12-16', 'English novelist known for her six major novels'),
('George', 'Orwell', '1903-06-25', 'English novelist, essayist, journalist, and critic'),
('J.R.R.', 'Tolkien', '1892-01-03', 'English writer, poet, philologist, and academic'),
('Ernest', 'Hemingway', '1899-07-21', 'American novelist, short-story writer, and journalist'),
('Virginia', 'Woolf', '1882-01-25', 'English writer, considered one of the most important modernist 20th-century authors'),
('Mark', 'Twain', '1835-11-30', 'American writer, humorist, entrepreneur, publisher, and lecturer'),
('Leo', 'Tolstoy', '1828-09-09', 'Russian writer who is regarded as one of the greatest authors of all time');

-- Insert Books
INSERT INTO books (isbn, title, category_id, publisher_id, publication_date, edition, pages, language, summary, shelf_location) VALUES
('9780747532743', 'Harry Potter and the Philosopher''s Stone', 1, 1, '1997-06-26', '1st', 223, 'English', 'The first novel in the Harry Potter series.', 'A1-01'),
('9780060935467', 'To Kill a Mockingbird', 1, 2, '1960-07-11', 'Reprint', 336, 'English', 'A novel about racial inequality in the American South.', 'A1-02'),
('9780141187761', '1984', 2, 1, '1949-06-08', 'Reprint', 328, 'English', 'A dystopian novel set in a totalitarian regime.', 'A1-03'),
('9780061120084', 'The Handmaid''s Tale', 2, 2, '1985-06-01', 'Reprint', 311, 'English', 'A dystopian novel set in a near-future New England.', 'A1-04'),
('9780743273565', 'The Great Gatsby', 1, 3, '1925-04-10', 'Reprint', 180, 'English', 'A novel about the American Dream set in the Jazz Age.', 'A1-05'),
('9780316769174', 'The Catcher in the Rye', 1, 4, '1951-07-16', 'Reprint', 277, 'English', 'A novel about teenage angst and alienation.', 'A1-06'),
('9780307474278', 'The Da Vinci Code', 3, 1, '2003-03-18', 'Reprint', 454, 'English', 'A mystery thriller novel.', 'A2-01'),
('9780062315007', 'Gone Girl', 3, 2, '2012-06-05', '1st', 432, 'English', 'A psychological thriller novel.', 'A2-02'),
('9780141439518', 'Pride and Prejudice', 4, 1, '1813-01-28', 'Reprint', 480, 'English', 'A romantic novel of manners.', 'A2-03'),
('9780743477574', 'Romeo and Juliet', 4, 3, '1597-01-01', 'Reprint', 336, 'English', 'A tragedy about two young lovers.', 'A2-04');

-- Connect Books with Authors (Many-to-Many)
INSERT INTO book_authors (book_id, author_id, is_primary_author) VALUES
(1, 1, TRUE),  -- J.K. Rowling for Harry Potter
(2, 4, TRUE),  -- Jane Austen for To Kill a Mockingbird
(3, 5, TRUE),  -- George Orwell for 1984
(4, 3, TRUE),  -- Agatha Christie for The Handmaid's Tale
(5, 7, TRUE),  -- Ernest Hemingway for The Great Gatsby
(6, 8, TRUE),  -- Virginia Woolf for The Catcher in the Rye
(7, 2, TRUE),  -- Stephen King for The Da Vinci Code
(8, 2, TRUE),  -- Stephen King for Gone Girl
(9, 4, TRUE),  -- Jane Austen for Pride and Prejudice
(10, 10, TRUE); -- Leo Tolstoy for Romeo and Juliet

-- Insert Book Copies (Inventory)
INSERT INTO book_copies (book_id, barcode, acquisition_date, price, status, condition) VALUES
(1, 'BC-001-001', '2020-01-15', 15.99, 'Available', 'Good'),
(1, 'BC-001-002', '2020-01-15', 15.99, 'Available', 'Good'),
(1, 'BC-001-003', '2020-01-15', 15.99, 'Borrowed', 'Good'),
(2, 'BC-002-001', '2020-02-10', 12.50, 'Available', 'Good'),
(2, 'BC-002-002', '2020-02-10', 12.50, 'Borrowed', 'Good'),
(3, 'BC-003-001', '2020-03-05', 14.25, 'Available', 'Fair'),
(4, 'BC-004-001', '2020-04-20', 16.75, 'Borrowed', 'Good'),
(5, 'BC-005-001', '2020-05-12', 11.99, 'Available', 'Good'),
(6, 'BC-006-001', '2020-06-08', 13.50, 'Available', 'Good'),
(7, 'BC-007-001', '2020-07-14', 18.25, 'Borrowed', 'Good'),
(8, 'BC-008-001', '2020-08-22', 17.99, 'Available', 'New'),
(9, 'BC-009-001', '2020-09-30', 10.50, 'Available', 'Good'),
(10, 'BC-010-001', '2020-10-05', 9.99, 'Available', 'Fair');

-- Insert Members
INSERT INTO members (first_name, last_name, date_of_birth, email, phone, address, membership_date, membership_expiry, membership_status, membership_type) VALUES
('John', 'Smith', '1985-05-15', 'john.smith@email.com', '123-456-7890', '123 Main St, Anytown, USA', '2020-01-10', '2023-01-10', 'Active', 'Standard'),
('Emily', 'Johnson', '1990-08-22', 'emily.j@email.com', '234-567-8901', '456 Elm St, Anytown, USA', '2020-02-15', '2023-02-15', 'Active', 'Premium'),
('Michael', 'Williams', '1978-11-30', 'michael.w@email.com', '345-678-9012', '789 Oak St, Anytown, USA', '2020-03-20', '2023-03-20', 'Active', 'Standard'),
('Sarah', 'Brown', '1995-03-12', 'sarah.b@email.com', '456-789-0123', '101 Pine St, Anytown, USA', '2020-04-25', '2023-04-25', 'Active', 'Student'),
('David', 'Jones', '1982-07-08', 'david.j@email.com', '567-890-1234', '202 Maple St, Anytown, USA', '2020-05-30', '2023-05-30', 'Active', 'Standard'),
('Lisa', 'Davis', '1973-01-25', 'lisa.d@email.com', '678-901-2345', '303 Cedar St, Anytown, USA', '2020-06-05', '2023-06-05', 'Active', 'Senior'),
('James', 'Miller', '1998-09-17', 'james.m@email.com', '789-012-3456', '404 Birch St, Anytown, USA', '2020-07-10', '2022-07-10', 'Expired', 'Student'),
('Jennifer', 'Wilson', '1980-12-03', 'jennifer.w@email.com', '890-123-4567', '505 Walnut St, Anytown, USA', '2020-08-15', '2023-08-15', 'Active', 'Standard'),
('Robert', 'Moore', '1965-04-20', 'robert.m@email.com', '901-234-5678', '606 Spruce St, Anytown, USA', '2020-09-20', '2023-09-20', 'Active', 'Senior'),
('Patricia', 'Taylor', '1993-06-11', 'patricia.t@email.com', '012-345-6789', '707 Fir St, Anytown, USA', '2020-10-25', '2020-10-25', 'Suspended', 'Standard');

-- Insert Staff
INSERT INTO staff (first_name, last_name, email, phone, role, hire_date, salary, is_active) VALUES
('Margaret', 'Adams', 'margaret.a@library.com', '111-222-3333', 'Librarian', '2015-03-15', 55000.00, TRUE),
('Thomas', 'Baker', 'thomas.b@library.com', '222-333-4444', 'Assistant Librarian', '2017-06-20', 45000.00, TRUE),
('Elizabeth', 'Clark', 'elizabeth.c@library.com', '333-444-5555', 'Admin', '2016-09-10', 50000.00, TRUE),
('William', 'Davis', 'william.d@library.com', '444-555-6666', 'IT Support', '2018-12-05', 52000.00, TRUE),
('Katherine', 'Evans', 'katherine.e@library.com', '555-666-7777', 'Clerk', '2019-05-18', 38000.00, TRUE);

-- Insert Membership Fees
INSERT INTO membership_fees (member_id, amount, payment_date, payment_method, reference_number, receipt_number) VALUES
(1, 50.00, '2020-01-10', 'Credit Card', 'REF-001', 'RCPT-001'),
(2, 75.00, '2020-02-15', 'Credit Card', 'REF-002', 'RCPT-002'),
(3, 50.00, '2020-03-20', 'Cash', 'REF-003', 'RCPT-003'),
(4, 25.00, '2020-04-25', 'Debit Card', 'REF-004', 'RCPT-004'),
(5, 50.00, '2020-05-30', 'Online Payment', 'REF-005', 'RCPT-005'),
(6, 30.00, '2020-06-05', 'Cash', 'REF-006', 'RCPT-006'),
(7, 25.00, '2020-07-10', 'Credit Card', 'REF-007', 'RCPT-007'),
(8, 50.00, '2020-08-15', 'Debit Card', 'REF-008', 'RCPT-008'),
(9, 30.00, '2020-09-20', 'Cash', 'REF-009', 'RCPT-009'),
(10, 50.00, '2020-10-25', 'Online Payment', 'REF-010', 'RCPT-010');

-- Insert Book Loans
INSERT INTO book_loans (copy_id, member_id, staff_id_checkout, staff_id_return, borrow_date, due_date, return_date, status) VALUES
(3, 1, 1, NULL, '2022-04-01', '2022-04-15', NULL, 'Borrowed'),
(5, 2, 1, NULL, '2022-04-02', '2022-04-16', NULL, 'Borrowed'),
(7, 3, 2, NULL, '2022-04-03', '2022-04-17', NULL, 'Borrowed'),
(10, 4, 2, NULL, '2022-04-04', '2022-04-18', NULL, 'Borrowed'),
(1, 5, 1, 1, '2022-03-15', '2022-03-29', '2022-03-28', 'Returned'),
(2, 6, 2, 2, '2022-03-16', '2022-03-30', '2022-03-30', 'Returned'),
(4, 7, 2, 1, '2022-03-17', '2022-03-31', '2022-04-05', 'Returned'),
(6, 8, 1, 1, '2022-03-18', '2022-04-01', '2022-04-01', 'Returned'),
(8, 9, 2, 2, '2022-03-19', '2022-04-02', '2022-04-02', 'Returned'),
(9, 10, 1, NULL, '2022-03-20', '2022-04-03', NULL, 'Overdue');

-- Insert Fines
INSERT INTO fines (loan_id, member_id, amount, reason, issue_date, payment_date, payment_status, payment_method, staff_id) VALUES
(7, 7, 5.00, 'Late Return', '2022-04-05', '2022-04-10', 'Paid', 'Cash', 1),
(10, 10, 10.00, 'Late Return', '2022-04-04', NULL, 'Pending', NULL, 2),
(1, 1, 5.00, 'Damaged Book', '2022-04-15', '2022-04-20', 'Paid', 'Credit Card', 1);

-- Insert Reservations
INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status) VALUES
(1, 3, '2022-04-01 10:15:00', '2022-04-15', 'Pending'),
(2, 4, '2022-04-02 11:30:00', '2022-04-16', 'Pending'),
(3, 5, '2022-04-03 12:45:00', '2022-04-17', 'Cancelled'),
(4, 6, '2022-04-04 14:00:00', '2022-04-18', 'Fulfilled'),
(5, 7, '2022-04-05 15:15:00', '2022-04-19', 'Pending');

-- Insert Events
INSERT INTO events (title, description, start_datetime, end_datetime, location, max_attendees, event_type, host_staff_id) VALUES
('Summer Reading Club', 'Weekly book club for summer reading program', '2022-07-10 14:00:00', '2022-07-10 16:00:00', 'Main Reading Room', 20, 'Book Club', 1),
('Author Visit: Local Poets', 'Meet and greet with local poets', '2022-07-15 18:30:00', '2022-07-15 20:30:00', 'Conference Room A', 50, 'Author Visit', 2),
('Children''s Story Hour', 'Weekly storytelling session for children', '2022-07-05 10:00:00', '2022-07-05 11:00:00', 'Children''s Section', 15, 'Reading Session', 3),
('Digital Library Workshop', 'Learn how to use digital library resources', '2022-07-20 13:00:00', '2022-07-20 15:00:00', 'Computer Lab', 12, 'Workshop', 4),
('Book Launch: Mystery Series', 'Launch of new mystery book series', '2022-07-25 19:00:00', '2022-07-25 21:00:00', 'Main Hall', 100, 'Other', 1);

-- Insert Event Attendees
INSERT INTO event_attendees (event_id, member_id, attendance_status) VALUES
(1, 1, 'Registered'),
(1, 2, 'Registered'),
(1, 3, 'Registered'),
(2, 4, 'Registered'),
(2, 5, 'Registered'),
(2, 6, 'Registered'),
(3, 7, 'Registered'),
(3, 8, 'Registered'),
(4, 9, 'Registered'),
(4, 10, 'Registered'),
(5, 1, 'Registered'),
(5, 3, 'Registered'),
(5, 5, 'Registered'),
(5, 7, 'Registered'),
(5, 9, 'Registered');

-- CREATING VIEWS FOR COMMON QUERIES
-- View for available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    c.category_name,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name,
    p.publisher_name,
    COUNT(bc.copy_id) AS available_copies
FROM 
    books b
JOIN 
    categories c ON b.category_id = c.category_id
JOIN 
    book_authors ba ON b.book_id = ba.book_id
JOIN 
    authors a ON ba.author_id = a.author_id
JOIN 
    publishers p ON b.publisher_id = p.publisher_id
JOIN 
    book_copies bc ON b.book_id = bc.book_id
WHERE 
    bc.status = 'Available'
GROUP BY 
    b.book_id, b.title, b.isbn, c.category_name, author_name, p.publisher_name;

-- View for active loans
CREATE VIEW active_loans AS
SELECT 
    bl.loan_id,
    b.title,
    bc.barcode,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    bl.borrow_date,
    bl.due_date,
    DATEDIFF(CURDATE(), bl.due_date) AS days_overdue,
    bl.status
FROM 
    book_loans bl
JOIN 
    book_copies bc ON bl.copy_id = bc.copy_id
JOIN 
    books b ON bc.book_id = b.book_id
JOIN 
    members m ON bl.member_id = m.member_id
WHERE 
    bl.return_date IS NULL;

-- View for member borrowing history
CREATE VIEW member_borrowing_history AS
SELECT 
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title,
    bl.borrow_date,
    bl.due_date,
    bl.return_date,
    bl.status,
    CASE 
        WHEN bl.return_date IS NULL AND bl.due_date < CURDATE() THEN 'Overdue'
        WHEN bl.return_date IS NULL THEN 'Currently Borrowed'
        WHEN bl.return_date > bl.due_date THEN 'Returned Late'
        ELSE 'Returned On Time'
    END AS return_status
FROM 
    members m
JOIN 
    book_loans bl ON m.member_id = bl.member_id
JOIN 
    book_copies bc ON bl.copy_id = bc.copy_id
JOIN 
    books b ON bc.book_id = b.book_id
ORDER BY 
    m.member_id, bl.borrow_date DESC;

-- View for book checkout statistics
CREATE VIEW book_checkout_stats AS
SELECT 
    b.book_id,
    b.title,
    c.category_name,
    COUNT(bl.loan_id) AS total_checkouts
FROM 
    books b
LEFT JOIN 
    categories c ON b.category_id = c.category_id
LEFT JOIN 
    book_copies bc ON b.book_id = bc.book_id
LEFT JOIN 
    book_loans bl ON bc.copy_id = bl.copy_id
GROUP BY 
    b.book_id, b.title, c.category_name
ORDER BY 
    total_checkouts DESC;

-- View for overdue books
CREATE VIEW overdue_books AS
SELECT 
    bl.loan_id,
    b.title,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    m.phone,
    bl.borrow_date,
    bl.due_date,
    DATEDIFF(CURDATE(), bl.due_date) AS days_overdue,
    (DATEDIFF(CURDATE(), bl.due_date) * 0.50) AS estimated_fine
FROM 
    book_loans bl
JOIN 
    book_copies bc ON bl.copy_id = bc.copy_id
JOIN 
    books b ON bc.book_id = b.book_id
JOIN 
    members m ON bl.member_id = m.member_id
WHERE 
    bl.return_date IS NULL 
    AND bl.due_date < CURDATE()
ORDER BY 
    days_overdue DESC;

-- CREATING STORED PROCEDURES
-- Procedure to check out a book
DELIMITER //
CREATE PROCEDURE check_out_book(
    IN p_copy_id INT,
    IN p_member_id INT,
    IN p_staff_id INT,
    IN p_loan_days INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_membership_status VARCHAR(20);
    DECLARE v_book_count INT;
    
    -- Check if the book copy is available
    SELECT status INTO v_status FROM book_copies WHERE copy_id = p_copy_id;
    
    -- Check if the member is active
    SELECT membership_status INTO v_membership_status FROM members WHERE member_id = p_member_id;
    
    -- Count how many books the member currently has
    SELECT COUNT(*) INTO v_book_count 
    FROM book_loans 
    WHERE member_id = p_member_id AND return_date IS NULL;
    
    -- Validate and process checkout
    IF v_status = 'Available' THEN
        IF v_membership_status = 'Active' THEN
            IF v_book_count < 5 THEN
                -- Update book copy status
                UPDATE book_copies SET status = 'Borrowed' WHERE copy_id = p_copy_id;
                
                -- Create loan record
                INSERT INTO book_loans(
                    copy_id, 
                    member_id, 
                    staff_id_checkout, 
                    borrow_date, 
                    due_date, 
                    status
                )
                VALUES(
                    p_copy_id,
                    p_member_id,
                    p_staff_id,
                    CURDATE(),
                    DATE_ADD(CURDATE(), INTERVAL p_loan_days DAY),
                    'Borrowed'
                );
                
                SELECT 'Book checked out successfully.' AS message;
            ELSE
                SELECT 'Member has reached maximum number of books allowed.' AS message;
            END IF;
        ELSE
            SELECT 'Member is not active. Cannot check out books.' AS message;
        END IF;
    ELSE
        SELECT 'Book copy is not available for checkout.' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_loan_id INT,
    IN p_staff_id INT,
    IN p_book_condition VARCHAR(20)
)
BEGIN
    DECLARE v_copy_id INT;
    DECLARE v_member_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- Get loan details
    SELECT copy_id, member_id, due_date INTO v_copy_id, v_member_id, v_due_date
    FROM book_loans
    WHERE loan_id = p_loan_id;
    
    -- Calculate days overdue and potential fine
    SET v_days_overdue = DATEDIFF(CURDATE(), v_due_date);
    
    -- Process return
    IF v_days_overdue > 0 THEN
        -- Calculate fine amount ($0.50 per day)
        SET v_fine_amount = v_days_overdue * 0.50;
        
        -- Create fine record
        INSERT INTO fines(
            loan_id,
            member_id,
            amount,
            reason,
            issue_date,
            payment_status,
            staff_id
        )
        VALUES(
            p_loan_id,
            v_member_id,
            v_fine_amount,
            'Late Return',
            CURDATE(),
            'Pending',
            p_staff_id
        );
        
        -- Update loan status
        UPDATE book_loans
        SET 
            return_date = CURDATE(),
            staff_id_return = p_staff_id,
            status = 'Returned'
        WHERE loan_id = p_loan_id;
        
        SELECT CONCAT('Book returned with a late fee of , v_fine_amount) AS message;
    ELSE
        -- Update loan status
        UPDATE book_loans
        SET 
            return_date = CURDATE(),
            staff_id_return = p_staff_id,
            status = 'Returned'
        WHERE loan_id = p_loan_id;
        
        SELECT 'Book returned successfully with no late fees.' AS message;
    END IF;
    
    -- Update book condition and status
    IF p_book_condition = 'Damaged' THEN
        UPDATE book_copies
        SET status = 'Under Repair', condition = 'Poor'
        WHERE copy_id = v_copy_id;
        
        -- Create damaged book fine
        INSERT INTO fines(
            loan_id,
            member_id,
            amount,
            reason,
            issue_date,
            payment_status,
            staff_id
        )
        VALUES(
            p_loan_id,
            v_member_id,
            20.00, -- Standard damage fee
            'Damaged Book',
            CURDATE(),
            'Pending',
            p_staff_id
        );
        
        SELECT 'Book reported as damaged. Additional fee applied.' AS message;
    ELSE
        UPDATE book_copies
        SET status = 'Available'
        WHERE copy_id = v_copy_id;
    END IF;
END //
DELIMITER ;

-- Procedure to renew a book
DELIMITER //
CREATE PROCEDURE renew_book(
    IN p_loan_id INT,
    IN p_extension_days INT
)
BEGIN
    DECLARE v_return_date DATE;
    DECLARE v_status VARCHAR(20);
    DECLARE v_renewal_count INT;
    DECLARE v_new_due_date DATE;
    
    -- Get current loan details
    SELECT return_date, status, renewal_count, due_date 
    INTO v_return_date, v_status, v_renewal_count, v_new_due_date
    FROM book_loans
    WHERE loan_id = p_loan_id;
    
    -- Check if the book can be renewed
    IF v_return_date IS NULL THEN
        IF v_status = 'Borrowed' THEN
            IF v_renewal_count < 2 THEN
                -- Set new due date
                SET v_new_due_date = DATE_ADD(v_new_due_date, INTERVAL p_extension_days DAY);
                
                -- Update loan record
                UPDATE book_loans
                SET 
                    due_date = v_new_due_date,
                    renewal_count = v_renewal_count + 1
                WHERE loan_id = p_loan_id;
                
                SELECT CONCAT('Book renewed successfully. New due date: ', v_new_due_date) AS message;
            ELSE
                SELECT 'Maximum renewals reached for this loan.' AS message;
            END IF;
        ELSE
            SELECT 'Book cannot be renewed due to its current status.' AS message;
        END IF;
    ELSE
        SELECT 'Book has already been returned and cannot be renewed.' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to generate overdue notices
DELIMITER //
CREATE PROCEDURE generate_overdue_notices()
BEGIN
    SELECT 
        m.member_id,
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        m.email,
        m.phone,
        b.title AS book_title,
        bl.borrow_date,
        bl.due_date,
        DATEDIFF(CURDATE(), bl.due_date) AS days_overdue,
        (DATEDIFF(CURDATE(), bl.due_date) * 0.50) AS estimated_fine
    FROM 
        book_loans bl
    JOIN 
        book_copies bc ON bl.copy_id = bc.copy_id
    JOIN 
        books b ON bc.book_id = b.book_id
    JOIN 
        members m ON bl.member_id = m.member_id
    WHERE 
        bl.return_date IS NULL 
        AND bl.due_date < CURDATE()
    ORDER BY 
        member_id, days_overdue DESC;
END //
DELIMITER ;

-- Procedure to search books
DELIMITER //
CREATE PROCEDURE search_books(
    IN p_search_term VARCHAR(255)
)
BEGIN
    SELECT 
        b.book_id,
        b.isbn,
        b.title,
        c.category_name,
        GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
        p.publisher_name,
        b.publication_date,
        b.shelf_location,
        COUNT(CASE WHEN bc.status = 'Available' THEN 1 ELSE NULL END) AS available_copies,
        COUNT(bc.copy_id) AS total_copies
    FROM 
        books b
    LEFT JOIN 
        categories c ON b.category_id = c.category_id
    LEFT JOIN 
        book_authors ba ON b.book_id = ba.book_id
    LEFT JOIN 
        authors a ON ba.author_id = a.author_id
    LEFT JOIN 
        publishers p ON b.publisher_id = p.publisher_id
    LEFT JOIN 
        book_copies bc ON b.book_id = bc.book_id
    WHERE 
        b.title LIKE CONCAT('%', p_search_term, '%')
        OR b.isbn LIKE CONCAT('%', p_search_term, '%')
        OR CONCAT(a.first_name, ' ', a.last_name) LIKE CONCAT('%', p_search_term, '%')
        OR c.category_name LIKE CONCAT('%', p_search_term, '%')
        OR p.publisher_name LIKE CONCAT('%', p_search_term, '%')
    GROUP BY 
        b.book_id, b.isbn, b.title, c.category_name, p.publisher_name, b.publication_date, b.shelf_location
    ORDER BY 
        b.title;
END //
DELIMITER ;

-- CREATING TRIGGERS
-- Trigger to update book copies status when a book is marked as lost
DELIMITER //
CREATE TRIGGER trg_mark_book_lost
AFTER UPDATE ON book_loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'Lost' AND OLD.status != 'Lost' THEN
        -- Update the book copy status
        UPDATE book_copies
        SET status = 'Lost'
        WHERE copy_id = NEW.copy_id;
        
        -- Create a fine for the lost book
        INSERT INTO fines(
            loan_id,
            member_id,
            amount,
            reason,
            issue_date,
            payment_status,
            staff_id
        )
        VALUES(
            NEW.loan_id,
            NEW.member_id,
            50.00, -- Standard fee for lost book
            'Lost Book',
            CURDATE(),
            'Pending',
            NEW.staff_id_checkout
        );
    END IF;
END //
DELIMITER ;

-- Trigger to check for overdue books
DELIMITER //
CREATE TRIGGER trg_check_overdue
BEFORE UPDATE ON book_loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        IF NEW.return_date > OLD.due_date THEN
            SET NEW.status = 'Overdue';
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger to update reservation status when a book becomes available
DELIMITER //
CREATE TRIGGER trg_update_reservation
AFTER UPDATE ON book_copies
FOR EACH ROW
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_reservation_id INT;
    
    IF NEW.status = 'Available' AND OLD.status != 'Available' THEN
        -- Get the book_id
        SELECT book_id INTO v_book_id FROM book_copies WHERE copy_id = NEW.copy_id;
        
        -- Find the oldest pending reservation for this book
        SELECT reservation_id INTO v_reservation_id 
        FROM reservations 
        WHERE book_id = v_book_id 
        AND status = 'Pending' 
        AND expiry_date >= CURDATE() 
        ORDER BY reservation_date
        LIMIT 1;
        
        -- Update the reservation status if found
        IF v_reservation_id IS NOT NULL THEN
            UPDATE reservations
            SET status = 'Fulfilled'
            WHERE reservation_id = v_reservation_id;
        END IF;
    END IF;
END //
DELIMITER ;