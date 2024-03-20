page 60405 "eVch_eVoucher Card_NT"
{
    Caption = 'eVoucher Card';
    PageType = Card;
    SourceTable = "eVch_eVoucher Header_NT";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice No. field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Data Entry Type"; Rec."Data Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Entry Type field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Member Card No."; Rec."Member Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Card No. field.';
                }
                field("Member Contact Name"; Rec."Member Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Contact Name field.';
                }
                field("Template File Name"; Rec."Template File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template File Name field.';
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix field.';
                }
                field("Amount Code"; Rec."Amount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Code field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field("Creation Nos."; Rec."Creation Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Nos. field.';
                }
                field("Send e-Mail"; Rec."Send e-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send e-Mail field.';
                }
                field("Creation No. Series"; Rec."Creation No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation No. Series field.';
                }
            }
            part(lines; "eVch_eVoucher Subform_NT")
            {
                ApplicationArea = all;
                Caption = 'Lines';
                SubPageView = sorting("Document No.", "Line No.");
                SubPageLink = "Document No." = field("No.");
                ShowFilter = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Release")
            {
                Caption = 'Release';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    Clear(eVchMgmt);
                    eVchMgmt.eVoucherOnRelease(Rec);
                    CurrPage.Update();
                end;
            }
            action("&Reopen")
            {
                Caption = 'Reopen';
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    Clear(eVchMgmt);
                    eVchMgmt.eVoucherOnReopen(Rec);
                    CurrPage.Update();
                end;
            }
            action("C&reate")
            {
                Caption = 'Create';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                RunObject = codeunit "eVch_eVoucher Management_NT";
                // trigger OnAction()
                // begin
                //     Clear(eVchMgmt);
                //     eVchMgmt.Run(Rec);
                //     CurrPage.Update(true);
                // end;
            }
            action("&Cancel")
            {
                ApplicationArea = All;
                Image = CancelAllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    if not confirm('Cancel all entries?') then
                        exit;
                    eVchMgmt.CancelEntries("No.", 0);
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        eVchMgmt: Codeunit "eVch_eVoucher Management_NT";
}
