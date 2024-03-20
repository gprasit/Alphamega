tableextension 60417 "MA_LSC Member Login_NT" extends "LSC Member Login"
{
    fields
    {
        field(60101; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(60102; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key2; "Account No.", "Contact No.")
        {
        }
    }
}
