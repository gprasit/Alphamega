page 60029 "Stmt._Staff POS Terminal_NT"
{
    Caption = 'Staff POS Terminals';
    PageType = List;
    SourceTable = "LSC Statement Line";
    UsageCategory = None;
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        TreasuryGenFun: Codeunit "Treasury General Functions_NT";
    begin
        TreasuryGenFun.StatementStaffPOS(Rec);
    end;
}
