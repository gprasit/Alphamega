tableextension 60414 "eCom_Member Account_NT" extends "LSC Member Account"
{
    fields
    {
        field(60101; "Special Group"; Text[2])
        {
            Caption = 'Special Group';
            DataClassification = CustomerContent;
        }
        field(60102; "Balance at Date"; Decimal)
        {
            Caption = 'Balance at Date';
            FieldClass = FlowField;
            CalcFormula = Sum("LSC Member Point Entry".Points WHERE("Account No." = FIELD("No."), Date = FIELD("Date Filter")));
        }
    }
}
