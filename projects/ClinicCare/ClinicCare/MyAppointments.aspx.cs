using System;
using System.Data;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClinicCare.DataAccess;

namespace ClinicCare
{
    public partial class MyAppointments : Page
    {
        /// <summary>The lookup value is kept in ViewState so paging can re-query.</summary>
        private string LastLookup
        {
            get { return (string)(ViewState["LastLookup"] ?? string.Empty); }
            set { ViewState["LastLookup"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLookup_Click(object sender, EventArgs e)
        {
            string lookup = txtLookup.Text.Trim();

            // Server-side validation before touching the database.
            if (lookup.Length == 0)
            {
                ShowMessage("alert alert-warning", "Please enter your mobile number or National ID.");
                pnlResults.Visible = false;
                return;
            }

            if (!Regex.IsMatch(lookup, @"^(05\d{8}|\d{10})$"))
            {
                ShowMessage("alert alert-warning",
                    "Enter a Saudi mobile number in the format 05XXXXXXXX, or a 10-digit National ID.");
                pnlResults.Visible = false;
                return;
            }

            LastLookup = lookup;
            gvMyAppointments.PageIndex = 0;
            BindResults();
        }

        private void BindResults()
        {
            DataTable results = AppointmentRepository.GetByPatientLookup(LastLookup);

            gvMyAppointments.DataSource = results;
            gvMyAppointments.DataBind();

            pnlResults.Visible = true;

            if (results.Rows.Count == 0)
            {
                ShowMessage("alert alert-info",
                    "No appointments were found for that number. Please check it and try again.");
            }
            else
            {
                ShowMessage("alert alert-success",
                    "Found <strong>" + results.Rows.Count + "</strong> appointment(s).");
            }
        }

        protected void gvMyAppointments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMyAppointments.PageIndex = e.NewPageIndex;
            BindResults();
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

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
