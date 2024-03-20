tableextension 60423 "Pos_Income/Expense Account_NT" extends "LSC Income/Expense Account"
{
    fields
    {
        field(60401; "No Loyalty Points"; Boolean)
        {
            Caption = 'No Loyalty Points';
            DataClassification = CustomerContent;
        }
    }
}
