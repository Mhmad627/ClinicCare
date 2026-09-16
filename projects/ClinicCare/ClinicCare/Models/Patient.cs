using System;

namespace ClinicCare.Models
{
    /// <summary>Maps to dbo.tblPatients.</summary>
    public class Patient
    {
        public int PatientID { get; set; }
        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string NationalID { get; set; }
        public string Notes { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
