using System;
using System.Web.UI;

namespace ClinicCare
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["returnUrl"] != null)
            {
                ShowMessage("alert alert-info", "Please sign in to continue to that page.");
            }
        }

        protected void ctlLogin_LoginError(object sender, EventArgs e)
        {
            // The Login control shows its own FailureText; this adds a Bootstrap
            // alert at the top of the page so the failure is obvious.
            ShowMessage("alert alert-danger",
                "Sign-in failed. Please check your username and password and try again.");
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }
    }
}
