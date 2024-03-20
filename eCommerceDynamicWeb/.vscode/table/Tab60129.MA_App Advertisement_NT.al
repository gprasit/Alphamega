table 60129 "MA_App Advertisement_NT"
{
    Caption = 'App Advertisement';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Description EN"; Text[50])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
        field(3; "Description GR"; Text[50])
        {
            Caption = 'Description GR';
            DataClassification = CustomerContent;
        }
        field(4; "Image Code EN"; Code[20])
        {
            Caption = 'Image Code EN';
            TableRelation = "LSC Retail Image";
            DataClassification = CustomerContent;
        }
        field(5; "Image Code GR"; Code[20])
        {
            Caption = 'Image Code GR';
            TableRelation = "LSC Retail Image";
            DataClassification = CustomerContent;
        }
        field(6; "Link EN"; Text[250])
        {
            Caption = 'Link EN';
            DataClassification = CustomerContent;
        }
        field(7; "Link GR"; Text[250])
        {
            Caption = 'Link GR';
            DataClassification = CustomerContent;
        }
        field(8; "Expiration Date"; DateTime)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(9; "Display Order"; Integer)
        {
            Caption = 'Display Order';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
