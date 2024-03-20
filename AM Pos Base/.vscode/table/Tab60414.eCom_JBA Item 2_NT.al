table 60414 "eCom_JBA Item 2_NT"
{
    Caption = 'JBA Item 2';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Barcode No."; Code[20])
        {
            Caption = 'Barcode No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
        }
        field(4; "Item Vendor No."; Code[20])
        {
            Caption = 'Item Vendor No.';
            DataClassification = CustomerContent;
        }
        field(5; "Section Code"; Code[20])
        {
            Caption = 'Section Code';
            DataClassification = CustomerContent;
        }
        field(6; "POS Item Type"; Code[20])
        {
            Caption = 'POS Item Type';
            DataClassification = CustomerContent;
        }
        field(7; "Brand Code"; Code[20])
        {
            Caption = 'Brand Code';
            DataClassification = CustomerContent;
        }
        field(8; Department; Code[20])
        {
            Caption = 'Department';
            DataClassification = CustomerContent;
        }
        field(9; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            DataClassification = CustomerContent;
        }
        field(10; "VAT Code"; Code[20])
        {
            Caption = 'VAT Code';
            DataClassification = CustomerContent;
        }
        field(11; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
        field(12; "Vendor Status"; Code[1])
        {
            Caption = 'Vendor Status';
            DataClassification = CustomerContent;
            Description = '1 = Active, 0 = Inactive';
        }
        field(13; "Vendor Location"; Code[1])
        {
            Caption = 'Vendor Location';
            DataClassification = CustomerContent;
            Description = '1 = Local, 0 = Foreign';
        }
    }
    keys
    {
        key(PK; "Item Code", "Barcode No.")
        {
            Clustered = true;
        }
    }
}
