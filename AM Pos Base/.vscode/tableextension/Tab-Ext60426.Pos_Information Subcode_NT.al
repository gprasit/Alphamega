tableextension 60426 "Pos_Information Subcode_NT" extends "LSC Information Subcode"
{
    fields
    {
        field(60401; "JBA Code"; Code[10])
        {
            Caption = 'JBA Code';
            DataClassification = CustomerContent;
        }
        field(60402; "Bean Bar"; Boolean)
        {
            Caption = 'Bean Bar';
            DataClassification = CustomerContent;
        }
    }
}
