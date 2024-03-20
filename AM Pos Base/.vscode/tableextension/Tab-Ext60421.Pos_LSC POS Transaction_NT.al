tableextension 60421 "Pos_LSC POS Transaction_NT" extends "LSC POS Transaction"
{
    fields
    {
        field(60401; "QR Code Used"; Boolean)
        {
            Caption = 'QR Code Used';
            DataClassification = CustomerContent;
        }
        field(60402; "Point Value"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("LSC POS Trans. Line"."Point Value" WHERE("Entry Type" = CONST(Payment), "Receipt No." = FIELD("Receipt No."), "Entry Status" = CONST(" ")));
        }
        field(60403; "Continuity Member No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(60404; "Food Amount"; Decimal)
        {        
            FieldClass = FlowField;
            CalcFormula = Sum("LSC POS Trans. Line".Amount WHERE ("Entry Type"=CONST(Item),"Receipt No."=FIELD("Receipt No."),"Entry Status"=CONST(" "),"Division Code"=CONST('01')));
            Editable = false;
        }
        field(60405; "Non Food Amount"; Decimal)
        {        
            FieldClass = FlowField;
            CalcFormula = Sum("LSC POS Trans. Line".Amount WHERE ("Entry Type"=CONST(Item),"Receipt No."=FIELD("Receipt No."),"Entry Status"=CONST(" "),"Division Code"=filter('<>01')));
            Editable = false;
        }        
    }
}
