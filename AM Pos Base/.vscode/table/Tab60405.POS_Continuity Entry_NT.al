table 60405 "POS Continuity Entry_NT"
{
    Caption = 'POS Continuity Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
        }
        field(15; "Trans. Time"; Time)
        {
            Caption = 'Trans. Time';
        }
        field(20; Date; Date)
        {
            Caption = 'Date';
        }
        field(25; Time; Time)
        {
            Caption = 'Time';
        }
        field(30; Success; Boolean)
        {
            Caption = 'Success';
        }
        field(35; "Voucher Code"; Text[30])
        {
            Caption = 'Voucher Code';
        }
        field(40; "Barcode No."; Code[20])
        {
            Caption = 'Barcode No.';
        }
        field(45; "Mobile No."; Code[10])
        {
            Caption = 'Mobile No.';
        }
        field(50; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = " ",Voided;
        }
        field(55; "Response Code"; Code[10])
        {
            Caption = 'Response Code';
        }
        field(60; "Response Message Type"; Code[10])
        {
            Caption = 'Response Code';
        }
        field(65; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
        }
        field(70; "Merchant Name"; Text[30])
        {
            Caption = 'Merchant Name';
        }
        field(75; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
        }
        field(80; "Merchant Discount Amount"; Decimal)
        {
            Caption = 'Merchant Discount Amount';
        }
        field(85; "e-voucher Discount Amount"; Decimal)
        {
            Caption = 'e-voucher Discount Amount';
        }
        field(90; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
        }
        field(95; "Total Amount"; Decimal)
        {
            Caption = 'Total AAmount';
        }
        field(100; "Available Redemption Amount"; Decimal)
        {
            Caption = 'Available Redemption Amount';
        }
        field(105; "Redemption Amount"; Decimal)
        {
            Caption = 'Redemption Amount';
        }
        field(110; "Max Redem Amt. For Shop Items"; Decimal)
        {
            Caption = 'Max Redem Amt. For Shop Items';
        }
        field(115; "Grand Total Amount"; Decimal)
        {
            Caption = 'Grand Total Amount';
        }
        field(120; "Previous Balance"; Decimal)
        {
            Caption = 'Previous Balance';
        }
        field(125; "Points Earned"; Decimal)
        {
            Caption = 'Points Earned';
        }
        field(130; "Points Redeemed"; Decimal)
        {
            Caption = 'Points Redeemed';
        }
        field(135; "New Balance"; Decimal)
        {
            Caption = 'New Balance';
        }
        field(140; "Transaction Number"; Integer)
        {
            Caption = 'Transaction Number';
        }
        field(145; "Initialize Terminal"; Text[30])
        {
            Caption = 'Initialize Terminal';
        }
        field(150; "T&C Accepted"; Boolean)
        {
            Caption = 'T&C Accepted';
        }
        field(155; "T&C Success"; Boolean)
        {
            Caption = 'T&C Success';
        }
        field(160; "T&C Response Code"; code[10])
        {
            Caption = 'T&C Response Code';
        }
        field(165; "T&C Response Message Type"; code[10])
        {
            Caption = 'T&C Response Message Type';
        }
        field(170; "T&C Response Message"; Text[250])
        {
            Caption = 'T&C Response Message';
        }
        field(175; "T&C Accepted Number"; Text[30])
        {
            Caption = 'T&C Accepted Number';
        }
        field(180; "T&C Accepted Name"; Text[30])
        {
            Caption = 'T&C Accepted Name';
        }
        field(185; "Reversal Success"; Boolean)
        {
            Caption = 'Reversal Success';
        }
        field(190; "Reversal Response Code"; Code[10])
        {
            Caption = 'Reversal Response Code';
        }
        field(195; "Reversal Response Message Type"; Code[10])
        {
            Caption = 'Reversal Response Message Type';
        }
        field(200; "Reversal Response Message"; Text[250])
        {
            Caption = 'Reversal Response Message';
        }
    }
    keys
    {
        key(PK; "Receipt No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
