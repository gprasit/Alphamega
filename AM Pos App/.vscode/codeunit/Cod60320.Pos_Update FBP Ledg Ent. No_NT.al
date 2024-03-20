codeunit 60320 "Pos_Update FBP Ledg Ent. No_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    begin
        UpdateFBPLedgerEntryToReplicateCouponEntry(Rec.DateFormula);
    end;

    local procedure UpdateFBPLedgerEntryToReplicateCouponEntry(DTFormula: DateFormula)
    var
        CouponEntry: Record "LSC Coupon Entry";
        BlankDateFormula: DateFormula;
    begin
        if DTFormula <> BlankDateFormula then begin
            CouponEntry.SetRange("Issue Date", CalcDate(DTFormula, Today), Today);
            if CouponEntry.FindSet() then
                repeat
                    if CouponEntry."FBP Ledger Entry No." = 0 then begin
                        CouponEntry."FBP Ledger Entry No." := FindLastFBPLedgerEntryNo();
                        CouponEntry.Modify();
                    end;
                until CouponEntry.Next() = 0;
        end;
    end;

    local procedure FindLastFBPLedgerEntryNo(): Integer
    var
        CouponEntry: Record "LSC Coupon Entry";
    begin
        CouponEntry.SetCurrentKey("FBP Ledger Entry No.");
        if CouponEntry.FindLast() then
            exit(CouponEntry."FBP Ledger Entry No." + 1)
        else
            exit(1);

    end;

    var
        myInt: Integer;
}
