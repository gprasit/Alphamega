table 60105 "eCom_Post Code Location_NT"
{
    Caption = 'Post Code Location';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Post Code"; Code[10])
        {
            Caption = 'Post Code';
        }
        field(60002; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }

    }
    keys
    {
        key(PK; "Post Code")
        {
            Clustered = true;
        }
    }
}
