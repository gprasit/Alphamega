table 60427 Pos_Continuity_NT
{
    Caption = 'Continuity';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(4; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(5; "One Coupon Per Amount"; Integer)
        {
            Caption = 'One Coupon Per Amount';
            DataClassification = CustomerContent;
        }
        field(6; "One Digital Coupon Per Amount"; Integer)
        {
            Caption = 'One Digital Coupon Per Amount';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Starting Date","Ending Date")
        {            
        }
    }
}
