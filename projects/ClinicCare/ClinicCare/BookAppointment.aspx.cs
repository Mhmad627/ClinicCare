using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClinicCare.DataAccess;
using ClinicCare.Models;
using ClinicCare.Services;

namespace ClinicCare
{
    public partial class BookAppointment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // The RangeValidator bounds are relative to "today", so they have to be
            // set in code rather than declared in the markup - and they must be set
            // on every request, not just the first, or client-side validation on a
            // postback compares against an empty range.
            rvDate.MinimumValue = DateTime.Today.ToString("yyyy-MM-dd");
            rvDate.MaximumValue = DateTime.Today.AddMonths(6).ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                LoadSpecialties();
                LoadDoctors();
                PreselectDoctorFromQueryString();
                PrefillFromSignedInUser();

                // Default to tomorrow - the clinic does not take same-day bookings online.
                txtAppointmentDate.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
            }
        }

        /// <summary>
        /// Booking now requires a signed-in user, so the email is pre-filled from
        /// the membership record to save re-typing it.
        /// </summary>
        private void PrefillFromSignedInUser()
        {
            if (!Request.IsAuthenticated) return;

            MembershipUser user = Membership.GetUser();
            if (user != null && !string.IsNullOrEmpty(user.Email))
            {
                txtEmail.Text = user.Email;
            }
        }

        // -------------------------------------------------------------------
        // Data loading - cascading DropDownLists (rubric ID 11)
        // -------------------------------------------------------------------

        private void LoadSpecialties()
        {
            ddlSpecialty.DataSource = SpecialtyRepository.GetAllTable();
            ddlSpecialty.DataTextField = "SpecialtyName";
            ddlSpecialty.DataValueField = "SpecialtyID";
            ddlSpecialty.DataBind();
            ddlSpecialty.Items.Insert(0, new ListItem("-- Select a specialty --", "0"));
        }

        /// <summary>Repopulates ddlDoctor from the specialty currently selected.</summary>
        private void LoadDoctors()
        {
            ddlDoctor.Items.Clear();

            int specialtyId;
            if (!int.TryParse(ddlSpecialty.SelectedValue, out specialtyId) || specialtyId == 0)
            {
                ddlDoctor.Items.Add(new ListItem("-- Select a specialty first --", "0"));
                return;
            }

            ddlDoctor.DataSource = DoctorRepository.GetBySpecialty(specialtyId);
            ddlDoctor.DataTextField = "FullName";
            ddlDoctor.DataValueField = "DoctorID";
            ddlDoctor.DataBind();
            ddlDoctor.Items.Insert(0, new ListItem("-- Select a doctor --", "0"));
        }

        /// <summary>Supports the "Book with this doctor" link on Doctors.aspx.</summary>
        private void PreselectDoctorFromQueryString()
        {
            int doctorId;
            if (!int.TryParse(Request.QueryString["doctorId"], out doctorId) || doctorId <= 0) return;

            Doctor doctor = DoctorRepository.GetById(doctorId);
            if (doctor == null) return;

            ListItem specialtyItem = ddlSpecialty.Items.FindByValue(doctor.SpecialtyID.ToString());
            if (specialtyItem == null) return;

            ddlSpecialty.ClearSelection();
            specialtyItem.Selected = true;

            LoadDoctors();

            ListItem doctorItem = ddlDoctor.Items.FindByValue(doctor.DoctorID.ToString());
            if (doctorItem != null)
            {
                ddlDoctor.ClearSelection();
                doctorItem.Selected = true;
            }
        }

        protected void ddlSpecialty_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDoctors();
        }

        // -------------------------------------------------------------------
        // Booking 
        // -------------------------------------------------------------------

        protected void btnBook_Click(object sender, EventArgs e)
        {
            DoBooking();
        }

        /// <summary>Server-side check for the time-slot CheckBoxList (rubric ID 7).</summary>
        protected void cvTimeSlot_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = GetSelectedTimeSlot() != null;
        }

        private void DoBooking()
        {
            pnlSummary.Visible = false;

            // ---- Layer 1: the validator controls ----
            // Page.IsValid must be checked explicitly; a disabled-JavaScript client
            // can post straight past the client-side validation.
            Page.Validate("Booking");
            if (!Page.IsValid)
            {
                ShowMessage("alert alert-danger",
                    "Some of the details are missing or invalid. Please check the highlighted fields.");
                return;
            }

            // ---- Layer 2: independent server-side rules ----
            List<string> errors = ValidateForm();
            if (errors.Count > 0)
            {
                ShowMessage("alert alert-danger",
                    "<strong>Please correct the following:</strong><ul class=\"mb-0\"><li>" +
                    string.Join("</li><li>", errors.ToArray()) + "</li></ul>");
                return;
            }

            try
            {
                // Reuse the patient record if this phone / National ID is already known.
                Patient patient = new Patient
                {
                    FullName = txtFullName.Text.Trim(),
                    Gender = rblGender.SelectedValue,
                    Phone = txtPhone.Text.Trim(),
                    Email = txtEmail.Text.Trim(),
                    NationalID = txtNationalID.Text.Trim(),
                    Notes = txtNotes.Text.Trim()
                };

                int patientId = PatientRepository.FindOrCreate(patient);

                string timeSlot = GetSelectedTimeSlot();
                string symptoms = BuildSymptomsText();

                Appointment appointment = new Appointment
                {
                    PatientID = patientId,
                    DoctorID = int.Parse(ddlDoctor.SelectedValue),
                    AppointmentDate = DateTime.Parse(txtAppointmentDate.Text),
                    TimeSlot = timeSlot,
                    VisitType = rblVisitType.SelectedValue,
                    Symptoms = symptoms,
                    Status = "Pending"
                };

                int appointmentId = AppointmentRepository.Insert(appointment);

                ShowSummary(appointmentId, timeSlot, symptoms);

                // ---- Confirmation email (rubric ID 3) ----
                // The appointment is already saved; a mail failure must never undo it,
                // so the outcome only changes the wording of the on-screen message.
                string emailNote = string.Empty;
                string toEmail = txtEmail.Text.Trim();

                if (toEmail.Length > 0)
                {
                    Appointment saved = AppointmentRepository.GetById(appointmentId);
                    bool sent = EmailHelper.SendAppointmentConfirmation(saved ?? appointment, toEmail);

                    emailNote = sent
                        ? " A confirmation email has been sent to " + Server.HtmlEncode(toEmail) + "."
                        : " We could not send the confirmation email, but your booking is saved.";
                }

                ShowMessage("alert alert-success",
                    "Your appointment has been booked. Reference number <strong>#" +
                    appointmentId + "</strong>." + emailNote);
            }
            catch (SqlException ex)
            {
                // usp_Appointment_Insert raises a readable message when the doctor's
                // slot is already taken - surface it rather than a stack trace.
                ShowMessage("alert alert-warning", Server.HtmlEncode(ex.Message));
            }
            catch (Exception)
            {
                ShowMessage("alert alert-danger",
                    "Sorry, the booking could not be saved. Please try again or call reception.");
            }
        }

        /// <summary>
        /// Server-side rules, deliberately independent of the validator controls
        /// that are added in Week 5 - the data is re-checked in C# before any save.
        /// </summary>
        private List<string> ValidateForm()
        {
            List<string> errors = new List<string>();

            if (txtFullName.Text.Trim().Length == 0)
                errors.Add("Full name is required.");

            string phone = txtPhone.Text.Trim();
            if (phone.Length == 0)
                errors.Add("Mobile number is required.");
            else if (!Regex.IsMatch(phone, @"^05\d{8}$"))
                errors.Add("Mobile number must be a Saudi number in the format 05XXXXXXXX.");

            string email = txtEmail.Text.Trim();
            if (email.Length > 0 && !Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                errors.Add("Email address is not in a valid format.");

            string nationalId = txtNationalID.Text.Trim();
            if (nationalId.Length > 0 && !Regex.IsMatch(nationalId, @"^\d{10}$"))
                errors.Add("National ID must be 10 digits.");

            int specialtyId;
            if (!int.TryParse(ddlSpecialty.SelectedValue, out specialtyId) || specialtyId == 0)
                errors.Add("Please select a specialty.");

            int doctorId;
            if (!int.TryParse(ddlDoctor.SelectedValue, out doctorId) || doctorId == 0)
                errors.Add("Please select a doctor.");

            DateTime appointmentDate;
            if (!DateTime.TryParse(txtAppointmentDate.Text, out appointmentDate))
            {
                errors.Add("Please choose a valid appointment date.");
            }
            else if (appointmentDate.Date < DateTime.Today)
            {
                errors.Add("The appointment date cannot be in the past.");
            }
            else if (appointmentDate.Date > DateTime.Today.AddMonths(6))
            {
                errors.Add("Appointments can only be booked up to six months ahead.");
            }

            if (GetSelectedTimeSlot() == null)
                errors.Add("Please choose at least one time slot.");

            return errors;
        }

        /// <summary>
        /// The CheckBoxList allows several ticks; a single appointment occupies one
        /// slot, so the earliest ticked slot is the one reserved.
        /// </summary>
        private string GetSelectedTimeSlot()
        {
            foreach (ListItem item in cblTimeSlots.Items)
            {
                if (item.Selected) return item.Value;
            }
            return null;
        }

        private string BuildSymptomsText()
        {
            List<string> selected = new List<string>();
            foreach (ListItem item in cblSymptoms.Items)
            {
                if (item.Selected) selected.Add(item.Text);
            }

            string symptoms = string.Join(", ", selected.ToArray());
            string notes = txtNotes.Text.Trim();

            if (symptoms.Length > 0 && notes.Length > 0) return symptoms + ". " + notes;
            return symptoms.Length > 0 ? symptoms : notes;
        }

        // -------------------------------------------------------------------
        // Posting the captured data back to the screen
        // -------------------------------------------------------------------

        private void ShowSummary(int appointmentId, string timeSlot, string symptoms)
        {
            litReference.Text = "#" + appointmentId;
            litSumName.Text = Server.HtmlEncode(txtFullName.Text.Trim());
            litSumGender.Text = Server.HtmlEncode(rblGender.SelectedValue);
            litSumPhone.Text = Server.HtmlEncode(txtPhone.Text.Trim());
            litSumEmail.Text = Server.HtmlEncode(Blank(txtEmail.Text));
            litSumSpecialty.Text = Server.HtmlEncode(ddlSpecialty.SelectedItem.Text);
            litSumDoctor.Text = Server.HtmlEncode(ddlDoctor.SelectedItem.Text);
            litSumDate.Text = DateTime.Parse(txtAppointmentDate.Text).ToString("dddd, dd MMMM yyyy");
            litSumSlot.Text = Server.HtmlEncode(timeSlot);
            litSumVisitType.Text = Server.HtmlEncode(rblVisitType.SelectedValue);
            litSumSymptoms.Text = Server.HtmlEncode(Blank(symptoms));
            litSumNotes.Text = Server.HtmlEncode(Blank(txtNotes.Text));
            litSumStatus.Text = "Pending confirmation";

            pnlSummary.Visible = true;
        }

        private static string Blank(string value)
        {
            return string.IsNullOrEmpty(value) || value.Trim().Length == 0 ? "-" : value.Trim();
        }

        private void ShowMessage(string cssClass, string html)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = html;
            pnlMessage.Visible = true;
        }

        // -------------------------------------------------------------------

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtFullName.Text = txtPhone.Text = txtEmail.Text = txtNationalID.Text = txtNotes.Text = string.Empty;

            rblGender.ClearSelection();
            rblGender.Items[0].Selected = true;
            rblVisitType.ClearSelection();
            rblVisitType.Items[0].Selected = true;

            foreach (ListItem item in cblTimeSlots.Items) item.Selected = false;
            foreach (ListItem item in cblSymptoms.Items) item.Selected = false;

            ddlSpecialty.ClearSelection();
            ddlSpecialty.Items[0].Selected = true;
            LoadDoctors();

            txtAppointmentDate.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");

            pnlSummary.Visible = false;
            pnlMessage.Visible = false;
        }
    }
}
