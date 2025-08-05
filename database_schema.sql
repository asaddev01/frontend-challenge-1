-- Database Schema Generated from ERD
-- Created: $(date)

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS ProductRoutes;
DROP TABLE IF EXISTS Logger;
DROP TABLE IF EXISTS QRcodes;
DROP TABLE IF EXISTS Routes;
DROP TABLE IF EXISTS Vehicle;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS User;

-- Create User table
CREATE TABLE User (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Type ENUM('admin', 'driver', 'customer', 'manager') NOT NULL DEFAULT 'customer',
    Address TEXT,
    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (Email),
    INDEX idx_user_type (Type),
    INDEX idx_user_location (City, State)
);

-- Create Product table
CREATE TABLE Product (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    SKU VARCHAR(100) UNIQUE NOT NULL,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_sku (SKU),
    INDEX idx_product_title (Title)
);

-- Create Vehicle table
CREATE TABLE Vehicle (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Number VARCHAR(50) UNIQUE NOT NULL,
    Registration VARCHAR(50) UNIQUE NOT NULL,
    Address TEXT,
    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_vehicle_number (Number),
    INDEX idx_vehicle_registration (Registration),
    INDEX idx_vehicle_location (City, State)
);

-- Create Routes table
CREATE TABLE Routes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    VehicleID INT NOT NULL,
    DriverID INT NOT NULL,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME,
    StartPoint VARCHAR(255),
    EndPoint VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(ID) ON DELETE CASCADE,
    FOREIGN KEY (DriverID) REFERENCES User(ID) ON DELETE CASCADE,
    INDEX idx_routes_vehicle (VehicleID),
    INDEX idx_routes_driver (DriverID),
    INDEX idx_routes_datetime (StartDateTime, EndDateTime),
    INDEX idx_routes_points (StartPoint, EndPoint)
);

-- Create QRcodes table
CREATE TABLE QRcodes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    key_value VARCHAR(255) UNIQUE NOT NULL,
    t1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    t2 TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE CASCADE,
    INDEX idx_qrcodes_product (ProductID),
    INDEX idx_qrcodes_key (key_value),
    INDEX idx_qrcodes_timestamps (t1, t2)
);

