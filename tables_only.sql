-- Simple Table Definitions Only
-- No relationships, foreign keys, or constraints

-- User table
CREATE TABLE User (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255),
    Email VARCHAR(255),
    Password VARCHAR(255),
    Type VARCHAR(20),
    Address TEXT,
    County VARCHAR(100),
    State VARCHAR(100),
    City VARCHAR(100)
);

-- Product table
CREATE TABLE Product (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    SKU VARCHAR(100),
    Description TEXT,
    Title VARCHAR(255)
);

-- QRcodes table
CREATE TABLE QRcodes (
    key_value VARCHAR(255),
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    t2 TIMESTAMP NULL,
    t1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Logger table
CREATE TABLE Logger (
    lat DECIMAL(10, 8),
    ID INT PRIMARY KEY AUTO_INCREMENT,
    lng DECIMAL(11, 8),
    UserID INT,
    DeviceID VARCHAR(255),
    ProductID INT,
    current_qrID INT,
    max_qrID INT,
    IPAddress VARCHAR(45),
    DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    min_qrID INT
);

-- Routes table
CREATE TABLE Routes (
    VehicleID INT,
    ID INT PRIMARY KEY AUTO_INCREMENT,
    StartDateTime DATETIME,
    DriverID INT,
    EndDateTime DATETIME,
    StartPoint VARCHAR(255),
    EndPoint VARCHAR(255)
);

-- Vehicle table
CREATE TABLE Vehicle (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Address TEXT,
    Number VARCHAR(50),
    Registration VARCHAR(50),
    County VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100)
);

-- ProductRoutes junction table
CREATE TABLE ProductRoutes (
    ProductID INT,
    RouteID INT
);