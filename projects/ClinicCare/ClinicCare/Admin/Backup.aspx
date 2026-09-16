<%@ Page Title="Database Backup" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Backup.aspx.cs" Inherits="ClinicCare.Admin.Backup" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="h3 mb-1">Database Backup</h1>
    <p class="text-muted">Take an on-demand full backup of ClinicDB and review existing backup files.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <div class="card mb-4">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-8">
                    <label class="form-label" for="<%= txtBackupFolder.ClientID %>">Backup folder (on the database server)</label>
                    <asp:TextBox ID="txtBackupFolder" runat="server" CssClass="form-control" ReadOnly="true" />
                    <div class="form-text">
                        Configured in Web.config as <code>BackupFolder</code>. The SQL Server service
                        account must have write access to this folder.
                    </div>
                </div>
                <div class="col-md-4">
                    <asp:Button ID="btnBackupNow" runat="server" Text="Backup Now"
                        CssClass="btn btn-primary btn-lg w-100"
                        OnClick="btnBackupNow_Click" CausesValidation="false"
                        OnClientClick="this.value='Backing up...';" />
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-2">
        <h2 class="h5 mb-0">Existing backup files</h2>
        <asp:Button ID="btnRefresh" runat="server" Text="Refresh"
            CssClass="btn btn-sm btn-outline-secondary"
            OnClick="btnRefresh_Click" CausesValidation="false" />
    </div>

    <asp:GridView ID="gvBackups" runat="server" AutoGenerateColumns="false"
        CssClass="table table-striped table-hover align-middle"
        HeaderStyle-CssClass="table-primary" GridLines="None"
        EmptyDataText="No backup files found in the configured folder.">
        <Columns>
            <asp:BoundField DataField="FileName" HeaderText="File" />
            <asp:BoundField DataField="SizeMb"   HeaderText="Size (MB)" DataFormatString="{0:N2}" />
            <asp:BoundField DataField="Created"  HeaderText="Created" DataFormatString="{0:dd MMM yyyy HH:mm}" />
        </Columns>
    </asp:GridView>

    <div class="alert alert-secondary mt-4 small">
        <strong>Restoring.</strong> Restores are performed by an administrator in SSMS using
        <code>db/11_Restore.sql</code>, not from this page. A restore needs exclusive access to the
        database, which would disconnect the running web application, so it is deliberately not
        exposed as a button here.
    </div>

</asp:Content>
