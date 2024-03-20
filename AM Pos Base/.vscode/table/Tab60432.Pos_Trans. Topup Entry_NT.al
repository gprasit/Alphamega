table 60432 "Pos_Trans. Topup Entry_NT"
{
    Caption = 'Trans. Topup Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Store";
        }
        field(2; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC POS Terminal";
            ValidateTableRelation = false;
        }
        field(3; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(15; "Trans. Line No."; Integer)
        {
            Caption = 'Trans. Line No.';
        }
        field(18; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(20; "Topup ID"; Code[10])
        {
            Caption = 'Topup ID';
        }
        field(21; "Topup Amount"; Decimal)
        {
            Caption = 'Topup Amount';
        }
        field(22; "Member Card No."; Code[20])
        {
            Caption = 'Member Card No.';
        }
        field(30; "Transaction ID"; Text[50])
        {
            Caption = 'Transaction ID';
        }
        field(31; "Serial No."; Text[50])
        {
            Caption = 'Serial No.';
        }
        field(32; Pin; Text[50])
        {
            Caption = 'Pin';
        }
        field(35; "Transaction Status"; Enum "Topup Transaction Status_NT")
        {
            Caption = 'Transaction Status';
        }
        field(40; Balance; Decimal)
        {
            Caption = 'Balance';
        }
        field(50; "Request Date"; Date)
        {
            Caption = 'Request Date';
        }
        field(51; "Request Time"; Time)
        {
            Caption = 'Request Time';
        }
        field(52; "Request User ID"; Code[20])
        {
            Caption = 'Request User ID';
        }
        field(55; "Processing Date"; Date)
        {
            Caption = 'Processing Date';
        }
        field(56; "Processing Time"; Time)
        {
            Caption = 'Processing Time';
        }
        field(57; "Processing User ID"; Code[20])
        {
            Caption = 'Processing User ID';
        }
        field(60; "Error Message 1"; Text[250])
        {
            Caption = 'Error Message 1';
        }
        field(61; "Error Message 2"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(70; "Promotion Code 1"; Code[20])
        {
            Caption = 'Promotion Code 1';
        }
        field(71; "Promotion Code 2"; Code[20])
        {
            Caption = 'Promotion Code 2';
        }
        field(72; "Promotion Text"; Text[250])
        {
            Caption = 'Promotion Text';
        }
    }
    keys
    {
        key(PK; "Store No.","POS Terminal No.","Transaction No.","Entry No.")
        {
            Clustered = true;
        }
        key(KEY2; "Store No.","POS Terminal No.","Receipt No.")
        {            
        }
    }
}
