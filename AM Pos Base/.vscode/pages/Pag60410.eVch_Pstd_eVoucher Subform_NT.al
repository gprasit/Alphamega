page 60410 "eVch_Pstd eVoucher Subform_NT"
{
    Caption = 'Posted eVoucher Subform';
    PageType = ListPart;
    SourceTable = "eVch_eVoucher Line_NT";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("e-Mail"; Rec."e-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the e-Mail field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
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
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Amount field.';
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
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Cancel")
            {
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                    eVchMgmt: Codeunit "eVch_eVoucher Management_NT";
                begin
                    if not confirm('Cancel Line?') then
                        exit;
                    eVchMgmt.CancelEntries("Document No.", "Line No.");
                end;
            }
        }
    }
}
