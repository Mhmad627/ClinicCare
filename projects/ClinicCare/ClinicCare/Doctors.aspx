<%@ Page Title="Doctors" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Doctors.aspx.cs" Inherits="ClinicCare.Doctors" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-1">Our Doctors</h1>
            <p class="text-muted mb-0">Consultants and specialists currently accepting appointments.</p>
        </div>
        <div style="min-width: 240px;">
            <asp:DropDownList ID="ddlFilterSpecialty" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSpecialty_SelectedIndexChanged" />
        </div>
    </div>

    <!-- =============== Repeater control (rubric ID 16) =============== -->
    <asp:Repeater ID="rptDoctors" runat="server">
        <HeaderTemplate>
            <div class="row g-4">
        </HeaderTemplate>

        <ItemTemplate>
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 shadow-sm">
                    <div class="card-body d-flex flex-column">
                        <div class="d-flex align-items-center mb-3">
                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center flex-shrink-0"
                                 style="width:56px;height:56px;font-size:1.4rem;">
                                <i class="bi bi-person-fill"></i>
                            </div>
                            <div class="ms-3">
                                <h5 class="card-title mb-0"><%# Eval("FullName") %></h5>
                                <span class="badge bg-secondary mt-1"><%# Eval("SpecialtyName") %></span>
                            </div>
                        </div>

                        <p class="card-text text-muted small flex-grow-1"><%# Eval("Bio") %></p>

                        <ul class="list-unstyled small text-muted mb-3">
                            <li><i class="bi bi-envelope me-1"></i><%# Eval("Email") %></li>
                            <li><i class="bi bi-telephone me-1"></i><%# Eval("Phone") %></li>
                        </ul>

                        <a class="btn btn-sm btn-primary mt-auto"
                           href='<%# ResolveUrl("~/BookAppointment.aspx?doctorId=") + Eval("DoctorID") %>'>
                            <i class="bi bi-calendar-plus me-1"></i>Book with this doctor
                        </a>
                    </div>
                </div>
            </div>
        </ItemTemplate>

        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlNoDoctors" runat="server" Visible="false" CssClass="alert alert-info">
        No doctors are currently listed for this specialty.
    </asp:Panel>

</asp:Content>
