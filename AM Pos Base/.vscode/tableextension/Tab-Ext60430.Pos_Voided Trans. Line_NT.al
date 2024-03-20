tableextension 60430 "Pos_Voided Trans. Line_NT" extends "LSC POS Voided Trans. Line"
{
    fields
    {
        field(60405; "Void Command"; Code[20])
        {
            Caption = 'Void Command';
            DataClassification = CustomerContent;
        }
    }
}
