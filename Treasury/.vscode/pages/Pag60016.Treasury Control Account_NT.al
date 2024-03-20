page 60016 "Treasury Control Account_NT"
{
    Caption = 'Treasury Control Account';
    PageType = ListPart;
    SourceTable = "Treasury Control Account_NT";
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Hierarchy No. field.';
                }
                field("Store Hierarchy Name"; Rec."Store Hierarchy Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Hierarchy Name field.';
                }
                field("Control Account No."; Rec."Control Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Control Account No. field.';
                }
                field("Control Account Name"; Rec."Control Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account Name field.';
                }
                field("Float Tender"; Rec."Float Tender")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Float Tender field.';
                }
                field("Fixed Float"; Rec."Fixed Float")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of fixed float for the corresponding store hierarchy.';
                }
                field("Bank Bag Nos."; Rec."Bank Bag Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to bank bag nos for deposits.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&Cash Management")
            {
                Caption = '&Cash Management';
                Image = Line;
                action("Tender Types")
                {
                    ApplicationArea = All;
                    Caption = 'Tender T&ypes';
                    Image = CashFlowSetup;
                    RunObject = page "Store Hierarchy Tender Type_NT";
                    RunPageLink = "Store Hierarchy No." = field("Store Hierarchy No."), "Control Account No." = field("Control Account No.");
                }
                action(TenderType)
                {
                    Caption = 'Update Tender Control Acc.';
                    Image = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        NewCmpSetupMgmt: Codeunit NewCompanySetupMgmt_NT;
                    begin
                        NewCmpSetupMgmt.UpdateTenderType(Rec);
                    end;
                }
            }
        }
    }
}
