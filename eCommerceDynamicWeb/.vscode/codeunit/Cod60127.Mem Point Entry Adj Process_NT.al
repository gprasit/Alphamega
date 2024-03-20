codeunit 60127 "Mem Point Entry Adj Process_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    begin
        ProcessMemberPointAdjustment(Rec.DateFormula);
    end;

    local procedure ProcessMemberPointAdjustment(DateFormula: DateFormula)
    var
        MemberPointPosAdjustment: Record "Member Point EntryPOS Adj_NT";
        TransHeader: Record "LSC Transaction Header";
        Window: Dialog;
        NoOfTrans: Integer;
        NoOfUnsuccessful: Integer;
    begin
        SelectLatestVersion();
        IF GuiAllowed THEN
            Window.Open('#1############################################################');
        AllowNegative := TRUE;
        UpdateAccNoForBlockedMemCards();
        if Format(DateFormula) <> '' then begin
            MemberPointPosAdjustment.SETCURRENTKEY("Date Processed", Date);
            MemberPointPosAdjustment.SETRANGE("Date Processed", 0D);
            MemberPointPosAdjustment.SETRANGE(Date, CALCDATE(DateFormula, TODAY), TODAY);
        end else begin
            MemberPointPosAdjustment.SETCURRENTKEY("Date Processed");
            MemberPointPosAdjustment.SETRANGE("Date Processed", 0D);
        end;

        if MemberPointPosAdjustment.FindSet() then
            repeat
                if GuiAllowed then
                    Window.Update(1, StrSubstNo(Text001, MemberPointPosAdjustment."Source Type", MemberPointPosAdjustment."Entry Type"));
                if MemberPointPosAdjustment."Entry Type" = MemberPointPosAdjustment."Entry Type"::"Positive Adjmt." THEN
                    ProcessEntry(MemberPointPosAdjustment, TRUE)
                else
                    ProcessEntry(MemberPointPosAdjustment, FALSE);
            until (MemberPointPosAdjustment.Next() = 0);
        BlockMemberAcc();
        if GuiAllowed then begin
            Window.Close();
            Message(Text002, NoOfTrans - NoOfUnsuccessful, NoOfTrans);
        end;
    end;

    local procedure ProcessEntry(MemberPointPosAdjustment: Record "Member Point EntryPOS Adj_NT"; PositiveAdj: Boolean)
    var
        MemberAcc: Record "LSC Member Account";
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
    begin

        Clear(MemberPointJnlLine);
        if PositiveAdj then
            MemberPointJnlLine.Type := MemberPointJnlLine.Type::"Pos. Adjustment"
        else
            MemberPointJnlLine.Type := MemberPointJnlLine.Type::"Neg. Adjustment";
        if MemberPointJnlLine.Type = MemberPointJnlLine.Type::"Neg. Adjustment" then
            //MemberPointJnlLine.SetAllowNegativeBalance;
        if MemberPointPosAdjustment."Card No." <> '' then
                MemberPointJnlLine.Validate("Card No.", MemberPointPosAdjustment."Card No.");

        MemberPointJnlLine.Validate("Account No.", MemberPointPosAdjustment."Account No.");
        MemberPointJnlLine.Validate(Date, TODAY);
        UnBlockMemberAcc(MemberPointJnlLine."Account No.");
        MemberPointJnlLine.Validate(Points, MemberPointPosAdjustment.Points);
        MemberPointJnlLine."Store No." := MemberPointPosAdjustment."Store No.";
        MemberPointJnlLine."POS Terminal No." := MemberPointPosAdjustment."POS Terminal No.";
        MemberPointJnlLine."Store No." := MemberPointPosAdjustment."Store No.";
        MemberPointJnlLine."Reason Code" := MemberPointPosAdjustment."Reason Code";
        MemberPointJnlLine."Document No." := MemberPointPosAdjustment."Document No.";
        //IF AllowNegative THEN
        //  PointJnlPostLine.SetAllowNegativeBalance;
        PointJnlPostLine.Run(MemberPointJnlLine);
        MemberPointPosAdjustment."Date Processed" := Today;
        MemberPointPosAdjustment."Time Processed" := Time;
        MemberPointPosAdjustment.Modify();
    end;

    local procedure UpdateAccNoForBlockedMemCards()
    var
        MembershipCard: Record "LSC Membership Card";
        ProcessOrderEntry: Record "LSC Member Process Order Entry";
        TransHeader: Record "LSC Transaction Header";
    begin
        ProcessOrderEntry.SETCURRENTKEY("Date Processed");
        ProcessOrderEntry.SETRANGE("Date Processed", 0D);
        IF ProcessOrderEntry.FINDSET THEN
            REPEAT
                IF ProcessOrderEntry."Account No." = '' THEN
                    IF TransHeader.GET(ProcessOrderEntry."Store No.", ProcessOrderEntry."POS Terminal No.", ProcessOrderEntry."Transaction No.") THEN
                        IF MembershipCard.GET(TransHeader."Member Card No.") THEN BEGIN
                            ProcessOrderEntry.VALIDATE("Account No.", MembershipCard."Account No.");
                            ProcessOrderEntry.MODIFY();
                        END;
            UNTIL ProcessOrderEntry.NEXT = 0;
    end;

    local procedure UnBlockMemberAcc(AccNo: Code[20])
    var
        MemberAcc: Record "LSC Member Account";
    begin
        MemberAcc.GET(AccNo);
        IF MemberAcc.Blocked THEN
            IF NOT TempBlockedMembers.GET(AccNo) THEN BEGIN
                CLEAR(TempBlockedMembers);
                TempBlockedMembers.INIT;
                TempBlockedMembers := MemberAcc;
                TempBlockedMembers.INSERT;
                MemberAcc.Blocked := FALSE;
                MemberAcc.MODIFY;
            END;
    end;

    LOCAL procedure BlockMemberAcc()
    var
        MemberAcc: Record "LSC Member Account";
    begin
        TempBlockedMembers.RESET;
        IF TempBlockedMembers.FINDSET THEN
            REPEAT
                MemberAcc.GET(TempBlockedMembers."No.");
                MemberAcc.Blocked := TRUE;
                MemberAcc.MODIFY;
            UNTIL TempBlockedMembers.NEXT = 0;
    end;

    var
        TempBlockedMembers: Record "LSC Member Account" temporary;
        AllowNegative: Boolean;
        Text001: label 'Updating Member Information from %1 %2';
        Text002: Label '%1 of %2 document(s) processed.';
}