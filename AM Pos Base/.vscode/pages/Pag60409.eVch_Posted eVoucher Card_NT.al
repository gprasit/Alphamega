page 60409 "eVch_Posted eVoucher Card_NT"
{
    Caption = 'Posted eVoucher Card';
    PageType = Card;
    SourceTable = "eVch_eVoucher Header_NT";
    Editable = false;    
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
            part(lines; "eVch_Pstd eVoucher Subform_NT")
            {
                ApplicationArea = all;
                Caption = 'Lines';
                SubPageView =sorting("Document No.","Line No.");
                SubPageLink = "Document No."=field("No.");
                ShowFilter = false;
                Editable = false;
            }
            part("Email Queue"; "eVch_eVoucher Email Queue_NT")
            {
                ApplicationArea = all;
                SubPageLink = "Created by Receipt No."=field("No.");
                Editable = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
        
        }
    }
    var
        eVchMgmt: Codeunit "eVch_eVoucher Management_NT";
}
