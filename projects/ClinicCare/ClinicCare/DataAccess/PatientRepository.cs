using System;
using System.Data;
using System.Data.SqlClient;
using ClinicCare.Models;

namespace ClinicCare.DataAccess
{
    /// <summary>
    /// Full CRUD against dbo.tblPatients. Every operation calls a stored
    /// procedure (usp_Patient_Insert / _Update / _Delete / _SelectAll).
    /// </summary>
    public static class PatientRepository
    {
        public static DataTable GetAll(string search = null)
        {
            return DbHelper.ExecuteDataTable("usp_Patient_SelectAll",
                DbHelper.Param("@Search", SqlDbType.NVarChar, search));
        }

        public static Patient GetById(int patientId)
        {
            DataTable table = DbHelper.ExecuteDataTable("usp_Patient_SelectByID",
                new SqlParameter("@PatientID", SqlDbType.Int) { Value = patientId });

            if (table.Rows.Count == 0) return null;

            return MapRow(table.Rows[0]);
        }

        /// <summary>Inserts a patient and returns the new PatientID.</summary>
        public static int Insert(Patient patient)
        {
            SqlParameter newId = new SqlParameter("@NewPatientID", SqlDbType.Int)
            {
                Direction = ParameterDirection.Output
            };

            using (SqlConnection cn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("usp_Patient_Insert", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(DbHelper.Param("@FullName", SqlDbType.NVarChar, patient.FullName));
                cmd.Parameters.Add(DbHelper.Param("@Gender", SqlDbType.NVarChar, patient.Gender));
                cmd.Parameters.Add(DbHelper.Param("@DateOfBirth", SqlDbType.Date, patient.DateOfBirth));
                cmd.Parameters.Add(DbHelper.Param("@Phone", SqlDbType.NVarChar, patient.Phone));
                cmd.Parameters.Add(DbHelper.Param("@Email", SqlDbType.NVarChar, patient.Email));
                cmd.Parameters.Add(DbHelper.Param("@NationalID", SqlDbType.NVarChar, patient.NationalID));
                cmd.Parameters.Add(DbHelper.Param("@Notes", SqlDbType.NVarChar, patient.Notes));
                cmd.Parameters.Add(newId);

                cn.Open();
                cmd.ExecuteNonQuery();
            }

            return newId.Value == DBNull.Value ? 0 : Convert.ToInt32(newId.Value);
        }

        public static int Update(Patient patient)
        {
            return DbHelper.ExecuteNonQuery("usp_Patient_Update",
                new SqlParameter("@PatientID", SqlDbType.Int) { Value = patient.PatientID },
                DbHelper.Param("@FullName", SqlDbType.NVarChar, patient.FullName),
                DbHelper.Param("@Gender", SqlDbType.NVarChar, patient.Gender),
                DbHelper.Param("@DateOfBirth", SqlDbType.Date, patient.DateOfBirth),
                DbHelper.Param("@Phone", SqlDbType.NVarChar, patient.Phone),
                DbHelper.Param("@Email", SqlDbType.NVarChar, patient.Email),
                DbHelper.Param("@NationalID", SqlDbType.NVarChar, patient.NationalID),
                DbHelper.Param("@Notes", SqlDbType.NVarChar, patient.Notes));
        }

        public static int Delete(int patientId)
        {
            return DbHelper.ExecuteNonQuery("usp_Patient_Delete",
                new SqlParameter("@PatientID", SqlDbType.Int) { Value = patientId });
        }

        /// <summary>
        /// Used by the booking page: reuse the existing patient record when the
        /// phone number or National ID already exists, otherwise create one.
        /// </summary>
        public static int FindOrCreate(Patient patient)
        {
            string lookup = string.IsNullOrEmpty(patient.NationalID) ? patient.Phone : patient.NationalID;

            DataTable matches = GetAll(lookup);
            foreach (DataRow row in matches.Rows)
            {
                if (DbHelper.GetString(row, "Phone") == patient.Phone ||
                    (!string.IsNullOrEmpty(patient.NationalID) &&
                     DbHelper.GetString(row, "NationalID") == patient.NationalID))
                {
                    return DbHelper.GetInt(row, "PatientID");
                }
            }

            return Insert(patient);
        }

        private static Patient MapRow(DataRow row)
        {
            return new Patient
            {
                PatientID = DbHelper.GetInt(row, "PatientID"),
                FullName = DbHelper.GetString(row, "FullName"),
                Gender = DbHelper.GetString(row, "Gender"),
                DateOfBirth = DbHelper.GetNullableDateTime(row, "DateOfBirth"),
                Phone = DbHelper.GetString(row, "Phone"),
                Email = DbHelper.GetString(row, "Email"),
                NationalID = DbHelper.GetString(row, "NationalID"),
                Notes = DbHelper.GetString(row, "Notes"),
                CreatedAt = DbHelper.GetDateTime(row, "CreatedAt")
            };
        }
    }
}
