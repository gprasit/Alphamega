table 60416 "eCom_Item Parameter_NT"
{
    Caption = 'Item Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; Code[20])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(2; "Search Key"; Code[20])
        {
            Caption = 'Search Key';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }


    }
    keys
    {
        key(PK; Type, "Search Key")
        {
            Clustered = true;
        }
    }
}
