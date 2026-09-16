using System;
using System.Data;
using System.Data.SqlClient;
using ClinicCare.Models;

namespace ClinicCare.DataAccess
{
    /// <summary>Full CRUD against dbo.tblDoctors via the usp_Doctor_* procedures.</summary>
    public static class DoctorRepository
    {
        public static DataTable GetAll(bool activeOnly = false)
        {
            return DbHelper.ExecuteDataTable("usp_Doctor_SelectAll",
                new SqlParameter("@ActiveOnly", SqlDbType.Bit) { Value = activeOnly });
        }

        /// <summary>Feeds the cascading DropDownList on BookAppointment.aspx.</summary>
        public static DataTable GetBySpecialty(int specialtyId)
        {
            return DbHelper.ExecuteDataTable("usp_Doctor_SelectBySpecialty",
                new SqlParameter("@SpecialtyID", SqlDbType.Int) { Value = specialtyId });
        }

        public static Doctor GetById(int doctorId)
        {
            DataTable table = DbHelper.ExecuteDataTable("usp_Doctor_SelectByID",
                new SqlParameter("@DoctorID", SqlDbType.Int) { Value = doctorId });

            if (table.Rows.Count == 0) return null;

            DataRow row = table.Rows[0];
            return new Doctor
            {
                DoctorID = DbHelper.GetInt(row, "DoctorID"),
                FullName = DbHelper.GetString(row, "FullName"),
                SpecialtyID = DbHelper.GetInt(row, "SpecialtyID"),
                SpecialtyName = DbHelper.GetString(row, "SpecialtyName"),
                Email = DbHelper.GetString(row, "Email"),
                Phone = DbHelper.GetString(row, "Phone"),
                Bio = DbHelper.GetString(row, "Bio"),
                PhotoUrl = DbHelper.GetString(row, "PhotoUrl"),
                IsActive = DbHelper.GetBool(row, "IsActive")
            };
        }

        public static int Insert(Doctor doctor)
        {
            SqlParameter newId = new SqlParameter("@NewDoctorID", SqlDbType.Int)
            {
                Direction = ParameterDirection.Output
            };

            using (SqlConnection cn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("usp_Doctor_Insert", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(DbHelper.Param("@FullName", SqlDbType.NVarChar, doctor.FullName));
                cmd.Parameters.Add(new SqlParameter("@SpecialtyID", SqlDbType.Int) { Value = doctor.SpecialtyID });
                cmd.Parameters.Add(DbHelper.Param("@Email", SqlDbType.NVarChar, doctor.Email));
                cmd.Parameters.Add(DbHelper.Param("@Phone", SqlDbType.NVarChar, doctor.Phone));
                cmd.Parameters.Add(DbHelper.Param("@Bio", SqlDbType.NVarChar, doctor.Bio));
                cmd.Parameters.Add(DbHelper.Param("@PhotoUrl", SqlDbType.NVarChar, doctor.PhotoUrl));
                cmd.Parameters.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = doctor.IsActive });
                cmd.Parameters.Add(newId);

                cn.Open();
                cmd.ExecuteNonQuery();
            }

            return newId.Value == DBNull.Value ? 0 : Convert.ToInt32(newId.Value);
        }

        public static int Update(Doctor doctor)
        {
            return DbHelper.ExecuteNonQuery("usp_Doctor_Update",
                new SqlParameter("@DoctorID", SqlDbType.Int) { Value = doctor.DoctorID },
                DbHelper.Param("@FullName", SqlDbType.NVarChar, doctor.FullName),
                new SqlParameter("@SpecialtyID", SqlDbType.Int) { Value = doctor.SpecialtyID },
                DbHelper.Param("@Email", SqlDbType.NVarChar, doctor.Email),
                DbHelper.Param("@Phone", SqlDbType.NVarChar, doctor.Phone),
                DbHelper.Param("@Bio", SqlDbType.NVarChar, doctor.Bio),
                DbHelper.Param("@PhotoUrl", SqlDbType.NVarChar, doctor.PhotoUrl),
                new SqlParameter("@IsActive", SqlDbType.Bit) { Value = doctor.IsActive });
        }

        public static int Delete(int doctorId)
        {
            return DbHelper.ExecuteNonQuery("usp_Doctor_Delete",
                new SqlParameter("@DoctorID", SqlDbType.Int) { Value = doctorId });
        }
    }
}
