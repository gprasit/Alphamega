tableextension 60410 "eCom_Transaction Header_NT" extends "LSC Transaction Header"
{
    fields
    {
        field(60000; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
        }
        field(60001; "Continuity Member No."; Code[20])
        {
            Caption = 'Continuity Member No.';
            DataClassification = CustomerContent;
        }
        field(60002; "QR Code Used"; Boolean)
        {
            Caption = 'QR Code Used';
            DataClassification = CustomerContent;
        }
        field(60003; "Loyalty Gross Amount"; Decimal)
        {
            Caption = 'Loyalty Gross Amount';
            DataClassification = CustomerContent;
        }
        field(60004; "External Order ID"; Code[20])
        {
            Caption = 'External Order ID';
            DataClassification = CustomerContent;
        }
        field(60005; "eCom Order No."; Code[20])
        {
            Caption = 'eCom Order No.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(TH_KEY1_NT; "Member Card No.")
        {
        }
    }
}
