codeunit 60208 "Upd. Vch Entry Voucher Type_NT"
{

    trigger OnRun()
    begin
        UpdateVoucherEntVoucherType();
    end;
    local procedure UpdateVoucherEntVoucherType()
    var
        PosDataEntry: Record "LSC POS Data Entry";
        VchEntries: Record "LSC Voucher Entries";
    begin
        if VchEntries.FindSet() then
            repeat
                if VchEntries."Voucher Type" = '' THEN BEGIN
                    PosDataEntry.SetRange("Entry Code", VchEntries."Voucher No.");
                    if PosDataEntry.FindFirst() then begin
                        VchEntries."Voucher Type" := PosDataEntry."Entry Type";
                        VchEntries.Modify();
                    end;
                end;
            until VchEntries.Next() = 0;
    end;
}

