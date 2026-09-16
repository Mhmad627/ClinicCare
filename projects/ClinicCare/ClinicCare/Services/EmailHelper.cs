using System;
using System.Configuration;
using System.Net.Mail;
using System.Text;
using ClinicCare.Models;

namespace ClinicCare.Services
{
    /// <summary>
    /// Sends the clinic's outbound notifications through Gmail SMTP.
    /// Host, port, SSL and credentials come from &lt;system.net&gt;&lt;mailSettings&gt;
    /// in Web.config, so no connection details are hard-coded here.
    ///
    /// Every send is wrapped so a mail failure can never break a booking - the
    /// appointment is already committed by the time these run.
    /// </summary>
    public static class EmailHelper
    {
        private static bool EmailEnabled
        {
            get
            {
                string setting = ConfigurationManager.AppSettings["EmailEnabled"];
                bool enabled;
                return bool.TryParse(setting, out enabled) && enabled;
            }
        }

        private static string FromAddress
        {
            get { return ConfigurationManager.AppSettings["ClinicFromEmail"] ?? "noreply@cliniccare.sa"; }
        }

        private static string FromName
        {
            get { return ConfigurationManager.AppSettings["ClinicFromName"] ?? "ClinicCare"; }
        }

        private static string ClinicName
        {
            get { return ConfigurationManager.AppSettings["ClinicName"] ?? "ClinicCare"; }
        }

        private static string ClinicPhone
        {
            get { return ConfigurationManager.AppSettings["ClinicPhone"] ?? string.Empty; }
        }

        // -------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------

        /// <summary>Sent to the patient immediately after a successful booking.</summary>
        public static bool SendAppointmentConfirmation(Appointment appointment, string toEmail)
        {
            if (appointment == null || string.IsNullOrEmpty(toEmail)) return false;

            string subject = string.Format("Appointment confirmation - reference #{0}", appointment.AppointmentID);
            string body = BuildHtmlBody(
                "Your appointment is booked",
                "Thank you for booking with " + ClinicName + ". Here are your appointment details:",
                appointment,
                "Please arrive 15 minutes early and bring your National ID.");

            return Send(toEmail, subject, body);
        }

        /// <summary>Sent when an administrator changes an appointment's status.</summary>
        public static bool SendStatusChangeNotification(Appointment appointment, string toEmail, string newStatus)
        {
            if (appointment == null || string.IsNullOrEmpty(toEmail)) return false;

            string subject = string.Format("Appointment #{0} is now {1}", appointment.AppointmentID, newStatus);

            string intro;
            switch (newStatus)
            {
                case "Confirmed":
                    intro = "Good news - your appointment has been confirmed by the clinic.";
                    break;
                case "Cancelled":
                    intro = "Your appointment has been cancelled. Please contact reception to rebook.";
                    break;
                case "Completed":
                    intro = "Your appointment has been marked as completed. Thank you for visiting us.";
                    break;
                default:
                    intro = "The status of your appointment has been updated.";
                    break;
            }

            string body = BuildHtmlBody(
                "Appointment " + newStatus.ToLowerInvariant(),
                intro,
                appointment,
                "If this is unexpected, please call reception on " + ClinicPhone + ".");

            return Send(toEmail, subject, body);
        }

        // -------------------------------------------------------------------
        // Internals
        // -------------------------------------------------------------------

        /// <summary>
        /// Returns true when the message was handed to the SMTP server.
        /// Never throws - failures are logged and reported through the return value.
        /// </summary>
        private static bool Send(string toEmail, string subject, string htmlBody)
        {
            if (!EmailEnabled)
            {
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Email disabled; skipped send to " + toEmail);
                return false;
            }

            try
            {
                using (MailMessage message = new MailMessage())
                {
                    message.From = new MailAddress(FromAddress, FromName);
                    message.To.Add(new MailAddress(toEmail));
                    message.Subject = subject;
                    message.Body = htmlBody;
                    message.IsBodyHtml = true;
                    message.BodyEncoding = Encoding.UTF8;
                    message.SubjectEncoding = Encoding.UTF8;

                    // Parameterless SmtpClient reads host/port/SSL/credentials
                    // from <system.net><mailSettings> in Web.config.
                    using (SmtpClient client = new SmtpClient())
                    {
                        client.Send(message);
                    }
                }

                return true;
            }
            catch (SmtpException ex)
            {
                // Most common causes: Gmail app password not set, 2-Step Verification
                // not enabled on the account, or port 587 blocked by the network.
                System.Diagnostics.Debug.WriteLine(
                    "[ClinicCare] SMTP send failed (" + ex.StatusCode + "): " + ex.Message);
                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ClinicCare] Email send failed: " + ex.Message);
                return false;
            }
        }

        private static string BuildHtmlBody(string heading, string intro, Appointment a, string footerNote)
        {
            StringBuilder sb = new StringBuilder();

            sb.Append("<div style=\"font-family:Segoe UI,Arial,sans-serif;max-width:600px;color:#212529;\">");
            sb.Append("<div style=\"background:#0d6efd;color:#fff;padding:16px 20px;\">");
            sb.Append("<h2 style=\"margin:0;font-size:20px;\">").Append(Escape(ClinicName)).Append("</h2>");
            sb.Append("</div>");

            sb.Append("<div style=\"padding:20px;border:1px solid #dee2e6;border-top:none;\">");
            sb.Append("<h3 style=\"margin-top:0;\">").Append(Escape(heading)).Append("</h3>");
            sb.Append("<p>").Append(Escape(intro)).Append("</p>");

            sb.Append("<table cellpadding=\"6\" cellspacing=\"0\" style=\"border-collapse:collapse;width:100%;\">");
            Row(sb, "Reference", "#" + a.AppointmentID);
            Row(sb, "Patient", a.PatientName);
            Row(sb, "Doctor", a.DoctorName);
            Row(sb, "Specialty", a.SpecialtyName);
            Row(sb, "Date", a.AppointmentDate.ToString("dddd, dd MMMM yyyy"));
            Row(sb, "Time", a.TimeSlot);
            Row(sb, "Visit type", a.VisitType);
            Row(sb, "Status", a.Status);
            sb.Append("</table>");

            sb.Append("<p style=\"margin-top:20px;\">").Append(Escape(footerNote)).Append("</p>");
            sb.Append("<p style=\"color:#6c757d;font-size:12px;margin-bottom:0;\">");
            sb.Append("This is an automated message, please do not reply. Reception: ")
              .Append(Escape(ClinicPhone));
            sb.Append("</p>");
            sb.Append("</div></div>");

            return sb.ToString();
        }

        private static void Row(StringBuilder sb, string label, string value)
        {
            sb.Append("<tr>");
            sb.Append("<td style=\"border-bottom:1px solid #eee;color:#6c757d;width:35%;\">")
              .Append(Escape(label)).Append("</td>");
            sb.Append("<td style=\"border-bottom:1px solid #eee;font-weight:600;\">")
              .Append(Escape(value)).Append("</td>");
            sb.Append("</tr>");
        }

        private static string Escape(string value)
        {
            return string.IsNullOrEmpty(value) ? "-" : System.Web.HttpUtility.HtmlEncode(value);
        }
    }
}
