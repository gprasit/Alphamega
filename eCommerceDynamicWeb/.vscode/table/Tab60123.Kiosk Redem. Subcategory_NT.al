table 60123 "Kiosk Redem. Subcategory_NT"
{
    Caption = 'Kiosk Redemption Subcategory';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Category; Code[20])
        {
            Caption = 'Category';
            TableRelation = "Kiosk Redemption Header_NT";
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Image File Name"; Text[250])
        {
            Caption = 'Image File Name';
            DataClassification = CustomerContent;
        }
        field(5; "Description GR"; Text[250])
        {
            Caption = 'Description GR';
            DataClassification = CustomerContent;
        }
        field(6; "Description RU"; Text[250])
        {
            Caption = 'Description RU';
            DataClassification = CustomerContent;
        }
        field(7; Nicosia; Boolean)
        {
            Caption = 'Nicosia';
            DataClassification = CustomerContent;
        }
        field(8; Limassol; Boolean)
        {
            Caption = 'Limassol';
            DataClassification = CustomerContent;
        }
        field(9; Larnaca; Boolean)
        {
            Caption = 'Larnaca';
            DataClassification = CustomerContent;
        }
        field(10; Paphos; Boolean)
        {
            Caption = 'Paphos';
            DataClassification = CustomerContent;
        }
        field(11; Famagusta; Boolean)
        {
            Caption = 'Famagusta';
            DataClassification = CustomerContent;
        }
        field(12; "Area"; Integer)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Category, Code)
        {
            Clustered = true;
        }
    }
}
