table 60413 eCom_Address_NT
{
    Caption = 'Address';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Name GR"; Text[100])
        {
            Caption = 'Name GR';
            DataClassification = CustomerContent;
        }
        field(4; Municipality; Text[100])
        {
            Caption = 'Municipality';
            DataClassification = CustomerContent;
        }
        field(5; "Municipality GR"; Text[100])
        {
            Caption = 'Municipality GR';
            DataClassification = CustomerContent;
        }
        field(6; District; Text[30])
        {
            Caption = 'District';
            DataClassification = CustomerContent;
        }
        field(7; "District GR"; Text[30])
        {
            Caption = 'District GR';
            DataClassification = CustomerContent;
        }
        field(8; "Postal Code"; Code[10])
        {
            Caption = 'Postal Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
    }
}
