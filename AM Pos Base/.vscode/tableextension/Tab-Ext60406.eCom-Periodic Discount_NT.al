tableextension 60406 "eCom-Periodic Discount_NT" extends "LSC Periodic Discount"
{
    fields
    {
        field(60000; "PMT"; Code[20])
        {
            Caption = 'PMT';
            DataClassification = CustomerContent;
        }
        field(50001; "Qty Sold"; Decimal)
        {
            Caption = 'Qty Sold';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50002; "Amount Sold"; Decimal)
        {
            Caption = 'Amount Sold';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50003; "PMT Type"; enum "eCom-PMT Type_NT")
        {
            Caption = 'PMT Type';
            DataClassification = CustomerContent;
        }
        field(50004; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
        }
        field(50005; "Store Filter"; Code[20])
        {
            Caption = 'Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "LSC Store"."No.";
        }
        field(50006; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(50007; "Location Filter"; Code[20])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = "LSC Store"."No.";
        }
        field(50008; "Qty. Sold"; Decimal)
        {
            Caption = 'Qty. Sold';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50009; "Promo Sales"; Decimal)
        {
            Caption = 'Promo Sales';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50010; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50011; "Periodic Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(50012; "POS Popup Message"; Text[250])
        {
            Caption = 'POS Popup Message';
            DataClassification = CustomerContent;
        }
        field(50013; "Retail Status"; Option)
        {
            Caption = 'Retail Status';
            DataClassification = CustomerContent;
            OptionMembers = New,Active,Ended;
        }
        field(50014; "Over Limit Discount Line Exist"; Boolean)
        {
            Caption = 'Over Limit Discount Line Exist';
            DataClassification = CustomerContent;
        }
        field(50015; "Valid Only When Member Scanned"; Boolean)
        {
            Caption = 'Valid Only When Member Scanned';
            DataClassification = CustomerContent;
        }
        field(50016; "Created From Promotion File"; Boolean)
        {
            Caption = 'Created From Promotion File';
            DataClassification = CustomerContent;
        }
        field(50020; "Amt. to Trigger Based on Lines"; Boolean)
        {
            Caption = 'Amt. to Trigger Based on Lines';
            DataClassification = CustomerContent;
        }
        field(50021; "ESL Offer Description"; Text[50])
        {
            Caption = 'ESL Offer Description';
            DataClassification = CustomerContent;
        }
        field(50022; "Offer Target"; Option)
        {
            Caption = 'Offer Target';
            DataClassification = ToBeClassified;
            OptionMembers = POS,"Mobile App.";
        }
        field(50023; GreekDescription; Text[50])
        {
            Caption = 'GreekDescription';
            DataClassification = CustomerContent;
        }
        field(50024; "Promotion Search Key"; Code[250])
        {
            DataClassification = CustomerContent;
        }
        field(50025; "Discount Offer No."; Code[20])
        {
            Caption = 'Discount Offer No.';
            DataClassification = CustomerContent;
        }
    }    
}
