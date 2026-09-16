using System;

namespace ClinicCare.Models
{
    /// <summary>Maps to dbo.tblAppointments (joined to patient / doctor names).</summary>
    public class Appointment
    {
        public int AppointmentID { get; set; }

        public int PatientID { get; set; }
        public string PatientName { get; set; }
        public string PatientPhone { get; set; }
        public string PatientEmail { get; set; }

        public int DoctorID { get; set; }
        public string DoctorName { get; set; }
        public string SpecialtyName { get; set; }

        public DateTime AppointmentDate { get; set; }
        public string TimeSlot { get; set; }
        public string VisitType { get; set; }
        public string Symptoms { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
