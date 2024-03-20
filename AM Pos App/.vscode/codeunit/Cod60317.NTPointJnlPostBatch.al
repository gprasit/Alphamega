codeunit 60317 "NT_Point Jnl.-Post Batch"
{
    Access = Internal;
    TableNo = "LSC Member Point Jnl. Line";

    trigger OnRun()
    begin
        PointJnlLine.Copy(Rec);
        Code;
        Rec := PointJnlLine;
    end;

    var
        PointJnlLine: Record "LSC Member Point Jnl. Line";
        PointJnlTempl: Record "LSC Member Point Jnl. Template";
        PointJnlBatch: Record "LSC Member Point Jnl. Batch";
        PointJnlCheck: Codeunit "NT_Point Jnl.-Check Line";
        Text000: Label 'cannot exceed %1 characters';
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        PointJnlPost: Codeunit "NT_Point Jnl.-Post Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    local procedure "Code"()
    var
        PointJnlLine2: Record "LSC Member Point Jnl. Line";
        PointJnlLine3: Record "LSC Member Point Jnl. Line";
        Window: Dialog;
        NoOfRec: Integer;
        CurrNo: Integer;
    begin
        PointJnlLine.Reset;
        PointJnlLine.SetRange("Journal Template Name", PointJnlLine."Journal Template Name");
        PointJnlLine.SetRange("Journal Batch Name", PointJnlLine."Journal Batch Name");
        if PointJnlLine.RecordLevelLocking then
            PointJnlLine.LockTable;
        if PointJnlLine."Journal Template Name" <> '' then begin
            PointJnlTempl.Get(PointJnlLine."Journal Template Name");
            PointJnlBatch.Get(PointJnlLine."Journal Template Name", PointJnlLine."Journal Batch Name");
            if StrLen(IncStr(PointJnlBatch.Name)) > MaxStrLen(PointJnlBatch.Name) then
                PointJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    Text000,
                    MaxStrLen(PointJnlBatch.Name)));
        end;

        if not PointJnlLine.Find('=><') then begin
            Commit;
            PointJnlLine."Line No." := 0;
            exit;
        end;


        if ShowDialog then begin
            Window.Open(Text001 + Text003);
            Window.Update(1, PointJnlLine."Journal Batch Name");
            NoOfRec := PointJnlLine.Count;
        end;

        PointJnlCheck.RunJournalCheck(PointJnlLine, true);

        CurrNo := 0;
        if PointJnlLine.FindSet then
            repeat
                CurrNo := CurrNo + 1;
                if ShowDialog then begin
                    Window.Update(3, PointJnlLine."Line No.");
                    Window.Update(4, Round(CurrNo / NoOfRec * 10000, 1));
                end;

                PointJnlPost.RunWithoutCheck(PointJnlLine);
            until PointJnlLine.Next = 0;

        PointJnlLine2.CopyFilters(PointJnlLine);
        PointJnlLine2.SetFilter("Account No.", '<>%1', '');
        if PointJnlLine2.FindLast then; // Remember the last line

        PointJnlLine3.SetRange("Journal Template Name", PointJnlLine."Journal Template Name");
        PointJnlLine3.SetRange("Journal Batch Name", PointJnlLine."Journal Batch Name");
        if not PointJnlLine3.FindLast then
            if IncStr(PointJnlLine."Journal Batch Name") <> '' then begin
                PointJnlBatch.Delete;
                PointJnlBatch.Name := IncStr(PointJnlLine."Journal Batch Name");
                if PointJnlBatch.Insert then;
                PointJnlLine."Journal Batch Name" := PointJnlBatch.Name;
            end;

        PointJnlLine.DeleteAll;

        if PointJnlBatch."No. Series" <> '' then begin
            PointJnlLine3."Document No." := '';
            NoSeriesMgt.InitSeries(PointJnlBatch."No. Series", PointJnlBatch."No. Series", PointJnlLine2.Date, PointJnlLine3."Document No."
              , PointJnlBatch."No. Series");
            NoSeriesMgt.SaveNoSeries;
        end;

        Commit;


        if ShowDialog then
            Window.Close;
    end;

    procedure ShowDialog(): Boolean
    begin
        if not GuiAllowed then
            exit(false)
        else
            exit(true);
    end;
}

