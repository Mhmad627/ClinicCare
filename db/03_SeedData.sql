/*
================================================================================
  ClinicCare
  Script:  03_SeedData.sql
  Purpose: Populate the database with realistic sample data for development
           and for the demo required by the rubric.
           5 specialties, 8 doctors, 12 patients, 18 appointments.
  Note:    Appointment dates are generated relative to GETDATE() so the demo
           always shows past, today's and upcoming appointments.
================================================================================
*/

USE ClinicDB;
GO

SET NOCOUNT ON;

/* Clear existing rows (children first) and reset identity seeds. */
DELETE FROM dbo.tblAppointmentAudit;
DELETE FROM dbo.tblAppointments;
DELETE FROM dbo.tblPatients;
DELETE FROM dbo.tblDoctors;
DELETE FROM dbo.tblSpecialties;
GO

/* IMPORTANT - DBCC CHECKIDENT ... RESEED behaves in two different ways:
     * table that has NEVER held a row  -> next row uses the reseed value itself
     * table that HAS held rows         -> next row uses reseed value + increment
   So a blanket "RESEED, 0" gives IDs starting at 0 on a freshly created table,
   and a blanket "RESEED, 1" gives IDs starting at 2 on a re-run. Testing
   last_value tells the two cases apart: it is NULL only when no row has ever
   been inserted, and in that case the identity already starts at 1 on its own. */
IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.tblSpecialties')) IS NOT NULL
    DBCC CHECKIDENT ('dbo.tblSpecialties',  RESEED, 0) WITH NO_INFOMSGS;

IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.tblDoctors')) IS NOT NULL
    DBCC CHECKIDENT ('dbo.tblDoctors',      RESEED, 0) WITH NO_INFOMSGS;

IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.tblPatients')) IS NOT NULL
    DBCC CHECKIDENT ('dbo.tblPatients',     RESEED, 0) WITH NO_INFOMSGS;

IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.tblAppointments')) IS NOT NULL
    DBCC CHECKIDENT ('dbo.tblAppointments', RESEED, 0) WITH NO_INFOMSGS;
GO

/* ---------------------------------------------------------------------------
   Specialties
   --------------------------------------------------------------------------- */
INSERT INTO dbo.tblSpecialties (SpecialtyName, Description) VALUES
    (N'Cardiology',   N'Diagnosis and treatment of heart and vascular conditions.'),
    (N'Dermatology',  N'Skin, hair and nail conditions.'),
    (N'Pediatrics',   N'Medical care for infants, children and adolescents.'),
    (N'Orthopedics',  N'Bones, joints, ligaments and musculoskeletal injuries.'),
    (N'Neurology',    N'Disorders of the brain, spine and nervous system.'),
    (N'Dentistry',    N'Oral health, dental treatment and surgery.');
GO

/* ---------------------------------------------------------------------------
   Doctors
   --------------------------------------------------------------------------- */
