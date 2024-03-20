table 60408 "Pos_Trans. Continuity Entry_NT"
{
    Caption = 'Trans. Continuity Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(5; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(10; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(15; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(20; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(25; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
        }
        field(30; "Trans. Time"; Time)
        {

            Caption = 'Trans. Time';
        }
        field(35; Date; Date)
        {
            Caption = 'Date';
        }
        field(40; Time; Time)
        {
            Caption = 'Time';
        }
        field(45; Success; Boolean)
        {
            Caption = 'Success';
        }
        field(50; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Sale,Reverse,Voucher';
            OptionMembers = Sale,Reverse,Voucher;
        }
        field(55; "Barcode No."; Code[20])
        {
            Caption = 'Barcode No.';
        }
        field(60; "Mobile No."; Code[10])
        {
            Caption = 'Mobile No.';
        }
        field(65; "Response Code"; Code[10])
        {
            Caption = 'Response Code';
        }
        field(70; "Response Message Type"; Code[10])
        {
            Caption = 'Response Message Type';
        }
        field(75; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
        }
        field(80; "Merchant Name"; Text[30])
        {
            Caption = 'Merchant Name';
        }
        field(85; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
        }
        field(90; "Merchant Discount Amount"; Decimal)
        {
            Caption = 'Merchant Discount Amount';
        }
        field(95; "e-voucher Discount Amount"; Decimal)
        {
            Caption = 'e-voucher Discount Amount';
        }
        field(100; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
        }
        field(105; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
        }
        field(110; "Available Redemption Amount"; Decimal)
        {
            Caption = 'Available Redemption Amount';
        }
        field(115; "Redemption Amount"; Decimal)
        {
            Caption = 'Redemption Amount';
        }
        field(120; "Max Redem Amt. For Shop Items"; Decimal)
        {
            Caption = 'Max Redem Amt. For Shop Items';
        }
        field(125; "Grand Total Amount"; Decimal)
        {
            Caption = 'Grand Total Amount';
        }
        field(130; "Previous Balance"; Decimal)
        {
            Caption = 'Previous Balance';
        }
        field(135; "Points Earned"; Decimal)
        {
            Caption = 'Points Earned';
        }
        field(140; "Points Redeemed"; Decimal)
        {
            Caption = 'Points Redeemed';
        }
        field(145; "New Balance"; Decimal)
        {
            Caption = 'New Balance';
        }
        field(150; "Transaction Number"; Integer)
        {
            Caption ='Transaction Number';
        }
        field(155; "Initialize Terminal"; Text[30])
        {
            Caption='Initialize Terminal';
        }
    }

    keys
    {
        key(PK; "Store No.","POS Terminal No.","Transaction No.","Line No.")
        {
            Clustered = true;
        }
    }
}
