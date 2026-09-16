using System.Collections.Generic;
using System.Data;
using ClinicCare.Models;

namespace ClinicCare.DataAccess
{
    /// <summary>Read access to dbo.tblSpecialties via usp_Specialty_SelectAll.</summary>
    public static class SpecialtyRepository
    {
        public static DataTable GetAllTable()
        {
            return DbHelper.ExecuteDataTable("usp_Specialty_SelectAll");
        }

        public static List<Specialty> GetAll()
        {
            List<Specialty> list = new List<Specialty>();

            foreach (DataRow row in GetAllTable().Rows)
            {
                list.Add(new Specialty
                {
                    SpecialtyID = DbHelper.GetInt(row, "SpecialtyID"),
                    SpecialtyName = DbHelper.GetString(row, "SpecialtyName"),
                    Description = DbHelper.GetString(row, "Description"),
                    IsActive = DbHelper.GetBool(row, "IsActive")
                });
            }

            return list;
        }
    }
}
