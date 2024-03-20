table 60132 "MA_Customer Coupon_NT"
{
    Caption = 'Customer Coupon';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Coupon Code"; Code[30])
        {
            Caption = 'Coupon Code';
            DataClassification = CustomerContent;
        }
        field(2; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(3; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(4; "Remaining Qty."; Decimal)
        {
            Caption = 'Remaining Qty.';
            FieldClass = FlowField;
            CalcFormula = Sum("MA_Customer Coupon Entry_NT".Quantity WHERE("Coupon Code" = FIELD("Coupon Code"), "Contact No." = FIELD("Contact No.")));
        }
    }
    keys
    {
        key(PK; "Coupon Code", "Contact No.")
        {
            Clustered = true;
        }
    }
}
