using System;
using System.Web.Security;

namespace ClinicCare.Security
{
    /// <summary>
    /// Creates the three application roles and one seed account per role.
    /// Called once from Application_Start so a fresh database is usable
    /// immediately after aspnet_regsql has run.
    /// </summary>
    public static class RoleSeeder
    {
        public const string AdminRole = "Admin";
        public const string DoctorRole = "Doctor";
        public const string PatientRole = "Patient";

        private static readonly string[] AllRoles = { AdminRole, DoctorRole, PatientRole };

        /// <summary>Creates any role that does not exist yet. Safe to call repeatedly.</summary>
        public static void EnsureRolesExist()
        {
            foreach (string role in AllRoles)
            {
                if (!Roles.RoleExists(role))
                {
                    Roles.CreateRole(role);
                }
            }
        }

        /// <summary>
        /// Creates the demo accounts used for testing and for the project
        /// demonstration. Existing accounts are left untouched.
        /// TODO: remove or change these passwords before deploying publicly.
        /// </summary>
        public static void EnsureSeedAccounts()
        {
            CreateIfMissing("admin", "__REDACTED__", "admin@cliniccare.sa", AdminRole);
            CreateIfMissing("doctor", "__REDACTED__", "doctor@cliniccare.sa", DoctorRole);
            CreateIfMissing("patient", "__REDACTED__", "patient@cliniccare.sa", PatientRole);
        }

        private static void CreateIfMissing(string userName, string password, string email, string role)
        {
            MembershipUser user = Membership.GetUser(userName);

            if (user == null)
            {
                MembershipCreateStatus status;
                Membership.CreateUser(userName, password, email, null, null, true, out status);

                if (status != MembershipCreateStatus.Success)
                {
                    System.Diagnostics.Debug.WriteLine(
                        "[ClinicCare] Could not create seed user '" + userName + "': " + status);
                    return;
                }
            }

            if (!Roles.IsUserInRole(userName, role))
            {
                Roles.AddUserToRole(userName, role);
            }
        }

        /// <summary>Runs the whole seed, swallowing errors so a provider problem never blocks startup.</summary>
        public static void SeedAll()
        {
            try
            {
                EnsureRolesExist();
                EnsureSeedAccounts();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Role/account seeding failed: " + ex);
            }
        }
    }
}
