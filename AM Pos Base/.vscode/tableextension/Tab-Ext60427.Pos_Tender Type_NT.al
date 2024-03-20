tableextension 60427 "Pos_Tender Type_NT" extends "LSC Tender Type"
{
    fields
    {
        field(60401; "Only Negative Transaction"; Boolean)
        {
            Caption = 'Only Negative Transaction';
            DataClassification = CustomerContent;
        }
        field(60402; "Not Valid On Account Payment"; Boolean)
        {
            Caption = 'Not Valid On Account Payment';
            DataClassification = CustomerContent;
        }
        field(60403; "Mobile Payment"; Boolean)
        {
            Caption = 'Mobile Payment';
            DataClassification = CustomerContent;
        }
        field(60404; "sKash Payment"; Boolean)
        {
            Caption = 'sKash Payment';
            DataClassification = CustomerContent;
        }
        // field(60405; "EFT Provider"; Option)
        // {
        //     Caption = 'EFT Provider';
        //     DataClassification = CustomerContent;
        //     OptionMembers = ,JCC,RCB;
        // }
        field(60406; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(60407; "WEB Name"; Text[30])
        {
            Caption = 'WEB Name';
            DataClassification = CustomerContent;
        }
        field(60408; "Master Tender"; Code[10])
        {
            Caption = 'Master Tender';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "LSC Tender Type Setup".Code;
        }
        field(60409; "Exclude in Z Report_NC"; Boolean)
        {
            Caption = 'Exclude in Z Report Non Cash';
            DataClassification = CustomerContent;
        }
    }
}
