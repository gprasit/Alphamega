table 60002 "Posted Treasury Statement_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Posted Treasury Statement';
    DataCaptionFields = "Treasury Statement No.", "Store Hierarchy No.", "Store Hierarchy Name";
    DrillDownPageID = "Posted Treasury Stmt. List_NT";
    LookupPageID = "Posted Treasury Stmt. List_NT";

    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';
        }
        field(5; Date; Date)
        {
            Caption = 'Date';
        }
        field(10; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "LSC Retail Hierarchy".Code;
            trigger OnValidate()
            begin
            end;
        }
        field(15; "Store Hierarchy Name"; Text[100])
        {
            CalcFormula = Lookup("LSC Retail Hierarchy".Name WHERE(Code = FIELD("Store Hierarchy No.")));
            Caption = 'Store Hierarchy Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
            end;
        }

        field(25; "Trans. Starting Date"; Date)
        {
            Caption = 'Trans. Starting Date';
            trigger OnValidate()
            begin
            end;
        }
        field(30; "Trans. Ending Date"; Date)
        {
            Caption = 'Trans. Ending Date';

            trigger OnValidate()
            begin
                "Posting Date" := "Trans. Ending Date";
            end;
        }
        field(35; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(40; Recalculate; Boolean)
        {
            Caption = 'Recalculate';
        }
    }

    keys
    {
        key(Key1; "Treasury Statement No.")
        {
            Clustered = true;
        }
        key(Key2; "Store Hierarchy No.")
        {
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
        Text013: Label 'No closed %1 found.';
        Text014: Label 'A %1 has been allocated to this %2. This could lead to a gap in the %3.  Continue?';
        Text015: Label 'Canceled';
        Text016: Label 'You can not change the %1 field because %2 %3 has %4 = %5 and the %6 has already been assigned %7 %8.';
        Text017: Label 'Confirm change %1 in %2 %3.';
        StatementPost: Codeunit "LSC Statement-Post";
        Text018: Label 'Deleting this document will cause a gap in the number series for posted Statements. ';
        Text019: Label 'An empty posted Statement %1 will be created to fill this gap in the number series.\\';
        Text020: Label 'Do you want to continue?';
}
