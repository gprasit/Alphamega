tableextension 60002 ReasonCode_NT extends "Reason Code"
{
    fields
    {
        field(60000; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(60001; "G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name';
            CalcFormula = Lookup("G/L Account".Name WHERE("No." = FIELD("G/L Account No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    fieldgroups
    {
        addlast(Brick; "G/L Account No.") { }
    }
}
