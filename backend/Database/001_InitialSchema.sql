-- Smart Barber Booking System - PostgreSQL Database Schema
-- Server: ManHenry
-- Database: BarberBookingDB
-- Version: 1.0

-- Create database (run this separately if database doesn't exist)
-- CREATE DATABASE "BarberBookingDB"
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'English_United States.1252'
--     LC_CTYPE = 'English_United States.1252'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- Connect to the database
-- \c BarberBookingDB

-- Drop tables if they exist (for clean installation)
DROP TABLE IF EXISTS "ChatMessages" CASCADE;
DROP TABLE IF EXISTS "ChatSessions" CASCADE;
DROP TABLE IF EXISTS "Invoices" CASCADE;
DROP TABLE IF EXISTS "Appointments" CASCADE;
DROP TABLE IF EXISTS "Services" CASCADE;
DROP TABLE IF EXISTS "StaffProfiles" CASCADE;
DROP TABLE IF EXISTS "Shops" CASCADE;
DROP TABLE IF EXISTS "Users" CASCADE;

-- Create Users Table
CREATE TABLE "Users" (
    "Id" SERIAL PRIMARY KEY,
    "Username" VARCHAR(100) NOT NULL UNIQUE,
    "PasswordHash" VARCHAR(255) NOT NULL,
    "Role" INTEGER NOT NULL,
    "FullName" VARCHAR(200) NOT NULL,
    "Phone" VARCHAR(20) NOT NULL,
    "AvatarUrl" VARCHAR(500),
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP
);

CREATE INDEX "IX_Users_Phone" ON "Users" ("Phone");
CREATE INDEX "IX_Users_Role" ON "Users" ("Role");

-- Create Shops Table
CREATE TABLE "Shops" (
    "Id" SERIAL PRIMARY KEY,
    "ManagerId" INTEGER NOT NULL,
    "Name" VARCHAR(200) NOT NULL,
    "Location" VARCHAR(500) NOT NULL,
    "OpenTime" TIME NOT NULL,
    "CloseTime" TIME NOT NULL,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP,
    CONSTRAINT "FK_Shops_Users_ManagerId" FOREIGN KEY ("ManagerId") 
        REFERENCES "Users" ("Id") ON DELETE RESTRICT
);

CREATE INDEX "IX_Shops_ManagerId" ON "Shops" ("ManagerId");
CREATE INDEX "IX_Shops_Location" ON "Shops" ("Location");

-- Create StaffProfiles Table
CREATE TABLE "StaffProfiles" (
    "Id" SERIAL PRIMARY KEY,
    "UserId" INTEGER NOT NULL,
    "ShopId" INTEGER NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "SkillSet" VARCHAR(1000),
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP,
    CONSTRAINT "FK_StaffProfiles_Users_UserId" FOREIGN KEY ("UserId") 
        REFERENCES "Users" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_StaffProfiles_Shops_ShopId" FOREIGN KEY ("ShopId") 
        REFERENCES "Shops" ("Id") ON DELETE RESTRICT
);

CREATE UNIQUE INDEX "IX_StaffProfiles_UserId_ShopId" ON "StaffProfiles" ("UserId", "ShopId");
CREATE INDEX "IX_StaffProfiles_ShopId" ON "StaffProfiles" ("ShopId");

-- Create Services Table
CREATE TABLE "Services" (
    "Id" SERIAL PRIMARY KEY,
    "ShopId" INTEGER NOT NULL,
    "Name" VARCHAR(200) NOT NULL,
    "Price" DECIMAL(18,2) NOT NULL,
    "DurationMinutes" INTEGER NOT NULL,
    "ImageUrl" VARCHAR(500),
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP,
    CONSTRAINT "FK_Services_Shops_ShopId" FOREIGN KEY ("ShopId") 
        REFERENCES "Shops" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_Services_ShopId" ON "Services" ("ShopId");

-- Create Appointments Table
CREATE TABLE "Appointments" (
    "Id" SERIAL PRIMARY KEY,
    "CustomerId" INTEGER NOT NULL,
    "StaffId" INTEGER NOT NULL,
    "ServiceId" INTEGER NOT NULL,
    "StartTime" TIMESTAMP NOT NULL,
    "EndTime" TIMESTAMP NOT NULL,
    "Status" INTEGER NOT NULL DEFAULT 1,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP,
    CONSTRAINT "FK_Appointments_Users_CustomerId" FOREIGN KEY ("CustomerId") 
        REFERENCES "Users" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Appointments_StaffProfiles_StaffId" FOREIGN KEY ("StaffId") 
        REFERENCES "StaffProfiles" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Appointments_Services_ServiceId" FOREIGN KEY ("ServiceId") 
        REFERENCES "Services" ("Id") ON DELETE RESTRICT
);

CREATE INDEX "IX_Appointments_StaffId_StartTime_EndTime" ON "Appointments" ("StaffId", "StartTime", "EndTime");
CREATE INDEX "IX_Appointments_CustomerId_StartTime" ON "Appointments" ("CustomerId", "StartTime");
CREATE INDEX "IX_Appointments_ServiceId" ON "Appointments" ("ServiceId");

-- Create Invoices Table
CREATE TABLE "Invoices" (
    "Id" SERIAL PRIMARY KEY,
    "AppointmentId" INTEGER NOT NULL UNIQUE,
    "TotalAmount" DECIMAL(18,2) NOT NULL,
    "PaymentMethod" INTEGER NOT NULL,
    "CreatedByStaffId" INTEGER NOT NULL,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "FK_Invoices_Appointments_AppointmentId" FOREIGN KEY ("AppointmentId") 
        REFERENCES "Appointments" ("Id") ON DELETE RESTRICT
);

CREATE INDEX "IX_Invoices_CreatedAt" ON "Invoices" ("CreatedAt");

-- Create ChatSessions Table
CREATE TABLE "ChatSessions" (
    "Id" SERIAL PRIMARY KEY,
    "User1_Id" INTEGER,
    "User2_Id" INTEGER,
    "Type" INTEGER NOT NULL,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP
);

CREATE INDEX "IX_ChatSessions_User1_Id_User2_Id" ON "ChatSessions" ("User1_Id", "User2_Id");

-- Create ChatMessages Table
CREATE TABLE "ChatMessages" (
    "Id" SERIAL PRIMARY KEY,
    "SessionId" INTEGER NOT NULL,
    "SenderId" INTEGER NOT NULL,
    "Content" TEXT NOT NULL,
    "IsImage" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "FK_ChatMessages_ChatSessions_SessionId" FOREIGN KEY ("SessionId") 
        REFERENCES "ChatSessions" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_ChatMessages_SessionId_CreatedAt" ON "ChatMessages" ("SessionId", "CreatedAt");

-- Insert Sample Data

-- Admin User (Password: password)
INSERT INTO "Users" ("Username", "PasswordHash", "Role", "FullName", "Phone", "CreatedAt")
VALUES ('admin', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 1, 'System Administrator', '+1234567890', CURRENT_TIMESTAMP);

-- Shop Manager (Password: password)
INSERT INTO "Users" ("Username", "PasswordHash", "Role", "FullName", "Phone", "CreatedAt")
VALUES ('manager1', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 2, 'John Manager', '+1234567891', CURRENT_TIMESTAMP);

-- Staff Members (Password: password)
INSERT INTO "Users" ("Username", "PasswordHash", "Role", "FullName", "Phone", "CreatedAt")
VALUES 
    ('barber1', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 3, 'Mike Barber', '+1234567892', CURRENT_TIMESTAMP),
    ('stylist1', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 3, 'Sarah Stylist', '+1234567893', CURRENT_TIMESTAMP);

-- Customers (Password: password)
INSERT INTO "Users" ("Username", "PasswordHash", "Role", "FullName", "Phone", "CreatedAt")
VALUES 
    ('customer1', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 4, 'James Customer', '+1234567894', CURRENT_TIMESTAMP),
    ('customer2', '$2a$11$xQZ9z8N7K5yK5qJ5z8N7KO5z8N7K5yK5qJ5z8N7K5yK5qJ5z8N7KO', 4, 'Emily Client', '+1234567895', CURRENT_TIMESTAMP);

-- Shop
INSERT INTO "Shops" ("ManagerId", "Name", "Location", "OpenTime", "CloseTime", "CreatedAt")
VALUES (2, 'Premium Cuts Salon', '123 Main Street, New York, NY 10001', '09:00:00', '20:00:00', CURRENT_TIMESTAMP);

-- Staff Profiles
INSERT INTO "StaffProfiles" ("UserId", "ShopId", "IsActive", "SkillSet", "CreatedAt")
VALUES 
    (3, 1, TRUE, 'Classic cuts, Beard trimming, Hot towel shave', CURRENT_TIMESTAMP),
    (4, 1, TRUE, 'Modern styles, Hair coloring, Treatments', CURRENT_TIMESTAMP);

-- Services
INSERT INTO "Services" ("ShopId", "Name", "Price", "DurationMinutes", "CreatedAt")
VALUES 
    (1, 'Classic Haircut', 25.00, 30, CURRENT_TIMESTAMP),
    (1, 'Premium Haircut & Styling', 45.00, 60, CURRENT_TIMESTAMP),
    (1, 'Beard Trim', 15.00, 20, CURRENT_TIMESTAMP),
    (1, 'Hot Towel Shave', 35.00, 45, CURRENT_TIMESTAMP),
    (1, 'Hair Coloring', 80.00, 90, CURRENT_TIMESTAMP),
    (1, 'Kids Haircut', 20.00, 25, CURRENT_TIMESTAMP);

-- Comments
COMMENT ON TABLE "Users" IS 'Stores all user accounts with role-based access control';
COMMENT ON TABLE "Shops" IS 'Barber shops/salons managed by ShopManagers';
COMMENT ON TABLE "StaffProfiles" IS 'Staff members assigned to shops with their skills';
COMMENT ON TABLE "Services" IS 'Services offered by each shop';
COMMENT ON TABLE "Appointments" IS 'Customer bookings with conflict prevention logic';
COMMENT ON TABLE "Invoices" IS 'Payment records for completed appointments';
COMMENT ON TABLE "ChatSessions" IS 'Chat sessions between users or with AI';
COMMENT ON TABLE "ChatMessages" IS 'Messages within chat sessions';

-- Grant permissions (adjust username as needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO your_app_user;

-- Verification Queries
SELECT 'Database setup completed successfully!' AS Status;
SELECT COUNT(*) AS "Total Users" FROM "Users";
SELECT COUNT(*) AS "Total Shops" FROM "Shops";
SELECT COUNT(*) AS "Total Services" FROM "Services";
SELECT COUNT(*) AS "Total Staff" FROM "StaffProfiles";
