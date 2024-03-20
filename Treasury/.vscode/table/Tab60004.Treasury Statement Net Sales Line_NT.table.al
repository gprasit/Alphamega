table 60004 "Treasury Stmt. NetSalesLine_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Statement Net Sales Line';

    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';

            TableRelation = "Treasury Statement_NT"."Treasury Statement No.";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Line Type"; Enum "Treasury Stmt. Line Type_NT")
        {
            Caption = 'Line Type';
        }
        field(15; "Store Attribute Code"; Code[20])
        {
            Caption = 'Store Attribute Code';
            TableRelation = "LSC Attribute";
            Editable = false;
        }
        field(20; "Attribute Value"; Text[250])
        {
            Caption = 'Attribute Value';
            //TableRelation = "LSC Attribute";
            Editable = false;
        }
        field(25; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(30; "Counted Amount"; Decimal)
        {
            Caption = 'Counted Amount';
            DecimalPlaces = 2 : 2;
        }
        field(35; "Counted Amount in LCY"; Decimal)
        {
            Caption = 'Counted Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(40; "Trans. Amount"; Decimal)
        {
            Caption = 'Trans. Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(45; "Trans. Amount in LCY"; Decimal)
        {
            Caption = 'Trans. Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }

        field(50; "Difference Amount"; Decimal)
        {
            Caption = 'Difference Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(55; "Difference in LCY"; Decimal)
        {
            Caption = 'Difference in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(60; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type Setup".Code;
            trigger OnValidate()
            var
                TenderType: Record "LSC Tender Type Setup";
            begin
                if "Tender Type" <> '' then begin
                    TenderType.Get("Tender Type");
                    "Tender Type Name" := TenderType.Description;
                end else
                    "Tender Type Name" := '';
            end;
        }
        field(65; "Tender Type Name"; Text[30])
        {
            Caption = 'Tender Type Name';
            Editable = false;
        }
        field(70; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "Treasury Statement_NT"."Store Hierarchy No." where("Store Hierarchy No." = field("Store Hierarchy No."));
            trigger OnValidate()
            begin
            end;
        }
        field(75; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            Editable = false;
        }
        field(80; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            Editable = false;
        }
        field(85; "Total Discount"; Decimal)
        {
            Caption = 'Total Discount';
            Editable = false;
        }
        field(90; "Line Discount"; Decimal)
        {
            Caption = 'Line Discount';
            Editable = false;
        }
        field(95; "Discount Total Ammount"; Decimal)
        {
            Caption = 'Discount Total Ammount';
            Editable = false;
        }
        field(100; Income; Decimal)
        {
            Caption = 'Income';
            Editable = false;
        }
        field(105; Expenses; Decimal)
        {
            Caption = 'Expenses';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Treasury Statement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin

    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnRename()
    begin

    end;

    var

}
