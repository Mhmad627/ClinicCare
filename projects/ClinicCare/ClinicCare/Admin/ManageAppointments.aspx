<%@ Page Title="Manage Appointments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ManageAppointments.aspx.cs" Inherits="ClinicCare.Admin.ManageAppointments" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Manage Appointments</h1>
    <p class="text-muted">Review every booking, change its status or remove it.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <div class="row g-2 align-items-end mb-3">
        <div class="col-md-3">
            <label class="form-label" for="<%= ddlFilterStatus.ClientID %>">Filter by status</label>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                <asp:ListItem Value="" Text="All statuses" />
                <asp:ListItem Value="Pending" Text="Pending" />
                <asp:ListItem Value="Confirmed" Text="Confirmed" />
                <asp:ListItem Value="Completed" Text="Completed" />
                <asp:ListItem Value="Cancelled" Text="Cancelled" />
            </asp:DropDownList>
        </div>
    </div>

    <!-- GridView with inline editing of the appointment status -->
    <asp:GridView ID="gvAppointments" runat="server" AutoGenerateColumns="false"
        DataKeyNames="AppointmentID"
        CssClass="table table-striped table-hover align-middle"
        HeaderStyle-CssClass="table-primary" GridLines="None"
        AllowPaging="true" PageSize="10"
        AllowSorting="true"
        EmptyDataText="No appointments match this filter."
        OnPageIndexChanging="gvAppointments_PageIndexChanging"
        OnSorting="gvAppointments_Sorting"
        OnRowEditing="gvAppointments_RowEditing"
        OnRowCancelingEdit="gvAppointments_RowCancelingEdit"
        OnRowUpdating="gvAppointments_RowUpdating"
        OnRowCommand="gvAppointments_RowCommand">
        <Columns>
            <asp:BoundField DataField="AppointmentID" HeaderText="Ref #" ReadOnly="true"
                SortExpression="AppointmentID" />
            <asp:BoundField DataField="PatientName"   HeaderText="Patient"   ReadOnly="true"
                SortExpression="PatientName" />
            <asp:BoundField DataField="PatientPhone"  HeaderText="Mobile"    ReadOnly="true" />
            <asp:BoundField DataField="DoctorName"    HeaderText="Doctor"    ReadOnly="true"
                SortExpression="DoctorName" />
            <asp:BoundField DataField="SpecialtyName" HeaderText="Specialty" ReadOnly="true"
                SortExpression="SpecialtyName" />

            <asp:TemplateField HeaderText="Date" SortExpression="AppointmentDate">
                <ItemTemplate>
                    <%# Eval("AppointmentDate", "{0:dd MMM yyyy}") %>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtEditDate" runat="server" CssClass="form-control form-control-sm"
                        TextMode="Date" Text='<%# Eval("AppointmentDate", "{0:yyyy-MM-dd}") %>' />
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Time">
                <ItemTemplate><%# Eval("TimeSlot") %></ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtEditTimeSlot" runat="server" CssClass="form-control form-control-sm"
                        Text='<%# Eval("TimeSlot") %>' />
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Visit type">
                <ItemTemplate><%# Eval("VisitType") %></ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlEditVisitType" runat="server" CssClass="form-select form-select-sm"
                        SelectedValue='<%# Eval("VisitType") %>'>
                        <asp:ListItem Value="New" Text="New" />
                        <asp:ListItem Value="Follow-up" Text="Follow-up" />
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Status" SortExpression="Status">
                <ItemTemplate>
                    <span class='<%# StatusBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select form-select-sm"
                        SelectedValue='<%# Eval("Status") %>'>
                        <asp:ListItem Value="Pending" Text="Pending" />
                        <asp:ListItem Value="Confirmed" Text="Confirmed" />
                        <asp:ListItem Value="Completed" Text="Completed" />
                        <asp:ListItem Value="Cancelled" Text="Cancelled" />
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-outline-primary"
                        CommandName="Edit">
                        <i class="bi bi-pencil"></i> Edit
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkDelete" runat="server" CssClass="btn btn-sm btn-outline-danger ms-1"
                        CommandName="DeleteAppointment" CommandArgument='<%# Eval("AppointmentID") %>'
                        OnClientClick="return confirm('Delete this appointment?');">
                        <i class="bi bi-trash"></i> Delete
                    </asp:LinkButton>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:LinkButton ID="lnkUpdate" runat="server" CssClass="btn btn-sm btn-success"
                        CommandName="Update">
                        <i class="bi bi-check-lg"></i> Save
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkCancel" runat="server" CssClass="btn btn-sm btn-outline-secondary ms-1"
                        CommandName="Cancel" CausesValidation="false">
                        Cancel
                    </asp:LinkButton>
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
        <PagerStyle CssClass="cc-pager" />
    </asp:GridView>

</asp:Content>
