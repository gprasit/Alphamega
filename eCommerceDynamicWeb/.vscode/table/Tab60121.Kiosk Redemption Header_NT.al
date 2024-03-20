table 60121 "Kiosk Redemption Header_NT"
{
    Caption = 'Kiosk Redemption Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Category; Code[20])
        {
            Caption = 'Category';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Description GR"; Text[250])
        {
            Caption = 'Description GR';
            DataClassification = CustomerContent;
        }
        field(4; "Description RU"; Text[250])
        {
            Caption = 'Description RU';
            DataClassification = CustomerContent;
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(6; "Image File Name"; Text[250])
        {
            Caption = 'Image File Name';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Category)
        {
            Clustered = true;
        }
    }
}
