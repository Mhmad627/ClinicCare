/*
================================================================================
  ClinicCare
  Script:  02_CreateTables.sql
  Purpose: Create the four core tables with PK / FK relationships,
           check constraints and unique keys.
  Naming:  tables  = tblXxx      (plural entity)
           columns = PascalCase, keys carry the entity prefix (PatientID)
================================================================================
*/

USE ClinicDB;
GO

/* Drop in reverse dependency order so the script can be re-run cleanly. */
IF OBJECT_ID(N'dbo.tblAppointmentAudit', N'U') IS NOT NULL DROP TABLE dbo.tblAppointmentAudit;
IF OBJECT_ID(N'dbo.tblAppointments',     N'U') IS NOT NULL DROP TABLE dbo.tblAppointments;
IF OBJECT_ID(N'dbo.tblPatients',         N'U') IS NOT NULL DROP TABLE dbo.tblPatients;
IF OBJECT_ID(N'dbo.tblDoctors',          N'U') IS NOT NULL DROP TABLE dbo.tblDoctors;
IF OBJECT_ID(N'dbo.tblSpecialties',      N'U') IS NOT NULL DROP TABLE dbo.tblSpecialties;
GO

/* ---------------------------------------------------------------------------
   tblSpecialties  -  lookup table for medical specialties
   --------------------------------------------------------------------------- */
CREATE TABLE dbo.tblSpecialties
(
    SpecialtyID    INT             IDENTITY(1,1) NOT NULL,
    SpecialtyName  NVARCHAR(100)   NOT NULL,
    Description    NVARCHAR(300)   NULL,
    IsActive       BIT             NOT NULL CONSTRAINT DF_tblSpecialties_IsActive DEFAULT (1),

    CONSTRAINT PK_tblSpecialties        PRIMARY KEY CLUSTERED (SpecialtyID),
    CONSTRAINT UQ_tblSpecialties_Name   UNIQUE (SpecialtyName)
);
GO

/* ---------------------------------------------------------------------------
   tblDoctors  -  one doctor belongs to one specialty
   --------------------------------------------------------------------------- */
CREATE TABLE dbo.tblDoctors
(
    DoctorID     INT            IDENTITY(1,1) NOT NULL,
    FullName     NVARCHAR(150)  NOT NULL,
    SpecialtyID  INT            NOT NULL,
    Email        NVARCHAR(150)  NULL,
    Phone        NVARCHAR(20)   NULL,
    Bio          NVARCHAR(600)  NULL,
    PhotoUrl     NVARCHAR(260)  NULL,
    IsActive     BIT            NOT NULL CONSTRAINT DF_tblDoctors_IsActive DEFAULT (1),

    CONSTRAINT PK_tblDoctors PRIMARY KEY CLUSTERED (DoctorID),
    CONSTRAINT FK_tblDoctors_tblSpecialties
        FOREIGN KEY (SpecialtyID) REFERENCES dbo.tblSpecialties (SpecialtyID),
    CONSTRAINT CK_tblDoctors_Email
        CHECK (Email IS NULL OR Email LIKE '%_@_%._%')
);
GO

/* ---------------------------------------------------------------------------
   tblPatients
   --------------------------------------------------------------------------- */
CREATE TABLE dbo.tblPatients
(
    PatientID    INT            IDENTITY(1,1) NOT NULL,
    FullName     NVARCHAR(150)  NOT NULL,
    Gender       NVARCHAR(10)   NOT NULL,
    DateOfBirth  DATE           NULL,
    Phone        NVARCHAR(20)   NOT NULL,
    Email        NVARCHAR(150)  NULL,
    NationalID   NVARCHAR(20)   NULL,
    Notes        NVARCHAR(600)  NULL,
    CreatedAt    DATETIME       NOT NULL CONSTRAINT DF_tblPatients_CreatedAt DEFAULT (GETDATE()),

    CONSTRAINT PK_tblPatients            PRIMARY KEY CLUSTERED (PatientID),
    CONSTRAINT UQ_tblPatients_NationalID UNIQUE (NationalID),
    CONSTRAINT CK_tblPatients_Gender     CHECK (Gender IN (N'Male', N'Female')),
    CONSTRAINT CK_tblPatients_Phone      CHECK (Phone LIKE '05[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

/* ---------------------------------------------------------------------------
   tblAppointments  -  links a patient to a doctor on a date / time slot
   --------------------------------------------------------------------------- */
CREATE TABLE dbo.tblAppointments
(
    AppointmentID    INT            IDENTITY(1,1) NOT NULL,
    PatientID        INT            NOT NULL,
    DoctorID         INT            NOT NULL,
    AppointmentDate  DATE           NOT NULL,
    TimeSlot         NVARCHAR(20)   NOT NULL,
    VisitType        NVARCHAR(20)   NOT NULL CONSTRAINT DF_tblAppointments_VisitType DEFAULT (N'New'),
    Symptoms         NVARCHAR(600)  NULL,
    Status           NVARCHAR(20)   NOT NULL CONSTRAINT DF_tblAppointments_Status    DEFAULT (N'Pending'),
    CreatedAt        DATETIME       NOT NULL CONSTRAINT DF_tblAppointments_CreatedAt DEFAULT (GETDATE()),

    CONSTRAINT PK_tblAppointments PRIMARY KEY CLUSTERED (AppointmentID),
    CONSTRAINT FK_tblAppointments_tblPatients
        FOREIGN KEY (PatientID) REFERENCES dbo.tblPatients (PatientID),
    CONSTRAINT FK_tblAppointments_tblDoctors
        FOREIGN KEY (DoctorID)  REFERENCES dbo.tblDoctors  (DoctorID),
    CONSTRAINT CK_tblAppointments_Status
        CHECK (Status IN (N'Pending', N'Confirmed', N'Completed', N'Cancelled')),
    CONSTRAINT CK_tblAppointments_VisitType
        CHECK (VisitType IN (N'New', N'Follow-up')),
    /* A doctor cannot be double-booked in the same slot on the same day. */
    CONSTRAINT UQ_tblAppointments_DoctorSlot
        UNIQUE (DoctorID, AppointmentDate, TimeSlot)
);
GO

/* ---------------------------------------------------------------------------
   tblAppointmentAudit  -  written to by the INSERT trigger (see script 04)
   --------------------------------------------------------------------------- */
CREATE TABLE dbo.tblAppointmentAudit
(
    AuditID        INT           IDENTITY(1,1) NOT NULL,
    AppointmentID  INT           NOT NULL,
    Action         NVARCHAR(20)  NOT NULL,
    PerformedBy    NVARCHAR(128) NOT NULL CONSTRAINT DF_tblAppointmentAudit_By   DEFAULT (SUSER_SNAME()),
    PerformedAt    DATETIME      NOT NULL CONSTRAINT DF_tblAppointmentAudit_At   DEFAULT (GETDATE()),
    Details        NVARCHAR(400) NULL,

    CONSTRAINT PK_tblAppointmentAudit PRIMARY KEY CLUSTERED (AuditID)
);
GO

PRINT '02_CreateTables.sql completed successfully.';
GO
