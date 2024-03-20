tableextension 60434 "Pos_Bom Component_NT" extends "BOM Component"
{
    fields
    {
        field(60401; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(60402; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
    }
}
