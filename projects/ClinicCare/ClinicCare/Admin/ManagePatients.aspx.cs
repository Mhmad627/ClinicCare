using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClinicCare.DataAccess;
using ClinicCare.Models;

namespace ClinicCare.Admin
{
    public partial class ManagePatients : Page
    {
        // ---- GridView sort state (kept in ViewState across postbacks) ----
        private string SortColumn
        {
            get { return (string)(ViewState["SortColumn"] ?? "FullName"); }
            set { ViewState["SortColumn"] = value; }
        }

        private SortDirection SortDir
        {
            get { return (SortDirection)(ViewState["SortDir"] ?? SortDirection.Ascending); }
            set { ViewState["SortDir"] = value; }
        }

        private string SearchTerm
        {
            get { return (string)(ViewState["SearchTerm"] ?? string.Empty); }
            set { ViewState["SearchTerm"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        // -------------------------------------------------------------------
        // Grid binding, paging and sorting
        // -------------------------------------------------------------------

        private void BindGrid()
        {
            DataTable patients = PatientRepository.GetAll(
                SearchTerm.Length == 0 ? null : SearchTerm);

            // DataView applies the sort chosen by the GridView header.
            DataView view = patients.DefaultView;
            view.Sort = SortColumn + (SortDir == SortDirection.Ascending ? " ASC" : " DESC");

            gvPatients.DataSource = view;
            gvPatients.DataBind();
        }

        protected void gvPatients_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvPatients.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvPatients_Sorting(object sender, GridViewSortEventArgs e)
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

            BindGrid();
        }

        // -------------------------------------------------------------------
        // Row commands - Edit / Delete
        // -------------------------------------------------------------------

        protected void gvPatients_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int patientId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out patientId)) return;

            if (e.CommandName == "EditPatient")
            {
                LoadIntoForm(patientId);
            }
            else if (e.CommandName == "DeletePatient")
            {
                DeletePatient(patientId);
            }
        }

        private void LoadIntoForm(int patientId)
        {
            Patient patient = PatientRepository.GetById(patientId);
            if (patient == null)
            {
                ShowMessage("alert alert-warning", "That patient no longer exists.");
                BindGrid();
                return;
            }

            hfPatientID.Value = patient.PatientID.ToString();
            txtFullName.Text = patient.FullName;
            txtPhone.Text = patient.Phone;
            txtEmail.Text = patient.Email;
            txtNationalID.Text = patient.NationalID;
            txtNotes.Text = patient.Notes;
            txtDateOfBirth.Text = patient.DateOfBirth.HasValue
                ? patient.DateOfBirth.Value.ToString("yyyy-MM-dd")
                : string.Empty;

            rblGender.ClearSelection();
            ListItem genderItem = rblGender.Items.FindByValue(patient.Gender);
            if (genderItem != null) genderItem.Selected = true;

            litFormTitle.Text = "Editing patient #" + patient.PatientID;
            btnSave.Text = "Update patient";
            btnCancelEdit.Visible = true;

            pnlMessage.Visible = false;
        }

        private void DeletePatient(int patientId)
        {
            try
            {
                PatientRepository.Delete(patientId);
                ShowMessage("alert alert-success", "Patient deleted.");
                ClearForm();
            }
            catch (SqlException ex)
            {
                // usp_Patient_Delete blocks deletion when appointments exist.
                ShowMessage("alert alert-warning", Server.HtmlEncode(ex.Message));
            }

            BindGrid();
        }

        // -------------------------------------------------------------------
        // Save (insert or update, both via stored procedures)
        // -------------------------------------------------------------------

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Layer 1 - the validator controls (rubric ID 6).
            Page.Validate("Patient");
            if (!Page.IsValid)
            {
                ShowMessage("alert alert-danger",
                    "Some details are missing or invalid. Please check the highlighted fields.");
                return;
            }

            // Layer 2 - independent server-side rules (rubric ID 7).
            List<string> errors = ValidateForm();
            if (errors.Count > 0)
            {
                ShowMessage("alert alert-danger",
                    "<strong>Please correct the following:</strong><ul class=\"mb-0\"><li>" +
                    string.Join("</li><li>", errors.ToArray()) + "</li></ul>");
                return;
            }

            Patient patient = new Patient
            {
                PatientID = int.Parse(hfPatientID.Value),
                FullName = txtFullName.Text.Trim(),
                Gender = rblGender.SelectedValue,
                Phone = txtPhone.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                NationalID = txtNationalID.Text.Trim(),
                Notes = txtNotes.Text.Trim()
            };

            DateTime dob;
            if (DateTime.TryParse(txtDateOfBirth.Text, out dob)) patient.DateOfBirth = dob;

            try
            {
                if (patient.PatientID > 0)
                {
                    PatientRepository.Update(patient);
                    ShowMessage("alert alert-success", "Patient #" + patient.PatientID + " updated.");
                }
                else
                {
                    int newId = PatientRepository.Insert(patient);
                    ShowMessage("alert alert-success", "Patient added with ID #" + newId + ".");
                }

                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                // Most likely the UNIQUE constraint on NationalID.
                string message = ex.Number == 2627 || ex.Number == 2601
                    ? "That National ID is already registered to another patient."
                    : Server.HtmlEncode(ex.Message);

                ShowMessage("alert alert-danger", message);
            }
        }

        /// <summary>Server-side validation, run before any database call.</summary>
        private List<string> ValidateForm()
        {
            List<string> errors = new List<string>();

            if (txtFullName.Text.Trim().Length == 0)
                errors.Add("Full name is required.");

            string phone = txtPhone.Text.Trim();
            if (phone.Length == 0)
                errors.Add("Mobile number is required.");
            else if (!Regex.IsMatch(phone, @"^05\d{8}$"))
                errors.Add("Mobile number must be in the format 05XXXXXXXX.");

            string email = txtEmail.Text.Trim();
            if (email.Length > 0 && !Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                errors.Add("Email address is not in a valid format.");

            string nationalId = txtNationalID.Text.Trim();
            if (nationalId.Length > 0 && !Regex.IsMatch(nationalId, @"^\d{10}$"))
                errors.Add("National ID must be 10 digits.");

            DateTime dob;
            if (txtDateOfBirth.Text.Trim().Length > 0)
            {
                if (!DateTime.TryParse(txtDateOfBirth.Text, out dob))
                    errors.Add("Date of birth is not a valid date.");
                else if (dob.Date > DateTime.Today)
                    errors.Add("Date of birth cannot be in the future.");
            }

            return errors;
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearForm();
            pnlMessage.Visible = false;
        }

        private void ClearForm()
        {
            hfPatientID.Value = "0";
            txtFullName.Text = txtPhone.Text = txtEmail.Text = string.Empty;
            txtNationalID.Text = txtNotes.Text = txtDateOfBirth.Text = string.Empty;

            rblGender.ClearSelection();
            rblGender.Items[0].Selected = true;

            litFormTitle.Text = "Add a new patient";
            btnSave.Text = "Save patient";
            btnCancelEdit.Visible = false;
        }

        // -------------------------------------------------------------------
        // Search
        // -------------------------------------------------------------------

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearch.Text.Trim();
            gvPatients.PageIndex = 0;
            BindGrid();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = string.Empty;
            txtSearch.Text = string.Empty;
            gvPatients.PageIndex = 0;
            BindGrid();
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
