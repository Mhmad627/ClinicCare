using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ClinicCare.DataAccess
{
    /// <summary>
    /// Thin ADO.NET wrapper. Every call in the application goes through a stored
    /// procedure with typed parameters - no SQL string concatenation anywhere,
    /// which also removes any SQL-injection surface.
    /// </summary>
    public static class DbHelper
    {
        /// <summary>Connection string from Web.config.</summary>
        public static string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ClinicDBConnection"].ConnectionString; }
        }

        private static SqlCommand BuildCommand(SqlConnection cn, string procedureName, params SqlParameter[] parameters)
        {
            SqlCommand cmd = new SqlCommand(procedureName, cn);
            cmd.CommandType = CommandType.StoredProcedure;

            if (parameters != null)
            {
                foreach (SqlParameter p in parameters)
                {
                    if (p == null) continue;

                    // ADO.NET sends CLR null as "no value"; DBNull is what SQL Server expects.
                    if (p.Value == null) p.Value = DBNull.Value;
                    cmd.Parameters.Add(p);
                }
            }

            return cmd;
        }

        /// <summary>Runs a SELECT stored procedure and returns the result set.</summary>
        public static DataTable ExecuteDataTable(string procedureName, params SqlParameter[] parameters)
        {
            DataTable table = new DataTable();

            using (SqlConnection cn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = BuildCommand(cn, procedureName, parameters))
            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
            {
                adapter.Fill(table);
            }

            return table;
        }

        /// <summary>Runs an INSERT / UPDATE / DELETE stored procedure. Returns rows affected.</summary>
        public static int ExecuteNonQuery(string procedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection cn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = BuildCommand(cn, procedureName, parameters))
            {
                cn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>Runs a stored procedure and returns the first column of the first row.</summary>
        public static object ExecuteScalar(string procedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection cn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = BuildCommand(cn, procedureName, parameters))
            {
                cn.Open();
                return cmd.ExecuteScalar();
            }
        }

        // -------------------------------------------------------------------
        // Small conversion helpers - DataRow columns arrive as object/DBNull.
        // -------------------------------------------------------------------

        public static string GetString(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value) return string.Empty;
            return Convert.ToString(row[column]);
        }

        public static int GetInt(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value) return 0;
            return Convert.ToInt32(row[column]);
        }

        public static bool GetBool(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value) return false;
            return Convert.ToBoolean(row[column]);
        }

        public static DateTime GetDateTime(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value) return DateTime.MinValue;
            return Convert.ToDateTime(row[column]);
        }

        public static DateTime? GetNullableDateTime(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value) return null;
            return Convert.ToDateTime(row[column]);
        }

        /// <summary>Builds a parameter, converting empty strings and nulls to DBNull.</summary>
        public static SqlParameter Param(string name, SqlDbType type, object value)
        {
            SqlParameter p = new SqlParameter(name, type);

            string s = value as string;
            if (value == null || (s != null && s.Trim().Length == 0))
                p.Value = DBNull.Value;
            else
                p.Value = value;

            return p;
        }
    }
}
