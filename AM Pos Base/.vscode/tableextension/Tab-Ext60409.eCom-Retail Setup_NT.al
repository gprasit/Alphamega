tableextension 60409 "eCom-Retail Setup_NT" extends "LSC Retail Setup"
{
    fields
    {
        field(60000; "Loyalty Redemption No. Series"; Code[10])
        {
            Caption = 'Loyalty Redemption No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60001; "Internet Users Counter"; Integer)
        {
            Caption = 'Internet Users Counter';
            DataClassification = CustomerContent;
        }
        field(60002; "Max Discount %"; Decimal)
        {
            Caption = 'Max Discount %';
            DataClassification = CustomerContent;
        }
        field(60003; "Redemption Nos."; Code[10])
        {
            Caption = 'Redemption Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60004; "Max Adjustment Points"; Decimal)
        {
            Caption = 'Max Adjustment Points';
            DataClassification = CustomerContent;
        }
        field(60005; "Price Change Email"; Text[250])
        {
            Caption = 'Price Change Email';
            DataClassification = CustomerContent;
        }
        field(60006; "Update Web Item OOS"; Boolean)
        {
            Caption = 'Update Web Item OOS';
            DataClassification = CustomerContent;
        }
    }
}
