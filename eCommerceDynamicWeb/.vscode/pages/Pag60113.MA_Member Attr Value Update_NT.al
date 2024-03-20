page 60113 "MA_Member Attr Value Update_NT"
{
    ApplicationArea = All;
    Caption = 'Member Attribute Value Update';
    PageType = List;
    SourceTable = "MA_Member Attr Value Update_NT";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Club Code"; Rec."Club Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Club Code field.';
                }
                field("Member Attribute"; Rec."Member Attribute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Attribute field.';
                }
                field("Member Attribute Value"; Rec."Member Attribute Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Attribute Value field.';
                }
            }
        }
    }
}
