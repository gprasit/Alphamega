table 60017 "Posted Treasury Cash Decl._NT"
{
    Caption = 'Posted Treasury Cash Declaration';
    DataClassification = CustomerContent;
    DrillDownPageId = "Posted Treasury Cash Decl._NT";
    LookupPageId = "Posted Treasury Cash Decl._NT";
    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Treasury Statement_NT";
        }
        field(2; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coin,Note,Roll,Total';
            OptionMembers = Coin,Note,Roll,Total;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(6; "Treasury Allocation Line No."; Integer)
        {
            Caption = 'Treasury Allocation Line No.';
        }
        field(10; "Qty."; Integer)
        {
            Caption = 'Qty.';

            trigger OnValidate()
            begin
            end;
        }
        field(15; Total; Decimal)
        {
            Caption = 'Total';
        }
        field(16; "Total Line"; Boolean)
        {
            Caption = 'Total Line';
        }
        field(17; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type".Code;
        }
        field(18; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Treasury Statement No.", "Tender Type", "Currency Code", Type, Amount, "Treasury Allocation Line No.", "Total Line")
        {
            Clustered = true;
            SumIndexFields = Total;
        }
    }

    fieldgroups
    {
    }

    var
        CashDeclaration: Record "Treasury Cash Declaration_NT";
        CashDeclaration2: Record "Treasury Cash Declaration_NT";
        GrandTotal: Decimal;

    var
        Text001: Label 'No store defined for store hierarchy %1';
}

