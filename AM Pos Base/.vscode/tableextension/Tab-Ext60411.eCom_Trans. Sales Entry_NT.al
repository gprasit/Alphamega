tableextension 60411 "eCom_Trans. Sales Entry_NT" extends "LSC Trans. Sales Entry"
{
    fields
    {
        field(60000; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(60001; "Member Card No."; Code[20])
        {
            Caption = 'Member Card No.';
            DataClassification = CustomerContent;
        }
        field(60002; "Item Department Code"; Code[20])
        {
            Caption = 'Item Department Code';
            DataClassification = CustomerContent;
            TableRelation = "eCom_Item Department_NT";
        }
        field(60003; "Item Brand Code"; Code[20])
        {
            Caption = 'Item Brand Code';
            DataClassification = CustomerContent;
        }
        field(60004; "Item Vendor No."; Code[20])
        {
            Caption = 'Item Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(60005; "POS Item Type Code"; Code[20])
        {
            Caption = 'POS Item Type Code';
            DataClassification = CustomerContent;
        }
        field(60006; "Gross Amount"; Decimal)
        {
            Caption = 'Gross Amount';
            DataClassification = CustomerContent;
        }
        field(60007; "Price After Discount"; Decimal)
        {
            Caption = 'Price After Discount';
            DataClassification = CustomerContent;
        }
        field(60008; "ASR Department Code"; Code[10])
        {
            Caption = 'ASR Department Code';
            DataClassification = CustomerContent;
            TableRelation = eCom_Address_NT;
        }
        field(60009; "No. Of Exchange Cards"; Integer)
        {
            Caption = 'No. Of Exchange Cards';
            DataClassification = CustomerContent;
        }
        field(60010; "Item Family Code"; Code[10])
        {
            Caption = 'Item Family Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Item Family".Code;
        }
        field(60011; "Discount Offer No."; Code[20])
        {
            Caption = 'Discount Offer No.';
            DataClassification = CustomerContent;
        }
        field(60012; "Discount Offer Description"; Text[30])
        {
            Caption = 'Discount Offer Description';
            DataClassification = CustomerContent;
        }
        field(60013; "Gift Receipt Qty. to Print";Integer)
        {
            Caption ='Gift Receipt Qty. to Print';            
            DataClassification = CustomerContent;
        }
    }
}
