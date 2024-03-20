page 60106 "eCom_Kiosk Setup_NT"
{
    Caption = 'Kiosk Setup';
    PageType = Card;
    SourceTable = "Kiosk Setup_NT";
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Registration Bonus Points"; Rec."Registration Bonus Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration Bonus Points field.';
                }
                field("Redemption Store No."; Rec."Redemption Store No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redemption Store No. field.';
                }
                field("Redemption Pos Terminal No."; Rec."Redemption Pos Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redemption Pos Terminal No. field.';
                }
                field("Last Loyalty Points Entry No."; Rec."Last Loyalty Points Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Loyalty Points Entry No. field.';
                }
                field("Last Contact Entry No."; Rec."Last Contact Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Contact Entry No. field.';
                }
                field("SMTP Server"; Rec."SMTP Server")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMTP Server field.';
                }
                field("SMTP Server Password"; Rec."SMTP Server Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMTP Server Password field.';
                }
                field("SMTP Server Port"; Rec."SMTP Server Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMTP Server Port field.';
                }
                field("SMTP Server User Name"; Rec."SMTP Server User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMTP Server User Name field.';
                }
                field("Cancel Voucher Nos."; Rec."Cancel Voucher Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancel Voucher Nos. field.';
                }
                field("Club Code"; Rec."Club Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Define default member club for members registration from kiosk';
                }
                field("Vouch.Exp. Date Calc. (Months)"; Rec."Vouch.Exp. Date Calc. (Months)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vouch.Exp. Date Calc. (Months) field.';
                }
                field("Voucher Nos."; Rec."Voucher Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Nos. field.';
                }
                field("Default Kiosk Store No."; Rec."Default Kiosk Store No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies Store no for identification new member creation and points redemption coupons issued from kiosk';
                }
                field("Default Supplier ID"; Rec."Default Supplier ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies Company name for identification of redemption coupons issued from kiosk';
                }
                field("Default Country/Region Code"; Rec."Default Country/Region Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies Country/Region for new member registration from eCommerce and Kiosk';
                }
                field("Default Web Store No."; Rec."Default Web Store No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies default store no for new member registration from eCommerce';
                }
                field("Welcome Email Template"; "Welcome Email Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Update Email Template"; "Update Email Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Change PIN Email Template"; "Change PIN Email Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Welcome SMS Template"; "Welcome SMS Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Update SMS Template"; "Update SMS Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Change PIN SMS Template"; "Change PIN SMS Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Voucher SMS Template"; "Voucher SMS Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Voucher Email Template"; "Voucher Email Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Import)
            {
                Caption = 'Import';
                group(ImportEmailTemplates)
                {
                    Caption = 'Email Templates';
                    action(ImpWelcomeEmailTemplate)
                    {
                        Caption = 'Welcome Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Welcome Email Template"));
                        end;
                    }
                    action(ImpUpdateEmailTemplate)
                    {
                        Caption = 'Update Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Update Email Template"));
                        end;
                    }
                    action(ImpChangePINEmailTemplate)
                    {
                        Caption = 'Change PIN Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Change PIN Email Template"));
                        end;
                    }
                    action(ImpVoucherEmailTemplate)
                    {
                        Caption = 'Voucher Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Voucher Email Template"));
                        end;
                    }
                }
                group(ImporSMSTemplates)
                {
                    Caption = 'SMS Templates';
                    action(ImpWelcomeSMSTemplate)
                    {
                        Caption = 'Welcome SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Welcome SMS Template"));
                        end;
                    }
                    action(ImpUpdateSMSTemplate)
                    {
                        Caption = 'Update SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Update SMS Template"));
                        end;
                    }
                    action(ImpChangePINSMSTemplate)
                    {
                        Caption = 'Change PIN SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Change PIN SMS Template"));
                        end;
                    }

                    action(ImpVoucherSMSTemplate)
                    {
                        Caption = 'Voucher SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, true, Rec.FieldNo("Voucher SMS Template"));
                        end;
                    }
                }
            }
            group(Export)
            {
                Caption = 'Export';
                group(EmailExp)
                {
                    Caption = 'Email Templates';
                    action(ExpWelcomeEmailTemplate)
                    {
                        Caption = 'Welcome Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Welcome Email Template"));
                        end;
                    }
                    action(ExpUpdateEmailTemplate)
                    {
                        Caption = 'Update Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Update Email Template"));
                        end;
                    }
                    action(ExpChangePINEmailTemplate)
                    {
                        Caption = 'Change PIN Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Change PIN Email Template"));
                        end;
                    }
                    action(ExpVoucherEmailTemplate)
                    {
                        Caption = 'Change PIN Email Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Voucher Email Template"));
                        end;
                    }
                }

                group(SMSExp)
                {
                    Caption = 'SMS Templates';
                    action(ExpWelcomeSMSTemplate)
                    {
                        Caption = 'Welcome SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Welcome SMS Template"));
                        end;
                    }
                    action(ExpUpdateSMSTemplate)
                    {
                        Caption = 'Update SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Update SMS Template"));
                        end;
                    }
                    action(ExpChangePINSMSTemplate)
                    {
                        Caption = 'Change PIN SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Change PIN SMS Template"));
                        end;
                    }
                    action(ExpVoucherSMSTemplate)
                    {
                        Caption = 'Change PIN SMS Template';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            eComGenFn: Codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.KioskImportExportTemplate(Rec, false, Rec.FieldNo("Voucher SMS Template"));
                        end;
                    }
                }
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

    var
        WelcomeEmailTemplate: Boolean;
}