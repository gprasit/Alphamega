page 60411 "eVch_Create Data Entry Amt_NT"
{
    Caption = 'Create Data Entry Amount';
    PageType = List;
    SourceTable = "eVch_Create Data Entry Amt_NT";
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
            }
        }
    }
}
