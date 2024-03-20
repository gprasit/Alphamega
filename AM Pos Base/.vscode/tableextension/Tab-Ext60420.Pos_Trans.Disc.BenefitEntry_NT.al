tableextension 60420 "Pos_Trans.Disc.BenefitEntry_NT" extends "LSC Trans. Disc. Benefit Entry"
{
    fields
    {
        field(60401; PopUp; Boolean)
        {
            Caption = 'PopUp';
            DataClassification = CustomerContent;
        }
        field(60402; "Popup Message"; Text[50])
        {
            Caption = 'Popup Message';
            DataClassification = CustomerContent;
        }
    }
}
