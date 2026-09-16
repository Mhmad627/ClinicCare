# ClinicCare

A clinic appointment booking system built as a co-op training project. ASP.NET Web Forms
front end backed by a SQL Server database, covering patient/doctor/appointment management,
role-based security, membership & authentication, email notifications, and data export.

## Structure

```
projects/ClinicCare/   ASP.NET Web Forms application (.NET Framework 4.8)
db/                     SQL Server schema, seed data, stored procedures, and ERD
```

## Features

- Patient self-registration and appointment booking, with doctor/specialty browsing
- Admin dashboard for managing doctors, patients, and appointments
- Role-based access control (Admin / Doctor / Patient) via ASP.NET Membership & Roles
- Double-booking prevention enforced at both the application and database level
- Appointment audit trail (trigger-based, survives deletion of the appointment)
- Email confirmations (SMTP) and PDF/Excel export of appointment data
- Database backup/restore scripts and an in-app admin backup page

## Tech stack

- ASP.NET Web Forms, C#, .NET Framework 4.8
- SQL Server (T-SQL: tables, stored procedures, triggers, indexes)
- iTextSharp (PDF export), EPPlus (Excel export), BouncyCastle

## Database

See [`db/ERD.md`](db/ERD.md) for the full entity-relationship diagram and schema notes.
Core tables: `tblSpecialties`, `tblDoctors`, `tblPatients`, `tblAppointments`,
`tblAppointmentAudit`. Set up a local database by running the numbered scripts in
`db/` in order (`01_CreateDatabase.sql` through `05_MembershipEvidence.sql`).

## Running locally

Requirements: Visual Studio (or Build Tools) with the ASP.NET workload, IIS Express, and
SQL Server Express.

1. Run the scripts in `db/` against your SQL Server instance to create the database.
2. Update the connection string in `projects/ClinicCare/ClinicCare/Web.config`.
3. Run `projects/ClinicCare/run-local.cmd`, or open `ClinicCare.sln` in Visual Studio and
   press F5.

> Note: credentials in the config files and seed scripts are placeholders
> (`__REDACTED__`) — set your own before running.
