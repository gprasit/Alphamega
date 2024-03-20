page 60202 "eCom_Web Order Coordinates_NT"
{
    ApplicationArea = All;
    Caption = 'Web Order Coordinates';
    PageType = List;
    SourceTable = "eCom_Web Order Coordinates_NT";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field("Postal Code"; Rec."Postal Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Postal Code field.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field(Latitude; Rec.Latitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Latitude field.';
                }
                field(Longitude; Rec.Longitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Longitude field.';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed field.';
                }
                field("Member Contact No."; Rec."Member Contact No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Contact No. field.';
                }
            }
        }
    }
}
