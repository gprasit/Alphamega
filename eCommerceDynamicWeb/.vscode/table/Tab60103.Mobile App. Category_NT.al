table 60103 "Mobile App. Category_NT"
{
    Caption = 'Mobile App. Category';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Aurora ID"; Code[10])
        {
            Caption = 'Aurora ID';
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
