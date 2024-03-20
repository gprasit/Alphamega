page 60103 Kiosk_NT
{
    ApplicationArea = All;
    Caption = 'Kiosk_NT';
    PageType = List;
    SourceTable = Kiosk_NT;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("IP Address"; Rec."IP Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the IP Address field.';
                }
                field("Kiosk Code"; Rec."Kiosk Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kiosk Code field.';
                }
                field("Kiosk Location"; Rec."Kiosk Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kiosk Location field.';
                }
                field("Kiosk Name"; Rec."Kiosk Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kiosk Name field.';
                }
                field("Kiosk Store"; Rec."Kiosk Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kiosk Store field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemId field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                }
                field("Terminal No."; Rec."Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal No. field.';
                }
            }
        }
    }
}
