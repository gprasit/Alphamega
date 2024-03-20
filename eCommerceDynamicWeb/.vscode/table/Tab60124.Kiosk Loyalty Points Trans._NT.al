table 60124 "Kiosk Loyalty Points Trans._NT"
{
    Caption = 'Kiosk Loyalty Points Trans.';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(2; Points; Decimal)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(3; "Date Of Issue"; Date)
        {
            Caption = 'Date Of Issue';
            DataClassification = CustomerContent;
        }
        field(4; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
        }
        field(5; "Card No."; Code[20])
        {
            Caption = 'Card No.';
            DataClassification = CustomerContent;
        }
        field(6; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(7; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = "LSC Member Account";
            DataClassification = CustomerContent;
        }
        field(8; "Entry Type"; Enum "Kiosk Entry Type_NT")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(9; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(10; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(11; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(12; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(13; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(14; "Line No."; Integer)
        {
            Caption = 'Line No.';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(15; "Point Calc. Type"; Enum "Kiosk Point Calc. Type_NT")
        {
            Caption = 'Point Calc. Type';
            DataClassification = CustomerContent;
        }
        field(16; "Point Item No. Calc."; Code[20])
        {
            Caption = 'Point Item No. Calc.';
            DataClassification = CustomerContent;
        }
        field(17; "Item-Catalogue Ref. No."; Code[10])
        {
            Caption = 'Item-Catalogue Ref. No.';
            DataClassification = CustomerContent;
        }
        field(18; "Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
            DataClassification = CustomerContent;
        }
        field(19; "Item-Catalogue Ref. Item No."; Code[10])
        {
            Caption = 'Item-Catalogue Ref. Item No.';
            DataClassification = CustomerContent;
        }

        field(20; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
