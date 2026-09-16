using System;
using System.Web;

namespace ClinicCare
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Create the Admin / Doctor / Patient roles and the seed accounts on
            // first run. Safe to run every start - existing data is left alone.
            ClinicCare.Security.RoleSeeder.SeedAll();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            // Unhandled exceptions are logged so a failure is traceable even when
            // customErrors hides the detail from the user.
            Exception ex = Server.GetLastError();
            if (ex != null)
            {
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Unhandled error: " + ex);
            }
        }
    }
}