-- Create Logger table
CREATE TABLE Logger (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    ProductID INT,
    DeviceID VARCHAR(255),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    current_qrID INT,
    max_qrID INT,
    min_qrID INT,
    IPAddress VARCHAR(45),
    DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(ID) ON DELETE SET NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE SET NULL,
    FOREIGN KEY (current_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL,
    FOREIGN KEY (max_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL,
    FOREIGN KEY (min_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL,
    INDEX idx_logger_user (UserID),
    INDEX idx_logger_product (ProductID),
    INDEX idx_logger_device (DeviceID),
    INDEX idx_logger_location (lat, lng),
    INDEX idx_logger_datetime (DateTime),
    INDEX idx_logger_qr_current (current_qrID),
    INDEX idx_logger_qr_range (min_qrID, max_qrID)
);

-- Create ProductRoutes junction table for many-to-many relationship
CREATE TABLE ProductRoutes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    RouteID INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Routes(ID) ON DELETE CASCADE,
    UNIQUE KEY unique_product_route (ProductID, RouteID),
    INDEX idx_productroutes_product (ProductID),
    INDEX idx_productroutes_route (RouteID)
);

-- Create views for common queries
CREATE VIEW UserDetails AS
SELECT 
    u.ID,
    u.Name,
    u.Email,
    u.Type,
    CONCAT(u.Address, ', ', u.City, ', ', u.County, ', ', u.State) AS FullAddress,
    u.created_at
FROM User u;

CREATE VIEW ProductWithQRCount AS
SELECT 
    p.ID,
    p.SKU,
    p.Title,
    p.Description,
    COUNT(qr.ID) as QRCodeCount,
    p.created_at
FROM Product p
LEFT JOIN QRcodes qr ON p.ID = qr.ProductID
GROUP BY p.ID, p.SKU, p.Title, p.Description, p.created_at;

CREATE VIEW ActiveRoutes AS
SELECT 
    r.ID,
    r.VehicleID,
    v.Number as VehicleNumber,
    r.DriverID,
    u.Name as DriverName,
    r.StartDateTime,
    r.EndDateTime,
    r.StartPoint,
    r.EndPoint,
    CASE 
        WHEN r.EndDateTime IS NULL THEN 'Active'
        ELSE 'Completed'
    END as Status
FROM Routes r
JOIN Vehicle v ON r.VehicleID = v.ID
JOIN User u ON r.DriverID = u.ID;

CREATE VIEW LoggerActivity AS
SELECT 
    l.ID,
    l.UserID,
    u.Name as UserName,
    l.ProductID,
    p.Title as ProductTitle,
    l.DeviceID,
    l.lat,
    l.lng,
    l.IPAddress,
    l.DateTime,
    qr.key_value as CurrentQRCode
FROM Logger l
LEFT JOIN User u ON l.UserID = u.ID
LEFT JOIN Product p ON l.ProductID = p.ID
LEFT JOIN QRcodes qr ON l.current_qrID = qr.ID;

-- Insert sample data for testing
INSERT INTO User (Name, Email, Password, Type, Address, City, County, State) VALUES
('John Doe', 'john.doe@example.com', 'hashed_password_1', 'admin', '123 Main St', 'New York', 'New York County', 'NY'),
('Jane Smith', 'jane.smith@example.com', 'hashed_password_2', 'driver', '456 Oak Ave', 'Los Angeles', 'Los Angeles County', 'CA'),
('Bob Johnson', 'bob.johnson@example.com', 'hashed_password_3', 'customer', '789 Pine Rd', 'Chicago', 'Cook County', 'IL');

INSERT INTO Product (SKU, Title, Description) VALUES
('PROD-001', 'Wireless Headphones', 'High-quality wireless Bluetooth headphones'),
('PROD-002', 'Smartphone Case', 'Protective case for smartphones'),
('PROD-003', 'USB Cable', 'USB-C charging cable');

INSERT INTO Vehicle (Number, Registration, Address, City, County, State) VALUES
('VEH-001', 'ABC123', '100 Fleet St', 'New York', 'New York County', 'NY'),
('VEH-002', 'XYZ789', '200 Transport Ave', 'Los Angeles', 'Los Angeles County', 'CA');

INSERT INTO Routes (VehicleID, DriverID, StartDateTime, StartPoint, EndPoint) VALUES
(1, 2, '2024-01-15 08:00:00', 'Warehouse A', 'Customer Location 1'),
(2, 2, '2024-01-15 10:00:00', 'Warehouse B', 'Customer Location 2');

INSERT INTO QRcodes (ProductID, key_value) VALUES
(1, 'QR-PROD001-001'),
(1, 'QR-PROD001-002'),
(2, 'QR-PROD002-001'),
(3, 'QR-PROD003-001');

INSERT INTO ProductRoutes (ProductID, RouteID) VALUES
(1, 1),
(2, 1),
(3, 2);

INSERT INTO Logger (UserID, ProductID, DeviceID, lat, lng, current_qrID, IPAddress) VALUES
(1, 1, 'DEVICE-001', 40.7128, -74.0060, 1, '192.168.1.100'),
(2, 2, 'DEVICE-002', 34.0522, -118.2437, 3, '192.168.1.101');

-- Create stored procedures for common operations
DELIMITER //

CREATE PROCEDURE GetUserActivity(IN user_id INT)
BEGIN
    SELECT 
        l.DateTime,
        p.Title as Product,
        l.lat,
        l.lng,
        l.IPAddress,
        qr.key_value as QRCode
    FROM Logger l
    LEFT JOIN Product p ON l.ProductID = p.ID
    LEFT JOIN QRcodes qr ON l.current_qrID = qr.ID
    WHERE l.UserID = user_id
    ORDER BY l.DateTime DESC;
END //

CREATE PROCEDURE GetRouteProducts(IN route_id INT)
BEGIN
    SELECT 
        p.ID,
        p.SKU,
        p.Title,
        p.Description,
        COUNT(qr.ID) as QRCodeCount
    FROM Product p
    JOIN ProductRoutes pr ON p.ID = pr.ProductID
    LEFT JOIN QRcodes qr ON p.ID = qr.ProductID
    WHERE pr.RouteID = route_id
    GROUP BY p.ID, p.SKU, p.Title, p.Description;
END //

CREATE PROCEDURE CreateNewRoute(
    IN vehicle_id INT,
    IN driver_id INT,
    IN start_datetime DATETIME,
    IN start_point VARCHAR(255),
    IN end_point VARCHAR(255)
)
BEGIN
    INSERT INTO Routes (VehicleID, DriverID, StartDateTime, StartPoint, EndPoint)
    VALUES (vehicle_id, driver_id, start_datetime, start_point, end_point);
    
    SELECT LAST_INSERT_ID() as RouteID;
END //

DELIMITER ;

-- Create triggers for audit logging
CREATE TABLE AuditLog (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    TableName VARCHAR(50),
    Operation VARCHAR(10),
    RecordID INT,
    OldValues JSON,
    NewValues JSON,
    UserID INT,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER Product_Audit_Insert
AFTER INSERT ON Product
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, RecordID, NewValues)
    VALUES ('Product', 'INSERT', NEW.ID, JSON_OBJECT('SKU', NEW.SKU, 'Title', NEW.Title, 'Description', NEW.Description));
END //

CREATE TRIGGER Product_Audit_Update
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
    VALUES ('Product', 'UPDATE', NEW.ID, 
            JSON_OBJECT('SKU', OLD.SKU, 'Title', OLD.Title, 'Description', OLD.Description),
            JSON_OBJECT('SKU', NEW.SKU, 'Title', NEW.Title, 'Description', NEW.Description));
END //

CREATE TRIGGER Routes_Audit_Update
AFTER UPDATE ON Routes
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
    VALUES ('Routes', 'UPDATE', NEW.ID,
            JSON_OBJECT('EndDateTime', OLD.EndDateTime),
            JSON_OBJECT('EndDateTime', NEW.EndDateTime));
END //

DELIMITER ;

-- Performance optimization indexes
CREATE INDEX idx_logger_composite ON Logger (UserID, ProductID, DateTime);
CREATE INDEX idx_routes_active ON Routes (VehicleID, DriverID) WHERE EndDateTime IS NULL;
CREATE INDEX idx_qrcodes_product_key ON QRcodes (ProductID, key_value);

-- Comments for documentation
ALTER TABLE User COMMENT = 'Stores user information including admins, drivers, and customers';
ALTER TABLE Product COMMENT = 'Product catalog with SKU and descriptions';
ALTER TABLE Vehicle COMMENT = 'Fleet vehicles used for deliveries';
ALTER TABLE Routes COMMENT = 'Delivery routes assigned to vehicles and drivers';
ALTER TABLE QRcodes COMMENT = 'QR codes associated with products for tracking';
ALTER TABLE Logger COMMENT = 'Activity logs for user interactions and location tracking';
ALTER TABLE ProductRoutes COMMENT = 'Junction table linking products to delivery routes';
ALTER TABLE AuditLog COMMENT = 'Audit trail for tracking changes to critical tables';