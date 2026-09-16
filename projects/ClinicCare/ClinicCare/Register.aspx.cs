using System;
using System.Web.Security;
using System.Web.UI;
using ClinicCare.Security;

namespace ClinicCare
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Every self-registered account is a patient. The Admin and Doctor roles
        /// are assigned by an administrator, never through this page.
        /// </summary>
        protected void ctlCreateUser_CreatedUser(object sender, EventArgs e)
        {
            try
            {
                RoleSeeder.EnsureRolesExist();

                string userName = ctlCreateUser.UserName;
                if (!Roles.IsUserInRole(userName, RoleSeeder.PatientRole))
                {
                    Roles.AddUserToRole(userName, RoleSeeder.PatientRole);
                }
            }
            catch (Exception ex)
            {
                // The account itself was created successfully; failing to attach the
                // role should not present as a registration failure.
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Role assignment failed: " + ex);
                ShowMessage("alert alert-warning",
                    "Your account was created, but the Patient role could not be assigned. " +
                    "Please contact reception.");
            }
        }

        protected void ctlCreateUser_CreateUserError(object sender, EventArgs e)
        {
            ShowMessage("alert alert-danger",
                "The account could not be created. The username or email may already be registered.");
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
