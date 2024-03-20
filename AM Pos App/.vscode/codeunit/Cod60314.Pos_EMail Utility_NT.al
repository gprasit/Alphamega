codeunit 60314 "Pos_EMail Utility_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    begin
        SendSlipEmail(Rec);
    end;

    local procedure SendSlipEmail(var SchJobHdr: Record "LSC Scheduler Job Header")
    var
        SlipEmailEntry: Record "Pos_Slip Email Entry_NT";
        SlipEmailEntry2: Record "Pos_Slip Email Entry_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        Trans: Record "LSC Transaction Header";
        ErrorMsg: Text[150];
        Ok: Boolean;
        Text001: Label 'EMail Sent';
    begin
        ClearLastError();
        SlipEmailEntry.SetCurrentKey("Date Processed");
        SlipEmailEntry.SetRange("Date Processed", 0D);
        if SlipEmailEntry.FindSet then
            repeat                
                SlipEmailEntry2.Get(SlipEmailEntry."Store No.", SlipEmailEntry."POS Terminal No.", SlipEmailEntry."Transaction No.");
                Trans.Get(SlipEmailEntry."Store No.", SlipEmailEntry."POS Terminal No.", SlipEmailEntry."Transaction No.");
                Ok := PosGenFunc.EmailCopy(Trans, SlipEmailEntry2."Customer/Member Email", ErrorMsg);
                if not Ok then begin
                    if ErrorMsg <> '' then
                        SlipEmailEntry2.Message := ErrorMsg
                    else
                        SlipEmailEntry2.Message := StrSubstNo(GetLastErrorText(), 1, MaxStrLen(SlipEmailEntry2.Message));
                    SlipEmailEntry2.Modify();
                end else begin
                    SlipEmailEntry2.Message := Text001;
                    SlipEmailEntry2."Date Processed" := Today;
                    SlipEmailEntry2."Time Processed" := Time;
                    SlipEmailEntry2.Modify();
                end;
            until SlipEmailEntry.Next() = 0;
    end;

}

