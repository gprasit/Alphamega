page 60111 "MA_Mobile App Setup_NT"
{
    Caption = 'Mobile App Setup';
    PageType = Card;
    SourceTable = "MA_Mobile App Setup_NT";
    ApplicationArea = all;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Carouzel Recipe Nos."; Rec."Carouzel Recipe Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Carouzel Recipe Nos. field.';
                }
                field("Leaflet Nos."; Rec."Leaflet Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Leaflet Nos. field.';
                }
                field("Member Notification Enabled"; Rec."Member Notification Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Notification Enabled field.';
                }
                field("Menu Recipe Nos."; Rec."Menu Recipe Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Menu Recipe Nos. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Registration Bonus Points"; Rec."Registration Bonus Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration Bonus Points field.';
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

}
