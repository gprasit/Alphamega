tableextension 60428 "Pos_Tender Type Setup_NT" extends "LSC Tender Type Setup"
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
        field(60403; "Confirm On Select"; Boolean)
        {
            Caption = 'Confirm On Select';
            DataClassification = CustomerContent;
        }
        // field(60404; "EFT Provider"; Option)
        // {
        //     Caption = 'EFT Provider';
        //     DataClassification = CustomerContent;
        //     OptionMembers = ,JCC,RCB;
        // }
        // field(60405; "Sorting"; Integer)
        // {
        //     Caption = 'Sorting';
        //     DataClassification = CustomerContent;
        // }
    }
}
