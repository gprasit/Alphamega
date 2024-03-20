tableextension 60429 "Pos_Trans. Payment Entry_NT" extends "LSC Trans. Payment Entry"
{
    fields
    {
        field(60401; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
        }
        field(60402; "sKash Entry No."; Integer)
        {
            Caption = 'sKash Entry No.';
            DataClassification = CustomerContent;
        }
        // field(60403; "EFT Transaction System ID"; Code[30])
        // {
        //     Caption = 'EFT Transaction System ID';
        //     DataClassification = CustomerContent;
        // }
    }
}
