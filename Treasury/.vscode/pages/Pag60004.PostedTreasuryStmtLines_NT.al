page 60004 "Posted Treasury Stmt. Lines_NT"
{
    Caption = 'Lines';
    PageType = ListPart;
    Editable = false;
    SourceTable = "Posted Treasury Stmt. Line_NT";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Tender Type"; Rec."Tender Type")
                {
                    ToolTip = 'Specifies the value of the Tender Type field.';
                    ApplicationArea = All;
                }
                field("Tender Type Name"; Rec."Tender Type Name")
                {
                    ToolTip = 'Specifies the value of the Tender Type Name field.';
                    ApplicationArea = All;
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
                field("Trans. Amount"; Rec."Trans. Amount")
                {
                    ToolTip = 'Specifies the value of the Trans. Amount field.';
                    ApplicationArea = All;
                }
                field("Difference Amount"; Rec."Difference Amount")
                {
                    ToolTip = 'Specifies the value of the Difference Amount field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
