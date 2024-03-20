table 60106 "Mobile App. Product Group_NT"
{
    Caption = 'Mobile App. Product Group';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Mobile App. Category"; Code[10])
        {
            Caption = 'Mobile App. Category';
            TableRelation = "Mobile App. Category_NT".Code;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Mobile App. Category")
        {
            Clustered = true;
        }
    }
}
