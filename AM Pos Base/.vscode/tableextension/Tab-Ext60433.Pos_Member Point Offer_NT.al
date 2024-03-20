tableextension 60433 "Pos_Member Point Offer_NT" extends "LSC Member Point Offer"
{
    fields
    {
        field(60400; "Amount To Trigger"; Decimal)
        {
            Caption = 'Amount To Trigger';
            DataClassification = CustomerContent;
        }
        field(60401; "Amt. To Trigger Based On Lines"; Boolean)
        {
            Caption = 'Amt. To Trigger Based On Lines';
            DataClassification = CustomerContent;
        }
        field(60402; "Custom Sticker"; Text[30])
        {
            Caption ='Custom Sticker';
            DataClassification = CustomerContent;
        }
    }
}
