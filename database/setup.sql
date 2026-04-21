CREATE DATABASE IF NOT EXISTS hotel_booking_db;
USE hotel_booking_db;

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'customer') DEFAULT 'customer',
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ROOMS TABLE
CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    roomNumber VARCHAR(50) NOT NULL,
    type VARCHAR(100) NOT NULL,
    pricePerNight DECIMAL(10, 2) NOT NULL,
    amenities TEXT,
    image TEXT,
    isAvailable BOOLEAN DEFAULT TRUE,
    totalRooms INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    bookingId INT AUTO_INCREMENT PRIMARY KEY,
    userName VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    nic VARCHAR(50) NOT NULL,
    roomId INT NOT NULL,
    checkIn DATE NOT NULL,
    checkOut DATE NOT NULL,
    roomCount INT NOT NULL,
    persons INT NOT NULL,
    totalAmount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'waiting', 'paid', 'cancelled', 'completed') DEFAULT 'pending',
    assignedRoom VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (roomId) REFERENCES rooms(id) ON DELETE CASCADE,
    INDEX idx_room_dates (roomId, checkIn, checkOut),
    INDEX idx_phone (phone)
);

-- PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bookingId INT NOT NULL,
    method VARCHAR(100) NOT NULL,
    accountNumber VARCHAR(100) NOT NULL,
    accountTitle VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bookingId) REFERENCES bookings(bookingId) ON DELETE CASCADE
);

-- Sample Data (Optional)
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@hotel.com', 'admin123', 'admin'),
('Customer One', 'user@gmail.com', 'user123', 'customer');

INSERT INTO rooms (roomNumber, type, pricePerNight, amenities, image, totalRooms) VALUES 
('101', 'Deluxe Single', 5000, 'AC, WiFi, TV', 'assets/room1.jpg', 5),
('201', 'Executive Suite', 12000, 'AC, WiFi, Mini Bar, Sea View', 'assets/room2.jpg', 2);
