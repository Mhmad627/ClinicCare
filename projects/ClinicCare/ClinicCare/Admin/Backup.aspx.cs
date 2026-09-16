using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using ClinicCare.DataAccess;

namespace ClinicCare.Admin
{
    public partial class Backup : Page
    {
        /// <summary>Row shape for the backup file GridView.</summary>
        public class BackupFile
        {
            public string FileName { get; set; }
            public double SizeMb { get; set; }
            public DateTime Created { get; set; }
        }

        private static string BackupFolder
        {
            get
            {
                string folder = ConfigurationManager.AppSettings["BackupFolder"];
                return string.IsNullOrEmpty(folder) ? string.Empty : folder.Trim();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // On shared hosting the database runs on a separate server, so no
                // BackupFolder is configured and this page cannot write to or list
                // one. That is expected, not a misconfiguration - explain it rather
                // than showing an error.
                if (BackupFolder.Length == 0)
                {
                    ShowHostedNotice();
                    return;
                }

                txtBackupFolder.Text = BackupFolder;
                BindBackupList();
            }
        }

        // -------------------------------------------------------------------
        // Backup Now
        // -------------------------------------------------------------------

        /// <summary>
        /// Shown when no BackupFolder is configured, which is the normal state on
        /// shared hosting where the database lives on a different machine.
        /// </summary>
        private void ShowHostedNotice()
        {
            ShowMessage("alert alert-info",
                "<strong>On this server, backups are taken from the hosting control panel.</strong><br />" +
                "The database runs on a separate machine from the web application, so this page " +
                "cannot write a backup file to it or list one. Where the database and the web " +
                "application share a machine, the button below performs the backup directly.");

            txtBackupFolder.Text = "Not applicable - the database is hosted on a separate server";
            btnBackupNow.Enabled = false;
            btnRefresh.Enabled = false;
            gvBackups.EmptyDataText =
                "Backup files are stored on the database server and are managed from the hosting control panel.";
            gvBackups.DataSource = null;
            gvBackups.DataBind();
        }

        protected void btnBackupNow_Click(object sender, EventArgs e)
        {
            if (BackupFolder.Length == 0)
            {
                ShowHostedNotice();
                return;
            }

            try
            {
                string path = RunBackup();

                string sizeNote = string.Empty;
                if (File.Exists(path))
                {
                    double mb = new FileInfo(path).Length / 1024d / 1024d;
                    sizeNote = string.Format(" ({0:N2} MB)", mb);
                }

                ShowMessage("alert alert-success",
                    "Backup completed: <code>" + Server.HtmlEncode(path) + "</code>" + sizeNote + ".");
            }
            catch (SqlException ex)
            {
                // Operating system error 5 means the SQL Server service account
                // cannot write to the folder - the usual cause on a new machine.
                string message = ex.Message.IndexOf("Operating system error 5", StringComparison.OrdinalIgnoreCase) >= 0
                    ? "The SQL Server service account cannot write to the backup folder. " +
                      "Grant it modify permission on <code>" + Server.HtmlEncode(BackupFolder) + "</code>."
                    : Server.HtmlEncode(ex.Message);

                ShowMessage("alert alert-danger", message);
            }
            catch (Exception ex)
            {
                ShowMessage("alert alert-danger", Server.HtmlEncode(ex.Message));
            }

            BindBackupList();
        }

        /// <summary>
        /// Calls usp_Database_Backup and returns the path the server wrote to.
        /// A backup can take longer than the default 30-second command timeout,
        /// so the timeout is raised for this call.
        /// </summary>
        private string RunBackup()
        {
            SqlParameter pathOut = new SqlParameter("@BackupPath", SqlDbType.NVarChar, 500)
            {
                Direction = ParameterDirection.Output
            };

            using (SqlConnection cn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("usp_Database_Backup", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 300;
                cmd.Parameters.Add(DbHelper.Param("@BackupFolder", SqlDbType.NVarChar, BackupFolder));
                cmd.Parameters.Add(pathOut);

                cn.Open();
                cmd.ExecuteNonQuery();
            }

            return pathOut.Value == DBNull.Value ? string.Empty : Convert.ToString(pathOut.Value);
        }

        // -------------------------------------------------------------------
        // Existing files
        // -------------------------------------------------------------------

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindBackupList();
        }

        private void BindBackupList()
        {
            List<BackupFile> files = new List<BackupFile>();

            try
            {
                if (BackupFolder.Length > 0 && Directory.Exists(BackupFolder))
                {
                    foreach (string path in Directory.GetFiles(BackupFolder, "*.bak"))
                    {
                        FileInfo info = new FileInfo(path);
                        files.Add(new BackupFile
                        {
                            FileName = info.Name,
                            SizeMb = info.Length / 1024d / 1024d,
                            Created = info.LastWriteTime
                        });
                    }

                    files.Sort(delegate (BackupFile a, BackupFile b)
                    {
                        return b.Created.CompareTo(a.Created);
                    });
                }
            }
            catch (Exception ex)
            {
                // On shared hosting the database server and the web server are
                // usually different machines, so the web application often
                // cannot see the folder SQL Server wrote to.
                ShowMessage("alert alert-warning",
                    "Backups may still be running correctly, but this server cannot list the folder: " +
                    Server.HtmlEncode(ex.Message));
            }

            gvBackups.DataSource = files;
            gvBackups.DataBind();
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
