table 60406 "eCom_Web Order Coordinates_NT"
{
    Caption = 'Web Order Coordinates';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Order ID"; Code[20])
        {
            Caption = 'Order ID';
        }
        field(60002; Name; Text[250])
        {
            Caption = 'Name';
        }
        field(60003; Address; Text[250])
        {
            Caption = 'Address';
        }
        field(60004; "Postal Code"; Code[20])
        {
            Caption = 'Postal Code';
        }
        field(60005; City; Text[30])
        {
            Caption = 'City';
        }
        field(60006; Latitude; Text[30])
        {
            Caption = 'Latitude';
        }
        field(60007; Longitude; Text[30])
        {
            Caption = 'Longitude';
        }
        field(60008; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(60009; "Member Contact No."; Code[20])
        {
            Caption = 'Member Contact No.';
        }

    }
    keys
    {
        key(PK; "Order ID")
        {
            Clustered = true;
        }
    }
}
