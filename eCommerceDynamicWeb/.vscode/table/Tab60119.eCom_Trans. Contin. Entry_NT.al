table 60119 "eCom_Trans. Contin. Entry_NT"
{
    Caption = 'Trans. Continuity Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
        }
        field(3; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(6; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
            DataClassification = CustomerContent;
        }
        field(7; "Trans. Time"; Time)
        {
            Caption = 'Trans. Time';
            DataClassification = CustomerContent;
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(9; Time; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(10; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
        field(11; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = Sale,Reverse,Voucher;
        }
        field(12; "Barcode No."; Code[20])
        {
            Caption = 'Barcode No.';
            DataClassification = CustomerContent;
        }
        field(13; "Mobile No."; Code[10])
        {
            Caption = 'Mobile No.';
            DataClassification = CustomerContent;
        }
        field(20; "Response Code"; Code[10])
        {
            Caption = 'Response Code';
            DataClassification = CustomerContent;
        }
        field(21; "Response Message Type"; Code[10])
        {
            Caption = 'Response Message Type';
            DataClassification = CustomerContent;
        }
        field(22; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
            DataClassification = CustomerContent;
        }
        field(23; "Merchant Name"; Text[30])
        {
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
        }
        field(24; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Merchant Discount Amount"; Decimal)
        {
            Caption = 'Merchant Discount Amount';
            DataClassification = CustomerContent;
        }
        field(26; "e-voucher Discount Amount"; Decimal)
        {
            Caption = 'e-voucher Discount Amount';
            DataClassification = CustomerContent;
        }
        field(27; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            DataClassification = CustomerContent;
        }
        field(28; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
        field(29; "Available Redemption Amount"; Decimal)
        {
            Caption = 'Available Redemption Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Redemption Amount"; Decimal)
        {
            Caption = 'Redemption Amount';
            DataClassification = CustomerContent;
        }
        field(31; "Max Redem Amt. For Shop Items"; Decimal)
        {
            Caption = 'Max Redem Amt. For Shop Items';
            DataClassification = CustomerContent;
        }
        field(32; "Grand Total Amount"; Decimal)
        {
            Caption = 'Grand Total Amount';
            DataClassification = CustomerContent;
        }
        field(33; "Previous Balance"; Decimal)
        {
            Caption = 'Previous Balance';
            DataClassification = CustomerContent;
        }
        field(34; "Points Earned"; Decimal)
        {
            Caption = 'Points Earned';
            DataClassification = CustomerContent;
        }
        field(35; "Points Redeemed"; Decimal)
        {
            Caption = 'Points Redeemed';
            DataClassification = CustomerContent;
        }
        field(36; "New Balance"; Decimal)
        {
            Caption = 'New Balance';
            DataClassification = CustomerContent;
        }
        field(37; "Transaction Number"; Integer)
        {
            Caption = 'Transaction Number';
            DataClassification = CustomerContent;
        }
        field(38; "Initialize Terminal"; Text[30])
        {
            Caption = 'Initialize Terminal';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
