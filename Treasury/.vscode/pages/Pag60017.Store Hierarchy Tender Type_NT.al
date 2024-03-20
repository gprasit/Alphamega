page 60017 "Store Hierarchy Tender Type_NT"
{
    Caption = 'Store Hierarchy Tender Types';
    PageType = List;
    SourceTable = "Store Hierarchy Tender Type_NT";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Tender Type Name"; Rec."Tender Type Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type Name field.';
                }
                field("Tender Account No."; Rec."Tender Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Account No. field.';
                }
                field("Tender Account Name"; Rec."Tender Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender G/L Account Name field.';
                }
                field("Deposit Bank Account"; Rec."Deposit Bank Account")
                {
                    ApplicationArea = All;
                }
                field("Deposit Bank Name"; Rec."Deposit Bank Name")
                {
                    ApplicationArea = All;
                }
                field("Diff. Bank Account"; Rec."Diff. Bank Account")
                {
                    ApplicationArea = all;
                }

                field("Diff. Bank Name"; Rec."Diff. Bank Name")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}
