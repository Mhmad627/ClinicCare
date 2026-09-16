/*
================================================================================
  ClinicCare
  Script:  05_MembershipEvidence.sql
  Purpose: Produce screenshot-ready proof that ASP.NET Membership security was
           installed AT THE DATABASE LEVEL inside ClinicDB (rubric ID 5).
  Usage:   Open in SSMS, make sure the database dropdown says ClinicDB, press F5,
           then screenshot the results grid.
  Note:    This script only reads - it changes nothing.
================================================================================
*/

USE ClinicDB;
GO

/* ---------------------------------------------------------------------------
   QUERY A - one database, two families of tables.
   This is the point of the rubric item: the membership schema lives inside the
   application's own database, not in a separate aspnetdb.
   --------------------------------------------------------------------------- */
SELECT
    DB_NAME()   AS DatabaseName,
    t.name      AS TableName,
    CASE
        WHEN t.name LIKE 'aspnet[_]%' THEN '1. ASP.NET Membership (created by aspnet_regsql)'
        WHEN t.name = 'sysdiagrams'   THEN '3. SSMS database diagram support'
        ELSE                               '2. ClinicCare application tables'
    END         AS Origin
FROM sys.tables t
ORDER BY Origin, TableName;
GO

/* ---------------------------------------------------------------------------
   QUERY B - the accounts and roles actually stored in those tables.
   Shows three things at once:
     * one account per role (Admin / Doctor / Patient)
     * roles are linked through aspnet_UsersInRoles
     * PasswordFormat = 1 means Hashed, so no password is recoverable
   --------------------------------------------------------------------------- */
SELECT
    u.UserName,
    m.Email,
    r.RoleName,
    LEFT(m.Password, 20) + '...' AS PasswordHash_Truncated,
    m.PasswordFormat             AS PasswordFormat_1_Means_Hashed,
    m.IsApproved,
    CONVERT(varchar(16), m.CreateDate, 120) AS CreatedOn
FROM aspnet_Users u
    INNER JOIN aspnet_Membership  m  ON m.UserId  = u.UserId
    LEFT  JOIN aspnet_UsersInRoles ur ON ur.UserId = u.UserId
    LEFT  JOIN aspnet_Roles        r  ON r.RoleId  = ur.RoleId
ORDER BY r.RoleName;
GO

/* ---------------------------------------------------------------------------
   QUERY C - the three application roles.
   --------------------------------------------------------------------------- */
SELECT r.RoleName,
       COUNT(ur.UserId) AS MemberCount
FROM aspnet_Roles r
    LEFT JOIN aspnet_UsersInRoles ur ON ur.RoleId = r.RoleId
GROUP BY r.RoleName
ORDER BY r.RoleName;
GO
