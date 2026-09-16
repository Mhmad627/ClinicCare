<%@ Page Title="Manage Doctors" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ManageDoctors.aspx.cs" Inherits="ClinicCare.Admin.ManageDoctors" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Manage Doctors</h1>
    <p class="text-muted">Maintain the consultant directory and their specialties.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <asp:ValidationSummary ID="vsDoctor" runat="server"
        ValidationGroup="Doctor"
        CssClass="alert alert-danger"
        HeaderText="Please correct the following:" />

    <!-- ===================== Insert / edit form ===================== -->
    <div class="card mb-4">
        <div class="card-header bg-white fw-semibold">
            <asp:Literal ID="litFormTitle" runat="server" Text="Add a new doctor" />
        </div>
        <div class="card-body">
            <asp:HiddenField ID="hfDoctorID" runat="server" Value="0" />

            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label" for="<%= txtFullName.ClientID %>">Full name <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="150" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                        ControlToValidate="txtFullName" ValidationGroup="Doctor"
                        Display="Dynamic" CssClass="text-danger small"
                        ErrorMessage="Doctor's full name is required." Text="Required." />
                </div>

                <!-- DropDownList bound to tblSpecialties -->
                <div class="col-md-3">
                    <label class="form-label" for="<%= ddlSpecialty.ClientID %>">Specialty <span class="text-danger">*</span></label>
                    <asp:DropDownList ID="ddlSpecialty" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvSpecialty" runat="server"
                        ControlToValidate="ddlSpecialty" InitialValue="0" ValidationGroup="Doctor"
                        Display="Dynamic" CssClass="text-danger small"
                        ErrorMessage="Please select a specialty." Text="Required." />
                </div>

                <div class="col-md-3">
                    <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="150" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server"
                        ControlToValidate="txtEmail" ValidationGroup="Doctor"
                        Display="Dynamic" CssClass="text-danger small"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"
                        ErrorMessage="Enter a valid email address." Text="Invalid email." />
                </div>
                <div class="col-md-2">
                    <label class="form-label" for="<%= txtPhone.ClientID %>">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="10" placeholder="05XXXXXXXX" />
                    <asp:RegularExpressionValidator ID="revPhone" runat="server"
                        ControlToValidate="txtPhone" ValidationGroup="Doctor"
                        Display="Dynamic" CssClass="text-danger small"
                        ValidationExpression="^05\d{8}$"
                        ErrorMessage="Phone must be in the format 05XXXXXXXX." Text="Use 05XXXXXXXX." />
                </div>
                <div class="col-md-8">
                    <label class="form-label" for="<%= txtBio.ClientID %>">Biography</label>
                    <asp:TextBox ID="txtBio" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" MaxLength="500" />
                </div>
                <div class="col-md-3">
                    <label class="form-label" for="<%= txtPhotoUrl.ClientID %>">Photo URL</label>
                    <asp:TextBox ID="txtPhotoUrl" runat="server" CssClass="form-control" MaxLength="260" />
                </div>
                <div class="col-md-1 d-flex align-items-end">
                    <div class="form-check mb-2">
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-check-input" />
                        <label class="form-check-label" for="<%= chkIsActive.ClientID %>">Active</label>
                    </div>
                </div>
            </div>

            <div class="mt-3">
                <asp:Button ID="btnSave" runat="server" Text="Save doctor"
                    CssClass="btn btn-primary" OnClick="btnSave_Click"
                    ValidationGroup="Doctor" />
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" Visible="false"
                    CssClass="btn btn-outline-secondary ms-2" OnClick="btnCancelEdit_Click" />
            </div>
        </div>
    </div>

    <!-- ===================== GridView ===================== -->
    <asp:GridView ID="gvDoctors" runat="server" AutoGenerateColumns="false"
        DataKeyNames="DoctorID"
        CssClass="table table-striped table-hover align-middle"
        HeaderStyle-CssClass="table-primary" GridLines="None"
        AllowPaging="true" PageSize="10"
        AllowSorting="true"
        EmptyDataText="No doctors have been added yet."
        OnPageIndexChanging="gvDoctors_PageIndexChanging"
        OnSorting="gvDoctors_Sorting"
        OnRowCommand="gvDoctors_RowCommand">
        <Columns>
            <asp:BoundField DataField="DoctorID"      HeaderText="ID"        SortExpression="DoctorID" />
            <asp:BoundField DataField="FullName"      HeaderText="Full name" SortExpression="FullName" />
            <asp:BoundField DataField="SpecialtyName" HeaderText="Specialty" SortExpression="SpecialtyName" />
            <asp:BoundField DataField="Email"         HeaderText="Email"     SortExpression="Email" />
            <asp:BoundField DataField="Phone"         HeaderText="Phone"     SortExpression="Phone" />

            <asp:TemplateField HeaderText="Status" SortExpression="IsActive">
                <ItemTemplate>
                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge bg-success" : "badge bg-secondary" %>'>
                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-outline-primary"
                        CommandName="EditDoctor" CommandArgument='<%# Eval("DoctorID") %>'
                        CausesValidation="false">
                        <i class="bi bi-pencil"></i> Edit
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkDelete" runat="server" CssClass="btn btn-sm btn-outline-danger ms-1"
                        CommandName="DeleteDoctor" CommandArgument='<%# Eval("DoctorID") %>'
                        CausesValidation="false"
                        OnClientClick="return confirm('Delete this doctor?');">
                        <i class="bi bi-trash"></i> Delete
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <PagerStyle CssClass="cc-pager" />
    </asp:GridView>

</asp:Content>
