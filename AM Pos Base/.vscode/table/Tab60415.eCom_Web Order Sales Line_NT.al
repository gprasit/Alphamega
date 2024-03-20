table 60415 "eCom_Web Order Sales Line_NT"
{
    Caption = 'Web Order Sales Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Refund Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Refund Document Type';
            DataClassification = CustomerContent;
        }
        field(6; "Refund Document No."; Code[20])
        {
            Caption = 'Refund Document No.';
            DataClassification = CustomerContent;
        }
        field(7; "Refund Line No."; Integer)
        {
            Caption = 'Refund Line No.';
            DataClassification = CustomerContent;
        }
        field(8; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DataClassification = CustomerContent;
        }
        field(9; "Refund Quantity"; Decimal)
        {
            Caption = 'Refund Quantity';
            DataClassification = CustomerContent;
        }
        field(10; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
        }
        field(11; "Refunded Quantity"; Decimal)
        {
            Caption = 'Refunded Quantity';
            FieldClass = FlowField;
            CalcFormula = Sum("eCom_Web Order Sales Line_NT"."Refund Quantity" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Line No." = FIELD("Line No.")));
        }
    }
    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.", "Entry No.")
        {
            Clustered = true;
            SumIndexFields = "Invoiced Quantity", "Refund Quantity", "Remaining Quantity";
        }
        key(SK; "Refund Document Type", "Refund Document No.", "Refund Line No.")
        {
        }
    }
}
