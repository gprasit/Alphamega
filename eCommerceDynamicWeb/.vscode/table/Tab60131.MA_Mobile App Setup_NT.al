table 60131 "MA_Mobile App Setup_NT"
{
    Caption = 'Mobile App Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Leaflet Nos."; Code[10])
        {
            Caption = 'Leaflet Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(3; "Menu Recipe Nos."; Code[10])
        {
            Caption = 'Menu Recipe Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(4; "Registration Bonus Points"; Integer)
        {
            Caption = 'Registration Bonus Points';
            DataClassification = CustomerContent;
        }
        field(5; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(6; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
        }
        field(7; "Carouzel Recipe Nos."; Code[10])
        {
            Caption = 'Carouzel Recipe Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(8; "Member Notification Enabled"; Boolean)
        {
            Caption = 'Member Notification Enabled';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
