tableextension 60432 "Pos_Trans. Discount Entry_NT" extends "LSC Trans. Discount Entry"
{
    fields
    {
        field(60401; "Discount Offer No."; Code[20])
        {
            Caption = 'Discount Offer No.';
            DataClassification = CustomerContent;
        }
        field(60402; "Discount Offer Description"; Text[30])
        {
            Caption = 'Discount Offer Description';
            DataClassification = CustomerContent;
        }
    }
}
