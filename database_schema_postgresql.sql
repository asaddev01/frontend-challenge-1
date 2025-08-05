-- PostgreSQL Database Schema Generated from ERD
-- Created: $(date)

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS ProductRoutes CASCADE;
DROP TABLE IF EXISTS Logger CASCADE;
DROP TABLE IF EXISTS QRcodes CASCADE;
DROP TABLE IF EXISTS Routes CASCADE;
DROP TABLE IF EXISTS Vehicle CASCADE;
DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

-- Create User table (User is a reserved word in PostgreSQL, so we use quotes)
CREATE TABLE "User" (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Type VARCHAR(20) CHECK (Type IN ('admin', 'driver', 'customer', 'manager')) NOT NULL DEFAULT 'customer',
    Address TEXT,
    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for User table
CREATE INDEX idx_user_email ON "User" (Email);
CREATE INDEX idx_user_type ON "User" (Type);
CREATE INDEX idx_user_location ON "User" (City, State);

-- Create Product table
CREATE TABLE Product (
    ID SERIAL PRIMARY KEY,
    SKU VARCHAR(100) UNIQUE NOT NULL,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for Product table
CREATE INDEX idx_product_sku ON Product (SKU);
CREATE INDEX idx_product_title ON Product (Title);

-- Create Vehicle table
CREATE TABLE Vehicle (
    ID SERIAL PRIMARY KEY,
    Number VARCHAR(50) UNIQUE NOT NULL,
    Registration VARCHAR(50) UNIQUE NOT NULL,
    Address TEXT,
    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for Vehicle table
CREATE INDEX idx_vehicle_number ON Vehicle (Number);
CREATE INDEX idx_vehicle_registration ON Vehicle (Registration);
CREATE INDEX idx_vehicle_location ON Vehicle (City, State);

-- Create Routes table
CREATE TABLE Routes (
    ID SERIAL PRIMARY KEY,
    VehicleID INTEGER NOT NULL,
    DriverID INTEGER NOT NULL,
    StartDateTime TIMESTAMP NOT NULL,
    EndDateTime TIMESTAMP,
    StartPoint VARCHAR(255),
    EndPoint VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(ID) ON DELETE CASCADE,
    FOREIGN KEY (DriverID) REFERENCES "User"(ID) ON DELETE CASCADE
);

-- Create indexes for Routes table
CREATE INDEX idx_routes_vehicle ON Routes (VehicleID);
CREATE INDEX idx_routes_driver ON Routes (DriverID);
CREATE INDEX idx_routes_datetime ON Routes (StartDateTime, EndDateTime);
CREATE INDEX idx_routes_points ON Routes (StartPoint, EndPoint);

-- Create QRcodes table
CREATE TABLE QRcodes (
    ID SERIAL PRIMARY KEY,
    ProductID INTEGER NOT NULL,
    key_value VARCHAR(255) UNIQUE NOT NULL,
    t1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    t2 TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE CASCADE
);

-- Create indexes for QRcodes table
CREATE INDEX idx_qrcodes_product ON QRcodes (ProductID);
CREATE INDEX idx_qrcodes_key ON QRcodes (key_value);
CREATE INDEX idx_qrcodes_timestamps ON QRcodes (t1, t2);

-- Create Logger table
CREATE TABLE Logger (
    ID SERIAL PRIMARY KEY,
    UserID INTEGER,
    ProductID INTEGER,
    DeviceID VARCHAR(255),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    current_qrID INTEGER,
    max_qrID INTEGER,
    min_qrID INTEGER,
    IPAddress INET,
    DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES "User"(ID) ON DELETE SET NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE SET NULL,
    FOREIGN KEY (current_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL,
    FOREIGN KEY (max_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL,
    FOREIGN KEY (min_qrID) REFERENCES QRcodes(ID) ON DELETE SET NULL
);

-- Create indexes for Logger table
CREATE INDEX idx_logger_user ON Logger (UserID);
CREATE INDEX idx_logger_product ON Logger (ProductID);
CREATE INDEX idx_logger_device ON Logger (DeviceID);
CREATE INDEX idx_logger_location ON Logger (lat, lng);
CREATE INDEX idx_logger_datetime ON Logger (DateTime);
CREATE INDEX idx_logger_qr_current ON Logger (current_qrID);
CREATE INDEX idx_logger_qr_range ON Logger (min_qrID, max_qrID);

-- Create ProductRoutes junction table for many-to-many relationship
CREATE TABLE ProductRoutes (
    ID SERIAL PRIMARY KEY,
    ProductID INTEGER NOT NULL,
    RouteID INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Routes(ID) ON DELETE CASCADE,
    UNIQUE (ProductID, RouteID)
);

-- Create indexes for ProductRoutes table
CREATE INDEX idx_productroutes_product ON ProductRoutes (ProductID);
CREATE INDEX idx_productroutes_route ON ProductRoutes (RouteID);

-- Create views for common queries
CREATE VIEW UserDetails AS
SELECT 
    u.ID,
    u.Name,
    u.Email,
    u.Type,
    CONCAT(u.Address, ', ', u.City, ', ', u.County, ', ', u.State) AS FullAddress,
    u.created_at
FROM "User" u;

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
JOIN "User" u ON r.DriverID = u.ID;

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
LEFT JOIN "User" u ON l.UserID = u.ID
LEFT JOIN Product p ON l.ProductID = p.ID
LEFT JOIN QRcodes qr ON l.current_qrID = qr.ID;

-- Insert sample data for testing
INSERT INTO "User" (Name, Email, Password, Type, Address, City, County, State) VALUES
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

-- Create stored procedures/functions for common operations
CREATE OR REPLACE FUNCTION GetUserActivity(user_id INTEGER)
RETURNS TABLE (
    DateTime TIMESTAMP,
    Product VARCHAR(255),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    IPAddress INET,
    QRCode VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
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
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetRouteProducts(route_id INTEGER)
RETURNS TABLE (
    ID INTEGER,
    SKU VARCHAR(100),
    Title VARCHAR(255),
    Description TEXT,
    QRCodeCount BIGINT
) AS $$
BEGIN
    RETURN QUERY
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
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateNewRoute(
    vehicle_id INTEGER,
    driver_id INTEGER,
    start_datetime TIMESTAMP,
    start_point VARCHAR(255),
    end_point VARCHAR(255)
)
RETURNS INTEGER AS $$
DECLARE
    new_route_id INTEGER;
BEGIN
    INSERT INTO Routes (VehicleID, DriverID, StartDateTime, StartPoint, EndPoint)
    VALUES (vehicle_id, driver_id, start_datetime, start_point, end_point)
    RETURNING ID INTO new_route_id;
    
    RETURN new_route_id;
END;
$$ LANGUAGE plpgsql;

-- Create audit log table and triggers
CREATE TABLE AuditLog (
    ID SERIAL PRIMARY KEY,
    TableName VARCHAR(50),
    Operation VARCHAR(10),
    RecordID INTEGER,
    OldValues JSONB,
    NewValues JSONB,
    UserID INTEGER,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to create audit log entries
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO AuditLog (TableName, Operation, RecordID, NewValues)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.ID, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.ID, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO AuditLog (TableName, Operation, RecordID, OldValues)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.ID, to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for audit logging
CREATE TRIGGER Product_Audit_Trigger
    AFTER INSERT OR UPDATE OR DELETE ON Product
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER Routes_Audit_Trigger
    AFTER INSERT OR UPDATE OR DELETE ON Routes
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER User_Audit_Trigger
    AFTER INSERT OR UPDATE OR DELETE ON "User"
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_user_updated_at BEFORE UPDATE ON "User" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_updated_at BEFORE UPDATE ON Product FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vehicle_updated_at BEFORE UPDATE ON Vehicle FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_routes_updated_at BEFORE UPDATE ON Routes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_qrcodes_updated_at BEFORE UPDATE ON QRcodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_logger_updated_at BEFORE UPDATE ON Logger FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Performance optimization indexes
CREATE INDEX idx_logger_composite ON Logger (UserID, ProductID, DateTime);
CREATE INDEX idx_routes_active ON Routes (VehicleID, DriverID) WHERE EndDateTime IS NULL;
CREATE INDEX idx_qrcodes_product_key ON QRcodes (ProductID, key_value);

-- Add table comments for documentation
COMMENT ON TABLE "User" IS 'Stores user information including admins, drivers, and customers';
COMMENT ON TABLE Product IS 'Product catalog with SKU and descriptions';
COMMENT ON TABLE Vehicle IS 'Fleet vehicles used for deliveries';
COMMENT ON TABLE Routes IS 'Delivery routes assigned to vehicles and drivers';
COMMENT ON TABLE QRcodes IS 'QR codes associated with products for tracking';
COMMENT ON TABLE Logger IS 'Activity logs for user interactions and location tracking';
COMMENT ON TABLE ProductRoutes IS 'Junction table linking products to delivery routes';
COMMENT ON TABLE AuditLog IS 'Audit trail for tracking changes to critical tables';

-- Add column comments for better documentation
COMMENT ON COLUMN "User".Type IS 'User role: admin, driver, customer, or manager';
COMMENT ON COLUMN Logger.lat IS 'Latitude coordinate for location tracking';
COMMENT ON COLUMN Logger.lng IS 'Longitude coordinate for location tracking';
COMMENT ON COLUMN Logger.IPAddress IS 'IP address of the device/user';
COMMENT ON COLUMN QRcodes.t1 IS 'Timestamp when QR code was created';
COMMENT ON COLUMN QRcodes.t2 IS 'Timestamp when QR code was last scanned';
COMMENT ON COLUMN Routes.StartDateTime IS 'When the route started';
COMMENT ON COLUMN Routes.EndDateTime IS 'When the route ended (NULL for active routes)';

-- Create materialized view for performance-critical queries
CREATE MATERIALIZED VIEW ProductLocationSummary AS
SELECT 
    p.ID as ProductID,
    p.SKU,
    p.Title,
    COUNT(DISTINCT l.UserID) as UniqueUsers,
    COUNT(l.ID) as TotalLogs,
    AVG(l.lat) as AvgLatitude,
    AVG(l.lng) as AvgLongitude,
    MAX(l.DateTime) as LastActivity
FROM Product p
LEFT JOIN Logger l ON p.ID = l.ProductID
GROUP BY p.ID, p.SKU, p.Title;

-- Create index on materialized view
CREATE INDEX idx_product_location_summary_product ON ProductLocationSummary (ProductID);
CREATE INDEX idx_product_location_summary_activity ON ProductLocationSummary (LastActivity);

-- Refresh the materialized view (should be done periodically)
-- REFRESH MATERIALIZED VIEW ProductLocationSummary;