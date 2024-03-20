tableextension 60424 "Pos_POS Data Entry Type_NT" extends "LSC POS Data Entry Type"
{
    fields
    {
        field(60401; Prefix; Text[30])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(60402; "Amount Editable"; Boolean)
        {
            Caption = 'Amount Editable';
            DataClassification = CustomerContent;
        }
        field(60403; "Exclude Item Category"; Text[250])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
            ValidateTableRelation = false;
        }
        field(60404; "Tender Type"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type Setup";
        }
    }
}
