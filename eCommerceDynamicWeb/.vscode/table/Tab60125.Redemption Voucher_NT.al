table 60125 "Redemption Voucher_NT"
{
    Caption = 'Redemption Voucher';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Created by"; Text[50])
        {
            Caption = 'Created by';
            DataClassification = CustomerContent;
        }
        field(5; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(6; "Creation Time"; DateTime)
        {
            Caption = 'Creation Time';
            DataClassification = CustomerContent;
        }
        field(7; "Loyalty Card No."; Code[20])
        {
            Caption = 'Loyalty Card No.';
            DataClassification = CustomerContent;
        }
        field(8; "Supplier ID"; Code[250])
        {
            Caption = 'Supplier ID';
            DataClassification = CustomerContent;
        }
        field(9; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(10; Status; Enum "Redemption Voucher Status_NT")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(11; Category; Code[20])
        {
            Caption = 'Category';
            DataClassification = CustomerContent;
        }
        field(12; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(13; "Item Description"; Text[250])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(14; "Redemption Date"; Date)
        {
            Caption = 'Redemption Date';
            DataClassification = CustomerContent;
        }
        field(15; "Redeemed By"; Text[50])
        {
            Caption = 'Redeemed By';
            DataClassification = CustomerContent;
        }
        field(16; "Redeemed By Customer"; Text[50])
        {
            Caption = 'Redeemed By Customer';
            DataClassification = CustomerContent;
        }
        field(17; "Redeemed By Company"; Text[50])
        {
            Caption = 'Redeemed By Company';
            DataClassification = CustomerContent;
        }
        field(18; "Redeemed By Store"; Text[50])
        {
            Caption = 'Redeemed By Store';
            DataClassification = CustomerContent;
        }
        field(19; "Redeemed By Customer Phone"; Text[50])
        {
            Caption = 'Redeemed By Customer Phone';
            DataClassification = CustomerContent;
        }
        field(20; Points; Integer)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(KEY2; "Voucher No.")
        {
        }
        key(KEY3; Status)
        {
        }
        key(KEY4; "Creation Date")
        {
        }
    }
}
