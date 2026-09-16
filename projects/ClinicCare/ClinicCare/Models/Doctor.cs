namespace ClinicCare.Models
{
    /// <summary>Maps to dbo.tblDoctors (joined to tblSpecialties for the name).</summary>
    public class Doctor
    {
        public int DoctorID { get; set; }
        public string FullName { get; set; }
        public int SpecialtyID { get; set; }
        public string SpecialtyName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Bio { get; set; }
        public string PhotoUrl { get; set; }
        public bool IsActive { get; set; }
    }
}
