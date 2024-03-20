tableextension 60403 "eCom-Sales Line_NT" extends "Sales Line"
{
    fields
    {
        field(60000; "Barcode No."; Code[20])
        {
            Caption = 'Barcode No.';
            DataClassification = CustomerContent;
        }
        field(60001; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DataClassification = CustomerContent;
        }
        field(60002; "New Line"; Boolean)
        {
            Caption = 'New Line';
            DataClassification = CustomerContent;
        }
        field(60003; "Reference Line No."; Integer)
        {
            Caption = 'Reference Line No.';
            DataClassification = CustomerContent;
        }
        field(60004; "Allow Substitute"; Boolean)
        {
            Caption = 'Allow Substitute';
            DataClassification = CustomerContent;
        }
        field(60005; "Web Order Line"; Boolean)
        {
            Caption = 'Web Order Line';
            DataClassification = CustomerContent;
        }
        field(60006; "Web Order Unit Price"; Decimal)
        {
            Caption = 'Web Order Unit Price';
            DataClassification = CustomerContent;
        }
        field(60007; "Web Order Sub. For Item No."; code[20])
        {
            Caption = 'Web Order Sub. For Item No.';
            DataClassification = CustomerContent;
        }
        field(60008; "Web Order Original Price"; Decimal)
        {
            Caption = 'Web Order Original Price';
            DataClassification = CustomerContent;
        }
        field(60009; "Shipping Line"; Boolean)
        {
            Caption = 'Shipping Line';
            DataClassification = CustomerContent;
        }
        field(60010; "Web Weight"; Decimal)
        {
            Caption = 'Web Weight';
            DataClassification = CustomerContent;
        }
        field(60011; "Actual Unit Price"; Decimal)
        {
            Caption = 'Actual Unit Price';
            DataClassification = CustomerContent;
        }
        field(60012; "Base Unit Price"; Decimal)
        {
            Caption = 'Base Unit Price';
            DataClassification = CustomerContent;
        }
        field(60013; "Return Qty. to Refund"; Decimal)
        {
            Caption = 'Return Qty. to Refund';
            DataClassification = CustomerContent;
        }
        field(60014; "Return Amount to Refund"; Decimal)
        {
            Caption = 'Return Amount to Refund';
            DataClassification = CustomerContent;
        }
        field(60015; "Unit Price Difference"; Decimal)
        {
            Caption = 'Unit Price Difference';
            DataClassification = CustomerContent;
        }
        field(60016; "Correct Unit Price"; Decimal)
        {
            Caption = 'Correct Unit Price';
            DataClassification = CustomerContent;
        }

        field(60020; "From Document Type"; Option)
        {
            Caption = 'From Document Type';
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(60021; "From Document No."; Code[20])
        {
            Caption = 'From Document No.';
            DataClassification = CustomerContent;
        }
        field(60022; "From Line No."; Integer)
        {
            Caption = 'From Line No.';
            DataClassification = CustomerContent;
        }
        field(60023; "Refunded Quantity"; Decimal)
        {
            Caption = 'Refunded Quantity';
            DataClassification = CustomerContent;
        }
        field(60024; "Updated Before Posting"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Updated Before Posting';
        }
        field(60025; "Web Variant"; Text[50])
        {
            Caption = 'Web Variant';
            DataClassification = CustomerContent;
        }
        field(60026; "Inv. Discount %"; Decimal)
        {
            Caption = 'Inv. Discount %';
            DataClassification = CustomerContent;
        }
    }
}
