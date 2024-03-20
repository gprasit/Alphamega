table 60429 "Pos_Vendor Supplier_NT"
{
    Caption = 'Vendor Supplier';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(2; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Vendor No.", "Supplier No.")
        {
            Clustered = true;
        }
        key(KEY2; "Supplier No.","Vendor No.")
        {            
        }
    }
}
