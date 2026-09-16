<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="ClinicCare.Default" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===================== Hero ===================== -->
    <div class="p-5 mb-4 bg-light rounded-3 border">
        <div class="container-fluid py-3">
            <h1 class="display-5 fw-bold">Your health, one appointment away</h1>
            <p class="col-md-9 fs-5 text-muted">
                ClinicCare lets you browse our consultants by specialty, book an appointment
                in a few clicks and track your visits &mdash; all in one place.
            </p>
            <a class="btn btn-primary btn-lg" href="<%: ResolveUrl("~/BookAppointment.aspx") %>">
                <i class="bi bi-calendar-plus me-1"></i>Book an Appointment
            </a>
            <a class="btn btn-outline-secondary btn-lg ms-2" href="<%: ResolveUrl("~/Doctors.aspx") %>">
                Meet our Doctors
            </a>
        </div>
    </div>

    <!-- ===================== At a glance ===================== -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card text-center h-100 border-primary">
                <div class="card-body">
                    <div class="display-6 fw-bold text-primary"><asp:Literal ID="litDoctorCount" runat="server" /></div>
                    <div class="text-muted">Consultants available</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-center h-100 border-primary">
                <div class="card-body">
                    <div class="display-6 fw-bold text-primary"><asp:Literal ID="litSpecialtyCount" runat="server" /></div>
                    <div class="text-muted">Medical specialties</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-center h-100 border-primary">
                <div class="card-body">
                    <div class="display-6 fw-bold text-primary"><asp:Literal ID="litPatientCount" runat="server" /></div>
                    <div class="text-muted">Registered patients</div>
                </div>
            </div>
        </div>
    </div>

    <!-- ===================== Quick links ===================== -->
    <h2 class="h4 mb-3">Quick links</h2>
    <div class="row g-3">
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-body">
                    <h5 class="card-title"><i class="bi bi-calendar-plus text-primary me-1"></i>Book Appointment</h5>
                    <p class="card-text text-muted">Choose a specialty, pick a consultant and reserve a time slot.</p>
                    <a class="btn btn-sm btn-outline-primary" href="<%: ResolveUrl("~/BookAppointment.aspx") %>">Go</a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-body">
                    <h5 class="card-title"><i class="bi bi-list-check text-primary me-1"></i>My Appointments</h5>
                    <p class="card-text text-muted">Look up your bookings with your phone number or National ID.</p>
                    <a class="btn btn-sm btn-outline-primary" href="<%: ResolveUrl("~/MyAppointments.aspx") %>">Go</a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-body">
                    <h5 class="card-title"><i class="bi bi-people text-primary me-1"></i>Our Doctors</h5>
                    <p class="card-text text-muted">Browse consultant profiles across all clinic specialties.</p>
                    <a class="btn btn-sm btn-outline-primary" href="<%: ResolveUrl("~/Doctors.aspx") %>">Go</a>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
