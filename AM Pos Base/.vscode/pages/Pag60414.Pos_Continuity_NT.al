page 60414 Pos_Continuity_NT
{
    ApplicationArea = All;
    Caption = 'Continuity';
    PageType = List;
    SourceTable = Pos_Continuity_NT;
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
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field.';
                }
                field("One Coupon Per Amount"; Rec."One Coupon Per Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the One Coupon Per Amount field.';
                }
                field("One Digital Coupon Per Amount"; Rec."One Digital Coupon Per Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the One Digital Coupon Per Amount field.';
                }
            }
        }
    }
}
