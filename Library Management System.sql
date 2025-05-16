-- Library Management System Database
-- Created by [NZAU]

CREATE DATABASE library_management;
USE library_management;

-- Library Branch Table
CREATE TABLE library_branch (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    opening_hours VARCHAR(100),
    UNIQUE (branch_name, address)
);

-- Publisher Table
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Book Table
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT NOT NULL,
    publication_year INT,
    edition INT,
    category VARCHAR(50),
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

-- Book Authors (M-M relationship between Book and Author)
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
);

-- Book Copies (M-M relationship between Book and Library Branch)
CREATE TABLE book_copy (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    acquisition_date DATE NOT NULL,
    status ENUM('available', 'checked_out', 'lost', 'damaged') DEFAULT 'available',
    shelf_location VARCHAR(20),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id)
);

-- Borrower Table
CREATE TABLE borrower (
    borrower_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    registration_date DATE NOT NULL,
    membership_expiry DATE NOT NULL,
    status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    UNIQUE (first_name, last_name, phone)
);

-- Loan Table
CREATE TABLE loan (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    borrower_id INT NOT NULL,
    checkout_date DATETIME NOT NULL,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    late_fee DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('active', 'returned', 'overdue', 'lost') DEFAULT 'active',
    FOREIGN KEY (copy_id) REFERENCES book_copy(copy_id),
    FOREIGN KEY (borrower_id) REFERENCES borrower(borrower_id)
);

-- Reservation Table
CREATE TABLE reservation (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_id INT NOT NULL,
    branch_id INT NOT NULL,
    reservation_date DATETIME NOT NULL,
    expiry_date DATETIME NOT NULL,
    status ENUM('pending', 'fulfilled', 'cancelled', 'expired') DEFAULT 'pending',
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (borrower_id) REFERENCES borrower(borrower_id),
    FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id)
);

-- Staff Table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id)
);

-- Fine Table
CREATE TABLE fine (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT,
    borrower_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL,
    payment_date DATE,
    status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id),
    FOREIGN KEY (borrower_id) REFERENCES borrower(borrower_id)
);

-- Create indexes for performance
CREATE INDEX idx_book_title ON book(title);
CREATE INDEX idx_borrower_name ON borrower(last_name, first_name);
CREATE INDEX idx_loan_dates ON loan(checkout_date, due_date, return_date);
CREATE INDEX idx_copy_status ON book_copy(status);