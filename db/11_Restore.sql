/*
================================================================================
  ClinicCare
  Script:  11_Restore.sql
  Purpose: Restore ClinicDB from the .bak file produced by 10_Backup.sql
           (rubric ID 8).
  Run in:  SSMS 18, connected to .\SQLEXP2017

  TWO MODES
  ---------
  OPTION A (default, safe)  - restores to a NEW database, ClinicDB_Restored.
                              Proves the backup is good without touching live data.
  OPTION B (destructive)    - overwrites the live ClinicDB.
                              Commented out; uncomment deliberately.

  WHY SINGLE_USER IS NEEDED (Option B)
  ------------------------------------
  RESTORE requires exclusive access. If the web application, SSMS, or any query
  window is connected to ClinicDB the restore fails with:
      "Exclusive access could not be obtained because the database is in use."
  ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE disconnects
  everyone else first. Remember to set MULTI_USER again afterwards.
================================================================================
*/

USE master;
GO

/* ============================================================================
   OPTION A - restore to a separate database (does not touch the live one)
   ============================================================================ */

/* Drop any previous verification copy. */
IF DB_ID(N'ClinicDB_Restored') IS NOT NULL
BEGIN
    ALTER DATABASE ClinicDB_Restored SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ClinicDB_Restored;
    PRINT 'Existing ClinicDB_Restored dropped.';
END
GO

/* MOVE is mandatory: the backup remembers the original .mdf/.ldf paths, and
   two databases cannot share the same physical files. */
RESTORE DATABASE ClinicDB_Restored
FROM DISK = N'c:\Users\hjasi\Desktop\COOP\Project\db\backups\ClinicDB.bak'
WITH
    MOVE N'ClinicDB'     TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXP2017\MSSQL\DATA\ClinicDB_Restored.mdf',
    MOVE N'ClinicDB_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXP2017\MSSQL\DATA\ClinicDB_Restored_log.ldf',
    REPLACE,
    RECOVERY,
    STATS = 10;
GO

/* ---------------------------------------------------------------------------
   Verification - the restored copy must hold the same data as the live one.
   --------------------------------------------------------------------------- */
SELECT 'Specialties'  AS TableName,
       (SELECT COUNT(*) FROM ClinicDB.dbo.tblSpecialties)          AS LiveRows,
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.tblSpecialties) AS RestoredRows
UNION ALL SELECT 'Doctors',
       (SELECT COUNT(*) FROM ClinicDB.dbo.tblDoctors),
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.tblDoctors)
UNION ALL SELECT 'Patients',
       (SELECT COUNT(*) FROM ClinicDB.dbo.tblPatients),
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.tblPatients)
UNION ALL SELECT 'Appointments',
       (SELECT COUNT(*) FROM ClinicDB.dbo.tblAppointments),
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.tblAppointments)
UNION ALL SELECT 'Stored procedures',
       (SELECT COUNT(*) FROM ClinicDB.sys.procedures),
       (SELECT COUNT(*) FROM ClinicDB_Restored.sys.procedures)
UNION ALL SELECT 'Membership users',
       (SELECT COUNT(*) FROM ClinicDB.dbo.aspnet_Users),
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.aspnet_Users)
UNION ALL SELECT 'Membership roles',
       (SELECT COUNT(*) FROM ClinicDB.dbo.aspnet_Roles),
       (SELECT COUNT(*) FROM ClinicDB_Restored.dbo.aspnet_Roles);
GO

PRINT '11_Restore.sql (Option A) completed successfully.';
GO


/* ============================================================================
   OPTION B - overwrite the LIVE ClinicDB. Destructive: uncomment to use.
   ============================================================================

USE master;
GO

-- Disconnect everyone, including the web application, and roll back their work.
ALTER DATABASE ClinicDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE ClinicDB
FROM DISK = N'c:\Users\hjasi\Desktop\COOP\Project\db\backups\ClinicDB.bak'
WITH REPLACE,
     RECOVERY,
     STATS = 10;
GO

-- Always put the database back into normal multi-user mode.
ALTER DATABASE ClinicDB SET MULTI_USER;
GO

PRINT '11_Restore.sql (Option B) completed - ClinicDB overwritten from backup.';
GO

============================================================================ */