INSERT INTO dbo.tblDoctors (FullName, SpecialtyID, Email, Phone, Bio, PhotoUrl, IsActive)
SELECT d.FullName, s.SpecialtyID, d.Email, d.Phone, d.Bio, d.PhotoUrl, d.IsActive
FROM (VALUES
    (N'Dr. Ahmed Al-Otaibi',  N'Cardiology',  N'a.alotaibi@cliniccare.sa',  N'0551000101',
     N'Consultant cardiologist with 15 years of experience in interventional cardiology and preventive heart care.',
     N'~/Assets/img/doctors/doc1.jpg', 1),
    (N'Dr. Sara Al-Harbi',    N'Dermatology', N's.alharbi@cliniccare.sa',   N'0551000102',
     N'Specialist dermatologist focusing on medical dermatology, acne management and laser therapy.',
     N'~/Assets/img/doctors/doc2.jpg', 1),
    (N'Dr. Khalid Al-Zahrani',N'Pediatrics',  N'k.alzahrani@cliniccare.sa', N'0551000103',
     N'Consultant paediatrician with a special interest in childhood asthma and newborn care.',
     N'~/Assets/img/doctors/doc3.jpg', 1),
    (N'Dr. Noura Al-Qahtani', N'Pediatrics',  N'n.alqahtani@cliniccare.sa', N'0551000104',
     N'Paediatric specialist covering routine vaccinations, growth monitoring and general child health.',
     N'~/Assets/img/doctors/doc4.jpg', 1),
    (N'Dr. Faisal Al-Dossari',N'Orthopedics', N'f.aldossari@cliniccare.sa', N'0551000105',
     N'Orthopaedic surgeon specialising in sports injuries, knee arthroscopy and joint replacement.',
     N'~/Assets/img/doctors/doc5.jpg', 1),
    (N'Dr. Mona Al-Shehri',   N'Neurology',   N'm.alshehri@cliniccare.sa',  N'0551000106',
     N'Consultant neurologist treating migraine, epilepsy and peripheral nerve disorders.',
     N'~/Assets/img/doctors/doc6.jpg', 1),
    (N'Dr. Omar Al-Ghamdi',   N'Cardiology',  N'o.alghamdi@cliniccare.sa',  N'0551000107',
     N'Cardiologist with expertise in echocardiography and hypertension management.',
     N'~/Assets/img/doctors/doc7.jpg', 1),
    (N'Dr. Layla Al-Mutairi', N'Dentistry',   N'l.almutairi@cliniccare.sa', N'0551000108',
     N'Dental surgeon providing restorative dentistry, root canal treatment and cosmetic procedures.',
     N'~/Assets/img/doctors/doc8.jpg', 1),
    (N'Dr. Yousef Al-Anazi',  N'Orthopedics', N'y.alanazi@cliniccare.sa',   N'0551000109',
     N'Orthopaedic consultant focusing on spine and lower back conditions.',
     N'~/Assets/img/doctors/doc9.jpg', 0)
) AS d (FullName, SpecialtyName, Email, Phone, Bio, PhotoUrl, IsActive)
INNER JOIN dbo.tblSpecialties s ON s.SpecialtyName = d.SpecialtyName;
GO

/* ---------------------------------------------------------------------------
   Patients
   --------------------------------------------------------------------------- */
INSERT INTO dbo.tblPatients (FullName, Gender, DateOfBirth, Phone, Email, NationalID, Notes) VALUES
    (N'Abdullah Al-Salem',  N'Male',   '1985-03-14', N'0501234501', N'abdullah.salem@example.com',  N'1012345601', N'Known hypertension, on medication.'),
    (N'Fatimah Al-Nasser',  N'Female', '1992-07-02', N'0501234502', N'fatimah.nasser@example.com',  N'1012345602', NULL),
    (N'Mohammed Al-Rashed', N'Male',   '1978-11-25', N'0501234503', N'm.rashed@example.com',        N'1012345603', N'Type 2 diabetes.'),
    (N'Hessa Al-Turki',     N'Female', '2001-01-19', N'0501234504', N'hessa.turki@example.com',     N'1012345604', NULL),
    (N'Saud Al-Faraj',      N'Male',   '1996-05-30', N'0501234505', N'saud.faraj@example.com',      N'1012345605', N'Allergic to penicillin.'),
    (N'Reem Al-Subaie',     N'Female', '1989-09-08', N'0501234506', N'reem.subaie@example.com',     N'1012345606', NULL),
    (N'Turki Al-Hamad',     N'Male',   '2015-02-11', N'0501234507', N'parent.hamad@example.com',    N'1012345607', N'Paediatric patient, accompanied by guardian.'),
    (N'Aisha Al-Marri',     N'Female', '1973-12-04', N'0501234508', N'aisha.marri@example.com',     N'1012345608', N'Previous knee surgery 2019.'),
    (N'Nasser Al-Juhani',   N'Male',   '1999-06-21', N'0501234509', N'nasser.juhani@example.com',   N'1012345609', NULL),
    (N'Maha Al-Buraidi',    N'Female', '1994-04-17', N'0501234510', N'maha.buraidi@example.com',    N'1012345610', NULL),
    (N'Ibrahim Al-Sudairy', N'Male',   '1968-08-09', N'0501234511', N'ibrahim.s@example.com',       N'1012345611', N'Regular cardiology follow-up.'),
    (N'Lama Al-Khalifa',    N'Female', '2018-10-27', N'0501234512', N'parent.khalifa@example.com',  N'1012345612', N'Paediatric patient, routine vaccinations.');
GO

/* ---------------------------------------------------------------------------
   Appointments
   Dates are offsets from today so the seed never goes stale.
   --------------------------------------------------------------------------- */
DECLARE @Today DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.tblAppointments
    (PatientID, DoctorID, AppointmentDate, TimeSlot, VisitType, Symptoms, Status)
