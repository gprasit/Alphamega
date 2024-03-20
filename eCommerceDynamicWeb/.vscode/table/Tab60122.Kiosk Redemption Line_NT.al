table 60122 "Kiosk Redemption Line_NT"
{
    Caption = 'Kiosk Redemption Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Category; Code[20])
        {
            Caption = 'Category';
            TableRelation = "Kiosk Redemption Header_NT";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sub Category"; Code[20])
        {
            Caption = 'Sub Category';
            TableRelation = "Kiosk Redem. Subcategory_NT".Code WHERE(Category = FIELD(Category));
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(5; Title; Text[250])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "Detailed Description"; Text[250])
        {
            Caption = 'Detailed Description';
            DataClassification = CustomerContent;
        }
        field(8; "Image File Name"; Text[250])
        {
            Caption = 'Image File Name';
            DataClassification = CustomerContent;
        }
        field(9; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(10; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(11; Points; Integer)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(12; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(13; "Coupon No."; Code[20])
        {
            Caption = 'Coupon No.';
            DataClassification = CustomerContent;
        }
        field(14; "Voucher Terms Text File Name"; Text[250])
        {
            Caption = 'Voucher Terms Text File Name';
            DataClassification = CustomerContent;
        }
        field(15; "Description GR"; Text[250])
        {
            Caption = 'Description GR';
            DataClassification = CustomerContent;
        }
        field(16; "Description RU"; Text[250])
        {
            Caption = 'Description RU';
            DataClassification = CustomerContent;
        }
        field(17; "Detailed Description GR"; Text[250])
        {
            Caption = 'Detailed Description GR';
            DataClassification = CustomerContent;
        }
        field(18; "Detailed Description RU"; Text[250])
        {
            Caption = 'Detailed Description RU';
            DataClassification = CustomerContent;
        }
        field(19; "Vou. Terms Text File Name GR"; Text[250])
        {
            Caption = 'Vou. Terms Text File Name GR';
            DataClassification = CustomerContent;
        }
        field(20; "Vou. Terms Text File Name RU"; Text[250])
        {
            Caption = 'Vou. Terms Text File Name RU';
            DataClassification = CustomerContent;
        }
        field(21; "Location Description"; Text[250])
        {
            Caption = 'Location Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Category, "Sub Category", "Line No.")
        {
            Clustered = true;
        }
    }
}
