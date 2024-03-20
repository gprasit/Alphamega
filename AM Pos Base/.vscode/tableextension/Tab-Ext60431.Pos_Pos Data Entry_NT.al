tableextension 60431 "Pos_Pos Data Entry_NT" extends "LSC POS Data Entry"
{
    fields
    {
        field(60401; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }
        field(60402; "e-mail"; Text[80])
        {
            Caption = 'e-mail';
            DataClassification = CustomerContent;
        }
        field(60403; Beneficiary; Text[50])
        {
            Caption = 'Beneficiary';
            DataClassification = CustomerContent;
        }
        field(60404; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }        
    }
}
