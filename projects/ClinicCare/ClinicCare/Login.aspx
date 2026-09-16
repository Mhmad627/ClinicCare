<%@ Page Title="Sign In" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="ClinicCare.Login" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">

            <h1 class="h3 mb-1">Sign in</h1>
            <p class="text-muted">Sign in to book and manage your appointments.</p>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="card">
                <div class="card-body">

                    <!-- ASP.NET Login control (rubric ID 5) -->
                    <asp:Login ID="ctlLogin" runat="server"
                        RenderOuterTable="false"
                        DestinationPageUrl="~/Default.aspx"
                        OnLoginError="ctlLogin_LoginError"
                        FailureText="Sign-in failed. Please check your username and password.">
                        <LayoutTemplate>

                            <div class="mb-3">
                                <label class="form-label" for="<%# Container.FindControl("UserName").ClientID %>">
                                    Username <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="UserName" runat="server" CssClass="form-control" MaxLength="60" />
                                <asp:RequiredFieldValidator ID="rfvUserName" runat="server"
                                    ControlToValidate="UserName"
                                    ValidationGroup="Login"
                                    Display="Dynamic"
                                    CssClass="text-danger small"
                                    ErrorMessage="Username is required."
                                    Text="Username is required." />
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="<%# Container.FindControl("Password").ClientID %>">
                                    Password <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="Password" runat="server" CssClass="form-control" TextMode="Password" />
                                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                    ControlToValidate="Password"
                                    ValidationGroup="Login"
                                    Display="Dynamic"
                                    CssClass="text-danger small"
                                    ErrorMessage="Password is required."
                                    Text="Password is required." />
                            </div>

                            <div class="form-check mb-3">
                                <asp:CheckBox ID="RememberMe" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%# Container.FindControl("RememberMe").ClientID %>">
                                    Keep me signed in
                                </label>
                            </div>

                            <asp:Literal ID="FailureText" runat="server" />

                            <div class="d-grid">
                                <asp:Button ID="LoginButton" runat="server"
                                    CommandName="Login"
                                    Text="Sign in"
                                    CssClass="btn btn-primary btn-lg"
                                    ValidationGroup="Login" />
                            </div>

                        </LayoutTemplate>
                    </asp:Login>

                </div>
                <div class="card-footer bg-white text-center">
                    Don't have an account?
                    <a href="<%: ResolveUrl("~/Register.aspx") %>">Create one</a>
                </div>
            </div>

        </div>
    </div>

</asp:Content>
