codeunit 60319 "NT_Point Jnl.-Post Line"
{
    TableNo = "LSC Member Point Jnl. Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        PointJnlLine: Record "LSC Member Point Jnl. Line";
        Register: Record "LSC Member Point Register";
        PointJnlCheckLine: Codeunit "NT_Point Jnl.-Check Line";
        LastEntryNo: Integer;
        GlobalMemberPointEntry: Record "LSC Member Point Entry";
        GlobalRegister: Record "LSC Member Point Register";

    internal procedure RunWithCheck(var pointJnlLine2: Record "LSC Member Point Jnl. Line")
    begin
        PointJnlLine.Copy(pointJnlLine2);
        Code(true);
        pointJnlLine2 := PointJnlLine;
    end;

    internal procedure RunWithoutCheck(var PointJnlLine2: Record "LSC Member Point Jnl. Line")
    begin        
        PointJnlLine.Copy(PointJnlLine2);
        Code(false);
        PointJnlLine2 := PointJnlLine;
    end;

    local procedure "Code"(CheckLine: Boolean)
    var
        PointEntry: Record "LSC Member Point Entry";
        TransToPointEntry: Record "LSC Member Point Entry";
        AccountRec: Record "LSC Member Account";
        ClubRec: Record "LSC Member Club";
        CardRec: Record "LSC Membership Card";
        AccountFromRec: Record "LSC Member Account";
    begin
        PointJnlCheckLine.SetAllowNegativeBalance;//NT
        if CheckLine then begin
            PointJnlCheckLine.SetAllowNegativeBalance;
            PointJnlCheckLine.RunLineCheck(PointJnlLine);
        end;

        PointEntry.Init;
        PointEntry."Entry No." := NextEntryNo;
        PointEntry."Source Type" := PointJnlLine."Source Type";
        PointEntry."Document No." := PointJnlLine."Document No.";
        PointEntry."Store No." := PointJnlLine."Store No.";
        PointEntry."POS Terminal No." := PointJnlLine."POS Terminal No.";
        PointEntry."Transaction No." := PointJnlLine."Transaction No.";
        PointEntry.Date := PointJnlLine.Date;
        if PointJnlLine."Card No." <> '' then begin
            CardRec.Get(PointJnlLine."Card No.");
            ClubRec.Get(CardRec."Club Code");
            if ClubRec."Card Registration" = ClubRec."Card Registration"::Register then begin
                AccountRec.Init;
                AccountRec."No." := CopyStr(CardRec."Card No.", 1, MaxStrLen(AccountRec."No."));
                AccountRec."Club Code" := CardRec."Club Code";
            end else
                AccountRec.Get(PointJnlLine."Account No.");
        end else
            AccountRec.Get(PointJnlLine."Account No.");
        AccountFromRec.Get(PointJnlLine."Account No.");

        ClubRec.Get(AccountRec."Club Code");
        PointEntry."Account No." := AccountRec."No.";
        PointEntry."Contact No." := PointJnlLine."Contact No";
        PointEntry."Card No." := PointJnlLine."Card No.";
        PointEntry."Point Value" := PointJnlLine."Point Value";
        case PointJnlLine.Type of
            PointJnlLine.Type::Sales:
                begin
                    PointEntry."Entry Type" := PointEntry."Entry Type"::Sales;
                    PointEntry.Points := PointJnlLine.Points;
                end;
            PointJnlLine.Type::Redemption:
                begin
                    PointEntry."Entry Type" := PointEntry."Entry Type"::Redemption;
                    PointEntry.Points := -PointJnlLine.Points;
                end;
            PointJnlLine.Type::"Pos. Adjustment":
                begin
                    PointEntry."Entry Type" := PointEntry."Entry Type"::"Positive Adjmt.";
                    PointEntry.Points := PointJnlLine.Points;
                end;
            PointJnlLine.Type::"Neg. Adjustment":
                begin
                    PointEntry."Entry Type" := PointEntry."Entry Type"::"Negative Adjmt";
                    PointEntry.Points := -PointJnlLine.Points;
                end;
            PointJnlLine.Type::Transfer:
                begin
                    PointEntry."Entry Type" := PointEntry."Entry Type"::"Transfer From";
                    PointEntry.Points := -PointJnlLine.Points;
                end;
        end;

        PointEntry."Posting Value" := PointEntry.Points * PointEntry."Point Value";
        PointEntry."Point Type" := PointJnlLine."Point Type";
        PointEntry.Open := true;
        PointEntry."Remaining Points" := PointEntry.Points;
        if PointEntry.Points > 0 then
            if Format(ClubRec."Point Expiration") <> '' then
                PointEntry."Expiration Date" := CalcDate(ClubRec."Point Expiration", PointEntry.Date);
        PointEntry."Member Club" := AccountRec."Club Code";
        PointEntry."Member Scheme" := AccountRec."Scheme Code";
        PointEntry."Reason Code" := PointJnlLine."Reason Code";
        PointEntry."Posted to G/L" := false;
        if PointJnlLine.Type = PointJnlLine.Type::Transfer then begin
            TransToPointEntry := PointEntry;
            TransToPointEntry."Entry No." := NextEntryNo;
            TransToPointEntry."Entry Type" := TransToPointEntry."Entry Type"::"Transfer To";
            TransToPointEntry.Points := PointJnlLine."Transferred Points";
            TransToPointEntry."Posting Value" := PointJnlLine."Transferred Points" * PointJnlLine."Point Value";
            AccountRec.Get(PointJnlLine."Transfer To Account No.");
            TransToPointEntry."Account No." := AccountRec."No.";
            TransToPointEntry."Contact No." := '';
            TransToPointEntry."Remaining Points" := TransToPointEntry.Points;
            TransToPointEntry."Point Type" := PointJnlLine."Transfer To Point Type";
            if Format(ClubRec."Transferred Point Expir.") <> '' then
                ClubRec."Point Expiration" := ClubRec."Transferred Point Expir.";
            if Format(ClubRec."Point Expiration") <> '' then
                TransToPointEntry."Expiration Date" := CalcDate(ClubRec."Point Expiration", TransToPointEntry.Date);
            TransToPointEntry.Insert(true);
            ApplyPointEntry(TransToPointEntry, PointJnlLine."Original Transaction No.");
        end;
        OnBeforeInsertPointEntry(PointEntry);
        PointEntry.Insert(true);
        ApplyPointEntry(PointEntry, PointJnlLine."Original Transaction No.");
    end;


    local procedure ApplyPointEntry(var NewPointEntry: Record "LSC Member Point Entry"; OriginalTransactionNo: Integer)
    var
        PointEntry: Record "LSC Member Point Entry";
        PointEntry2: Record "LSC Member Point Entry";
        Club: Record "LSC Member Club";
        Remaining: Decimal;
        NewDate: Date;
        IsHandled: Boolean;
    begin
        OnBeforeApplyPointEntry(NewPointEntry, OriginalTransactionNo, IsHandled);
        if IsHandled then
            exit;

        //Balance Copy field in Member Account table should be updated following a call to this function:
        //Ex. SomeAccountRec.UpdateBalanceCopy("Account No.",0); (see above).
        PointEntry.SetCurrentKey("Account No.", "Closed by Entry", Date);
        PointEntry.SetRange("Account No.", NewPointEntry."Account No.");
        PointEntry.SetRange("Closed by Entry", NewPointEntry."Closed by Entry");
        if NewPointEntry.Points < 0 then
            PointEntry.SetFilter(Points, '>=%1', 0)
        else
            PointEntry.SetFilter(Points, '<%1', 0);
        if NewPointEntry."Entry Type" = NewPointEntry."Entry Type"::"Transfer From" then begin
            Club.Get(NewPointEntry."Member Club");
            if Format(Club."Min Remain. Period for Trans.") <> '' then begin
                NewDate := CalcDate(Club."Transferred Point Expir.", NewPointEntry.Date);
                PointEntry.SetFilter("Expiration Date", '>%1', NewDate);
            end;
        end;
        Remaining := NewPointEntry."Remaining Points";
        if PointEntry.FindFirst then
            repeat
                PointEntry2 := PointEntry;
                if Abs(Remaining) >= Abs(PointEntry2."Remaining Points") then begin
                    PointEntry2."Closed by Entry" := NewPointEntry."Entry No.";
                    PointEntry2."Closed by Points" := -PointEntry2."Remaining Points";
                    PointEntry2.Open := false;
                    NewPointEntry."Remaining Points" := NewPointEntry."Remaining Points" + PointEntry2."Remaining Points";
                    PointEntry2."Remaining Points" := 0;
                    if NewPointEntry."Remaining Points" = 0 then begin
                        NewPointEntry."Closed by Entry" := PointEntry2."Entry No.";
                        NewPointEntry."Closed by Points" := -Remaining;
                        NewPointEntry.Open := false;
                    end;
                    Remaining := NewPointEntry."Remaining Points";
                end
                else begin
                    NewPointEntry."Closed by Entry" := PointEntry2."Entry No.";
                    NewPointEntry."Closed by Points" := -Remaining;
                    NewPointEntry."Remaining Points" := 0;
                    NewPointEntry.Open := false;
                    PointEntry2."Remaining Points" := PointEntry2."Remaining Points" + Remaining;
                    Remaining := 0;
                end;
                PointEntry2.Modify(true);
            until (not PointEntry.FindFirst) or (Remaining = 0);
        NewPointEntry.Modify(true);
    end;

    internal procedure NextEntryNo(): Integer
    var
        MemberPointEntry: Record "LSC Member Point Entry";
        lRegister: Record "LSC Member Point Register";
    begin
        if LastEntryNo = 0 then begin
            GlobalMemberPointEntry.LockTable;
            if MemberPointEntry.FindLast then
                LastEntryNo := MemberPointEntry."Entry No."
            else
                LastEntryNo := 0;
        end;

        if Register."No." = 0 then begin
            GlobalRegister.LockTable;
            if lRegister.FindLast then
                Register."No." := lRegister."No." + 1
            else
                Register."No." := 1;

            Register."From Entry No." := LastEntryNo + 1;
            Register."To Entry No." := Register."From Entry No.";
            Register."Creation Date" := Today;
            Register."User ID" := UserId;
            Register."Journal Batch Name" := PointJnlLine."Journal Batch Name";
            Register.Insert;
        end
        else begin
            Register."To Entry No." := LastEntryNo + 1;
            Register.Modify;
        end;

        LastEntryNo := LastEntryNo + 1;
        exit(LastEntryNo);
    end;

    internal procedure SetAllowNegativeBalance()
    begin
        PointJnlCheckLine.SetAllowNegativeBalance;
    end;

    [EventSubscriber(ObjectType::Codeunit, 99009008, 'OnBeforeApplyPointEntry', '', false, false)]
    local procedure BeforeApplyPointEntry(var NewPointEntry: Record "LSC Member Point Entry"; OriginalTransactionNo: Integer; var IsHandled: Boolean)
    var
        MemberPointEntry: Record "LSC Member Point Entry";
        MemberClub: Record "LSC Member Club";
    begin
        if IsHandled then
            exit;

        if NewPointEntry."Member Club" = '' then
            exit;

        MemberClub.get(NewPointEntry."Member Club");
        if MemberClub."Void Member Point Apply Method" <> MemberClub."Void Member Point Apply Method"::"Actual Entry" then
            exit;

        MemberPointEntry.SetFilter("Entry No.", '<>%1', NewPointEntry."Entry No.");
        MemberPointEntry.SetRange("Account No.", NewPointEntry."Account No.");
        MemberPointEntry.SetRange("Transaction No.", OriginalTransactionNo);
        MemberPointEntry.SetRange(Open, true);
        if MemberPointEntry.FindFirst() then
            if abs(MemberPointEntry."Remaining Points") = abs(NewPointEntry.Points) then begin
                MemberPointEntry."Closed by Entry" := NewPointEntry."Entry No.";
                MemberPointEntry."Closed by Points" := -NewPointEntry.Points;
                MemberPointEntry.Open := false;
                NewPointEntry."Remaining Points" := 0;
                MemberPointEntry."Remaining Points" := 0;
                NewPointEntry."Closed by Entry" := MemberPointEntry."Entry No.";
                NewPointEntry."Closed by Points" := -NewPointEntry.Points;
                NewPointEntry.Open := false;
                NewPointEntry.Modify(true);
                MemberPointEntry.Modify(true);
                IsHandled := true;
                exit;
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyPointEntry(var NewPointEntry: Record "LSC Member Point Entry"; OriginalTransactionNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPointEntry(var PointEntry: Record "LSC Member Point Entry");
    begin
    end;
}

