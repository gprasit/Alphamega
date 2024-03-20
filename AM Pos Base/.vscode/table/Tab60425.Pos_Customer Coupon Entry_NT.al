table 60425 "Pos_Customer Coupon Entry_NT"
{
    Caption = 'Customer Coupon Entry';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Coupon Code"; Code[30])
        {
            Caption = 'Coupon Code';
            DataClassification = CustomerContent;
        }
        field(5; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(15; "System Created Entry"; Boolean)
        {
            Caption = 'System Created Entry';
            DataClassification = CustomerContent;
        }
        field(20; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(25; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Coupon Code","Contact No.","Entry No.")
        {
            Clustered = true;
        }
    }
}
