table 60104 "eCom_Web.VerificationCodes_NT"
{
    Caption = 'Website Verification Codes';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Customer Information"; Text[80])
        {
            Caption = 'Customer Information';
            Description = 'Mobile phone or email';
        }
        field(60002; "Verification Code"; Text[100])
        {
            Caption = 'Verification Code';
        }
        field(60003; "Date Created"; Date)
        {
            Caption = 'Date Created';
        }
        field(60004; "Time Created"; Time)
        {
            Caption = 'Time Created';
        }
        field(60005; "Date of Verification"; Date)
        {
            Caption = 'Date of Verification';
        }
        field(60006; "Time of Verification"; Time)
        {
            Caption = 'Time of Verification';
        }

    }
    keys
    {
        key(PK; "Customer Information")
        {
            Clustered = true;
        }
    }
}
