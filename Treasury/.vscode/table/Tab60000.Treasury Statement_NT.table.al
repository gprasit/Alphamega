table 60000 "Treasury Statement_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Statement';
    DataCaptionFields = "Treasury Statement No.", "Store Hierarchy No.", "Store Hierarchy Name";
    DrillDownPageID = "Treasury Statement List_NT";
    LookupPageID = "Treasury Statement List_NT";
    Permissions = TableData "LSC Scheduler Setup" = rm;

    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Treasury Statement No.';

            trigger OnValidate()
            begin
                if "Treasury Statement No." <> xRec."Treasury Statement No." then begin
                    AlphaMegaSetup.Get;
                    NoSeriesMgt.TestManual(AlphaMegaSetup."Treasury Statement Nos.");
                    "No. Series" := '';
                end;
            end;
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
        field(45; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Posted';
            OptionMembers = " ","Posted";
        }
        field(50; "Float Opening"; Decimal)
        {
            Caption = 'Float Opening';
            BlankZero = true;
        }
        field(55; "SGN Signature"; Blob)
        {
            Caption = 'Customer Signature';
            DataClassification = CustomerContent;
            SubType = Bitmap;
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
    var
        TreasStmtLine: Record "Treasury Statement Line_NT";
    begin
        TreasStmtLine.Reset;
        TreasStmtLine.SetRange("Treasury Statement No.", "Treasury Statement No.");
        if TreasStmtLine.Find('-') then
            Error(Text021 + Text022);
    end;

    trigger OnInsert()
    begin
        Date := WorkDate;
        if "Treasury Statement No." = '' then begin
            AlphaMegaSetup.Get;
            AlphaMegaSetup.TestField(AlphaMegaSetup."Treasury Statement Nos.");
            NoSeriesMgt.InitSeries(AlphaMegaSetup."Treasury Statement Nos.", xRec."No. Series", 0D, "Treasury Statement No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnRename()
    begin
        if not Confirm(Text006 + Text007) then
            Error(Text008);
    end;

    procedure SignDocument(var Base64Text: Text)
    var
        Base64Cu: Codeunit "Base64 Convert";
        RecordRef: RecordRef;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        ImageBase64String: Text;
        Item: Record Item;
    begin
        Base64Text := Base64Text.Replace('data:image/png;base64,', '');
        TempBlob.CreateOutStream(OutStream);
        Base64Cu.FromBase64(Base64Text, OutStream);
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, Rec.FieldNo("SGN Signature"));
        RecordRef.Modify();
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
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text013: Label 'No closed %1 found.';
        Text014: Label 'A %1 has been allocated to this %2. This could lead to a gap in the %3.  Continue?';
        Text015: Label 'Canceled';
        Text016: Label 'You can not change the %1 field because %2 %3 has %4 = %5 and the %6 has already been assigned %7 %8.';
        Text017: Label 'Confirm change %1 in %2 %3.';
        StatementPost: Codeunit "LSC Statement-Post";
        Text018: Label 'Deleting this document will cause a gap in the number series for posted Statements. ';
        Text019: Label 'An empty posted Statement %1 will be created to fill this gap in the number series.\\';
        Text020: Label 'Do you want to continue?';
        UserMgt: Codeunit "User Selection";
        BackOfficeExt: Codeunit "LSC BackOffice Ext."; //CEN-434
        Text021: Label 'You are not allowed to delete after calculation.\';
        Text022: Label 'Run the Clear Statement function to delete the treasury statement lines first.';

#if __IS_SAAS__
    internal
#endif
    procedure AssistEdit(OldTreasuryStatement: Record "Treasury Statement_NT"): Boolean
    var
        TreasuryStatement: Record "Treasury Statement_NT";
    begin
        TreasuryStatement := Rec;
        AlphaMegaSetup.Get();
        AlphaMegaSetup.TestField("Treasury Statement Nos.");

        if NoSeriesMgt.SelectSeries(AlphaMegaSetup."Treasury Statement Nos.", OldTreasuryStatement."No. Series", TreasuryStatement."No. Series") then begin
            NoSeriesMgt.SetSeries(TreasuryStatement."Treasury Statement No.");
            Rec := TreasuryStatement;
            exit(true);
        end;
    end;

    local procedure TestNoSeriesDate(No: Code[20]; NoSeriesCode: Code[10]; NoCapt: Text[1024]; NoSeriesCapt: Text[1024])
    var
        NoSeries: Record "No. Series";
    begin
        if (No <> '') and (NoSeriesCode <> '') then begin
            NoSeries.Get(NoSeriesCode);
            if NoSeries."Date Order" then
                Error(
                  Text016,
                  FieldCaption("Posting Date"), NoSeriesCapt, NoSeriesCode,
                  NoSeries.FieldCaption("Date Order"), NoSeries."Date Order", TableCaption,
                  NoCapt, No);
        end;
    end;

}
