# Database Schema Documentation

## Overview

This database schema is designed for a logistics and product tracking system that manages users, products, vehicles, routes, QR codes, and activity logging. The system supports role-based access control and comprehensive audit trails.

## Database Files

- `database_schema.sql` - MySQL/MariaDB compatible schema
- `database_schema_postgresql.sql` - PostgreSQL compatible schema

## Entity Relationship Diagram

The schema is based on the provided ERD diagram and includes the following main entities:

## Tables

### User Table
Stores information about system users including administrators, drivers, and customers.

**Columns:**
- `ID` (Primary Key) - Unique user identifier
- `Name` - Full name of the user
- `Email` - Unique email address (used for login)
- `Password` - Hashed password
- `Type` - User role (admin, driver, customer, manager)
- `Address`, `City`, `County`, `State` - Location information
- `created_at`, `updated_at` - Timestamp tracking

**Indexes:**
- Email (unique)
- Type (for role-based queries)
- Location (City, State composite)

### Product Table
Contains the product catalog with SKUs and descriptions.

**Columns:**
- `ID` (Primary Key) - Unique product identifier
- `SKU` - Stock Keeping Unit (unique)
- `Title` - Product name
- `Description` - Detailed product description
- `created_at`, `updated_at` - Timestamp tracking

**Indexes:**
- SKU (unique)
- Title (for search functionality)

### Vehicle Table
Manages the fleet of vehicles used for deliveries.

**Columns:**
- `ID` (Primary Key) - Unique vehicle identifier
- `Number` - Vehicle identification number (unique)
- `Registration` - License plate/registration (unique)
- `Address`, `City`, `County`, `State` - Vehicle base location
- `created_at`, `updated_at` - Timestamp tracking

**Indexes:**
- Number (unique)
- Registration (unique)
- Location (City, State composite)

### Routes Table
Tracks delivery routes assigned to vehicles and drivers.

**Columns:**
- `ID` (Primary Key) - Unique route identifier
- `VehicleID` (Foreign Key) - References Vehicle.ID
- `DriverID` (Foreign Key) - References User.ID
- `StartDateTime` - When the route began
- `EndDateTime` - When the route ended (NULL for active routes)
- `StartPoint`, `EndPoint` - Route waypoints
- `created_at`, `updated_at` - Timestamp tracking

**Foreign Keys:**
- VehicleID → Vehicle.ID (CASCADE DELETE)
- DriverID → User.ID (CASCADE DELETE)

**Indexes:**
- VehicleID, DriverID (for assignment queries)
- DateTime range (for time-based queries)
- Route points (for location queries)

### QRcodes Table
Manages QR codes associated with products for tracking purposes.

**Columns:**
- `ID` (Primary Key) - Unique QR code identifier
- `ProductID` (Foreign Key) - References Product.ID
- `key_value` - Unique QR code value/string
- `t1` - Creation timestamp
- `t2` - Last scan timestamp (nullable)
- `created_at`, `updated_at` - Timestamp tracking

**Foreign Keys:**
- ProductID → Product.ID (CASCADE DELETE)

**Indexes:**
- ProductID (for product-based queries)
- key_value (unique, for QR lookups)
- Timestamps (for temporal queries)

### Logger Table
Comprehensive activity logging for user interactions and location tracking.

**Columns:**
- `ID` (Primary Key) - Unique log entry identifier
- `UserID` (Foreign Key) - References User.ID (nullable)
- `ProductID` (Foreign Key) - References Product.ID (nullable)
- `DeviceID` - Device identifier string
- `lat`, `lng` - GPS coordinates (decimal degrees)
- `current_qrID`, `max_qrID`, `min_qrID` - QR code references
- `IPAddress` - Network address of the device
- `DateTime` - When the activity occurred
- `created_at`, `updated_at` - Timestamp tracking

**Foreign Keys:**
- UserID → User.ID (SET NULL on delete)
- ProductID → Product.ID (SET NULL on delete)
- current_qrID, max_qrID, min_qrID → QRcodes.ID (SET NULL on delete)

**Indexes:**
- UserID, ProductID (for entity-based queries)
- DeviceID (for device tracking)
- Location coordinates (for geo queries)
- DateTime (for temporal queries)
- QR code references (for tracking queries)

### ProductRoutes Table (Junction Table)
Links products to delivery routes in a many-to-many relationship.

**Columns:**
- `ID` (Primary Key) - Unique relationship identifier
- `ProductID` (Foreign Key) - References Product.ID
- `RouteID` (Foreign Key) - References Routes.ID
- `created_at` - Timestamp tracking

**Foreign Keys:**
- ProductID → Product.ID (CASCADE DELETE)
- RouteID → Routes.ID (CASCADE DELETE)

**Constraints:**
- Unique constraint on (ProductID, RouteID) to prevent duplicates

