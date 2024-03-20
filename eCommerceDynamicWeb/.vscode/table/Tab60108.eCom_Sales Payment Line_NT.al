table 60108 "eCom_Sales Payment Line_NT"
{
    Caption = 'Sales Payment Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(6; "Card Payment"; Boolean)
        {
            Caption = 'Card Payment';
        }
        field(7; Points; Decimal)
        {
            Caption = 'Points';
        }

    }
    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
