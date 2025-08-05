-- Simple Table Definitions Only - PostgreSQL
-- No relationships, foreign keys, or constraints

-- User table
CREATE TABLE "User" (
    ID SERIAL PRIMARY KEY,
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
    ID SERIAL PRIMARY KEY,
    SKU VARCHAR(100),
    Description TEXT,
    Title VARCHAR(255)
);

-- QRcodes table
CREATE TABLE QRcodes (
    key_value VARCHAR(255),
    ID SERIAL PRIMARY KEY,
    ProductID INTEGER,
    t2 TIMESTAMP NULL,
    t1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Logger table
CREATE TABLE Logger (
    lat DECIMAL(10, 8),
    ID SERIAL PRIMARY KEY,
    lng DECIMAL(11, 8),
    UserID INTEGER,
    DeviceID VARCHAR(255),
    ProductID INTEGER,
    current_qrID INTEGER,
    max_qrID INTEGER,
    IPAddress INET,
    DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    min_qrID INTEGER
);

-- Routes table
CREATE TABLE Routes (
    VehicleID INTEGER,
    ID SERIAL PRIMARY KEY,
    StartDateTime TIMESTAMP,
    DriverID INTEGER,
    EndDateTime TIMESTAMP,
    StartPoint VARCHAR(255),
    EndPoint VARCHAR(255)
);

-- Vehicle table
CREATE TABLE Vehicle (
    ID SERIAL PRIMARY KEY,
    Address TEXT,
    Number VARCHAR(50),
    Registration VARCHAR(50),
    County VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100)
);

-- ProductRoutes junction table
CREATE TABLE ProductRoutes (
    ProductID INTEGER,
    RouteID INTEGER
);