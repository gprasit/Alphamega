table 60430 "Pos_Topup Setup_NT"
{
    Caption = 'Topup Setup';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Topup Alta XL Initializer"; Code[10])
        {
            Caption = 'Topup Alta XL Initializer';
        }
        field(3; "Topup User Name"; Code[10])
        {
            Caption = 'Topup User Name';
        }
        field(4; "Topup Temp Password"; Code[10])
        {
            Caption = 'Topup Temp Password';
        }
        field(5; "Topup Password"; Text[250])
        {
            Caption = 'Topup Password';
        }
        field(6; "Topup Location Hash"; Text[250])
        {
            Caption = 'Topup Location Hash';
        }
        field(7; "Topup No. Of Retries"; Integer)
        {
            Caption = 'Topup No. Of Retries';
        }
        field(8; "Topup Name On Receipt"; Text[30])
        {
            Caption = 'Topup Name On Receipt';
        }
        field(9; "sKash Password"; Text[250])
        {
            Caption = 'sKash Password';
        }
        field(10; "sKash Location Hash"; Text[250])
        {
            Caption = 'sKash Location Hash';
        }
        field(11; "sKash Schema"; Text[30])
        {
            Caption = 'sKash Schema';
        }
        field(12; "sKash Account Type"; Text[30])
        {
            Caption = 'sKash Account Type';
        }
        field(13; "sKash Time Out (ms)"; Integer)
        {
            Caption = 'sKash Time Out (ms)';
        }
        field(14; "sKash Retry Interval (ms)"; Integer)
        {
            Caption = 'sKash Retry Interval (ms)';
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
