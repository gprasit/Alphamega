tableextension 60418 "MA_LSC Published Offer_NT" extends "LSC Published Offer"
{
    fields
    {
        field(60101; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(60102; "Display Order"; Integer)
        {
            Caption = 'Display Order';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
    }
    keys
    {
        key(LPO_KEY1_NT; "Display Order")
        {
        }
    }
}
