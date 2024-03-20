tableextension 60412 "eCom_Return Reason_NT" extends "Return Reason"
{
    fields
    {
        field(60000; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Return,"Return & Adjust";
        }

    }
}
