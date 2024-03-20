codeunit 60112 "eCom_PostWebOrderRedemption_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    var
        WebOrderPointRedemption: Record "eCom_WebOrd.PointRedemption_NT";
        WebOrderPointRedemption2: Record "eCom_WebOrd.PointRedemption_NT";
    begin
        WebOrderPointRedemption.SETCURRENTKEY(Processed);
        WebOrderPointRedemption.SETRANGE(Processed, FALSE);
        IF WebOrderPointRedemption.FINDSET(TRUE, TRUE) THEN
            REPEAT
                WebOrderPointRedemption2.Get(WebOrderPointRedemption."Entry No.");
                WebOrderPointRedemption2.Processed := PostEntry(WebOrderPointRedemption2);
                IF WebOrderPointRedemption2.Processed THEN
                    WebOrderPointRedemption2.MODIFY;
            UNTIL WebOrderPointRedemption.NEXT = 0;

    end;

    procedure PostEntry(VAR WebOrderPointRedemption: Record "eCom_WebOrd.PointRedemption_NT"): Boolean
    var
        MemberCard: Record "LSC Membership Card";
        MemberClub: Record "LSC Member Club";
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
    begin
        IF WebOrderPointRedemption.Points = 0 THEN
            EXIT;
        MemberCard.SETRANGE("Contact No.", WebOrderPointRedemption."Member Contact No.");
        IF NOT MemberCard.FINDFIRST THEN
            EXIT(FALSE);

        MemberClub.GET(MemberCard."Club Code");

        MemberPointJnlLine.INIT;
        MemberPointJnlLine.Type := MemberPointJnlLine.Type::Redemption;
        MemberPointJnlLine.Date := WebOrderPointRedemption.Date;
        MemberPointJnlLine."Document No." := WebOrderPointRedemption."Document No.";
        MemberPointJnlLine."Account No." := MemberCard."Account No.";
        MemberPointJnlLine."Contact No" := MemberCard."Contact No.";
        MemberPointJnlLine."Card No." := MemberCard."Card No.";
        MemberPointJnlLine."Point Type" := MemberPointJnlLine."Point Type"::"Other Points";
        MemberPointJnlLine.Points := ROUND(WebOrderPointRedemption.Points, 1);
        MemberPointJnlLine."Point Value" := MemberClub."Point Value";
        MemberPointJnlLine."Total Value" := MemberPointJnlLine.Points * MemberPointJnlLine."Point Value";
        MemberPointJnlLine."Source Type" := MemberPointJnlLine."Source Type"::"Sales Invoice";
        MemberPointJnlLine."Store No." := WebOrderPointRedemption."Store No.";
        MemberPointJnlLine."POS Terminal No." := WebOrderPointRedemption."POS Terminal No.";
        MemberPointJnlLine."Transaction No." := 0;
        //PointJnlPostLine.SetAllowNegative; BC Upgrade As SetAllowNegativeBalance is already set
        //PointJnlPostLine.RunWithCheck(MemberPointJnlLine);//BC22 Upgrade
        PointJnlPostLine.Run(MemberPointJnlLine);//BC22 Upgrade
        EXIT(TRUE);
    end;

}
