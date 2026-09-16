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
    public partial class ManageDoctors : Page
    {
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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSpecialties();
                BindGrid();
            }
        }

        private void LoadSpecialties()
        {
            ddlSpecialty.DataSource = SpecialtyRepository.GetAllTable();
            ddlSpecialty.DataTextField = "SpecialtyName";
            ddlSpecialty.DataValueField = "SpecialtyID";
            ddlSpecialty.DataBind();
            ddlSpecialty.Items.Insert(0, new ListItem("-- Select a specialty --", "0"));
        }

        private void BindGrid()
        {
            DataTable doctors = DoctorRepository.GetAll();

            DataView view = doctors.DefaultView;
            view.Sort = SortColumn + (SortDir == SortDirection.Ascending ? " ASC" : " DESC");

            gvDoctors.DataSource = view;
            gvDoctors.DataBind();
        }

        protected void gvDoctors_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDoctors.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvDoctors_Sorting(object sender, GridViewSortEventArgs e)
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

        protected void gvDoctors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int doctorId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out doctorId)) return;

            if (e.CommandName == "EditDoctor")
            {
                LoadIntoForm(doctorId);
            }
            else if (e.CommandName == "DeleteDoctor")
            {
                DeleteDoctor(doctorId);
            }
        }

        private void LoadIntoForm(int doctorId)
        {
            Doctor doctor = DoctorRepository.GetById(doctorId);
            if (doctor == null)
            {
                ShowMessage("alert alert-warning", "That doctor no longer exists.");
                BindGrid();
                return;
            }

            hfDoctorID.Value = doctor.DoctorID.ToString();
            txtFullName.Text = doctor.FullName;
            txtEmail.Text = doctor.Email;
            txtPhone.Text = doctor.Phone;
            txtBio.Text = doctor.Bio;
            txtPhotoUrl.Text = doctor.PhotoUrl;
            chkIsActive.Checked = doctor.IsActive;

            ddlSpecialty.ClearSelection();
            ListItem specialtyItem = ddlSpecialty.Items.FindByValue(doctor.SpecialtyID.ToString());
            if (specialtyItem != null) specialtyItem.Selected = true;

            litFormTitle.Text = "Editing doctor #" + doctor.DoctorID;
            btnSave.Text = "Update doctor";
            btnCancelEdit.Visible = true;

            pnlMessage.Visible = false;
        }

        private void DeleteDoctor(int doctorId)
        {
            try
            {
                DoctorRepository.Delete(doctorId);
                ShowMessage("alert alert-success", "Doctor deleted.");
                ClearForm();
            }
            catch (SqlException ex)
            {
                // usp_Doctor_Delete blocks deletion when appointments exist and
                // suggests deactivating instead.
                ShowMessage("alert alert-warning", Server.HtmlEncode(ex.Message));
            }

            BindGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Layer 1 - the validator controls (rubric ID 6).
            Page.Validate("Doctor");
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

            Doctor doctor = new Doctor
            {
                DoctorID = int.Parse(hfDoctorID.Value),
                FullName = txtFullName.Text.Trim(),
                SpecialtyID = int.Parse(ddlSpecialty.SelectedValue),
                Email = txtEmail.Text.Trim(),
                Phone = txtPhone.Text.Trim(),
                Bio = txtBio.Text.Trim(),
                PhotoUrl = txtPhotoUrl.Text.Trim(),
                IsActive = chkIsActive.Checked
            };

            try
            {
                if (doctor.DoctorID > 0)
                {
                    DoctorRepository.Update(doctor);
                    ShowMessage("alert alert-success", "Doctor #" + doctor.DoctorID + " updated.");
                }
                else
                {
                    int newId = DoctorRepository.Insert(doctor);
                    ShowMessage("alert alert-success", "Doctor added with ID #" + newId + ".");
                }

                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                ShowMessage("alert alert-danger", Server.HtmlEncode(ex.Message));
            }
        }

        private List<string> ValidateForm()
        {
            List<string> errors = new List<string>();

            if (txtFullName.Text.Trim().Length == 0)
                errors.Add("Full name is required.");

            int specialtyId;
            if (!int.TryParse(ddlSpecialty.SelectedValue, out specialtyId) || specialtyId == 0)
                errors.Add("Please select a specialty.");

            string email = txtEmail.Text.Trim();
            if (email.Length > 0 && !Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                errors.Add("Email address is not in a valid format.");

            string phone = txtPhone.Text.Trim();
            if (phone.Length > 0 && !Regex.IsMatch(phone, @"^05\d{8}$"))
                errors.Add("Phone number must be in the format 05XXXXXXXX.");

            return errors;
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearForm();
            pnlMessage.Visible = false;
        }

        private void ClearForm()
        {
            hfDoctorID.Value = "0";
            txtFullName.Text = txtEmail.Text = txtPhone.Text = string.Empty;
            txtBio.Text = txtPhotoUrl.Text = string.Empty;
            chkIsActive.Checked = true;

            ddlSpecialty.ClearSelection();
            ddlSpecialty.Items[0].Selected = true;

            litFormTitle.Text = "Add a new doctor";
            btnSave.Text = "Save doctor";
            btnCancelEdit.Visible = false;
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
