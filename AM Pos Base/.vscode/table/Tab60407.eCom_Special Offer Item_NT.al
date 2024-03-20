table 60407 "eCom_Special Offer Item_NT"
{
    Caption = 'Special Offer Item_NT';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Offer Item No."; Code[10])
        {
            Caption = 'Offer Item No.';
        }
        field(2; "Offer Item Description"; Text[50])
        {
            Caption = 'Offer Item Description';
        }
        field(3; "Item No."; code[20])
        {
            Caption = 'Item No.';
        }
        field(4; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
        }

    }
    keys
    {
        key(PK; "Offer Item No.")
        {
            Clustered = true;
        }
    }
}
