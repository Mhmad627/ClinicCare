using System;
using System.Configuration;
using System.IO;
using System.Web.Security;
using System.Web.UI;
using ClinicCare.Security;

namespace ClinicCare
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            litClinicName.Text = ConfigurationManager.AppSettings["ClinicName"];
            litClinicPhone.Text = ConfigurationManager.AppSettings["ClinicPhone"];
            litYear.Text = DateTime.Now.Year.ToString();

            ApplyAuthenticationState();
        }

        /// <summary>
        /// Swaps the navbar between the anonymous and signed-in states, and shows
        /// the Admin menu only to users in the Admin role.
        /// </summary>
        private void ApplyAuthenticationState()
        {
            bool isAuthenticated = Request.IsAuthenticated;

            phAnonymous.Visible = !isAuthenticated;
            phAuthenticated.Visible = isAuthenticated;

            if (!isAuthenticated)
            {
                phAdminMenu.Visible = false;
                return;
            }

            litUserName.Text = Server.HtmlEncode(Page.User.Identity.Name);

            bool isAdmin = false;
            try
            {
                string[] roles = Roles.GetRolesForUser(Page.User.Identity.Name);
                litUserRoles.Text = roles.Length > 0
                    ? Server.HtmlEncode(string.Join(", ", roles))
                    : "none";

                isAdmin = Page.User.IsInRole(RoleSeeder.AdminRole);
            }
            catch (Exception ex)
            {
                // A role provider problem must not take the whole site down.
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Role lookup failed: " + ex.Message);
                litUserRoles.Text = "unavailable";
            }

            phAdminMenu.Visible = isAdmin;
        }

        protected void lnkSignOut_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect(FormsAuthentication.DefaultUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        /// <summary>
        /// Returns "active" when the requested page matches, so the navbar
        /// highlights the current section. Called inline from Site.Master.
        /// </summary>
        protected string NavClass(string pageName)
        {
            string current = Path.GetFileNameWithoutExtension(Request.AppRelativeCurrentExecutionFilePath ?? string.Empty);

            // Every page under /Admin lights up the single "Admin" menu entry.
            if (pageName == "Admin")
            {
                string path = Request.AppRelativeCurrentExecutionFilePath ?? string.Empty;
                return path.IndexOf("/Admin/", StringComparison.OrdinalIgnoreCase) >= 0 ? "active" : string.Empty;
            }

            return string.Equals(current, pageName, StringComparison.OrdinalIgnoreCase) ? "active" : string.Empty;
        }
    }
}
