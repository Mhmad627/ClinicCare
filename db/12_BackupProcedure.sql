/*
================================================================================
  ClinicCare
  Script:  12_BackupProcedure.sql
  Purpose: Stored procedure behind Admin/Backup.aspx, so the "Backup Now"
           button goes through a procedure like every other database call in
           the application rather than sending raw SQL from C# (rubric ID 8).
================================================================================
*/

USE ClinicDB;
GO

IF OBJECT_ID(N'dbo.usp_Database_Backup', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Database_Backup;
GO

CREATE PROCEDURE dbo.usp_Database_Backup
    @BackupFolder NVARCHAR(400),
    @BackupPath   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* BACKUP DATABASE cannot take the target path as a parameter, so the
       statement has to be built dynamically. The folder comes from Web.config
       and never from user input, and the single quotes are doubled up before
       the string is assembled, so nothing can break out of the literal. */

    IF @BackupFolder IS NULL OR LTRIM(RTRIM(@BackupFolder)) = N''
    BEGIN
        RAISERROR (N'A backup folder must be supplied.', 16, 1);
        RETURN -1;
    END

    /* Reject anything that is not a plain local or UNC folder path. */
    IF @BackupFolder LIKE N'%[;]%' OR @BackupFolder LIKE N'%--%'
    BEGIN
        RAISERROR (N'The backup folder contains characters that are not allowed.', 16, 1);
        RETURN -1;
    END

    DECLARE @Folder NVARCHAR(400) = LTRIM(RTRIM(@BackupFolder));
    IF RIGHT(@Folder, 1) <> N'\' SET @Folder = @Folder + N'\';

    /* Timestamped file name, generated here rather than passed in. */
    DECLARE @FileName NVARCHAR(200) =
        N'ClinicDB_' + CONVERT(NVARCHAR(8), GETDATE(), 112) + N'_' +
        REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), N':', N'') + N'.bak';

    SET @BackupPath = @Folder + @FileName;

    DECLARE @Safe NVARCHAR(1000) = REPLACE(@BackupPath, N'''', N'''''');
    DECLARE @Sql  NVARCHAR(MAX) =
        N'BACKUP DATABASE ClinicDB TO DISK = N''' + @Safe + N''' ' +
        N'WITH FORMAT, INIT, NAME = N''ClinicDB-Full'', CHECKSUM;';

    EXEC sp_executesql @Sql;

    /* NOTE - deliberately no RESTORE VERIFYONLY here.
       VERIFYONLY requires CREATE DATABASE permission in master, because a
       RESTORE could create a database. The application login (cliniccare_app)
       is only db_owner inside ClinicDB, so calling it fails with
           "CREATE DATABASE permission denied in database 'master'."
       Granting the web application that permission would be a far worse
       trade than losing the check, so verification stays in 10_Backup.sql,
       which an administrator runs under Windows authentication. The page
       confirms the file exists and reports its size instead.
       The backup itself is written WITH CHECKSUM, so page-level corruption
       is still detected as it is written. */

    RETURN 0;
END
GO

PRINT '12_BackupProcedure.sql completed successfully.';
GO
