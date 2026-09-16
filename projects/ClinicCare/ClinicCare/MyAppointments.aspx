<%@ Page Title="My Appointments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="MyAppointments.aspx.cs" Inherits="ClinicCare.MyAppointments" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">My Appointments</h1>
    <p class="text-muted">Enter the mobile number or National ID you booked with.</p>

    <div class="card mb-4">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-md-6">
                    <label class="form-label" for="<%= txtLookup.ClientID %>">Mobile number or National ID</label>
                    <asp:TextBox ID="txtLookup" runat="server" CssClass="form-control" MaxLength="20"
                        placeholder="05XXXXXXXX" />
                </div>
                <div class="col-md-3">
                    <asp:Button ID="btnLookup" runat="server" Text="Find my appointments"
                        CssClass="btn btn-primary w-100" OnClick="btnLookup_Click" />
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <asp:GridView ID="gvMyAppointments" runat="server" AutoGenerateColumns="false"
            CssClass="table table-striped table-hover align-middle"
            HeaderStyle-CssClass="table-primary" GridLines="None"
            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvMyAppointments_PageIndexChanging"
            DataKeyNames="AppointmentID" EmptyDataText="No appointments found.">
            <Columns>
                <asp:BoundField DataField="AppointmentID" HeaderText="Ref #" />
                <asp:BoundField DataField="DoctorName" HeaderText="Doctor" />
                <asp:BoundField DataField="SpecialtyName" HeaderText="Specialty" />
                <asp:BoundField DataField="AppointmentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                <asp:BoundField DataField="TimeSlot" HeaderText="Time" />
                <asp:BoundField DataField="VisitType" HeaderText="Visit type" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='<%# StatusBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <PagerStyle CssClass="cc-pager" />
        </asp:GridView>
    </asp:Panel>

</asp:Content>
