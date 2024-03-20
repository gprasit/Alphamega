table 60001 "Treasury Statement Line_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Statement Line';

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
        field(10; "Tender Type"; Code[10])
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
        field(15; "Tender Type Name"; Text[30])
        {
            Caption = 'Tender Type Name';
            Editable = false;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(25; "Counted Amount"; Decimal)
        {
            Caption = 'Counted Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(30; "Counted Amount in LCY"; Decimal)
        {
            Caption = 'Counted Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(35; "Trans. Amount"; Decimal)
        {
            Caption = 'Trans. Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(40; "Trans. Amount in LCY"; Decimal)
        {
            Caption = 'Trans. Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }

        field(45; "Difference Amount"; Decimal)
        {
            Caption = 'Difference Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(50; "Difference in LCY"; Decimal)
        {
            Caption = 'Difference in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(51; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "Treasury Statement_NT"."Store Hierarchy No." where("Store Hierarchy No." = field("Store Hierarchy No."));
            trigger OnValidate()
            begin
            end;
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
    Var
        TreasuryStmt: Record "Treasury Statement_NT";
    begin
        if "Store Hierarchy No." = '' then
            if TreasuryStmt.Get("Treasury Statement No.") then
                "Store Hierarchy No." := TreasuryStmt."Store Hierarchy No.";
    end;

    trigger OnModify()
    begin

    end;

    trigger OnRename()
    begin
        if not Confirm(Text006 + Text007) then
            Error(Text008);
    end;

    var
        Text002: Label 'You are not allowed to delete after calculation.\';
        Text003: Label 'Run the Clear Statement function to delete the statement lines first.';
        Text004: Label 'You are not allowed to delete a Statement after calculation.\';
        Text005: Label 'Run the Set Transactions Free function to free Transactions from the statement lines first.';
        Text006: Label 'Renaming the record could cause problems with data exchange.\';
        Text007: Label 'Do you still want to rename the record?';
        Text008: Label 'The record was not renamed.';
        Text009: Label 'This %1 is already assigned to a %2.';
        Text010: Label 'You are not allowed to change %1 after calculation.';
        Text011: Label 'No open %1 found.';
        BackOfficeSetup: Record "LSC Retail Setup";
}
