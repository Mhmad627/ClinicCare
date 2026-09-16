namespace ClinicCare.Models
{
    /// <summary>Maps to dbo.tblSpecialties.</summary>
    public class Specialty
    {
        public int SpecialtyID { get; set; }
        public string SpecialtyName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }
}
