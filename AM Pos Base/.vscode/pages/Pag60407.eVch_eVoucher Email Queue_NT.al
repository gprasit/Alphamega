page 60407 "eVch_eVoucher Email Queue_NT"
{
    Caption = 'eVoucher Email Queue';
    PageType = ListPart;
    SourceTable = "eVch_eVoucher Email Queue_NT";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field.';
                }
                field("Entry Code"; Rec."Entry Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Code field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Created by Receipt No."; Rec."Created by Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created by Receipt No. field.';
                }
                field("Date Created"; Rec."Date Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Created field.';
                }
                field("Created in Store No."; Rec."Created in Store No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created in Store No. field.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice No. field.';
                }
                field("e-mail"; Rec."e-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the e-mail field.';
                }
                field("Mail Sent"; Rec."Mail Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail Sent field.';
                }
                field("Date Sent"; Rec."Date Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Sent field.';
                }
                field("Time Sent"; Rec."Time Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Sent field.';
                }
                field("Last Message Text"; Rec."Last Message Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Message Text field.';
                }
                field("Mail Resent"; Rec."Mail Resent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the mail resent when check marked.';
                }
                field("Resent e-mail"; Rec."Resent e-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email id where mail is resent.';
                }
                field("Date Resent"; Rec."Date Resent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when mail is resent.';
                }
                field("Resent By"; Rec."Resent By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user id who resent the email.';
                }
                field(Redeemed; Rec.Redeemed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redeemed field.';
                }
                field(Cancelled; Rec.Cancelled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the voucher is cancelled when check marked.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Re-Send Email")
            {
                Caption = 'Re-Send Email';
                ApplicationArea = All;
                Image = Email;
                trigger OnAction()
                var
                    eVchEmailMgt: Codeunit "eVch_eVoucher Email Mgmt_NT";
                    eVchEmailQueue : Record "eVch_eVoucher Email Queue_NT";
                begin
                    //CurrPage.SetSelectionFilter(eVchEmailQueue);                    
                    //eVchEmailMgt.ResendEmail(eVchEmailQueue);
                    eVchEmailMgt.ResendEmail(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}


