tableextension 60419 "Pos_Periodic Disc. Benefits_NT" extends "LSC Periodic Discount Benefits"
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
            trigger OnValidate()
            var
            begin
                if Rec."Popup Message" <> '' then
                    TestField(PopUp);
            end;
        }
    }
}
