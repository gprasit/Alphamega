tableextension 60401 "eCom-Member Contact_NT" extends "LSC Member Contact"
{
    fields
    {
        field(60001; "Created In Store No."; Code[20])
        {
            Caption = 'Created In Store No.';
            DataClassification = CustomerContent;
        }
        field(60007; "Building Name"; Text[50])
        {
            Caption = 'Building Name';
            DataClassification = CustomerContent;
        }
        field(60008; "Flat No."; Code[10])
        {
            Caption = 'Flat No.';
            DataClassification = CustomerContent;
        }
        field(60009; PhoneCode; Text[20])
        {
            Caption = 'PhoneCode';
            DataClassification = CustomerContent;
        }
        field(60014; "ID Number"; Code[20])
        {
            Caption = 'ID Number';
            DataClassification = CustomerContent;
        }
        field(60018; Title; Code[5])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(60020; "Kiosk Pin"; Text[4])
        {
            Caption = 'Kiosk Pin';
            DataClassification = CustomerContent;
        }
        field(60021; "Gender 2"; Code[10])
        {
            Caption = 'Gender 2';
            DataClassification = CustomerContent;
        }
        field(60022; "Address Confirmed"; Boolean)
        {
            Caption = 'Address Confirmed';
            DataClassification = CustomerContent;
        }
        field(60025; "Address ID"; Integer)
        {
            Caption = 'Address ID';
            DataClassification = CustomerContent;
        }
        field(60026; "e-Commerce Customer"; Boolean)
        {
            Caption = 'e-Commerce Customer';
            DataClassification = CustomerContent;
        }
        field(60050; "GDPR Level"; Integer)
        {
            Caption = 'GDPR Level';
            DataClassification = CustomerContent;
        }
        field(60051; "GDPR Updated By"; Text[50])
        {
            Caption = 'GDPR Date Updated';
            DataClassification = CustomerContent;
        }
        field(60052; "GDPR Date Updated"; Date)
        {
            Caption = 'GDPR Date Updated';
            DataClassification = CustomerContent;
        }
        field(60053; "GDPR Time Updated"; Time)
        {
            Caption = 'GDPR Time Updated';
            DataClassification = CustomerContent;
        }
        field(60054; "GDPR Other"; Text[50])
        {
            Caption = 'GDPR Other';
            DataClassification = CustomerContent;
        }
        field(60055; "Region Code"; Code[150])
        {
            Caption = 'Region Code';
            DataClassification = CustomerContent;
        }
        // field(60066; "Language Code"; Code[10])
        // {
        //     Caption = 'Language Code';
        //     DataClassification = CustomerContent;
        // }
        field(60067; "E-Mail 2"; Text[80])
        {
            Caption = 'E-Mail 2';
            DataClassification = CustomerContent;
        }
        field(60068; "No SMS"; Boolean)
        {
            Caption = 'No SMS';
            DataClassification = CustomerContent;
        }
        field(60069; "Old Contact No."; Code[20])
        {
            Caption = 'Old Contact No.';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PKEY1_NT; "Phone No.")
        {
        }
        key(PKEY2_NT; "Mobile Phone No.")
        {
        }
    }

}
