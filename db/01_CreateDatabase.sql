/*
================================================================================
  ClinicCare - Clinic Appointment & Patient Management System
  Script:  01_CreateDatabase.sql
  Purpose: Create the ClinicDB database and the application SQL login/user.
  Target:  SQL Server Express (local instance .\SQLEXP2017)
  Run in:  SSMS 18  ->  master database
================================================================================
*/

USE master;
GO

/* ---------------------------------------------------------------------------
   1. Create the database (idempotent - safe to re-run)
   --------------------------------------------------------------------------- */
IF DB_ID(N'ClinicDB') IS NULL
BEGIN
    CREATE DATABASE ClinicDB;
    PRINT 'Database ClinicDB created.';
END
ELSE
BEGIN
    PRINT 'Database ClinicDB already exists - skipped.';
END
GO

/* Recovery model SIMPLE keeps the log small for a development database. */
ALTER DATABASE ClinicDB SET RECOVERY SIMPLE;
GO

/* ---------------------------------------------------------------------------
   2. Application login (SQL Authentication / mixed mode)
      The web application connects as this login, NOT as sa.
      NOTE: change the password before deploying to SmarterASP.net.
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'cliniccare_app')
BEGIN
    CREATE LOGIN cliniccare_app
        WITH PASSWORD     = N'__REDACTED__',
             DEFAULT_DATABASE = ClinicDB,
             CHECK_POLICY  = OFF;
    PRINT 'Login cliniccare_app created.';
END
ELSE
BEGIN
    PRINT 'Login cliniccare_app already exists - skipped.';
END
GO

USE ClinicDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'cliniccare_app')
BEGIN
    CREATE USER cliniccare_app FOR LOGIN cliniccare_app;
    PRINT 'Database user cliniccare_app created.';
END
GO

/* db_owner is used during development so the app can also run the
   aspnet_regsql membership schema install in Week 5. */
ALTER ROLE db_owner ADD MEMBER cliniccare_app;
GO

PRINT '01_CreateDatabase.sql completed successfully.';
GO
