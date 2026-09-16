/*
================================================================================
  ClinicCare
  Script:  04_StoredProcedures.sql
  Purpose: Full CRUD stored procedures for Patients, Doctors and Appointments,
           plus the specialty lookup, one audit TRIGGER and the
           non-clustered INDEXes required by the Week 1 report.
  Naming:  usp_<Entity>_<Action>
================================================================================
*/

USE ClinicDB;
GO

/* ===========================================================================
   SPECIALTIES
   =========================================================================== */

IF OBJECT_ID(N'dbo.usp_Specialty_SelectAll', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Specialty_SelectAll;
GO
CREATE PROCEDURE dbo.usp_Specialty_SelectAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SpecialtyID, SpecialtyName, Description, IsActive
    FROM   dbo.tblSpecialties
    WHERE  IsActive = 1
    ORDER BY SpecialtyName;
END
GO

/* ===========================================================================
   PATIENTS
   =========================================================================== */

IF OBJECT_ID(N'dbo.usp_Patient_SelectAll', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Patient_SelectAll;
GO
CREATE PROCEDURE dbo.usp_Patient_SelectAll
    @Search NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  PatientID, FullName, Gender, DateOfBirth, Phone, Email, NationalID, Notes, CreatedAt
    FROM    dbo.tblPatients
    WHERE   @Search IS NULL
            OR FullName   LIKE '%' + @Search + '%'
            OR Phone      LIKE '%' + @Search + '%'
            OR NationalID LIKE '%' + @Search + '%'
    ORDER BY FullName;
END
GO

IF OBJECT_ID(N'dbo.usp_Patient_SelectByID', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Patient_SelectByID;
GO
CREATE PROCEDURE dbo.usp_Patient_SelectByID
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  PatientID, FullName, Gender, DateOfBirth, Phone, Email, NationalID, Notes, CreatedAt
    FROM    dbo.tblPatients
    WHERE   PatientID = @PatientID;
END
GO

IF OBJECT_ID(N'dbo.usp_Patient_Insert', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Patient_Insert;
GO
CREATE PROCEDURE dbo.usp_Patient_Insert
    @FullName    NVARCHAR(150),
    @Gender      NVARCHAR(10),
    @DateOfBirth DATE          = NULL,
    @Phone       NVARCHAR(20),
    @Email       NVARCHAR(150) = NULL,
    @NationalID  NVARCHAR(20)  = NULL,
    @Notes       NVARCHAR(600) = NULL,
    @NewPatientID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tblPatients (FullName, Gender, DateOfBirth, Phone, Email, NationalID, Notes)
    VALUES (@FullName, @Gender, @DateOfBirth, @Phone,
            NULLIF(LTRIM(RTRIM(@Email)),      N''),
            NULLIF(LTRIM(RTRIM(@NationalID)), N''),
            NULLIF(LTRIM(RTRIM(@Notes)),      N''));

    SET @NewPatientID = SCOPE_IDENTITY();
END
GO

IF OBJECT_ID(N'dbo.usp_Patient_Update', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Patient_Update;
GO
CREATE PROCEDURE dbo.usp_Patient_Update
    @PatientID   INT,
    @FullName    NVARCHAR(150),
    @Gender      NVARCHAR(10),
    @DateOfBirth DATE          = NULL,
    @Phone       NVARCHAR(20),
    @Email       NVARCHAR(150) = NULL,
    @NationalID  NVARCHAR(20)  = NULL,
    @Notes       NVARCHAR(600) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tblPatients
    SET    FullName    = @FullName,
           Gender      = @Gender,
           DateOfBirth = @DateOfBirth,
           Phone       = @Phone,
           Email       = NULLIF(LTRIM(RTRIM(@Email)),      N''),
           NationalID  = NULLIF(LTRIM(RTRIM(@NationalID)), N''),
           Notes       = NULLIF(LTRIM(RTRIM(@Notes)),      N'')
    WHERE  PatientID   = @PatientID;

    RETURN @@ROWCOUNT;
END
GO

IF OBJECT_ID(N'dbo.usp_Patient_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Patient_Delete;
GO
CREATE PROCEDURE dbo.usp_Patient_Delete
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    /* A patient with appointments cannot be removed - the FK would block it,
       so return a friendly signal the UI can display instead of a raw error. */
    IF EXISTS (SELECT 1 FROM dbo.tblAppointments WHERE PatientID = @PatientID)
    BEGIN
        RAISERROR (N'This patient has existing appointments and cannot be deleted.', 16, 1);
        RETURN -1;
    END

    DELETE FROM dbo.tblPatients WHERE PatientID = @PatientID;
    RETURN @@ROWCOUNT;
END
GO

/* ===========================================================================
   DOCTORS
   =========================================================================== */

IF OBJECT_ID(N'dbo.usp_Doctor_SelectAll', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_SelectAll;
GO
CREATE PROCEDURE dbo.usp_Doctor_SelectAll
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  d.DoctorID, d.FullName, d.SpecialtyID, s.SpecialtyName,
            d.Email, d.Phone, d.Bio, d.PhotoUrl, d.IsActive
    FROM    dbo.tblDoctors d
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   (@ActiveOnly = 0 OR d.IsActive = 1)
    ORDER BY s.SpecialtyName, d.FullName;
END
GO

IF OBJECT_ID(N'dbo.usp_Doctor_SelectBySpecialty', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_SelectBySpecialty;
GO
CREATE PROCEDURE dbo.usp_Doctor_SelectBySpecialty
    @SpecialtyID INT
AS
BEGIN
    SET NOCOUNT ON;
    /* Feeds the cascading DropDownList on BookAppointment.aspx and the filtered
       Repeater on Doctors.aspx, so it returns the full doctor row - the
       dropdown simply ignores the columns it does not bind. */
    SELECT  d.DoctorID, d.FullName, d.SpecialtyID, s.SpecialtyName,
            d.Email, d.Phone, d.Bio, d.PhotoUrl, d.IsActive
    FROM    dbo.tblDoctors d
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   d.SpecialtyID = @SpecialtyID
            AND d.IsActive = 1
    ORDER BY d.FullName;
END
GO

IF OBJECT_ID(N'dbo.usp_Doctor_SelectByID', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_SelectByID;
GO
CREATE PROCEDURE dbo.usp_Doctor_SelectByID
    @DoctorID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  d.DoctorID, d.FullName, d.SpecialtyID, s.SpecialtyName,
            d.Email, d.Phone, d.Bio, d.PhotoUrl, d.IsActive
    FROM    dbo.tblDoctors d
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   d.DoctorID = @DoctorID;
END
GO

IF OBJECT_ID(N'dbo.usp_Doctor_Insert', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_Insert;
GO
CREATE PROCEDURE dbo.usp_Doctor_Insert
    @FullName    NVARCHAR(150),
    @SpecialtyID INT,
    @Email       NVARCHAR(150) = NULL,
    @Phone       NVARCHAR(20)  = NULL,
    @Bio         NVARCHAR(600) = NULL,
    @PhotoUrl    NVARCHAR(260) = NULL,
    @IsActive    BIT           = 1,
    @NewDoctorID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tblDoctors (FullName, SpecialtyID, Email, Phone, Bio, PhotoUrl, IsActive)
    VALUES (@FullName, @SpecialtyID,
            NULLIF(LTRIM(RTRIM(@Email)),    N''),
            NULLIF(LTRIM(RTRIM(@Phone)),    N''),
            NULLIF(LTRIM(RTRIM(@Bio)),      N''),
            NULLIF(LTRIM(RTRIM(@PhotoUrl)), N''),
            @IsActive);

    SET @NewDoctorID = SCOPE_IDENTITY();
END
GO

IF OBJECT_ID(N'dbo.usp_Doctor_Update', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_Update;
GO
CREATE PROCEDURE dbo.usp_Doctor_Update
    @DoctorID    INT,
    @FullName    NVARCHAR(150),
    @SpecialtyID INT,
    @Email       NVARCHAR(150) = NULL,
    @Phone       NVARCHAR(20)  = NULL,
    @Bio         NVARCHAR(600) = NULL,
    @PhotoUrl    NVARCHAR(260) = NULL,
    @IsActive    BIT           = 1
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tblDoctors
    SET    FullName    = @FullName,
           SpecialtyID = @SpecialtyID,
           Email       = NULLIF(LTRIM(RTRIM(@Email)),    N''),
           Phone       = NULLIF(LTRIM(RTRIM(@Phone)),    N''),
           Bio         = NULLIF(LTRIM(RTRIM(@Bio)),      N''),
           PhotoUrl    = NULLIF(LTRIM(RTRIM(@PhotoUrl)), N''),
           IsActive    = @IsActive
    WHERE  DoctorID    = @DoctorID;

    RETURN @@ROWCOUNT;
END
GO

IF OBJECT_ID(N'dbo.usp_Doctor_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Doctor_Delete;
GO
CREATE PROCEDURE dbo.usp_Doctor_Delete
    @DoctorID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.tblAppointments WHERE DoctorID = @DoctorID)
    BEGIN
        RAISERROR (N'This doctor has existing appointments. Deactivate the doctor instead of deleting.', 16, 1);
        RETURN -1;
    END

    DELETE FROM dbo.tblDoctors WHERE DoctorID = @DoctorID;
    RETURN @@ROWCOUNT;
END
GO

/* ===========================================================================
   APPOINTMENTS
   =========================================================================== */

IF OBJECT_ID(N'dbo.usp_Appointment_SelectAll', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_SelectAll;
GO
CREATE PROCEDURE dbo.usp_Appointment_SelectAll
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  a.AppointmentID,
            a.PatientID,  p.FullName AS PatientName,  p.Phone AS PatientPhone,
            a.DoctorID,   d.FullName AS DoctorName,   s.SpecialtyName,
            a.AppointmentDate, a.TimeSlot, a.VisitType, a.Symptoms,
            a.Status, a.CreatedAt
    FROM    dbo.tblAppointments a
            INNER JOIN dbo.tblPatients   p ON p.PatientID   = a.PatientID
            INNER JOIN dbo.tblDoctors    d ON d.DoctorID    = a.DoctorID
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   @Status IS NULL OR a.Status = @Status
    ORDER BY a.AppointmentDate DESC, a.TimeSlot;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_SelectByID', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_SelectByID;
GO
CREATE PROCEDURE dbo.usp_Appointment_SelectByID
    @AppointmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  a.AppointmentID,
            a.PatientID,  p.FullName AS PatientName, p.Phone AS PatientPhone, p.Email AS PatientEmail,
            a.DoctorID,   d.FullName AS DoctorName,  s.SpecialtyName,
            a.AppointmentDate, a.TimeSlot, a.VisitType, a.Symptoms,
            a.Status, a.CreatedAt
    FROM    dbo.tblAppointments a
            INNER JOIN dbo.tblPatients    p ON p.PatientID   = a.PatientID
            INNER JOIN dbo.tblDoctors     d ON d.DoctorID    = a.DoctorID
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   a.AppointmentID = @AppointmentID;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_SelectByPatientLookup', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_SelectByPatientLookup;
GO
CREATE PROCEDURE dbo.usp_Appointment_SelectByPatientLookup
    @Lookup NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    /* MyAppointments.aspx - patient finds their bookings by phone or National ID. */
    SELECT  a.AppointmentID,
            p.FullName AS PatientName,
            d.FullName AS DoctorName,
            s.SpecialtyName,
            a.AppointmentDate, a.TimeSlot, a.VisitType, a.Symptoms, a.Status
    FROM    dbo.tblAppointments a
            INNER JOIN dbo.tblPatients    p ON p.PatientID   = a.PatientID
            INNER JOIN dbo.tblDoctors     d ON d.DoctorID    = a.DoctorID
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   p.Phone = @Lookup OR p.NationalID = @Lookup
    ORDER BY a.AppointmentDate DESC, a.TimeSlot;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_SelectToday', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_SelectToday;
GO
CREATE PROCEDURE dbo.usp_Appointment_SelectToday
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  a.AppointmentID, p.FullName AS PatientName, d.FullName AS DoctorName,
            s.SpecialtyName, a.TimeSlot, a.VisitType, a.Status
    FROM    dbo.tblAppointments a
            INNER JOIN dbo.tblPatients    p ON p.PatientID   = a.PatientID
            INNER JOIN dbo.tblDoctors     d ON d.DoctorID    = a.DoctorID
            INNER JOIN dbo.tblSpecialties s ON s.SpecialtyID = d.SpecialtyID
    WHERE   a.AppointmentDate = CAST(GETDATE() AS DATE)
    ORDER BY a.TimeSlot;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_Insert', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_Insert;
GO
CREATE PROCEDURE dbo.usp_Appointment_Insert
    @PatientID       INT,
    @DoctorID        INT,
    @AppointmentDate DATE,
    @TimeSlot        NVARCHAR(20),
    @VisitType       NVARCHAR(20)  = N'New',
    @Symptoms        NVARCHAR(600) = NULL,
    @Status          NVARCHAR(20)  = N'Pending',
    @NewAppointmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* Server-side guard: the same doctor cannot be booked twice in one slot.
       The UNIQUE constraint enforces this too, but checking here lets the
       application show a readable message. */
    IF EXISTS (SELECT 1 FROM dbo.tblAppointments
               WHERE DoctorID = @DoctorID
                 AND AppointmentDate = @AppointmentDate
                 AND TimeSlot = @TimeSlot
                 AND Status <> N'Cancelled')
    BEGIN
        RAISERROR (N'That time slot is already booked for the selected doctor. Please choose another slot.', 16, 1);
        RETURN -1;
    END

    INSERT INTO dbo.tblAppointments
        (PatientID, DoctorID, AppointmentDate, TimeSlot, VisitType, Symptoms, Status)
    VALUES
        (@PatientID, @DoctorID, @AppointmentDate, @TimeSlot, @VisitType,
         NULLIF(LTRIM(RTRIM(@Symptoms)), N''), @Status);

    SET @NewAppointmentID = SCOPE_IDENTITY();
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_Update', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_Update;
GO
CREATE PROCEDURE dbo.usp_Appointment_Update
    @AppointmentID   INT,
    @AppointmentDate DATE,
    @TimeSlot        NVARCHAR(20),
    @VisitType       NVARCHAR(20),
    @Symptoms        NVARCHAR(600) = NULL,
    @Status          NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tblAppointments
    SET    AppointmentDate = @AppointmentDate,
           TimeSlot        = @TimeSlot,
           VisitType       = @VisitType,
           Symptoms        = NULLIF(LTRIM(RTRIM(@Symptoms)), N''),
           Status          = @Status
    WHERE  AppointmentID   = @AppointmentID;

    RETURN @@ROWCOUNT;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_UpdateStatus', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_UpdateStatus;
GO
CREATE PROCEDURE dbo.usp_Appointment_UpdateStatus
    @AppointmentID INT,
    @Status        NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.tblAppointments
    SET    Status = @Status
    WHERE  AppointmentID = @AppointmentID;

    RETURN @@ROWCOUNT;
END
GO

IF OBJECT_ID(N'dbo.usp_Appointment_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Appointment_Delete;
GO
CREATE PROCEDURE dbo.usp_Appointment_Delete
    @AppointmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.tblAppointments WHERE AppointmentID = @AppointmentID;
    RETURN @@ROWCOUNT;
END
GO

/* ===========================================================================
   DASHBOARD STATISTICS (used by Admin/Dashboard.aspx)
   =========================================================================== */

IF OBJECT_ID(N'dbo.usp_Dashboard_GetStats', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Dashboard_GetStats;
GO
CREATE PROCEDURE dbo.usp_Dashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM dbo.tblPatients)                                              AS TotalPatients,
        (SELECT COUNT(*) FROM dbo.tblDoctors WHERE IsActive = 1)                            AS ActiveDoctors,
        (SELECT COUNT(*) FROM dbo.tblAppointments)                                          AS TotalAppointments,
        (SELECT COUNT(*) FROM dbo.tblAppointments
          WHERE AppointmentDate = CAST(GETDATE() AS DATE))                                  AS TodaysAppointments,
        (SELECT COUNT(*) FROM dbo.tblAppointments WHERE Status = N'Pending')                AS PendingAppointments,
        (SELECT COUNT(*) FROM dbo.tblAppointments WHERE Status = N'Confirmed')              AS ConfirmedAppointments;
END
GO

/* ===========================================================================
   TRIGGER - audit every appointment that is created
   =========================================================================== */

IF OBJECT_ID(N'dbo.trg_tblAppointments_Insert', N'TR') IS NOT NULL DROP TRIGGER dbo.trg_tblAppointments_Insert;
GO
CREATE TRIGGER dbo.trg_tblAppointments_Insert
ON dbo.tblAppointments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tblAppointmentAudit (AppointmentID, Action, Details)
    SELECT  i.AppointmentID,
            N'INSERT',
            N'Booked for PatientID ' + CAST(i.PatientID AS NVARCHAR(10)) +
            N' with DoctorID '       + CAST(i.DoctorID  AS NVARCHAR(10)) +
            N' on '                  + CONVERT(NVARCHAR(10), i.AppointmentDate, 120) +
            N' at '                  + i.TimeSlot
    FROM    inserted i;
END
GO

/* ===========================================================================
   INDEXES - non-clustered indexes supporting the most common lookups
   =========================================================================== */

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_tblAppointments_AppointmentDate'
           AND object_id = OBJECT_ID(N'dbo.tblAppointments'))
    DROP INDEX IX_tblAppointments_AppointmentDate ON dbo.tblAppointments;
GO
CREATE NONCLUSTERED INDEX IX_tblAppointments_AppointmentDate
    ON dbo.tblAppointments (AppointmentDate DESC)
    INCLUDE (PatientID, DoctorID, TimeSlot, Status);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_tblPatients_Phone'
           AND object_id = OBJECT_ID(N'dbo.tblPatients'))
    DROP INDEX IX_tblPatients_Phone ON dbo.tblPatients;
GO
CREATE NONCLUSTERED INDEX IX_tblPatients_Phone
    ON dbo.tblPatients (Phone)
    INCLUDE (FullName, Email);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_tblDoctors_SpecialtyID'
           AND object_id = OBJECT_ID(N'dbo.tblDoctors'))
    DROP INDEX IX_tblDoctors_SpecialtyID ON dbo.tblDoctors;
GO
CREATE NONCLUSTERED INDEX IX_tblDoctors_SpecialtyID
    ON dbo.tblDoctors (SpecialtyID, IsActive)
    INCLUDE (FullName);
GO

PRINT '04_StoredProcedures.sql completed successfully.';
GO
