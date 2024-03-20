table 60107 Kiosk_NT
{
    Caption = 'Kiosk';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "IP Address"; Code[15])
        {
            Caption = 'IP Address';
        }
        field(2; "Kiosk Code"; Code[20])
        {
            Caption = 'Kiosk Code';
        }
        field(3; "Kiosk Name"; Text[50])
        {
            Caption = 'Kiosk Name';
        }
        field(4; "Kiosk Location"; Text[50])
        {
            Caption = 'Kiosk Location';
        }
        field(5; "Kiosk Store"; Code[20])
        {
            Caption = 'Kiosk Store';
        }
        field(6; "Terminal No."; Code[10])
        {
            Caption = 'Terminal No.';
        }
    }
    keys
    {
        key(PK; "IP Address")
        {
            Clustered = true;
        }
        key(KEY2; "Kiosk Code")
        {            
        }
    }
}
