using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using ClinicCare.DataAccess;
using ClinicCare.Services;

namespace ClinicCare.Admin
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStats();
                LoadTodaysAppointments();
            }
        }

        private void LoadStats()
        {
            DataRow stats = AppointmentRepository.GetDashboardStats();
            if (stats == null) return;

            litTotalPatients.Text = DbHelper.GetInt(stats, "TotalPatients").ToString();
            litActiveDoctors.Text = DbHelper.GetInt(stats, "ActiveDoctors").ToString();
            litTotalAppointments.Text = DbHelper.GetInt(stats, "TotalAppointments").ToString();
            litTodaysAppointments.Text = DbHelper.GetInt(stats, "TodaysAppointments").ToString();
            litPending.Text = DbHelper.GetInt(stats, "PendingAppointments").ToString();
            litConfirmed.Text = DbHelper.GetInt(stats, "ConfirmedAppointments").ToString();
        }

        private void LoadTodaysAppointments()
        {
            gvToday.DataSource = AppointmentRepository.GetToday();
            gvToday.DataBind();

            litExportCount.Text = AppointmentRepository.GetAll().Rows.Count.ToString();
        }

        // -------------------------------------------------------------------
        // Export to Excel / Word / PDF (rubric ID 4)
        // -------------------------------------------------------------------

        private static string ClinicName
        {
            get { return ConfigurationManager.AppSettings["ClinicName"] ?? "ClinicCare"; }
        }

        private static string FileStamp
        {
            get { return DateTime.Now.ToString("yyyy-MM-dd"); }
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable data = AppointmentRepository.GetAll();
            byte[] bytes = ExportHelper.BuildExcel(data, ClinicName);

            SendFile(bytes,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "Appointments_" + FileStamp + ".xlsx");
        }

        protected void btnExportWord_Click(object sender, EventArgs e)
        {
            DataTable data = AppointmentRepository.GetAll();
            byte[] bytes = ExportHelper.BuildWord(data, ClinicName);

            SendFile(bytes,
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "Appointments_" + FileStamp + ".docx");
        }

        protected void btnExportPdf_Click(object sender, EventArgs e)
        {
            DataTable data = AppointmentRepository.GetAll();
            byte[] bytes = ExportHelper.BuildPdf(data, ClinicName);

            SendFile(bytes, "application/pdf", "Appointments_" + FileStamp + ".pdf");
        }

        /// <summary>
        /// Streams a generated file to the browser as a download.
        ///
        /// SuppressContent is essential here. CompleteRequest() only skips the
        /// remaining HTTP pipeline events - the page carries on through its own
        /// lifecycle and renders its HTML into the response, which arrives
        /// appended to the file. The result is a response whose real length far
        /// exceeds the Content-Length header: tools that honour Content-Length
        /// (curl, HttpWebRequest) read a perfectly valid file and see nothing
        /// wrong, while browsers save a corrupt one. Setting SuppressContent
        /// after the flush discards everything the page writes afterwards.
        /// </summary>
        private void SendFile(byte[] bytes, string contentType, string fileName)
        {
            Response.Clear();
            Response.ClearHeaders();
            Response.Buffer = true;
            Response.ContentType = contentType;
            Response.AddHeader("content-disposition", "attachment; filename=\"" + fileName + "\"");
            Response.AddHeader("content-length", bytes.Length.ToString());
            Response.BinaryWrite(bytes);
            Response.Flush();

            Response.SuppressContent = true;                  // discard the page HTML
            Context.ApplicationInstance.CompleteRequest();
        }

        /// <summary>Maps an appointment status to a Bootstrap badge class.</summary>
        protected string StatusBadgeClass(object status)
        {
            switch (Convert.ToString(status))
            {
                case "Confirmed": return "badge bg-success";
                case "Completed": return "badge bg-secondary";
                case "Cancelled": return "badge bg-danger";
                default: return "badge bg-warning text-dark";
            }
        }
    }
}
