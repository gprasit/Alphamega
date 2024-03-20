table 60109 "eCom_WebOrd.PointRedemption_NT"
{
    Caption = 'Web Order Point Redemption';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Document Type"; Integer)
        {
            Caption = 'Document Type';
        }
        field(3; "Document No."; code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(5; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(6; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(8; Points; Decimal)
        {
            Caption = 'Points';
        }
        field(9; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(10; "Member Contact No."; Code[20])
        {
            Caption = 'Member Contact No.';
        }
        field(11; Date; Date)
        {
            Caption = 'Date';
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Processed)
        {
        }
        key(Key3; "Document Type", "Document No.")
        {
        }
        key(Key4; "Store No.", "POS Terminal No.", "Transaction No.")
        {
        }
    }
}