codeunit 60125 "Pos_Import Coupon_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    var
        FileName: Text;
        AddFileName: Text;
    begin
        FileName := Rec.Text;
        if FileName = '' then
            FileName := 'C:\ncr\NAV2016\lscoup.txt';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;

        iFile.CREATEINSTREAM(iStream);
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CouponNo := COPYSTR(iLine, 1, 13);
            EVALUATE(Value, COPYSTR(iLine, 14, 3));
            IF (CouponNo <> '') THEN
                InsertDataEntry;
            //  IF COPYSTR(CouponNo,1,1) <> 'G' THEN
            //    DeleteCouponEntry;
        END;
        iFile.CLOSE;

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        _File.Copy(FileName, 'C:\ncr\NAV2016\Processed\' + AddFileName + '_lscoup.txt');
        ERASE(FileName);
        //DataEntry.MODIFY(TRUE);
    end;

    local procedure InsertDataEntry()
    var
        DataEntry: Record "LSC POS Data Entry";
    begin
        CLEAR(DataEntry);
        DataEntry."Entry Type" := 'OLDGF';
        DataEntry."Entry Code" := CouponNo;
        DataEntry.Amount := Value;
        IF DataEntry.INSERT(TRUE) THEN;
    end;

    var
        _File: DotNet File;
        iFile: File;
        iStream: InStream;
        iLine: Text;
        CouponNo: Code[20];
        NextTransNo: Integer;
        Value: Decimal;
}
