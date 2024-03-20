table 60128 "ESL_Export Buffer_NT"
{
    Caption = 'ESL_Export Buffer_NT';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Item No"; Code[20])
        {
            Caption = 'Item No';
            DataClassification = CustomerContent;
        }
        field(2; "Offer No"; Code[20])
        {
            Caption = 'Offer No';
            DataClassification = CustomerContent;
        }
        field(3; "Decimal Value 1"; Decimal)
        {
            Caption = 'Decimal Value 1';
            DataClassification = CustomerContent;
        }
        field(4; "Decimal Value 2"; Decimal)
        {
            Caption = 'Decimal Value 2';
            DataClassification = CustomerContent;
        }
        field(5; "Store No"; Code[20])
        {
            Caption = 'Store No';
            DataClassification = CustomerContent;
        }
        field(6; "ESL Countries"; Boolean)
        {
            Caption = 'ESL Countries';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Item No")
        {
            Clustered = true;
        }
    }
}
