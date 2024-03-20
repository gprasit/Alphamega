codeunit 60009 "Treasury General Functions_NT"
{
    Permissions = tabledata "LSC Statement" = rm;
    procedure StatementStaffPOS(var TempStatementLine: Record "LSC Statement Line" temporary)
    var
        TempStaffSales: Record "LSC STAFF Sales Type per Term" temporary;
        TransactionStatus: Record "LSC Transaction Status";
        TransHeader: Record "LSC Transaction Header";
        StatementNo: Code[20];
        LineNo: Integer;
    begin
        LineNo := 10000;
        StatementNo := TempStatementLine.GetFilter("Statement No.");

        TempStatementLine.Reset();
        TempStatementLine.DeleteAll();

        TransactionStatus.SetCurrentKey("Statement No.");
        TransactionStatus.SetFilter("Statement No.", StatementNo);

        if TransactionStatus.FindSet() then
            repeat
                if TransHeader.Get(TransactionStatus."Store No.", TransactionStatus."POS Terminal No.", TransactionStatus."Transaction No.") then
                    if not TempStaffSales.Get(TransHeader."Staff ID", TransHeader."Store No.", TransHeader."POS Terminal No.") then begin
                        TempStaffSales.Init();
                        TempStaffSales."Staff ID" := TransHeader."Staff ID";
                        TempStaffSales."Store No." := TransHeader."Store No.";
                        TempStaffSales."POS Terminal No." := TransHeader."POS Terminal No.";
                        TempStaffSales.Insert();

                        TempStatementLine.Reset();
                        TempStatementLine.Init();
                        TempStatementLine."Staff ID" := TempStaffSales."Staff ID";
                        TempStatementLine."POS Terminal No." := TempStaffSales."POS Terminal No.";
                        TempStatementLine."Store No." := TempStaffSales."Store No.";
                        TempStatementLine."Statement No." := StatementNo;
                        TempStatementLine."Line No." := LineNo;
                        TempStatementLine.Insert();
                        LineNo := LineNo + 10000;
                    end;
            until TransactionStatus.Next = 0;
        TempStatementLine.Reset();
        if TempStatementLine.Count <> 0 then begin
            TempStatementLine.SetCurrentKey("Statement No.", "Statement Code", "Staff ID", "POS Terminal No.", "Tender Type", "Tender Type Card No.", "Currency Code");
            TempStatementLine.FindFirst();
        end;
    end;

    procedure StaffName(StaffCode: Code[20]): Text
    var
        Staff: Record "LSC Staff";
    begin
        if StaffCode <> '' then
            if Staff.Get(StaffCode) then
                exit(Staff."First Name" + ' ' + Staff."Last Name");
        exit('');
    end;

    procedure ValidateZAmount(StatementNo: Code[20]): Decimal
    var
        StatementLine: Record "LSC Statement Line";
        TransAmt: Decimal;
    begin
        StatementLine.SetFilter("Statement No.", StatementNo);
        if StatementLine.FindSet() then
            repeat
                TransAmt += StatementLine."Trans. Amount in LCY";
            until StatementLine.Next() = 0;
        exit(TransAmt);
    end;

    procedure ShowErrors(ErrorTxt: Text; Context: Variant; RegisterDesc: Text)
    var
        DataTypeMgt: Codeunit "Data Type Management";
        ErrorInfo: ErrorInfo;
        RecRef: RecordRef;
        RegisterID: Guid;
        ErrorMessage: Record "Error Message";
        //ErrorMessage: Record "Error Message_NT";
        ErrorMessageRegister: Record "Error Message Register";
        OutStr: OutStream;
        ErrID: Integer;
    begin
        if ErrorMessage.FindLast() then
            ErrID := ErrorMessage.ID + 1
        else
            ErrID := 1;
        ErrorMessage.Init();
        ErrorMessage.ID := ErrID;
        RegisterID := ErrorMessageRegister.New(RegisterDesc);
        ErrorMessage."Register ID" := RegisterID;
        ErrorMessage.ID := 0; // autoincrement
        ErrorMessage.Description := ErrorTxt;
        ErrorMessage."Context Record ID" := Context;
        ErrorMessage.Insert();

    end;

    procedure MarkStatementAsFinnished(var Statement: Record "LSC Statement")
    begin
        if Statement.Finish then
            Statement.Finish := false
        else
            Statement.Finish := true;
        Statement.Modify(true);
    end;

    procedure SignDocument(var Base64Text: Text; var RecTreaStmt: Record "Treasury Statement_NT")
    var
        Base64Cu: Codeunit "Base64 Convert";
        RecordRef: RecordRef;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        ImageBase64String: Text;
        Item: Record Item;
    begin
        Base64Text := Base64Text.Replace('data:image/png;base64,', '');
        TempBlob.CreateOutStream(OutStream);
        Base64Cu.FromBase64(Base64Text, OutStream);
        RecordRef.GetTable(RecTreaStmt);
        TempBlob.ToRecordRef(RecordRef, RecTreaStmt.FieldNo("SGN Signature"));
        RecordRef.Modify();
    end;

    var


}
