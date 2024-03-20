table 60019 "Posted Stmt. Z Report-Lines_NT"
{
    Caption = 'Posted Statement Z Report-Lines';
    DataClassification = CustomerContent;
    DrillDownPageId = "Posted Stmt. Z Report-Lines_NT";

    fields
    {
        field(1; "Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            NotBlank = true;
            TableRelation = "LSC Statement"."No.";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "LSC Staff";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin

            end;
        }
        field(20; "Z-Amount"; Decimal)
        {
            Caption = 'Z Amount';
            DecimalPlaces = 2 : 2;

            trigger OnLookup()
            begin
            end;

            trigger OnValidate()
            var
            begin

            end;
        }
        field(25; "Z-Amount in LCY"; Decimal)
        {
            Caption = 'Z Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;

            trigger OnLookup()
            begin

            end;
        }
        field(30; "Real Exchange Rate"; Decimal)
        {
            Caption = 'Real Exchange Rate';
            DecimalPlaces = 0 : 15;
            Editable = false;
        }
        field(35; "Trans. Amount in LCY"; Decimal)
        {
            Caption = 'Trans. Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(75; "Trans. Amount"; Decimal)
        {
            Caption = 'Trans. Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(80; "STMT-Difference in LCY"; Decimal)
        {
            Caption = 'Statement Difference in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(85; "STMT-Difference Amount"; Decimal)
        {
            Caption = 'Statement Difference Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(90; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "LSC Store"."No.";
        }
        field(95; Notes; Text[100])
        {
            Caption = 'Notes';
            Editable = false;
        }
        field(100; "Z-Difference in LCY"; Decimal)
        {
            Caption = 'Z Difference in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(105; "Z-Difference Amount"; Decimal)
        {
            Caption = 'Z Difference Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(110; "STMT-Counted Amount"; Decimal)
        {
            Caption = 'Statement Counted Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(115; "STMT-Counted in LCY"; Decimal)
        {
            Caption = 'Statement Counted in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(120; "Statement Code"; Code[20])
        {
            Caption = 'Statement Code';
        }
    }
    keys
    {
        key(PK; "Statement No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