### AuditLog Table
Comprehensive audit trail for tracking changes to critical tables.

**Columns:**
- `ID` (Primary Key) - Unique audit entry identifier
- `TableName` - Name of the affected table
- `Operation` - Type of operation (INSERT, UPDATE, DELETE)
- `RecordID` - ID of the affected record
- `OldValues` - JSON/JSONB of previous values (for updates/deletes)
- `NewValues` - JSON/JSONB of new values (for inserts/updates)
- `UserID` - User who made the change (nullable)
- `Timestamp` - When the change occurred

## Views

### UserDetails
Provides a consolidated view of user information with formatted addresses.

### ProductWithQRCount
Shows products along with their associated QR code counts.

### ActiveRoutes
Displays route information with vehicle and driver details, including status.

### LoggerActivity
Comprehensive view of logging activity with user and product information.

### ProductLocationSummary (Materialized View - PostgreSQL only)
Performance-optimized view for product location analytics.

## Stored Procedures/Functions

### GetUserActivity(user_id)
Retrieves all activity logs for a specific user, including product interactions and location data.

### GetRouteProducts(route_id)
Returns all products associated with a specific route along with QR code counts.

### CreateNewRoute(vehicle_id, driver_id, start_datetime, start_point, end_point)
Creates a new delivery route and returns the generated route ID.

## Triggers

### Audit Triggers
Automatically log changes to critical tables (Product, Routes, User) for compliance and tracking.

### Updated Timestamp Triggers (PostgreSQL)
Automatically update the `updated_at` column when records are modified.

## Performance Optimizations

### Indexes
- Composite indexes for common query patterns
- Partial indexes for active routes (WHERE EndDateTime IS NULL)
- Location-based indexes for geographical queries
- Foreign key indexes for join performance

### Materialized Views (PostgreSQL)
- ProductLocationSummary for complex analytical queries
- Requires periodic refresh for up-to-date data

## Data Types

### MySQL vs PostgreSQL Differences
- **Auto-increment**: `AUTO_INCREMENT` (MySQL) vs `SERIAL` (PostgreSQL)
- **IP Addresses**: `VARCHAR(45)` (MySQL) vs `INET` (PostgreSQL)
- **JSON**: `JSON` (MySQL) vs `JSONB` (PostgreSQL)
- **Enums**: `ENUM` (MySQL) vs `CHECK` constraints (PostgreSQL)
- **Reserved Words**: User table requires quotes in PostgreSQL

## Security Considerations

1. **Password Storage**: Passwords should be properly hashed (bcrypt, Argon2)
2. **IP Address Logging**: Full IP addresses are stored for audit purposes
3. **Soft Deletes**: Foreign keys use SET NULL to preserve audit trails
4. **Role-based Access**: User types enable role-based security
5. **Audit Trail**: Comprehensive logging of all changes

## Sample Data

Both schema files include sample data for testing:
- 3 users (admin, driver, customer)
- 3 products with different categories
- 2 vehicles with registrations
- 2 sample routes
- 4 QR codes linked to products
- Sample logger entries with GPS coordinates

## Usage Examples

### Query Active Routes
```sql
SELECT * FROM ActiveRoutes WHERE Status = 'Active';
```

### Get User Activity
```sql
-- MySQL
CALL GetUserActivity(1);

-- PostgreSQL
SELECT * FROM GetUserActivity(1);
```

### Find Products by Location
```sql
SELECT DISTINCT p.Title, l.lat, l.lng
FROM Product p
JOIN Logger l ON p.ID = l.ProductID
WHERE l.lat BETWEEN 40.0 AND 41.0
  AND l.lng BETWEEN -75.0 AND -73.0;
```

### Track QR Code Scans
```sql
SELECT qr.key_value, p.Title, COUNT(l.ID) as ScanCount
FROM QRcodes qr
JOIN Product p ON qr.ProductID = p.ID
LEFT JOIN Logger l ON qr.ID = l.current_qrID
GROUP BY qr.key_value, p.Title
ORDER BY ScanCount DESC;
```

## Maintenance

### Regular Tasks
1. **Refresh Materialized Views** (PostgreSQL): `REFRESH MATERIALIZED VIEW ProductLocationSummary;`
2. **Archive Old Logs**: Consider partitioning or archiving old Logger entries
3. **Index Maintenance**: Monitor and rebuild indexes as needed
4. **Audit Log Cleanup**: Implement retention policies for audit data

### Monitoring
- Monitor Logger table growth (high-volume inserts expected)
- Track query performance on location-based searches
- Monitor foreign key constraint violations
- Review audit log for security events

## Migration Notes

When migrating between MySQL and PostgreSQL:
1. Update auto-increment syntax
2. Convert ENUM types to CHECK constraints
3. Update JSON to JSONB for better performance
4. Add quotes around reserved words like "User"
5. Convert stored procedures to functions
6. Update trigger syntax