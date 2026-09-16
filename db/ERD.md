# ClinicDB — Entity Relationship Diagram

Generated from the live `ClinicDB` schema on SQL Server Express (instance `.\SQLEXP2017`).

Picture versions of this diagram, in the same folder:

- **`ERD.png`** — 2240x1400, drop straight into the biweekly report or a slide
- `ERD.svg` — vector source; re-render or edit it (also imports into draw.io)

## Relationships

| Foreign key | Child table | Column | Parent table | Column | Cardinality |
|---|---|---|---|---|---|
| `FK_tblDoctors_tblSpecialties` | `tblDoctors` | `SpecialtyID` | `tblSpecialties` | `SpecialtyID` | one specialty → many doctors |
| `FK_tblAppointments_tblPatients` | `tblAppointments` | `PatientID` | `tblPatients` | `PatientID` | one patient → many appointments |
| `FK_tblAppointments_tblDoctors` | `tblAppointments` | `DoctorID` | `tblDoctors` | `DoctorID` | one doctor → many appointments |

`tblAppointmentAudit` is written to by the `trg_tblAppointments_Insert` trigger. It deliberately
has **no** foreign key to `tblAppointments` so that the audit history survives if an appointment
is later deleted.

## Diagram

```mermaid
erDiagram
    tblSpecialties ||--o{ tblDoctors : "has"
    tblPatients    ||--o{ tblAppointments : "books"
    tblDoctors     ||--o{ tblAppointments : "attends"
    tblAppointments ..o{ tblAppointmentAudit : "audited by trigger"

    tblSpecialties {
        int SpecialtyID PK
        nvarchar100 SpecialtyName UK
        nvarchar300 Description
        bit IsActive
    }

    tblDoctors {
        int DoctorID PK
        nvarchar150 FullName
        int SpecialtyID FK
        nvarchar150 Email
        nvarchar20 Phone
        nvarchar600 Bio
        nvarchar260 PhotoUrl
        bit IsActive
    }

    tblPatients {
        int PatientID PK
        nvarchar150 FullName
        nvarchar10 Gender
        date DateOfBirth
        nvarchar20 Phone
        nvarchar150 Email
        nvarchar20 NationalID UK
        nvarchar600 Notes
        datetime CreatedAt
    }

    tblAppointments {
        int AppointmentID PK
        int PatientID FK
        int DoctorID FK
        date AppointmentDate
        nvarchar20 TimeSlot
        nvarchar20 VisitType
        nvarchar600 Symptoms
        nvarchar20 Status
        datetime CreatedAt
    }

    tblAppointmentAudit {
        int AuditID PK
        int AppointmentID
        nvarchar20 Action
        nvarchar128 PerformedBy
        datetime PerformedAt
        nvarchar400 Details
    }
```

## Constraints worth noting

- `UQ_tblAppointments_DoctorSlot` — `UNIQUE (DoctorID, AppointmentDate, TimeSlot)` prevents a
  doctor from being double-booked. `usp_Appointment_Insert` checks the same rule first so the
  application can show a readable message instead of a constraint violation.
- `UQ_tblPatients_NationalID` — one patient record per National ID.
- `CK_tblPatients_Gender`, `CK_tblAppointments_Status`, `CK_tblAppointments_VisitType` — restrict
  those columns to the values the UI offers.
- `CK_tblPatients_Phone` — enforces the Saudi mobile format `05XXXXXXXX` at the database level.

## Indexes

| Index | Table | Columns |
|---|---|---|
| `IX_tblAppointments_AppointmentDate` | `tblAppointments` | `AppointmentDate DESC` include `PatientID, DoctorID, TimeSlot, Status` |
| `IX_tblPatients_Phone` | `tblPatients` | `Phone` include `FullName, Email` |
| `IX_tblDoctors_SpecialtyID` | `tblDoctors` | `SpecialtyID, IsActive` include `FullName` |
