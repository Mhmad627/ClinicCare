# ClinicCare — Naming Convention Audit (rubric ID 9)

Audit performed in Week 7 across the whole solution: database objects, server
control IDs, and C# code. Result: **no violations in code we own.** The one set of
non-conforming names is imposed by the ASP.NET framework and is documented below.

---

## 1. Database objects

Verified by query against `ClinicDB` (see the audit query at the end).

| Object type | Convention | Example | Violations |
|---|---|---|---|
| Tables | `tbl` + plural entity | `tblAppointments` | **0** |
| Columns | PascalCase; keys carry the entity prefix | `AppointmentID`, `FullName` | **0** |
| Stored procedures | `usp_<Entity>_<Action>` | `usp_Patient_Insert` | **0** |
| Triggers | `trg_<Table>_<Event>` | `trg_tblAppointments_Insert` | **0** |
| Primary keys | `PK_<Table>` | `PK_tblPatients` | **0** |
| Foreign keys | `FK_<Child>_<Parent>` | `FK_tblAppointments_tblDoctors` | **0** |
| Unique constraints | `UQ_<Table>_<Columns>` | `UQ_tblAppointments_DoctorSlot` | **0** |
| Check constraints | `CK_<Table>_<Column>` | `CK_tblPatients_Gender` | **0** |
| Defaults | `DF_<Table>_<Column>` | `DF_tblAppointments_Status` | **0** |
| Non-clustered indexes | `IX_<Table>_<Columns>` | `IX_tblAppointments_AppointmentDate` | **0** |

**Excluded from the audit** (not ours to rename):

- `aspnet_*` — 11 tables and their stored procedures, created by `aspnet_regsql.exe`
- `sysdiagrams` and `sp_*diagram*` — created by SSMS when the database diagram was saved

---

## 2. Server control IDs

| Control type | Prefix | Examples |
|---|---|---|
| Button | `btn` | `btnBook`, `btnSave`, `btnExportExcel` |
| TextBox | `txt` | `txtFullName`, `txtAppointmentDate` |
| DropDownList | `ddl` | `ddlSpecialty`, `ddlDoctor` |
| GridView | `gv` | `gvPatients`, `gvAppointments` |
| Repeater | `rpt` | `rptDoctors` |
| CheckBoxList | `cbl` | `cblTimeSlots`, `cblSymptoms` |
| RadioButtonList | `rbl` | `rblGender`, `rblVisitType` |
| CheckBox | `chk` | `chkIsActive` |
| Literal | `lit` | `litMessage`, `litSumDoctor` |
| Panel | `pnl` | `pnlSummary`, `pnlMessage` |
| PlaceHolder | `ph` | `phAdminMenu`, `phAuthenticated` |
| HiddenField | `hf` | `hfPatientID`, `hfDoctorID` |
| LinkButton | `lnk` | `lnkEdit`, `lnkDelete` |
| RequiredFieldValidator | `rfv` | `rfvFullName`, `rfvPhone` |
| RegularExpressionValidator | `rev` | `revEmail`, `revPhone` |
| RangeValidator | `rv` | `rvDate` |
| CompareValidator / CustomValidator | `cv` | `cvPassword`, `cvTimeSlot` |
| ValidationSummary | `vs` | `vsBooking`, `vsPatient` |
| Content / ContentPlaceHolder | `cph` | `cphMain`, `cphHead` |
| Composite login controls | `ctl` | `ctlLogin`, `ctlCreateUser` |

### Documented exception — framework-mandated IDs

Inside the `<asp:Login>` and `<asp:CreateUserWizard>` templates these child
controls **must** keep their exact framework names:

```
UserName   Password   ConfirmPassword   Email   RememberMe
LoginButton   FailureText
```

The `Login` and `CreateUserWizard` controls find their children by these literal
IDs. Renaming `UserName` to `txtUserName` does not cause a compile error — the
page still builds, and the control simply stops working at runtime, because the
login control can no longer locate the field. They are therefore left as-is by
design, not by oversight.

---

## 3. C# code

| Element | Convention | Example |
|---|---|---|
| Classes | PascalCase | `AppointmentRepository`, `EmailHelper` |
| Public methods / properties | PascalCase | `SendAppointmentConfirmation`, `ConnectionString` |
| Private methods | PascalCase | `BindGrid`, `ValidateForm` |
| Local variables & parameters | camelCase | `appointmentId`, `specialtyId`, `toEmail` |
| Event handlers | `<control>_<Event>` | `btnBook_Click`, `gvPatients_Sorting` |
| Namespaces | `ClinicCare.<Area>` | `ClinicCare.DataAccess`, `ClinicCare.Services` |
| Constants | PascalCase | `AdminRole`, `PatientRole` |

---

## 4. Audit query

Re-runnable check — anything it returns is a violation:

```sql
USE ClinicDB;

SELECT 'table' AS Kind, name FROM sys.tables
WHERE name NOT LIKE 'tbl%' AND name NOT LIKE 'aspnet[_]%' AND name <> 'sysdiagrams'
UNION ALL
SELECT 'procedure', name FROM sys.procedures
WHERE name NOT LIKE 'usp[_]%' AND name NOT LIKE 'aspnet[_]%' AND name NOT LIKE 'sp[_]%diagram%'
UNION ALL
SELECT 'trigger', name FROM sys.triggers
WHERE is_ms_shipped = 0 AND name NOT LIKE 'trg[_]%'
UNION ALL
SELECT 'index', i.name FROM sys.indexes i
    JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.name IS NOT NULL AND t.name LIKE 'tbl%'
  AND i.name NOT LIKE 'IX[_]%' AND i.name NOT LIKE 'PK[_]%' AND i.name NOT LIKE 'UQ[_]%'
UNION ALL
SELECT 'constraint', name FROM sys.objects
WHERE type IN ('F','C','D') AND OBJECT_NAME(parent_object_id) LIKE 'tbl%'
  AND name NOT LIKE 'FK[_]%' AND name NOT LIKE 'CK[_]%' AND name NOT LIKE 'DF[_]%';
```

Last run: Week 7 — **0 rows returned.**
