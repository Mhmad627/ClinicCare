<%@ Page Title="Book Appointment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="BookAppointment.aspx.cs" Inherits="ClinicCare.BookAppointment" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Book an Appointment</h1>
    <p class="text-muted">Fill in your details and choose a consultant and time slot.</p>

    <!-- Result / error message area. CssClass is set from code-behind so the
         same panel can render a success, warning or danger alert. -->
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <!-- Client-side validation summary (rubric ID 6) -->
    <asp:ValidationSummary ID="vsBooking" runat="server"
        ValidationGroup="Booking"
        CssClass="alert alert-danger"
        HeaderText="Please correct the following before booking:"
        ShowSummary="true" />

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card">
                <div class="card-body">

                    <!-- =========== Patient details : TextBox (rubric ID 15) =========== -->
                    <h2 class="h5 border-bottom pb-2 mb-3">Patient details</h2>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="<%= txtFullName.ClientID %>">Full name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="150" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                                ControlToValidate="txtFullName" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Full name is required."
                                Text="Full name is required." />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="<%= txtPhone.ClientID %>">Mobile number <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="10" placeholder="05XXXXXXXX" />
                            <asp:RequiredFieldValidator ID="rfvPhone" runat="server"
                                ControlToValidate="txtPhone" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Mobile number is required."
                                Text="Mobile number is required." />
                            <asp:RegularExpressionValidator ID="revPhone" runat="server"
                                ControlToValidate="txtPhone" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ValidationExpression="^05\d{8}$"
                                ErrorMessage="Mobile number must be a Saudi number in the format 05XXXXXXXX."
                                Text="Use the format 05XXXXXXXX." />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="150" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"
                                ErrorMessage="Enter a valid email address."
                                Text="Enter a valid email address." />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="<%= txtNationalID.ClientID %>">National ID</label>
                            <asp:TextBox ID="txtNationalID" runat="server" CssClass="form-control" MaxLength="20" />
                            <asp:RegularExpressionValidator ID="revNationalID" runat="server"
                                ControlToValidate="txtNationalID" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ValidationExpression="^\d{10}$"
                                ErrorMessage="National ID must be exactly 10 digits."
                                Text="National ID must be 10 digits." />
                        </div>

                        <!-- =========== RadioButtonList (rubric ID 14) =========== -->
                        <div class="col-md-6">
                            <label class="form-label d-block">Gender <span class="text-danger">*</span></label>
                            <asp:RadioButtonList ID="rblGender" runat="server" RepeatDirection="Horizontal"
                                CssClass="cc-radio-inline">
                                <asp:ListItem Value="Male" Text="Male" Selected="True" />
                                <asp:ListItem Value="Female" Text="Female" />
                            </asp:RadioButtonList>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label d-block">Visit type <span class="text-danger">*</span></label>
                            <asp:RadioButtonList ID="rblVisitType" runat="server" RepeatDirection="Horizontal"
                                CssClass="cc-radio-inline">
                                <asp:ListItem Value="New" Text="New patient" Selected="True" />
                                <asp:ListItem Value="Follow-up" Text="Follow-up" />
                            </asp:RadioButtonList>
                        </div>
                    </div>

                    <!-- =========== Appointment : DropDownList (rubric ID 11) =========== -->
                    <h2 class="h5 border-bottom pb-2 mb-3 mt-4">Appointment</h2>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="<%= ddlSpecialty.ClientID %>">Specialty <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlSpecialty" runat="server" CssClass="form-select"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlSpecialty_SelectedIndexChanged" />
                            <%-- InitialValue="0" makes the RequiredFieldValidator reject the
                                 "-- Select a specialty --" placeholder item. --%>
                            <asp:RequiredFieldValidator ID="rfvSpecialty" runat="server"
                                ControlToValidate="ddlSpecialty" InitialValue="0"
                                ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Please select a specialty."
                                Text="Please select a specialty." />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="<%= ddlDoctor.ClientID %>">Doctor <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlDoctor" runat="server" CssClass="form-select" />
                            <asp:RequiredFieldValidator ID="rfvDoctor" runat="server"
                                ControlToValidate="ddlDoctor" InitialValue="0"
                                ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Please select a doctor."
                                Text="Please select a doctor." />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="<%= txtAppointmentDate.ClientID %>">Preferred date <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtAppointmentDate" runat="server" CssClass="form-control" TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvDate" runat="server"
                                ControlToValidate="txtAppointmentDate" ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="Appointment date is required."
                                Text="Appointment date is required." />
                            <%-- MinimumValue is set to today in Page_Load, so past dates are
                                 rejected on the client as well as on the server. --%>
                            <asp:RangeValidator ID="rvDate" runat="server"
                                ControlToValidate="txtAppointmentDate" Type="Date"
                                ValidationGroup="Booking"
                                Display="Dynamic" CssClass="text-danger small"
                                ErrorMessage="The appointment date must be between today and six months from now."
                                Text="Date must be between today and six months ahead." />
                        </div>
                    </div>

                    <!-- =========== CheckBoxList (rubric ID 13) =========== -->
                    <div class="mt-3">
                        <label class="form-label d-block">Preferred time slot <span class="text-danger">*</span>
                            <span class="text-muted small">(the earliest slot you tick is reserved)</span>
                        </label>
                        <asp:CheckBoxList ID="cblTimeSlots" runat="server" RepeatDirection="Horizontal"
                            RepeatColumns="4" CssClass="cc-check-inline">
                            <asp:ListItem Value="08:00 AM" Text="08:00 AM" />
                            <asp:ListItem Value="09:00 AM" Text="09:00 AM" />
                            <asp:ListItem Value="10:00 AM" Text="10:00 AM" />
                            <asp:ListItem Value="11:00 AM" Text="11:00 AM" />
                            <asp:ListItem Value="12:00 PM" Text="12:00 PM" />
                            <asp:ListItem Value="01:00 PM" Text="01:00 PM" />
                            <asp:ListItem Value="02:00 PM" Text="02:00 PM" />
                            <asp:ListItem Value="03:00 PM" Text="03:00 PM" />
                        </asp:CheckBoxList>
                        <%-- A CheckBoxList cannot be handled by RequiredFieldValidator,
                             so a CustomValidator with both a client-side and a
                             server-side check enforces "at least one slot". --%>
                        <asp:CustomValidator ID="cvTimeSlot" runat="server"
                            ValidationGroup="Booking"
                            Display="Dynamic" CssClass="text-danger small"
                            ClientValidationFunction="ccValidateTimeSlot"
                            OnServerValidate="cvTimeSlot_ServerValidate"
                            ErrorMessage="Please choose at least one time slot."
                            Text="Please choose at least one time slot." />
                    </div>

                    <div class="mt-3">
                        <label class="form-label d-block">Symptoms <span class="text-muted small">(select all that apply)</span></label>
                        <asp:CheckBoxList ID="cblSymptoms" runat="server" RepeatDirection="Horizontal"
                            RepeatColumns="3" CssClass="cc-check-inline">
                            <asp:ListItem Value="Pain" Text="Pain" />
                            <asp:ListItem Value="Fever" Text="Fever" />
                            <asp:ListItem Value="Swelling" Text="Swelling" />
                            <asp:ListItem Value="Fatigue" Text="Fatigue" />
                            <asp:ListItem Value="Headache" Text="Headache" />
                            <asp:ListItem Value="Other" Text="Other" />
                        </asp:CheckBoxList>
                    </div>

                    <div class="mt-3">
                        <label class="form-label" for="<%= txtNotes.ClientID %>">Additional notes</label>
                        <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine"
                            Rows="3" MaxLength="500" />
                    </div>

                    <!-- =========== Button (rubric ID 12) =========== -->
                    <div class="mt-4">
                        <asp:Button ID="btnBook" runat="server" Text="Confirm Booking"
                            CssClass="btn btn-primary btn-lg" OnClick="btnBook_Click"
                            ValidationGroup="Booking" />
                        <asp:Button ID="btnReset" runat="server" Text="Clear form"
                            CssClass="btn btn-outline-secondary btn-lg ms-2"
                            CausesValidation="false" OnClick="btnReset_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- ====== Confirmation summary: every captured value posted to the screen ====== -->
        <div class="col-lg-4">
            <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="card border-success">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-check-circle me-1"></i>Booking confirmed
                </div>
                <div class="card-body">
                    <p class="small text-muted">
                        Reference number
                        <span class="badge bg-success"><asp:Literal ID="litReference" runat="server" /></span>
                    </p>
                    <dl class="row mb-0 small">
                        <dt class="col-5">Patient</dt>      <dd class="col-7"><asp:Literal ID="litSumName" runat="server" /></dd>
                        <dt class="col-5">Gender</dt>       <dd class="col-7"><asp:Literal ID="litSumGender" runat="server" /></dd>
                        <dt class="col-5">Mobile</dt>       <dd class="col-7"><asp:Literal ID="litSumPhone" runat="server" /></dd>
                        <dt class="col-5">Email</dt>        <dd class="col-7"><asp:Literal ID="litSumEmail" runat="server" /></dd>
                        <dt class="col-5">Specialty</dt>    <dd class="col-7"><asp:Literal ID="litSumSpecialty" runat="server" /></dd>
                        <dt class="col-5">Doctor</dt>       <dd class="col-7"><asp:Literal ID="litSumDoctor" runat="server" /></dd>
                        <dt class="col-5">Date</dt>         <dd class="col-7"><asp:Literal ID="litSumDate" runat="server" /></dd>
                        <dt class="col-5">Time slot</dt>    <dd class="col-7"><asp:Literal ID="litSumSlot" runat="server" /></dd>
                        <dt class="col-5">Visit type</dt>   <dd class="col-7"><asp:Literal ID="litSumVisitType" runat="server" /></dd>
                        <dt class="col-5">Symptoms</dt>     <dd class="col-7"><asp:Literal ID="litSumSymptoms" runat="server" /></dd>
                        <dt class="col-5">Notes</dt>        <dd class="col-7"><asp:Literal ID="litSumNotes" runat="server" /></dd>
                        <dt class="col-5">Status</dt>       <dd class="col-7"><asp:Literal ID="litSumStatus" runat="server" /></dd>
                    </dl>
                </div>
                <div class="card-footer bg-white">
                    <a class="btn btn-sm btn-outline-primary" href="<%: ResolveUrl("~/MyAppointments.aspx") %>">
                        View my appointments
                    </a>
                </div>
            </asp:Panel>
        </div>
    </div>

</asp:Content>
