table 60102 "eCom_PostOfficeAddress_NT"
{
    Caption = 'Post Office Address';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Entry No."; Integer)
        {
            Caption = 'Entry No.';

        }
        field(60002; "Postal Code"; Code[10])
        {
            Caption = 'Postal Code';
        }
        field(60003; "Street Name"; Text[100])
        {
            Caption = 'Street Name';
        }

        field(60004; "Area"; Text[40])
        {
            Caption = 'Area';
        }
        field(60005; City; Code[20])
        {
            Caption = 'City';
        }
        field(60006; "Special Numbers"; Text[30])
        {
            Caption = 'Special Numbers';
        }
        field(60007; "Post Office Data"; Text[250])
        {
            Caption = 'Post Office Data';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PK2; "Postal Code")
        {
        }
    }
}
