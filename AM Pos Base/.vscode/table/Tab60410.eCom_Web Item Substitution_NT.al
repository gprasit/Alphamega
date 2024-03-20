table 60410 "eCom_Web Item Substitution_NT"
{
    Caption = 'Web Item Substitution';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Web Item No."; Code[20])
        {
            Caption = 'Web Item No.';
        }
        field(2; "Item No."; code[20])
        {
            Caption = 'Item No.';
        }
        field(3; "Description"; Text[50])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Web Item No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.")
        {
        }
    }
}