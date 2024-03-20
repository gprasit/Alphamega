page 60011 "Posted Treas. NetSalesLine_NT"
{
    Caption = 'Net Sales Lines';
    PageType = ListPart;
    SourceTable = "Posted Treas. NetSalesLine_NT";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the value of the Line Type field.';
                    ApplicationArea = All;
                }
                field("Store Attribute Code"; Rec."Store Attribute Code")
                {
                    ToolTip = 'Specifies the value of the Store Attribute Code field.';
                    ApplicationArea = All;
                }
                field("Attribute Value"; Rec."Attribute Value")
                {
                    ToolTip = 'Specifies the value of the Attribute Value field.';
                    ApplicationArea = All;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ToolTip = 'Specifies the value of the Tender Type field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tender Name"; Rec."Tender Type Name")
                {
                    ToolTip = 'Specifies the value of the Tender Type Name field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = All;
                }
                field("Counted Amount"; Rec."Counted Amount")
                {
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                    ApplicationArea = All;
                }
                field("Counted Amount in LCY"; Rec."Counted Amount in LCY")
                {
                    ToolTip = 'Specifies the value of the Counted Amount in LCY field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                action("&Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Cash &Journal Lines';
                    Image = Journal;
                    ShortCutKey = 'Ctrl+Alt+J';
                    Enabled = Rec."Line Type" <> Rec."Line Type"::Standard;
                    ToolTip = 'View or edit cash journal for the selected line. This action is available only for lines that has Line Type Cash-Payments and Cash-Receipts.';
                    trigger OnAction()
                    var
                        TreasuryMgmt: Codeunit "Treasury Management_NT";
                    begin
                        TreasuryMgmt.ShowPostedTreasuryJournal(Rec);
                    end;
                }
            }
        }
    }
}