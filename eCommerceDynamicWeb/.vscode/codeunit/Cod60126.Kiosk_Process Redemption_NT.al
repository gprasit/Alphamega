codeunit 60126 "Kiosk_Process Redemption_NT"
{
    trigger OnRun()
    var

    begin
        ProcessRedemptions();
    end;

    var

        MembershipCard: Record "LSC Membership Card";

    local procedure ProcessRedemptions()
    var
        MemberPointEntry: Record "LSC Member Point Entry";
        KioskPoints: Record "Kiosk Loyalty Points Trans._NT";
        MemberContact: Record "LSC Member Contact";
        KioskSetup: Record "Kiosk Setup_NT";
        MemberAccount: Record "LSC Member Account";
    begin
        MemberPointEntry.RESET;
        If not KioskSetup.Get() then//BC22
            Clear(KioskSetup);//BC22
        MemberPointEntry.SETCURRENTKEY("Source Type", "Document No.");
        KioskPoints.RESET;
        KioskPoints.SETFILTER("Entry No.", '>%1', KioskSetup."Last Loyalty Points Entry No.");
        IF KioskPoints.FINDFIRST THEN
            REPEAT
                IF NOT KioskPoints.Processed THEN BEGIN
                    MemberContact.SETRANGE("Contact No.", KioskPoints."Contact No.");
                    IF MemberContact.FINDFIRST THEN BEGIN
                        MemberPointEntry.SETRANGE("Source Type", MemberPointEntry."Source Type"::Journal);
                        MemberPointEntry.SETRANGE("Document No.", KioskPoints."Receipt No.");
                        MemberPointEntry.SETRANGE(Date, KioskPoints."Date Of Issue");
                        MemberPointEntry.SETRANGE("Contact No.", KioskPoints."Contact No.");
                        MemberPointEntry.SETRANGE("Entry Type", MemberPointEntry."Entry Type"::Redemption);
                        MemberPointEntry.SETRANGE(Points, KioskPoints.Points);
                        IF NOT MemberPointEntry.FINDFIRST THEN BEGIN
                            MemberAccount.GET(MemberContact."Account No.");
                            MembershipCard.GET(KioskPoints."Card No.");
                            //InsertPoints2(KioskPoints.Points, KioskPoints."Store No.", KioskPoints."POS Terminal No.", '');//BC22
                            InsertPoints2(KioskPoints.Points, KioskPoints."Store No.", KioskPoints."POS Terminal No.", KioskPoints."Receipt No.");//BC22
                            
                        END;
                        KioskPoints.Processed := TRUE;
                        KioskPoints.MODIFY;
                    END;
                END;
                KioskSetup."Last Loyalty Points Entry No." := KioskPoints."Entry No.";
            UNTIL KioskPoints.NEXT = 0;
        KioskSetup.MODIFY;
    end;

    local procedure InsertPoints2(Points: Decimal; StoreNo: Code[20]; POSTermNo: Code[20]; DocNo: Code[20]): Boolean
    var
        MemProcOrderEntry: Record "LSC Member Process Order Entry";
        NextTransNo: Integer;
    begin
        IF STRLEN(StoreNo) > 10 THEN
            StoreNo := COPYSTR(StoreNo, 1, 10);
        CLEAR(MemProcOrderEntry);
        //MemProcOrderEntry.SETRANGE("Document Source", MemProcOrderEntry."Document Source"::Kiosk);//BC Upgrade As Document Source will come from NAV
        MemProcOrderEntry.SETRANGE("Document Source", 2);//BC Upgrade As Document Source will come from NAV
        MemProcOrderEntry.SETRANGE("Store No.", StoreNo);
        MemProcOrderEntry.SETRANGE("POS Terminal No.", POSTermNo);
        IF MemProcOrderEntry.FINDLAST THEN
            NextTransNo := MemProcOrderEntry."Transaction No.";

        NextTransNo += 1;

        CLEAR(MemProcOrderEntry);
        //MemProcOrderEntry."Document Source" := MemProcOrderEntry."Document Source"::Kiosk;//BC Upgrade As Document Source will come from NAV
        MemProcOrderEntry."Document Source" := 2;//BC Upgrade As Document Source will come from NAV
        MemProcOrderEntry."Store No." := StoreNo;
        MemProcOrderEntry."POS Terminal No." := POSTermNo;
        MemProcOrderEntry."Transaction No." := NextTransNo;
        MemProcOrderEntry.Date := TODAY;
        MemProcOrderEntry.Time := TIME;
        MemProcOrderEntry."Card No." := MembershipCard."Card No.";
        MemProcOrderEntry."Account No." := MembershipCard."Account No.";
        MemProcOrderEntry."Points in Transaction" := Points;
        IF DocNo <> '' THEN
            MemProcOrderEntry."Document No." := DocNo;

        EXIT(MemProcOrderEntry.INSERT);
    end;
}