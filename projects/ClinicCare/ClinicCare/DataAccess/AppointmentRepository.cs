using System;
using System.Data;
using System.Data.SqlClient;
using ClinicCare.Models;

namespace ClinicCare.DataAccess
{
    /// <summary>Full CRUD against dbo.tblAppointments via the usp_Appointment_* procedures.</summary>
    public static class AppointmentRepository
    {
        public static DataTable GetAll(string status = null)
        {
            return DbHelper.ExecuteDataTable("usp_Appointment_SelectAll",
                DbHelper.Param("@Status", SqlDbType.NVarChar, status));
        }

        public static DataTable GetToday()
        {
            return DbHelper.ExecuteDataTable("usp_Appointment_SelectToday");
        }

        /// <summary>MyAppointments.aspx - look up by phone number or National ID.</summary>
        public static DataTable GetByPatientLookup(string lookup)
        {
            return DbHelper.ExecuteDataTable("usp_Appointment_SelectByPatientLookup",
                DbHelper.Param("@Lookup", SqlDbType.NVarChar, lookup));
        }

        public static Appointment GetById(int appointmentId)
        {
            DataTable table = DbHelper.ExecuteDataTable("usp_Appointment_SelectByID",
                new SqlParameter("@AppointmentID", SqlDbType.Int) { Value = appointmentId });

            if (table.Rows.Count == 0) return null;

            DataRow row = table.Rows[0];
            return new Appointment
            {
                AppointmentID = DbHelper.GetInt(row, "AppointmentID"),
                PatientID = DbHelper.GetInt(row, "PatientID"),
                PatientName = DbHelper.GetString(row, "PatientName"),
                PatientPhone = DbHelper.GetString(row, "PatientPhone"),
                PatientEmail = DbHelper.GetString(row, "PatientEmail"),
                DoctorID = DbHelper.GetInt(row, "DoctorID"),
                DoctorName = DbHelper.GetString(row, "DoctorName"),
                SpecialtyName = DbHelper.GetString(row, "SpecialtyName"),
                AppointmentDate = DbHelper.GetDateTime(row, "AppointmentDate"),
                TimeSlot = DbHelper.GetString(row, "TimeSlot"),
                VisitType = DbHelper.GetString(row, "VisitType"),
                Symptoms = DbHelper.GetString(row, "Symptoms"),
                Status = DbHelper.GetString(row, "Status"),
                CreatedAt = DbHelper.GetDateTime(row, "CreatedAt")
            };
        }

        /// <summary>
        /// Inserts an appointment and returns the new AppointmentID.
        /// The stored procedure raises an error if the doctor's slot is taken;
        /// callers should catch SqlException and show the message to the user.
        /// </summary>
        public static int Insert(Appointment appointment)
        {
            SqlParameter newId = new SqlParameter("@NewAppointmentID", SqlDbType.Int)
            {
                Direction = ParameterDirection.Output
            };

            using (SqlConnection cn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("usp_Appointment_Insert", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@PatientID", SqlDbType.Int) { Value = appointment.PatientID });
                cmd.Parameters.Add(new SqlParameter("@DoctorID", SqlDbType.Int) { Value = appointment.DoctorID });
                cmd.Parameters.Add(new SqlParameter("@AppointmentDate", SqlDbType.Date) { Value = appointment.AppointmentDate });
                cmd.Parameters.Add(DbHelper.Param("@TimeSlot", SqlDbType.NVarChar, appointment.TimeSlot));
                cmd.Parameters.Add(DbHelper.Param("@VisitType", SqlDbType.NVarChar, appointment.VisitType));
                cmd.Parameters.Add(DbHelper.Param("@Symptoms", SqlDbType.NVarChar, appointment.Symptoms));
                cmd.Parameters.Add(DbHelper.Param("@Status", SqlDbType.NVarChar, appointment.Status));
                cmd.Parameters.Add(newId);

                cn.Open();
                cmd.ExecuteNonQuery();
            }

            return newId.Value == DBNull.Value ? 0 : Convert.ToInt32(newId.Value);
        }

        public static int Update(Appointment appointment)
        {
            return DbHelper.ExecuteNonQuery("usp_Appointment_Update",
                new SqlParameter("@AppointmentID", SqlDbType.Int) { Value = appointment.AppointmentID },
                new SqlParameter("@AppointmentDate", SqlDbType.Date) { Value = appointment.AppointmentDate },
                DbHelper.Param("@TimeSlot", SqlDbType.NVarChar, appointment.TimeSlot),
                DbHelper.Param("@VisitType", SqlDbType.NVarChar, appointment.VisitType),
                DbHelper.Param("@Symptoms", SqlDbType.NVarChar, appointment.Symptoms),
                DbHelper.Param("@Status", SqlDbType.NVarChar, appointment.Status));
        }

        public static int UpdateStatus(int appointmentId, string status)
        {
            return DbHelper.ExecuteNonQuery("usp_Appointment_UpdateStatus",
                new SqlParameter("@AppointmentID", SqlDbType.Int) { Value = appointmentId },
                DbHelper.Param("@Status", SqlDbType.NVarChar, status));
        }

        public static int Delete(int appointmentId)
        {
            return DbHelper.ExecuteNonQuery("usp_Appointment_Delete",
                new SqlParameter("@AppointmentID", SqlDbType.Int) { Value = appointmentId });
        }

        /// <summary>Dashboard counters (single row of totals).</summary>
        public static DataRow GetDashboardStats()
        {
            DataTable table = DbHelper.ExecuteDataTable("usp_Dashboard_GetStats");
            return table.Rows.Count > 0 ? table.Rows[0] : null;
        }
    }
}
