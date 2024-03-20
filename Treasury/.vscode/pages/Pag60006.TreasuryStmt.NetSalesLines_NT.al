page 60006 "Treasury Stmt. NetSalesLine_NT"
{
    Caption = 'Net Sales Lines';
    PageType = ListPart;
    SourceTable = "Treasury Stmt. NetSalesLine_NT";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
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
                field("Counted Amount"; Rec."Counted Amount")
                {
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Counted Amount in LCY"; Rec."Counted Amount in LCY")
                {
                    ToolTip = 'Specifies the value of the Counted Amount in LCY field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Difference Amount"; Rec."Difference Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Difference Amount field.';
                }
                field("Difference in LCY"; Rec."Difference in LCY")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Difference in LCY field.';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Amount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ToolTip = 'Specifies the value of the VAT Amount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    ToolTip = 'Specifies the value of the Total Discount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Line Discount"; Rec."Line Discount")
                {
                    ToolTip = 'Specifies the value of the Line Discount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Discount Total Ammount"; Rec."Discount Total Ammount")
                {
                    ToolTip = 'Specifies the value of the Discount Total Ammount field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(Income; Rec.Income)
                {
                    ToolTip = 'Specifies the value of the  Income field.';
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(Expense; Rec.Expenses)
                {
                    ToolTip = 'Specifies the value of the  Expense field.';
                    ApplicationArea = All;
                    BlankZero = true;
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
                        TreasuryMgmt.ShowTreasuryJournal(Rec);
                    end;
                }
            }
        }
    }
}