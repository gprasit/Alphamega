page 60013 "AlphaMega Setup_IN"
{
    ApplicationArea = All;
    Caption = 'AlphaMega Setup';
    PageType = Card;
    SourceTable = "AlphaMega Setup_NT";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Treasury Statement Nos."; Rec."Treasury Statement Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Treasury Statement Nos. field.';
                }
                field("Store Type Attribute"; Rec."Store Type Attribute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Type Attribute field.';
                }
                field("Store Hierarchy Dimension"; Rec."Store Hierarchy Dimension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Hierarchy Dimension field.';
                }
                field("Ext. Doc. No. Mandatory"; Rec."Ext. Doc. No. Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if it is mandatory to enter an external document number in the External Document No. field on a treasury journal line.';
                }
            }
            part(PageControlAcc; "Treasury Control Account_NT")
            {
                ApplicationArea = all;
                Caption = 'Control Account';
            }
        }
    }
}