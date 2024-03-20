table 60120 "Kiosk Setup_NT"
{
    Caption = 'Kiosk Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Voucher Nos."; Code[20])
        {
            Caption = 'Voucher Nos.';
            DataClassification = CustomerContent;
        }
        field(3; "Club Code"; Code[10])
        {
            Caption = 'Club Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Member Club";
        }
        field(4; "Redemption Store No."; Code[20])
        {
            Caption = 'Redemption Store No.';
            DataClassification = CustomerContent;
        }
        field(5; "Redemption Pos Terminal No."; Code[20])
        {
            Caption = 'Redemption Pos Terminal No.';
            DataClassification = CustomerContent;
        }
        field(6; "Last Contact Entry No."; Integer)
        {
            Caption = 'Last Contact Entry No.';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(7; "Cancel Voucher Nos."; Code[10])
        {
            Caption = 'Cancel Voucher Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(8; "SMTP Server"; Text[30])
        {
            Caption = 'SMTP Server';
            DataClassification = CustomerContent;
        }
        field(9; "Last Loyalty Points Entry No."; Integer)
        {
            Caption = 'Last Loyalty Points Entry No.';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(10; "Registration Bonus Points"; Integer)
        {
            Caption = 'Registration Bonus Points';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(11; "SMTP Server Port"; Integer)
        {
            Caption = 'SMTP Server Port';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(12; "SMTP Server User Name"; Text[30])
        {
            Caption = 'SMTP Server User Name';
            DataClassification = CustomerContent;
        }
        field(13; "SMTP Server Password"; Text[30])
        {
            Caption = 'SMTP Server Password';
            DataClassification = CustomerContent;
        }
        field(14; "Vouch.Exp. Date Calc. (Months)"; Integer)
        {
            Caption = 'Vouch.Exp. Date Calc. (Months)';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(15; "Welcome Email Template"; Blob)
        {
            Caption = 'Welcome Email Template';
            DataClassification = CustomerContent;
        }
        field(16; "Update Email Template"; Blob)
        {
            Caption = 'Update Email Template';
            DataClassification = CustomerContent;
        }
        field(20; "Change PIN Email Template"; Blob)
        {
            Caption = 'Change PIN Email Template';
            DataClassification = CustomerContent;
        }

        field(25; "Welcome SMS Template"; Blob)
        {
            Caption = 'Welcome SMS Template';
            DataClassification = CustomerContent;
        }
        field(30; "Update SMS Template"; Blob)
        {
            Caption = 'Update SMS Template';
            DataClassification = CustomerContent;
        }
        field(35; "Change PIN SMS Template"; Blob)
        {
            Caption = 'Change PIN SMS Template';
            DataClassification = CustomerContent;
        }
        field(40; "Voucher SMS Template"; Blob)
        {
            Caption = 'Voucher SMS Template';
            DataClassification = CustomerContent;
        }
        field(45; "Voucher Email Template"; Blob)
        {
            Caption = 'Voucher Email Template';
            DataClassification = CustomerContent;
        }
        field(50; "Default Kiosk Store No."; Code[10])
        {
            Caption = 'Default Kiosk Store No.';
            TableRelation = "LSC Store";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(55; "Default Supplier ID"; Code[250])
        {
            Caption = 'Default Supplier ID';
            DataClassification = CustomerContent;
        }
        field(60; "Default Country/Region Code"; Code[10])
        {
            Caption = 'Default Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(65; "Default Web Store No."; Code[10])
        {
            Caption = 'Default Web Store No.';
            TableRelation = "LSC Store";
            ValidateTableRelation = false;
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
