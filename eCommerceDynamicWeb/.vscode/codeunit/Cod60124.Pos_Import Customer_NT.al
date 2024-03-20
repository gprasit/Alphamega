codeunit 60124 "Pos_Import Customer_NT"

{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    var
        Cust: Record Customer;
        Window: Dialog;
        iFile: File;
        _File: DotNet File;
        iStream: InStream;
        CustName: Code[35];
        CustNo: Code[10];
        VATPosGr: Code[10];
        CreditLimit: Decimal;
        CurrentLimit: Decimal;
        AddFileName: Text;
        FileName: Text;
        iLine: Text;

    begin
        FileName := Rec.Text;
        if FileName = '' then
            FileName := 'C:\ncr\Nav2016\lscust.txt';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);
        if GuiAllowed then
            Window.OPEN('Customer #1###############');
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CustNo := COPYSTR(iLine, 1, 8);
            CustName := COPYSTR(iLine, 9, 35);
            EVALUATE(CreditLimit, COPYSTR(iLine, 44, 10));
            CreditLimit /= 100;
            EVALUATE(CurrentLimit, COPYSTR(iLine, 54, 10));
            CurrentLimit /= 100;
            VATPosGr := 'NATIONAL';
            IF STRLEN(iLine) > 64 THEN
                IF COPYSTR(iLine, 65, 1) IN ['Z', 'z'] THEN
                    VATPosGr := 'EMBASSIES';
            if GuiAllowed then
                Window.UPDATE(1, CustNo);
            IF NOT Cust.GET(CustNo) THEN BEGIN
                CLEAR(Cust);
                Cust."No." := CustNo;
                Cust.INSERT(TRUE);
            END;
            Cust.VALIDATE("Gen. Bus. Posting Group", 'NATIONAL');
            Cust.VALIDATE("VAT Bus. Posting Group", VATPosGr);
            Cust.VALIDATE("Customer Posting Group", 'DOMESTIC');
            Cust."Search Name" := '';
            Cust.VALIDATE(Name, CustName);

            if CreditLimit = 0 then
                Cust."Credit Limit (LCY)" := 0
            else begin
                Cust."Credit Limit (LCY)" := CreditLimit - CurrentLimit;
                //AM.SK 10/11/2023 >>
                IF Cust."Credit Limit (LCY)" = 0 THEN
                    Cust."Credit Limit (LCY)" := 1;
                //<<
            end;
            if CopyStr(iLine, 64, 1) = '1' then
                Cust.Blocked := Cust.Blocked::All;
            Cust.Modify();
        end;
        iFile.CLOSE;

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        _File.Copy(FileName, 'C:\ncr\NAV2016\Processed\' + AddFileName + '_lscust.txt');
        ERASE(FileName);
        if GuiAllowed then
            Window.Close();
    end;

}
