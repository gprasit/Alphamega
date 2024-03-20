tableextension 60407 "eCom-Periodic Discount Line_NT" extends "LSC Periodic Discount Line"
{
    fields
    {
        field(60000; "Discount Offer No."; Code[20])
        {
            Caption = 'Discount Offer No.';
            DataClassification = CustomerContent;
        }
        field(50001; "Discount Offer Description"; Text[30])
        {
            Caption = 'Discount Offer Description';
            DataClassification = CustomerContent;
        }
        field(50002; "Offset for No. of Items"; Decimal)
        {
            Caption = 'Offset for No. of Items';
            DataClassification = CustomerContent;
        }
        field(50003; "Over Limit Discount"; Boolean)
        {
            Caption = 'Over Limit Discount';
            DataClassification = CustomerContent;
        }
        field(50004; "Category Code"; Code[10])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
        }
        field(50005; "Category Description"; Text[50])
        {
            Caption = 'Category Description';
            DataClassification = CustomerContent;
        }

    }    
    keys
    {
        key(Key1_NT; "Discount Offer No.")
        {            
        }
    }
}
