/*
================================================================================
  ClinicCare
  Script:  10_Backup.sql
  Purpose: Full backup of ClinicDB to a .bak file (rubric ID 8).
  Run in:  SSMS 18, connected to .\SQLEXP2017

  PREREQUISITE - folder permissions
  ---------------------------------
  BACKUP is executed by the SQL Server SERVICE account, not by the user running
  the script, so the service account needs write access to the target folder.
  On this machine the service runs as:

      NT Service\MSSQL$SQLEXP2017

  Grant it once from an ordinary command prompt:

      icacls "c:\Users\hjasi\Desktop\COOP\Project\db\backups" ^
             /grant "NT Service\MSSQL$SQLEXP2017:(OI)(CI)M"

  Without this the backup fails with:
      "Cannot open backup device ... Operating system error 5 (Access is denied)."
================================================================================
*/

USE master;
GO

DECLARE @BackupFile  NVARCHAR(400) = N'c:\Users\hjasi\Desktop\COOP\Project\db\backups\ClinicDB.bak';
DECLARE @Description NVARCHAR(255) = N'ClinicCare full backup taken ' +
                                     CONVERT(NVARCHAR(20), GETDATE(), 120);

/* WITH FORMAT + INIT overwrite the media set, so the file holds exactly one
   backup rather than growing with every run. CHECKSUM asks SQL Server to
   validate pages as it writes, so corruption is caught at backup time. */
BACKUP DATABASE ClinicDB
TO DISK = @BackupFile
WITH FORMAT,
     INIT,
     NAME        = N'ClinicDB-Full',
     DESCRIPTION = @Description,
     CHECKSUM,
     STATS = 10;
GO

/* ---------------------------------------------------------------------------
   Verify the backup is readable and internally consistent before trusting it.
   --------------------------------------------------------------------------- */
RESTORE VERIFYONLY
FROM DISK = N'c:\Users\hjasi\Desktop\COOP\Project\db\backups\ClinicDB.bak'
WITH CHECKSUM;
GO

/* ---------------------------------------------------------------------------
   Show what the backup file now contains.
   --------------------------------------------------------------------------- */
RESTORE HEADERONLY
FROM DISK = N'c:\Users\hjasi\Desktop\COOP\Project\db\backups\ClinicDB.bak';
GO

PRINT '10_Backup.sql completed successfully.';
GO
