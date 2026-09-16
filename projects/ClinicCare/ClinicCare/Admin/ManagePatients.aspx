<%@ Page Title="Manage Patients" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ManagePatients.aspx.cs" Inherits="ClinicCare.Admin.ManagePatients" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Manage Patients</h1>
    <p class="text-muted">Add, edit and remove patient records. All operations run through stored procedures.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <asp:ValidationSummary ID="vsPatient" runat="server"
        ValidationGroup="Patient"
        CssClass="alert alert-danger"
        HeaderText="Please correct the following:" />

    <!-- ===================== Insert / edit form ===================== -->
    <div class="card mb-4">
        <div class="card-header bg-white fw-semibold">
            <asp:Literal ID="litFormTitle" runat="server" Text="Add a new patient" />
        </div>
        <div class="card-body">
            <asp:HiddenField ID="hfPatientID" runat="server" Value="0" />

            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label" for="<%= txtFullName.ClientID %>">Full name <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="150" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                        ControlToValidate="txtFullName" ValidationGroup="Patient"
                        Display="Dynamic" CssClass="text-danger small"
                        ErrorMessage="Full name is required." Text="Required." />
                </div>
                <div class="col-md-2">
                    <label class="form-label d-block">Gender <span class="text-danger">*</span></label>
                    <asp:RadioButtonList ID="rblGender" runat="server" RepeatDirection="Horizontal" CssClass="cc-radio-inline">
                        <asp:ListItem Value="Male" Text="Male" Selected="True" />
                        <asp:ListItem Value="Female" Text="Female" />
                    </asp:RadioButtonList>
                </div>
                <div class="col-md-3">
                    <label class="form-label" for="<%= txtDateOfBirth.ClientID %>">Date of birth</label>
                    <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-3">
                    <label class="form-label" for="<%= txtPhone.ClientID %>">Mobile <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="10" placeholder="05XXXXXXXX" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server"
                        ControlToValidate="txtPhone" ValidationGroup="Patient"
                        Display="Dynamic" CssClass="text-danger small"
                        ErrorMessage="Mobile number is required." Text="Required." />
                    <asp:RegularExpressionValidator ID="revPhone" runat="server"
                        ControlToValidate="txtPhone" ValidationGroup="Patient"
                        Display="Dynamic" CssClass="text-danger small"
                        ValidationExpression="^05\d{8}$"
                        ErrorMessage="Mobile number must be in the format 05XXXXXXXX."
                        Text="Use 05XXXXXXXX." />
                </div>
                <div class="col-md-4">
                    <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="150" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server"
                        ControlToValidate="txtEmail" ValidationGroup="Patient"
                        Display="Dynamic" CssClass="text-danger small"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"
                        ErrorMessage="Enter a valid email address." Text="Invalid email." />
                </div>
                <div class="col-md-3">
                    <label class="form-label" for="<%= txtNationalID.ClientID %>">National ID</label>
                    <asp:TextBox ID="txtNationalID" runat="server" CssClass="form-control" MaxLength="20" />
                    <asp:RegularExpressionValidator ID="revNationalID" runat="server"
                        ControlToValidate="txtNationalID" ValidationGroup="Patient"
                        Display="Dynamic" CssClass="text-danger small"
                        ValidationExpression="^\d{10}$"
                        ErrorMessage="National ID must be exactly 10 digits." Text="10 digits." />
                </div>
                <div class="col-md-5">
                    <label class="form-label" for="<%= txtNotes.ClientID %>">Notes</label>
                    <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" MaxLength="500" />
                </div>
            </div>

            <div class="mt-3">
                <asp:Button ID="btnSave" runat="server" Text="Save patient"
                    CssClass="btn btn-primary" OnClick="btnSave_Click"
                    ValidationGroup="Patient" />
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" Visible="false"
                    CssClass="btn btn-outline-secondary ms-2" OnClick="btnCancelEdit_Click" />
            </div>
        </div>
    </div>

    <!-- ===================== Search + GridView ===================== -->
    <div class="row g-2 align-items-end mb-3">
        <div class="col-md-4">
            <label class="form-label" for="<%= txtSearch.ClientID %>">Search by name, mobile or National ID</label>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" />
        </div>
        <div class="col-md-2">
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-primary w-100"
                OnClick="btnSearch_Click" CausesValidation="false" />
        </div>
        <div class="col-md-2">
            <asp:Button ID="btnClearSearch" runat="server" Text="Show all" CssClass="btn btn-outline-secondary w-100"
                OnClick="btnClearSearch_Click" CausesValidation="false" />
        </div>
    </div>

    <asp:GridView ID="gvPatients" runat="server" AutoGenerateColumns="false"
        DataKeyNames="PatientID"
        CssClass="table table-striped table-hover align-middle"
        HeaderStyle-CssClass="table-primary" GridLines="None"
        AllowPaging="true" PageSize="10"
        AllowSorting="true"
        EmptyDataText="No patients match your search."
        OnPageIndexChanging="gvPatients_PageIndexChanging"
        OnSorting="gvPatients_Sorting"
        OnRowCommand="gvPatients_RowCommand">
        <Columns>
            <asp:BoundField DataField="PatientID"  HeaderText="ID"          SortExpression="PatientID" />
            <asp:BoundField DataField="FullName"   HeaderText="Full name"   SortExpression="FullName" />
            <asp:BoundField DataField="Gender"     HeaderText="Gender"      SortExpression="Gender" />
            <asp:BoundField DataField="DateOfBirth" HeaderText="Date of birth"
                DataFormatString="{0:dd MMM yyyy}" SortExpression="DateOfBirth" />
            <asp:BoundField DataField="Phone"      HeaderText="Mobile"      SortExpression="Phone" />
            <asp:BoundField DataField="Email"      HeaderText="Email"       SortExpression="Email" />
            <asp:BoundField DataField="NationalID" HeaderText="National ID" SortExpression="NationalID" />

            <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-outline-primary"
                        CommandName="EditPatient" CommandArgument='<%# Eval("PatientID") %>'
                        CausesValidation="false">
                        <i class="bi bi-pencil"></i> Edit
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkDelete" runat="server" CssClass="btn btn-sm btn-outline-danger ms-1"
                        CommandName="DeletePatient" CommandArgument='<%# Eval("PatientID") %>'
                        CausesValidation="false"
                        OnClientClick="return confirm('Delete this patient?');">
                        <i class="bi bi-trash"></i> Delete
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <PagerStyle CssClass="cc-pager" />
    </asp:GridView>

</asp:Content>
