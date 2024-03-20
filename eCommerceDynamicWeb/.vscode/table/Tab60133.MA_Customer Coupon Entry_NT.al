table 60133 "MA_Customer Coupon Entry_NT"
{
    Caption = 'Customer Coupon Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Coupon Code"; Code[20])
        {
            Caption = 'Coupon Code';
            DataClassification = CustomerContent;
        }
        field(2; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(4; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = CustomerContent;
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(6; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Coupon Code", "Contact No.", "Entry No.")
        {
            Clustered = true;
        }
    }
}
