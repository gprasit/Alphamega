tableextension 60003 "Bank Acc. Ledger Entry_NT" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(60000; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';
            DataClassification = CustomerContent;
            TableRelation = "Treasury Statement_NT"."Treasury Statement No.";
            Editable = false;
        }
        field(60001; "Treas. Alloc. Line No."; Integer)
        {
            Caption = 'Treas. Alloc. Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60002; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Retail Hierarchy".Code;
            Editable = false;
        }
    }
}