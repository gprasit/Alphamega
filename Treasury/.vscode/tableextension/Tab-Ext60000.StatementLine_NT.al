tableextension 60000 "Statement Line_NT" extends "LSC Statement Line"
{
    fields
    {
        field(60000; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';
            DataClassification = CustomerContent;
            TableRelation = "Treasury Statement_NT"."Treasury Statement No.";
        }
    }
}
