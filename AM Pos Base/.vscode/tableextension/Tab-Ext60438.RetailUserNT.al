tableextension 60438 "Retail User_NT" extends "LSC Retail User"
{
    fields
    {
        field(60401; "Allow Unlimited Points"; Boolean)
        {
            Caption = 'Allow Unlimited Points';
            DataClassification = CustomerContent;
        }
        field(60402; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Retail Hierarchy".Code;
        }
    }
}
