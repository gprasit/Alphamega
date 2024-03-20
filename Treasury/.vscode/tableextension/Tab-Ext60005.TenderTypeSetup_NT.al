tableextension 60005 "Tender Type Setup_NT" extends "LSC Tender Type Setup"
{
    fields
    {
        field(60000; "Default Treasury Jrnl. Tender"; Boolean)
        {
            Caption = 'Default Treasury Journal Tender';
            DataClassification = CustomerContent;
        }
    }
}
