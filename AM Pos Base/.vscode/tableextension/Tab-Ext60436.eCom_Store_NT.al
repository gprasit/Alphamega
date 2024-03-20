tableextension 60436 eCom_Store_NT extends "LSC Store"
{
    fields
    {
        field(60000; "Loyalty Cataloque No. Series"; Code[10])
        {
            Caption = 'Loyalty Cataloque No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60001; "Web Store No."; Code[10])
        {
            Caption = 'Web Store No.';
            DataClassification = CustomerContent;
        }
    }
}
