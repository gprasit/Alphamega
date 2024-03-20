page 60415 "Pos_Item Brand_NT"
{
    ApplicationArea = All;
    Caption = 'Item Brand';
    PageType = List;
    SourceTable = "Pos_Item Brand_NT";
    UsageCategory = Administration;
    DelayedInsert = true;
    
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}
