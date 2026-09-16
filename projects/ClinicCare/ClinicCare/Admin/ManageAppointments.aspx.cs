using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClinicCare.DataAccess;
using ClinicCare.Models;
using ClinicCare.Services;

namespace ClinicCare.Admin
{
    public partial class ManageAppointments : Page
    {
        private string SortColumn
        {
            get { return (string)(ViewState["SortColumn"] ?? "AppointmentDate"); }
            set { ViewState["SortColumn"] = value; }
        }

        private SortDirection SortDir
        {
            get { return (SortDirection)(ViewState["SortDir"] ?? SortDirection.Descending); }
            set { ViewState["SortDir"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            string status = ddlFilterStatus.SelectedValue;
            DataTable appointments = AppointmentRepository.GetAll(
                string.IsNullOrEmpty(status) ? null : status);

            DataView view = appointments.DefaultView;
            view.Sort = SortColumn + (SortDir == SortDirection.Ascending ? " ASC" : " DESC");

            gvAppointments.DataSource = view;
            gvAppointments.DataBind();
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvAppointments.PageIndex = 0;
            gvAppointments.EditIndex = -1;
            BindGrid();
        }

        protected void gvAppointments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAppointments.PageIndex = e.NewPageIndex;
            gvAppointments.EditIndex = -1;
            BindGrid();
        }

        protected void gvAppointments_Sorting(object sender, GridViewSortEventArgs e)
        {
            if (SortColumn == e.SortExpression)
            {
                SortDir = SortDir == SortDirection.Ascending
                    ? SortDirection.Descending
                    : SortDirection.Ascending;
            }
            else
            {
                SortColumn = e.SortExpression;
                SortDir = SortDirection.Ascending;
            }

            gvAppointments.EditIndex = -1;
            BindGrid();
        }

        // -------------------------------------------------------------------
        // Inline editing
        // -------------------------------------------------------------------

        protected void gvAppointments_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvAppointments.EditIndex = e.NewEditIndex;
            pnlMessage.Visible = false;
            BindGrid();
        }

        protected void gvAppointments_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvAppointments.EditIndex = -1;
            BindGrid();
        }

        protected void gvAppointments_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = gvAppointments.Rows[e.RowIndex];

            // DataKeyNames="AppointmentID" is what makes this lookup possible -
            // without it the key is null and the update silently targets nothing.
            int appointmentId = Convert.ToInt32(gvAppointments.DataKeys[e.RowIndex].Value);

            TextBox txtDate = (TextBox)row.FindControl("txtEditDate");
            TextBox txtSlot = (TextBox)row.FindControl("txtEditTimeSlot");
            DropDownList ddlVisitType = (DropDownList)row.FindControl("ddlEditVisitType");
            DropDownList ddlStatus = (DropDownList)row.FindControl("ddlEditStatus");

            DateTime appointmentDate;
            if (!DateTime.TryParse(txtDate.Text, out appointmentDate))
            {
                ShowMessage("alert alert-danger", "Please enter a valid appointment date.");
                return;
            }

            if (txtSlot.Text.Trim().Length == 0)
            {
                ShowMessage("alert alert-danger", "Time slot cannot be empty.");
                return;
            }

            // The existing record supplies the fields not shown in the edit row.
            Appointment existing = AppointmentRepository.GetById(appointmentId);
            if (existing == null)
            {
                ShowMessage("alert alert-warning", "That appointment no longer exists.");
                gvAppointments.EditIndex = -1;
                BindGrid();
                return;
            }

            string previousStatus = existing.Status;
            string newStatus = ddlStatus.SelectedValue;

            existing.AppointmentDate = appointmentDate;
            existing.TimeSlot = txtSlot.Text.Trim();
            existing.VisitType = ddlVisitType.SelectedValue;
            existing.Status = newStatus;

            try
            {
                AppointmentRepository.Update(existing);

                // ---- Notify the patient when the status actually changed (rubric ID 3) ----
                string emailNote = string.Empty;
                if (previousStatus != newStatus)
                {
                    if (!string.IsNullOrEmpty(existing.PatientEmail))
                    {
                        bool sent = EmailHelper.SendStatusChangeNotification(
                            existing, existing.PatientEmail, newStatus);

                        emailNote = sent
                            ? " The patient has been notified by email."
                            : " The patient could not be emailed - check the SMTP settings.";
                    }
                    else
                    {
                        emailNote = " No email address on file for this patient, so no notification was sent.";
                    }
                }

                ShowMessage("alert alert-success",
                    "Appointment #" + appointmentId + " updated." + emailNote);

                gvAppointments.EditIndex = -1;
                BindGrid();
            }
            catch (SqlException ex)
            {
                // UQ_tblAppointments_DoctorSlot fires if the doctor is now double-booked.
                string message = ex.Number == 2627 || ex.Number == 2601
                    ? "That doctor already has an appointment in this date and time slot."
                    : Server.HtmlEncode(ex.Message);

                ShowMessage("alert alert-danger", message);
            }
        }

        protected void gvAppointments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteAppointment") return;

            int appointmentId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out appointmentId)) return;

            try
            {
                AppointmentRepository.Delete(appointmentId);
                ShowMessage("alert alert-success", "Appointment #" + appointmentId + " deleted.");
            }
            catch (SqlException ex)
            {
                ShowMessage("alert alert-danger", Server.HtmlEncode(ex.Message));
            }

            gvAppointments.EditIndex = -1;
            BindGrid();
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