SELECT
    p.PatientID,
    d.DoctorID,
    DATEADD(DAY, a.DayOffset, @Today),
    a.TimeSlot,
    a.VisitType,
    a.Symptoms,
    a.Status
FROM (VALUES
    (N'1012345601', N'Dr. Ahmed Al-Otaibi',   -21, N'09:00 AM', N'New',       N'Chest tightness during exertion.',        N'Completed'),
    (N'1012345601', N'Dr. Ahmed Al-Otaibi',    -7, N'09:30 AM', N'Follow-up', N'Review of ECG results.',                  N'Completed'),
    (N'1012345602', N'Dr. Sara Al-Harbi',     -14, N'11:00 AM', N'New',       N'Persistent facial acne.',                 N'Completed'),
    (N'1012345603', N'Dr. Omar Al-Ghamdi',    -10, N'10:00 AM', N'New',       N'High blood pressure readings at home.',   N'Completed'),
    (N'1012345604', N'Dr. Mona Al-Shehri',     -5, N'01:00 PM', N'New',       N'Recurring migraine, 3 times per week.',   N'Completed'),
    (N'1012345605', N'Dr. Faisal Al-Dossari',  -3, N'02:00 PM', N'New',       N'Right knee pain after football injury.',  N'Cancelled'),
    (N'1012345606', N'Dr. Layla Al-Mutairi',   -2, N'03:00 PM', N'New',       N'Toothache in lower left molar.',          N'Completed'),
    (N'1012345607', N'Dr. Khalid Al-Zahrani',   0, N'09:00 AM', N'New',       N'Cough and mild fever for three days.',    N'Confirmed'),
    (N'1012345612', N'Dr. Noura Al-Qahtani',    0, N'10:00 AM', N'Follow-up', N'Routine vaccination schedule.',           N'Confirmed'),
    (N'1012345608', N'Dr. Faisal Al-Dossari',   0, N'11:00 AM', N'Follow-up', N'Post-operative knee review.',             N'Confirmed'),
    (N'1012345611', N'Dr. Ahmed Al-Otaibi',     0, N'01:00 PM', N'Follow-up', N'Quarterly cardiology check-up.',          N'Pending'),
    (N'1012345609', N'Dr. Layla Al-Mutairi',    1, N'09:30 AM', N'New',       N'Dental cleaning and check-up.',           N'Confirmed'),
    (N'1012345610', N'Dr. Sara Al-Harbi',       2, N'11:30 AM', N'New',       N'Skin rash on both forearms.',             N'Pending'),
    (N'1012345602', N'Dr. Mona Al-Shehri',      3, N'10:30 AM', N'New',       N'Numbness in left hand.',                  N'Pending'),
    (N'1012345605', N'Dr. Faisal Al-Dossari',   4, N'02:30 PM', N'Follow-up', N'Re-assessment of knee injury.',           N'Confirmed'),
    (N'1012345603', N'Dr. Omar Al-Ghamdi',      5, N'09:00 AM', N'Follow-up', N'Blood pressure medication review.',       N'Pending'),
    (N'1012345607', N'Dr. Khalid Al-Zahrani',   7, N'12:00 PM', N'Follow-up', N'Asthma inhaler technique review.',        N'Pending'),
    (N'1012345604', N'Dr. Sara Al-Harbi',      10, N'03:30 PM', N'New',       N'Hair loss consultation.',                 N'Pending')
) AS a (NationalID, DoctorName, DayOffset, TimeSlot, VisitType, Symptoms, Status)
INNER JOIN dbo.tblPatients p ON p.NationalID = a.NationalID
INNER JOIN dbo.tblDoctors  d ON d.FullName   = a.DoctorName;
GO

/* ---------------------------------------------------------------------------
   Verification
   --------------------------------------------------------------------------- */
SELECT 'tblSpecialties'  AS TableName, COUNT(*) AS RowCount_ FROM dbo.tblSpecialties
UNION ALL SELECT 'tblDoctors',      COUNT(*) FROM dbo.tblDoctors
UNION ALL SELECT 'tblPatients',     COUNT(*) FROM dbo.tblPatients
UNION ALL SELECT 'tblAppointments', COUNT(*) FROM dbo.tblAppointments;
GO

PRINT '03_SeedData.sql completed successfully.';
GO
