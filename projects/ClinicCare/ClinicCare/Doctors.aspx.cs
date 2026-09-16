using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClinicCare.DataAccess;

namespace ClinicCare
{
    public partial class Doctors : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSpecialtyFilter();
                LoadDoctors();
            }
        }

        private void LoadSpecialtyFilter()
        {
            ddlFilterSpecialty.DataSource = SpecialtyRepository.GetAllTable();
            ddlFilterSpecialty.DataTextField = "SpecialtyName";
            ddlFilterSpecialty.DataValueField = "SpecialtyID";
            ddlFilterSpecialty.DataBind();
            ddlFilterSpecialty.Items.Insert(0, new ListItem("All specialties", "0"));
        }

        private void LoadDoctors()
        {
            int specialtyId;
            int.TryParse(ddlFilterSpecialty.SelectedValue, out specialtyId);

            DataTable doctors = specialtyId > 0
                ? DoctorRepository.GetBySpecialty(specialtyId)
                : DoctorRepository.GetAll(activeOnly: true);

            rptDoctors.DataSource = doctors;
            rptDoctors.DataBind();

            // Repeater renders nothing at all when empty, so show a message instead.
            pnlNoDoctors.Visible = doctors.Rows.Count == 0;
        }

        protected void ddlFilterSpecialty_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDoctors();
        }
    }
}
