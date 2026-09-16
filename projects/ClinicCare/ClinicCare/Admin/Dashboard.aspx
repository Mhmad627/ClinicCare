<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs" Inherits="ClinicCare.Admin.Dashboard" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Admin Dashboard</h1>
    <p class="text-muted">Clinic activity at a glance.</p>

    <!-- ===================== Statistics ===================== -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-primary"><asp:Literal ID="litTotalPatients" runat="server" /></div>
                    <div class="small text-muted">Patients</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-primary"><asp:Literal ID="litActiveDoctors" runat="server" /></div>
                    <div class="small text-muted">Active doctors</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-primary"><asp:Literal ID="litTotalAppointments" runat="server" /></div>
                    <div class="small text-muted">Appointments</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100 border-info">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-info"><asp:Literal ID="litTodaysAppointments" runat="server" /></div>
                    <div class="small text-muted">Today</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100 border-warning">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-warning"><asp:Literal ID="litPending" runat="server" /></div>
                    <div class="small text-muted">Pending</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-2">
            <div class="card text-center h-100 border-success">
                <div class="card-body py-3">
                    <div class="h3 mb-0 text-success"><asp:Literal ID="litConfirmed" runat="server" /></div>
                    <div class="small text-muted">Confirmed</div>
                </div>
            </div>
        </div>
    </div>

    <!-- ===================== Export (rubric ID 4) ===================== -->
    <div class="card mb-4">
        <div class="card-body d-flex flex-wrap align-items-center gap-2">
            <span class="me-2 fw-semibold">Export the full appointments list:</span>

            <asp:Button ID="btnExportExcel" runat="server" Text="Export to Excel"
                CssClass="btn btn-success" OnClick="btnExportExcel_Click" CausesValidation="false" />

            <asp:Button ID="btnExportWord" runat="server" Text="Export to Word"
                CssClass="btn btn-primary" OnClick="btnExportWord_Click" CausesValidation="false" />

            <asp:Button ID="btnExportPdf" runat="server" Text="Export to PDF"
                CssClass="btn btn-danger" OnClick="btnExportPdf_Click" CausesValidation="false" />

            <span class="text-muted small ms-auto">
                <asp:Literal ID="litExportCount" runat="server" /> appointments will be included.
            </span>
        </div>
    </div>

    <!-- ===================== Today's schedule ===================== -->
    <div class="d-flex justify-content-between align-items-center mb-2">
        <h2 class="h5 mb-0">Today's appointments</h2>
        <a class="btn btn-sm btn-outline-primary" href="<%: ResolveUrl("~/Admin/ManageAppointments.aspx") %>">
            Manage all appointments
        </a>
    </div>

    <asp:GridView ID="gvToday" runat="server" AutoGenerateColumns="false"
        DataKeyNames="AppointmentID"
        CssClass="table table-striped table-hover align-middle"
        HeaderStyle-CssClass="table-primary" GridLines="None"
        EmptyDataText="There are no appointments scheduled for today.">
        <Columns>
            <asp:BoundField DataField="AppointmentID" HeaderText="Ref #" />
            <asp:BoundField DataField="TimeSlot"      HeaderText="Time" />
            <asp:BoundField DataField="PatientName"   HeaderText="Patient" />
            <asp:BoundField DataField="DoctorName"    HeaderText="Doctor" />
            <asp:BoundField DataField="SpecialtyName" HeaderText="Specialty" />
            <asp:BoundField DataField="VisitType"     HeaderText="Visit type" />
            <asp:TemplateField HeaderText="Status">
                <ItemTemplate>
                    <span class='<%# StatusBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <!-- Note: Export to Excel / Word / PDF buttons are added here in Week 6. -->

</asp:Content>
