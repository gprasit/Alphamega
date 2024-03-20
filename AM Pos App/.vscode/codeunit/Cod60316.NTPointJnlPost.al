codeunit 60316 "NT_Point Jnl.-Post"
{
    TableNo = "LSC Member Point Jnl. Line";

    trigger OnRun()
    begin
        PointJnlLine.Copy(Rec);
        Code;
        Rec.Copy(PointJnlLine);
    end;

    var
        Text001: Label 'Do you want to post the journal lines?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. You are now in the %1 journal.';
        PointJnlLine: Record "LSC Member Point Jnl. Line";
        PointJnlPostBatch: Codeunit "NT_Point Jnl.-Post Batch";
        TempJnlBatchName: Code[10];

    local procedure "Code"()
    begin
        if not Confirm(Text001, false) then
            exit;

        TempJnlBatchName := PointJnlLine."Journal Batch Name";

        PointJnlPostBatch.Run(PointJnlLine);

        if PointJnlLine."Line No." = 0 then
            Message(Text002)
        else
            if TempJnlBatchName = PointJnlLine."Journal Batch Name" then
                Message(Text003)
            else
                Message(
                  Text004,
                  PointJnlLine."Journal Batch Name");

        if not PointJnlLine.Find('=><') or (TempJnlBatchName <> PointJnlLine."Journal Batch Name") then begin
            PointJnlLine.Reset;
            PointJnlLine.FilterGroup(2);
            PointJnlLine.SetRange("Journal Template Name", PointJnlLine."Journal Template Name");
            PointJnlLine.SetRange("Journal Batch Name", PointJnlLine."Journal Batch Name");
            PointJnlLine.FilterGroup(0);
            PointJnlLine."Line No." := 1;
        end;
    end;
}

