<%@ Page Title="Create Account" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Register.aspx.cs" Inherits="ClinicCare.Register" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">

            <h1 class="h3 mb-1">Create an account</h1>
            <p class="text-muted">New patients register here. Accounts are assigned the Patient role.</p>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="card">
                <div class="card-body">

                    <!-- CreateUserWizard - the new account is added to the Patient role
                         in CreatedUser (see code-behind). -->
                    <asp:CreateUserWizard ID="ctlCreateUser" runat="server"
                        RenderOuterTable="false"
                        LoginCreatedUser="true"
                        ContinueDestinationPageUrl="~/Default.aspx"
                        OnCreatedUser="ctlCreateUser_CreatedUser"
                        OnCreateUserError="ctlCreateUser_CreateUserError">
                        <WizardSteps>

                            <asp:CreateUserWizardStep ID="stepCreateUser" runat="server">
                                <ContentTemplate>

                                    <div class="mb-3">
                                        <label class="form-label" for="<%# Container.FindControl("UserName").ClientID %>">
                                            Username <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="UserName" runat="server" CssClass="form-control" MaxLength="60" />
                                        <asp:RequiredFieldValidator ID="rfvUserName" runat="server"
                                            ControlToValidate="UserName" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ErrorMessage="Username is required."
                                            Text="Username is required." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label" for="<%# Container.FindControl("Email").ClientID %>">
                                            Email <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="Email" runat="server" CssClass="form-control" TextMode="Email" MaxLength="150" />
                                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                            ControlToValidate="Email" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ErrorMessage="Email is required."
                                            Text="Email is required." />
                                        <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                            ControlToValidate="Email" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"
                                            ErrorMessage="Enter a valid email address."
                                            Text="Enter a valid email address." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label" for="<%# Container.FindControl("Password").ClientID %>">
                                            Password <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="Password" runat="server" CssClass="form-control" TextMode="Password" />
                                        <div class="form-text">
                                            At least 7 characters, including one symbol (for example <code>!</code> or <code>#</code>).
                                        </div>
                                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                            ControlToValidate="Password" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ErrorMessage="Password is required."
                                            Text="Password is required." />
                                        <asp:RegularExpressionValidator ID="revPassword" runat="server"
                                            ControlToValidate="Password" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ValidationExpression="^(?=.*[^a-zA-Z0-9]).{7,}$"
                                            ErrorMessage="Password must be at least 7 characters and contain a symbol."
                                            Text="Password must be at least 7 characters and contain a symbol." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label" for="<%# Container.FindControl("ConfirmPassword").ClientID %>">
                                            Confirm password <span class="text-danger">*</span>
                                        </label>
                                        <asp:TextBox ID="ConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" />
                                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                                            ControlToValidate="ConfirmPassword" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ErrorMessage="Please confirm your password."
                                            Text="Please confirm your password." />
                                        <asp:CompareValidator ID="cvPassword" runat="server"
                                            ControlToValidate="ConfirmPassword" ControlToCompare="Password"
                                            Operator="Equal" Type="String" ValidationGroup="CreateUser"
                                            Display="Dynamic" CssClass="text-danger small"
                                            ErrorMessage="The passwords do not match."
                                            Text="The passwords do not match." />
                                    </div>

                                    <asp:ValidationSummary ID="vsCreateUser" runat="server"
                                        ValidationGroup="CreateUser"
                                        CssClass="alert alert-danger"
                                        HeaderText="Please correct the following:" />

                                    <div class="d-grid">
                                        <asp:Button ID="btnCreateUser" runat="server"
                                            CommandName="MoveNext" Text="Create account"
                                            CssClass="btn btn-primary btn-lg"
                                            ValidationGroup="CreateUser" />
                                    </div>

                                </ContentTemplate>
                            </asp:CreateUserWizardStep>

                            <asp:CompleteWizardStep ID="stepComplete" runat="server">
                                <ContentTemplate>
                                    <div class="alert alert-success">
                                        <strong>Your account has been created.</strong>
                                        You are now signed in and can book appointments.
                                    </div>
                                    <div class="d-grid">
                                        <asp:Button ID="btnContinue" runat="server"
                                            CommandName="Continue" Text="Continue"
                                            CssClass="btn btn-primary" />
                                    </div>
                                </ContentTemplate>
                            </asp:CompleteWizardStep>

                        </WizardSteps>
                    </asp:CreateUserWizard>

                </div>
                <div class="card-footer bg-white text-center">
                    Already registered?
                    <a href="<%: ResolveUrl("~/Login.aspx") %>">Sign in</a>
                </div>
            </div>

        </div>
    </div>

</asp:Content>
