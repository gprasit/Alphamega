table 60127 "ESL_ESL Stores_NT"
{
    Caption = 'ESL Stores';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Store No"; Code[10])
        {
            Caption = 'Store No';
            TableRelation = "LSC Store";
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Price Group Code"; Code[10])
        {
            Caption = 'Price Group Code';
            TableRelation = "Customer Price Group";
            DataClassification = CustomerContent;
        }
        field(4; "Store Group"; Code[10])
        {
            Caption = 'Store Group';
            DataClassification = CustomerContent;
        }
        field(5; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Store No")
        {
            Clustered = true;
        }
    }
}
