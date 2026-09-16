using System;
using System.Data;
using System.Web.UI;
using ClinicCare.DataAccess;

namespace ClinicCare
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCounters();
            }
        }

        private void LoadCounters()
        {
            try
            {
                DataRow stats = AppointmentRepository.GetDashboardStats();
                if (stats != null)
                {
                    litDoctorCount.Text = DbHelper.GetInt(stats, "ActiveDoctors").ToString();
                    litPatientCount.Text = DbHelper.GetInt(stats, "TotalPatients").ToString();
                }

                litSpecialtyCount.Text = SpecialtyRepository.GetAllTable().Rows.Count.ToString();
            }
            catch (Exception)
            {
                // The landing page must still render if the database is unreachable.
                litDoctorCount.Text = litPatientCount.Text = litSpecialtyCount.Text = "-";
            }
        }
    }
}
